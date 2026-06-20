// soc_top.v
// 完整 SoC 顶层：集成 CPU 内核与总线（包含 ROM、RAM、UART）
// 放置路径：rtl/soc_top.v

module soc_top (
    input  wire        clk,      // 系统时钟
    input  wire        rst      // 复位（低有效）
);

    // ------------------------------------------------------------
    // CPU 内核接口信号
    // ------------------------------------------------------------
    // 指令总线
    wire [31:0] i_addr;
    wire [31:0] i_rdata;
    wire        i_stall;

    // 数据总线
    wire        d_we;
    wire [2:0]  d_type;
    wire [31:0] d_addr;
    wire [31:0] d_wdata;
    wire [31:0] d_rdata;

    // ------------------------------------------------------------
    // CPU 实例
    // ------------------------------------------------------------
    cpu_top u_cpu (
        .clk     (clk),
        .rst     (rst),
        .i_addr  (i_addr),
        .i_rdata (i_rdata),
        .i_stall (i_stall),
        .d_we    (d_we),
        .d_type  (d_type),
        .d_addr  (d_addr),
        .d_wdata (d_wdata),
        .d_rdata (d_rdata)
    );

    // ------------------------------------------------------------
    // 总线实例（包含 ROM、RAM、UART）
    // ------------------------------------------------------------
    bus_top u_bus (
        .clk     (clk),
        .rst     (rst),
        .i_addr  (i_addr),
        .i_rdata (i_rdata),
        .i_stall (i_stall),
        .d_we    (d_we),
        .d_type  (d_type),
        .d_addr  (d_addr),
        .d_wdata (d_wdata),
        .d_rdata (d_rdata)
    );

endmodule