module rom(
    input  wire        clk,
    input  wire        stall,           // 新增：停顿信号，高电平时保持输出不变
    input  wire [31:0] addr,
    output reg  [31:0] inst
);

    parameter ROM_SIZE = 1024;
    reg [31:0] rom_mem [0:ROM_SIZE-1];
    integer i;
    wire valid_addr = (addr >= 32'h0000_0000) && (addr <= 32'h0000_0FFF);
    initial begin
        for (i = 0; i < ROM_SIZE; i = i + 1) begin
            rom_mem[i] = 32'h00000013; // NOP
        end

        // 测试程序（保持不变）
        /*
        rom_mem[0] = 32'h400000B7; //lui  x1,0x40000
        rom_mem[1] = 32'h02900113; //addi x2,x0,41(data)
        rom_mem[2] = 32'h03100113; //addi x3,x0,49(cgf)
        rom_mem[3] = 32'h00400213; //addi x4,x0,4（baut）
        rom_mem[4] = 32'h00302223; //sw x3,4(x0)
        rom_mem[5] = 32'h00202023; //sw x2 0(x0)
        rom_mem[6] = 32'h00402423; //sw x4,8(x0)
        */
        /*
        rom_mem[1] = 32'h000100B7; //lui x1, 0x10
        rom_mem[2] = 32'h00A08113; //addi x2 x1 20
        //rom_mem[3] = 32'h002081B3; //add x3,x1,x2
        /*
        rom_mem[1] = 32'h040000B7; //lui x1 4000
        rom_mem[4] = 32'h00102423; //sw x1 8（x0）
        */
        
        rom_mem[0] = 32'h00a00013;  // addi x0, x0, 10   ; x0 写无效，等效 NOP
        rom_mem[1] = 32'h00000233;  // add  x4, x0, x0   ; x4 = 0
        rom_mem[2] = 32'h01420193;  // addi x3, x4, 20   ; x3 = x4 + 20 = 20
        rom_mem[3] = 32'h00302823;  // sw   x3, 16(x0)   ; 将 x3 = 20 存入内存地址 16
        rom_mem[4] = 32'h01002283;  // lw   x5, 16(x0)   ; x5 = 内存[16] = 20
        rom_mem[5] = 32'h00528313;  // addi x6, x5, 5    ; x6 = x5 + 5 = 25
        rom_mem[6] = 32'h003303b3;  // add  x7, x6, x3   ; x7 = x6 + x3 = 25 + 20 = 45
        rom_mem[7] = 32'h00039863;  // bne  x7, x0, 16   ; 若 x7 != 0，则 PC += 16，跳转到 rom_mem[11]
        rom_mem[8] = 32'h3e700393;  // addi x7, x0, 999  ; x7 = 999（被上一条分支跳过，通常不执行）
        rom_mem[9] = 32'h37800313;  // addi x6, x0, 888  ; x6 = 888（被跳过，通常不执行）
        rom_mem[10]= 32'h00000013;  // addi x0, x0, 0    ; NOP（被跳过，通常不执行）
        rom_mem[11]= 32'h00000463;  // beq  x0, x0, 8    ; 无条件跳转 PC += 8，跳到 rom_mem[13]
        rom_mem[12]= 32'h01002083;  // lw   x1, 16(x0)   ; x1 = 内存[16]（被上一条跳转跳过，不执行）
        rom_mem[13]= 32'h00100413;  // addi x8, x0, 1    ; x8 = 1
        
    end

    // 同步读取：仅在非停顿周期锁存地址并输出指令
    always @(posedge clk) begin
        if (!stall) begin
            if (valid_addr)
                inst <= rom_mem[addr[31:2]];   // 地址有效时正常读出
            else
                inst <= 32'h00000013;         // 地址无效时返回 nop
        end
        // stall 为高时 inst 保持不变
    end

endmodule