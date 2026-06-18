module ex_mem0_reg(
   input wire clk,
   input wire rst,

    input  wire        ex_reg_write,
    input  wire        ex_mem_to_reg,
    input  wire        ex_mem_read,    
    input  wire        ex_mem_write,
    input  wire [2:0]  ex_mem_type,
    input  wire        ex_branch,
    input  wire [2:0]  ex_br_type,
    input  wire [31:0] ex_pc,
    input  wire [31:0] ex_alu_result,
    input  wire [31:0] ex_rdata2,
    input  wire [4:0]  ex_rd,
    input  wire        ex_jal,
    input  wire        ex_jalr,
    input  wire        ex_rd_from_pc,
    input  wire        ex_lui_sel,
    input  wire        ex_auipc_sel,
    input  wire [31:0] ex_imm,
    input  wire        stall_ex_mem0,
        // To MEM stage
    output reg         mem0_reg_write,
    output reg         mem0_mem_to_reg,
    output reg         mem0_mem_read,
    output reg         mem0_mem_write,
    output reg [2:0]   mem0_mem_type,
    output reg         mem0_branch,
    output reg [2:0]   mem0_br_type,
    output reg [31:0]  mem0_pc,
    output reg [31:0]  mem0_alu_result,
    output reg [31:0]  mem0_rdata2,
    output reg [4:0]   mem0_rd,
    output reg         mem0_jal,
    output reg         mem0_jalr,
    output reg         mem0_rd_from_pc,
    output reg         mem0_lui_sel,
    output reg         mem0_auipc_sel,
    output reg [31:0]  mem0_imm
);
        always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem0_reg_write   <= 1'b0;
            mem0_mem_to_reg  <= 1'b0;
            mem0_mem_read    <= 1'b0;
            mem0_mem_write   <= 1'b0;
            mem0_mem_type    <= 3'b0;
            mem0_branch      <= 1'b0;
            mem0_br_type     <= 3'b0;
            mem0_pc          <= 32'b0;
            mem0_alu_result  <= 32'b0;
            mem0_rdata2      <= 32'b0;
            mem0_rd          <= 5'b0;
            mem0_jal         <= 1'b0;
            mem0_jalr        <= 1'b0;
            mem0_rd_from_pc  <= 1'b0;
            mem0_lui_sel     <= 1'b0;
            mem0_auipc_sel   <= 1'b0;
            mem0_imm         <= 32'b0;
        end else if(!stall_ex_mem0) begin
            mem0_reg_write   <= ex_reg_write;
            mem0_mem_to_reg  <= ex_mem_to_reg;
            mem0_mem_read    <= ex_mem_read;
            mem0_mem_write   <= ex_mem_write;
            mem0_mem_type    <= ex_mem_type;
            mem0_branch      <= ex_branch;
            mem0_br_type     <= ex_br_type;
            mem0_pc          <= ex_pc;
            mem0_alu_result  <= ex_alu_result;
            mem0_rdata2      <= ex_rdata2;
            mem0_rd          <= ex_rd;
            mem0_jal         <= ex_jal;
            mem0_jalr        <= ex_jalr;
            mem0_rd_from_pc  <= ex_rd_from_pc;
            mem0_lui_sel     <= ex_lui_sel;
            mem0_auipc_sel   <= ex_auipc_sel;
            mem0_imm         <= ex_imm;
        end else begin
            mem0_reg_write   <= mem0_reg_write;
            mem0_mem_to_reg  <= mem0_mem_to_reg;
            mem0_mem_read    <= mem0_mem_read;
            mem0_mem_write   <= mem0_mem_write;
            mem0_mem_type    <= mem0_mem_type;
            mem0_branch      <= mem0_branch;
            mem0_br_type     <= mem0_br_type;
            mem0_pc          <= mem0_pc;
            mem0_alu_result  <= mem0_alu_result;
            mem0_rdata2      <= mem0_rdata2;
            mem0_rd          <= mem0_rd;
            mem0_jal         <= mem0_jal;
            mem0_jalr        <= mem0_jalr;
            mem0_rd_from_pc  <= mem0_rd_from_pc;
            mem0_lui_sel     <= mem0_lui_sel;
            mem0_auipc_sel   <= mem0_auipc_sel;
            mem0_imm         <= mem0_imm;
        end
    end

endmodule