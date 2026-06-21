module hazard_handler (
    input  wire        clk,
    input  wire        rst,
    // 保持原有输入完全不变
    input  wire [4:0]  id_rs1, id_rs2,
    input  wire [4:0]  ex_rd,
    input  wire        ex_mem_read,
    input  wire        ex_branch, ex_jal, ex_jalr,
    input  wire        branch_taken,
    input  wire        ex_mem_write,
    input  wire [31:0] ex_addr,
    input  wire        id_mem_read,
    input  wire [31:0] id_addr,
    // 保持原有输出完全不变
    output wire        stall_pc,
    output wire        stall_if1_if2,
    output wire        stall_if2_id,
    output wire        stalldd,
    output wire        stall_id_ex,
    output wire        flush_if1_if2,
    output wire        flush_if2_id,
    output wire        flush_id_ex,
    output wire        stall_ex_mem0
);

    // 1. 冲突检测逻辑（1 周期 Load-Use 判定）
    wire ex_load  = ex_mem_read && (ex_rd != 5'b0) &&
                    ((ex_rd == id_rs1) || (ex_rd == id_rs2));
    wire load_use = ex_load;
    
    // 2. Flush 控制逻辑（跳转信号）
    wire branch_flush = branch_taken || ex_jal || ex_jalr;

    // 3. 核心修正：当发生跳转清空时，必须强制解除 Stall 信号
    // 否则会发生 Stall 锁死 PC、导致无法跳转的严重故障
    wire actual_stall = load_use && !branch_flush;

    // 4. Stall 信号赋值
    assign stall_pc      = actual_stall;
    assign stall_if1_if2 = actual_stall;
    assign stall_if2_id  = actual_stall;
    assign stalldd       = actual_stall;

    // 保持后方阶段不被卡死，以便 Load 指令往后流动执行，腾出空间
    assign stall_id_ex   = 1'b0; 
    assign stall_ex_mem0 = 1'b0; 

    // 5. Flush 信号赋值
    assign flush_if1_if2 = branch_flush;
    assign flush_if2_id  = branch_flush;
    
    // 当 Stall 发生时，需要向 ID/EX 注入气泡（NOP）；或者发生跳转时直接清空
    assign flush_id_ex   = branch_flush || actual_stall;

endmodule