module if2_id_reg(
    input  wire        clk,
    input  wire        rst,
    input  wire        stall_if2_id,   // 为 1 时保持
    input  wire        flush_if2_id,   // 为 1 时清零
    input  wire [31:0] pc_in,
    input  wire [31:0] inst_in,
    output reg  [31:0] pc_out,
    output reg  [31:0] inst_out
);

    // 1. 声明一个内部寄存器，用来把 flush 信号延迟一拍
    reg flush_d1;
    always @(posedge clk or posedge rst) begin
        if (rst)
            flush_d1 <= 1'b0;
        else
            flush_d1 <= flush_if2_id; // 锁存上一拍的 flush 状态
    end

    // 2. 主流水线寄存器逻辑
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out   <= 32'b0;
            inst_out <= 32'b0;
        end 
        // 核心修改：如果当前拍要清空，或者上一拍有清空（清理 ROM 刚刚吐出来的指令）
        else if (flush_if2_id || flush_d1) begin
            pc_out   <= 32'b0;
            inst_out <= 32'b0; // 冲刷为 NOP
        end 
        else if (stall_if2_id) begin
            pc_out   <= pc_out;
            inst_out <= inst_out;
        end 
        else begin
            pc_out   <= pc_in;
            inst_out <= inst_in;
        end
    end

endmodule