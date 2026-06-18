module dmem (
    input  wire        clk,
    input  wire        mem_we,       // 来自 MEM1 阶段的写使能
    input  wire [2:0]  mem_type,     // 来自 MEM1 阶段
    input  wire [31:0] addr,         // 来自 MEM1 阶段
    input  wire [31:0] write_data,   // 来自 MEM1 阶段
    output reg  [31:0] read_data
);

    // 1024 x 32bit 内存
    reg [31:0] ram [0:1023];
    // ------------------- 初始化（仿真 & FPGA 综合必备）-------------------
    integer idx;
    initial begin
        for (idx = 0; idx < 1024; idx = idx + 1)
            ram[idx] = 32'h0;
    end

    // ------------------- 新增：MEM1→MEM2 流水线锁存（解决写使能早泄）-------------------
    reg        mem_we_d1;
    reg [2:0]  mem_type_d1;
    reg [31:0] addr_d1;
    reg [31:0] write_data_d1;

    always @(posedge clk) begin
        mem_we_d1     <= mem_we;
        mem_type_d1   <= mem_type;
        addr_d1       <= addr;
        write_data_d1 <= write_data;
    end

    // 后续所有逻辑全部使用 _d1 信号（即 MEM2 阶段的稳定信号）
    wire [9:0] word_addr   = addr_d1[11:2];
    wire [1:0] byte_offset = addr_d1[1:0];

    // ----- 写数据整理（使用锁存后的数据）-----
    wire [31:0] din_word;
    assign din_word = (mem_we_d1) ? 
        ( (mem_type_d1[1:0] == 2'b00) ? (write_data_d1[7:0]  << (byte_offset * 8)) :
          (mem_type_d1[1:0] == 2'b01) ? (write_data_d1[15:0] << ((byte_offset[1] ? 2 : 0) * 8)) :
          write_data_d1 ) : 32'h0;

    // ----- 字节写使能生成（使用锁存后的数据）-----
    reg [3:0] we_byte;
    always @(*) begin
        we_byte = 4'b0;
        if (mem_we_d1) begin
            case (mem_type_d1[1:0])
                2'b00: begin
                    case (byte_offset)
                        2'b00: we_byte[0] = 1'b1;
                        2'b01: we_byte[1] = 1'b1;
                        2'b10: we_byte[2] = 1'b1;
                        2'b11: we_byte[3] = 1'b1;
                    endcase
                end
                2'b01: begin
                    if (byte_offset[1] == 1'b0) we_byte[1:0] = 2'b11;
                    else we_byte[3:2] = 2'b11;
                end
                2'b10: we_byte = 4'b1111;
                default: we_byte = 4'b0000;
            endcase
        end
    end

    // ----- 写转发逻辑：组合读旧数据 + 合并新字节（使用锁存后的稳定信号）-----
    wire [31:0] new_data;
    assign new_data = (mem_we_d1) ?
        { (we_byte[3] ? din_word[31:24] : ram[word_addr][31:24]),
          (we_byte[2] ? din_word[23:16] : ram[word_addr][23:16]),
          (we_byte[1] ? din_word[15:8]  : ram[word_addr][15:8]),
          (we_byte[0] ? din_word[7:0]   : ram[word_addr][7:0]) } :
        ram[word_addr];

    // ----- BRAM 写操作 + 读数据锁存（写优先）-----
    reg [31:0] dout;
    always @(posedge clk) begin
        // 写操作（字节使能写入 RAM 实体）
        if (we_byte[0]) ram[word_addr][7:0]   <= din_word[7:0];
        if (we_byte[1]) ram[word_addr][15:8]  <= din_word[15:8];
        if (we_byte[2]) ram[word_addr][23:16] <= din_word[23:16];
        if (we_byte[3]) ram[word_addr][31:24] <= din_word[31:24];

        // 读数据输出（写转发结果）
        dout <= new_data;
    end

    // ----- 扩展逻辑（保持不变）-----
    always @(*) begin
        case (mem_type_d1)  // 注意这里也要用锁存后的类型，否则读出的数据会和指令类型错位
            3'b000:  // LB
                case (byte_offset)
                    2'b00: read_data = {{24{dout[7]}}, dout[7:0]};
                    2'b01: read_data = {{24{dout[15]}}, dout[15:8]};
                    2'b10: read_data = {{24{dout[23]}}, dout[23:16]};
                    2'b11: read_data = {{24{dout[31]}}, dout[31:24]};
                endcase
            3'b001:  // LH
                if (byte_offset[1] == 0)
                    read_data = {{16{dout[15]}}, dout[15:0]};
                else
                    read_data = {{16{dout[31]}}, dout[31:16]};
            3'b010:  // LW
                read_data = dout;
            3'b100:  // LBU
                case (byte_offset)
                    2'b00: read_data = {24'b0, dout[7:0]};
                    2'b01: read_data = {24'b0, dout[15:8]};
                    2'b10: read_data = {24'b0, dout[23:16]};
                    2'b11: read_data = {24'b0, dout[31:24]};
                endcase
            3'b101:  // LHU
                if (byte_offset[1] == 0)
                    read_data = {16'b0, dout[15:0]};
                else
                    read_data = {16'b0, dout[31:16]};
            default: read_data = dout;
        endcase
    end

endmodule