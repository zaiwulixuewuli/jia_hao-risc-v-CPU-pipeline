// bus_top.v
// 总线控制器：地址译码 + 指令 ROM + 数据 RAM + UART
// 放置路径：rtl/bus/bus_top.v

module bus_top (
    input  wire        clk,
    input  wire        rst,

    // ---- 指令总线 (连接到 CPU) ----
    input  wire [31:0] i_addr,       // 取指地址
    output wire [31:0] i_rdata,      // 指令数据
    input  wire        i_stall,      // 取指停顿信号

    // ---- 数据总线 (连接到 CPU) ----
    input  wire        d_we,         // 写使能
    input  wire [2:0]  d_type,       // 访问类型
    input  wire [31:0] d_addr,       // 数据地址
    input  wire [31:0] d_wdata,      // 写数据
    output wire [31:0] d_rdata       // 读数据
);

    // ============================================================
    // 1. 地址空间定义（可根据需要自由修改基地址）
    // ============================================================
    localparam ROM_BASE   = 32'h0000_0000;
    localparam ROM_LIMIT  = 32'h0000_0FFF;   // 4KB

    localparam RAM_BASE   = 32'h1000_0000;   // 已修正：修改为你的新目标基地址
    localparam RAM_LIMIT  = 32'h1000_0FFF;   // 4KB 空间


    // ============================================================
    // 2. 指令 ROM
    // ============================================================
    wire [31:0] rom_inst;
    rom u_rom (
        .clk   (clk),
        .stall (i_stall),
        .addr  (i_addr),
        .inst  (rom_inst)
    );
    assign i_rdata = rom_inst;


    // ============================================================
    // 3. 数据总线地址译码与流水线同步
    // ============================================================
    // MEM1 阶段：实时判断当前周期的地址是否命中 RAM 空间
    wire is_data_ram = (d_addr >= RAM_BASE) && (d_addr <= RAM_LIMIT);

    // 写使能分发：只有在当前周期命中 RAM 且 CPU 要求写时才有效（写操作是实时的）
    wire ram_we  = d_we && is_data_ram;

    // 【核心修复】MEM1 -> MEM2 译码信号打拍
    // 因为 dmem 内部读数据有 1 周期延迟，译码结果必须同步延迟 1 周期，否则会被下一条指令冲刷掉
    reg is_data_ram_d1;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            is_data_ram_d1 <= 1'b0;
        end else begin
            is_data_ram_d1 <= is_data_ram;
        end
    end

    // 读数据多路选择：必须使用延迟后的 is_data_ram_d1 信号来选通数据
    wire [31:0] ram_rdata; 
    assign d_rdata = is_data_ram_d1 ? ram_rdata : 32'h0;


    // ============================================================
    // 4. 数据 RAM (dmem)
    // ============================================================
    dmem u_dmem (
        .clk        (clk),
        .mem_we     (ram_we),
        .mem_type   (d_type),
        .addr       (d_addr),
        .write_data (d_wdata),
        .read_data  (ram_rdata)
    );

endmodule