module forward_passing(
    input  wire [31:0] ex_rdata1_in,
    input  wire [31:0] ex_rdata2_in,
    input  wire [4:0]  ex_rs1,
    input  wire [4:0]  ex_rs2,

    // MEM0 阶段（较近）
    input  wire        mem0_reg_write,
    input  wire [4:0]  mem0_rd,
    input  wire [31:0] mem0_wb_data,      // MEM0 的写回数据（ALU 结果等）
    input  wire        mem0_mem_read,
    input  wire [31:0] mem0_read_data,    // MEM0 的 Load 读出数据

    // MEM 阶段（较远）
    input  wire        mem_reg_write,
    input  wire [4:0]  mem_rd,
    input  wire [31:0] mem_wb_data,       // MEM 的写回数据
    input  wire        mem_mem_read,
    input  wire [31:0] mem_read_data,     // MEM 的 Load 读出数据

    // WB 阶段
    input  wire        wb_reg_write,
    input  wire [4:0]  wb_rd,
    input  wire [31:0] wb_wb_data,

    output wire [31:0] ex_rdata1_out,
    output wire [31:0] ex_rdata2_out
);

    // -------------------- MEM0 阶段匹配 --------------------
    // 只要有寄存器写使能、目标寄存器非 0 且与源寄存器匹配，即触发 MEM0 转发
    wire mem0_match_rs1 = mem0_reg_write && (mem0_rd != 5'b0) && (mem0_rd == ex_rs1);
    wire mem0_match_rs2 = mem0_reg_write && (mem0_rd != 5'b0) && (mem0_rd == ex_rs2);
    
    // 如果是 Load 指令，则选择读出的数据；否则选择 ALU 计算结果（或其它写回数据）
    // 注意：若为同步 RAM 且无 Stall，此处直接转发 mem0_read_data 可能会产生时序或功能问题
    wire [31:0] mem0_fwd_data_rs1 = mem0_mem_read ? mem0_read_data : mem0_wb_data;
    wire [31:0] mem0_fwd_data_rs2 = mem0_mem_read ? mem0_read_data : mem0_wb_data;

    // -------------------- MEM 阶段匹配 --------------------
    wire mem_match_rs1 = mem_reg_write && (mem_rd != 5'b0) && (mem_rd == ex_rs1);
    wire mem_match_rs2 = mem_reg_write && (mem_rd != 5'b0) && (mem_rd == ex_rs2);
    
    wire [31:0] mem_fwd_data_rs1 = mem_mem_read ? mem_read_data : mem_wb_data;
    wire [31:0] mem_fwd_data_rs2 = mem_mem_read ? mem_read_data : mem_wb_data;

    // -------------------- WB 阶段匹配 --------------------
    // 移除了冗余的 !mem0_match 和 !mem_match，依靠后续三目运算符的优先级自然分流
    wire wb_match_rs1 = wb_reg_write && (wb_rd != 5'b0) && (wb_rd == ex_rs1);
    wire wb_match_rs2 = wb_reg_write && (wb_rd != 5'b0) && (wb_rd == ex_rs2);

    // -------------------- 优先级转发（MEM0 > MEM > WB） --------------------
    assign ex_rdata1_out = mem0_match_rs1 ? mem0_fwd_data_rs1 :
                           (mem_match_rs1  ? mem_fwd_data_rs1  :
                           (wb_match_rs1   ? wb_wb_data       : ex_rdata1_in));

    assign ex_rdata2_out = mem0_match_rs2 ? mem0_fwd_data_rs2 :
                           (mem_match_rs2  ? mem_fwd_data_rs2  :
                           (wb_match_rs2   ? wb_wb_data       : ex_rdata2_in));

endmodule