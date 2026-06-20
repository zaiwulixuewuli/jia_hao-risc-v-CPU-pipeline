module dmem (
    input  wire        clk,
    input  wire        mem_we,       // 来自 MEM1 阶段
    input  wire [2:0]  mem_type,     // 来自 MEM1 阶段
    input  wire [31:0] addr,         // 来自 MEM1 阶段
    input  wire [31:0] write_data,   // 来自 MEM1 阶段
    output reg  [31:0] read_data     // 在 MEM2 阶段输出稳定数据
);

    reg [31:0] ram [0:1023];
    integer idx;
    initial begin
        for (idx = 0; idx < 1024; idx = idx + 1) ram[idx] = 32'h0;
    end

    // ==========================================
    // 1. MEM1 -> MEM2 级间寄存器 (极其重要)
    // 它们充当了你 CPU 流水线中的 MEM1/MEM2 段间寄存器
    // ==========================================
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

    wire [9:0] word_addr   = addr_d1[11:2];
    wire [1:0] byte_offset = addr_d1[1:0];

// ==========================================
    // 2. 写逻辑 (使用 MEM2 阶段的稳定信号)
    // ==========================================
    wire [31:0] din_word = (mem_we_d1) ? 
        ( (mem_type_d1[1:0] == 2'b00) ? (write_data_d1[7:0]  << (byte_offset * 8)) :
          (mem_type_d1[1:0] == 2'b01) ? (write_data_d1[15:0] << ((byte_offset[1] ? 2 : 0) * 8)) :
          write_data_d1 ) : 32'h0;

    reg [3:0] we_byte;
    always @(*) begin
        we_byte = 4'b0;
        if (mem_we_d1) begin
            case (mem_type_d1[1:0])
                2'b00: we_byte[byte_offset] = 1'b1;
                2'b01: if (byte_offset[1] == 1'b0) we_byte[1:0] = 2'b11; else we_byte[3:2] = 2'b11;
                2'b10: we_byte = 4'b1111;
            endcase
        end
    end

    // RAM 实际写入
    always @(posedge clk) begin
        if (we_byte[0]) ram[word_addr][7:0]   <= din_word[7:0];
        if (we_byte[1]) ram[word_addr][15:8]  <= din_word[15:8];
        if (we_byte[2]) ram[word_addr][23:16] <= din_word[23:16];
        if (we_byte[3]) ram[word_addr][31:24] <= din_word[31:24];
    end

    // ==========================================
    // 3. 读逻辑 (在 MEM2 阶段完全由组合逻辑生成)
    // 直接读取 ram，去除组合逻辑旁路。这能显著提高综合后的硬件性能并确保 BRAM 推导成功。
    // ==========================================
    wire [31:0] new_data = ram[word_addr]; // 移除了复杂的 (mem_we_d1) ? ... 旁路

    always @(*) begin
        case (mem_type_d1)  // 必须用 _d1 去切分数据！
            3'b000:  // LB
                case (byte_offset)
                    2'b00: read_data = {{24{new_data[7]}}, new_data[7:0]};
                    2'b01: read_data = {{24{new_data[15]}}, new_data[15:8]};
                    2'b10: read_data = {{24{new_data[23]}}, new_data[23:16]};
                    2'b11: read_data = {{24{new_data[31]}}, new_data[31:24]};
                endcase
            3'b001:  // LH
                if (byte_offset[1] == 0) read_data = {{16{new_data[15]}}, new_data[15:0]};
                else                     read_data = {{16{new_data[31]}}, new_data[31:16]};
            3'b010:  // LW
                read_data = new_data;
            3'b100:  // LBU
                case (byte_offset)
                    2'b00: read_data = {24'b0, new_data[7:0]};
                    2'b01: read_data = {24'b0, new_data[15:8]};
                    2'b10: read_data = {24'b0, new_data[23:16]};
                    2'b11: read_data = {24'b0, new_data[31:24]};
                endcase
            3'b101:  // LHU
                if (byte_offset[1] == 0) read_data = {16'b0, new_data[15:0]};
                else                     read_data = {16'b0, new_data[31:16]};
            default: read_data = new_data;
        endcase
    end
endmodule