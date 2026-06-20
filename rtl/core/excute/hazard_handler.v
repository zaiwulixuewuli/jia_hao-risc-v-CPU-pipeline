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

    // 1. 冲突检测逻辑（保持你原本的判断条件不变）
    wire ex_load  = ex_mem_read && (ex_rd != 5'b0) &&
                    ((ex_rd == id_rs1) || (ex_rd == id_rs2));
    wire load_use = ex_load;
    wire store_load_hazard = ex_mem_write && id_mem_read && (ex_addr == id_addr);
    //wire need_stall = load_use || store_load_hazard;
    wire  need_stall = load_use;
    // 2. 重构 Stall 信号为纯组合逻辑，解决“迟到一拍”的问题
    assign stall_pc      = need_stall;
    assign stall_if1_if2 = need_stall;
    assign stall_if2_id  = need_stall;
    assign stalldd       = need_stall;

    // 3. 修正段间控制：Stall 发生时，ID/EX 和 EX/MEM0 不能被卡死
    // 必须让 EX 阶段的指令流下去，并在 ID/EX 注入 NOP
    assign stall_id_ex   = 1'b0; 
    assign stall_ex_mem0 = 1'b0; 

    // 4. Flush 控制逻辑
    wire branch_flush = branch_taken || ex_jal || ex_jalr;
    assign flush_if1_if2 = 1'b0;
    assign flush_if2_id  = branch_flush;
    
    // 关键修正：在需要 Stall 时，向 ID/EX 注入 Flush 信号以产生 NOP 空泡
    assign flush_id_ex   = branch_flush || need_stall;

endmodule