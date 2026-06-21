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
        */
        /*
        rom_mem[1] = 32'h040000B7; //lui x1 4000
        rom_mem[4] = 32'h00102423; //sw x1 8（x0）
        */
        
        /*
        rom_mem[0] = 32'h00a00013;  // addi x0, x0, 10   ; x0 写无效，等效 NOP
        rom_mem[1] = 32'h10000237;  // lui  x4, 10000    ; x4 = 内存初始地址
        rom_mem[2] = 32'h01400193;  // addi x3, x0, 20   ; x3 = x4 + 20 = 20
        rom_mem[3] = 32'h00322823;  // sw   x3, 16(x4)   ; 将 x3 = 20 存入内存地址 16
        rom_mem[4] = 32'h01022283;  // lw   x5, 16(x4)   ; x5 = 内存[16] = 20
        rom_mem[5] = 32'h00528313;  // addi x6, x5, 5    ; x6 = x5 + 5 = 25
        rom_mem[6] = 32'h003303b3;  // add  x7, x6, x3   ; x7 = x6 + x3 = 25 + 20 = 45
        rom_mem[7] = 32'h00039863;   // bne  x7, x0, 16   ; 若 x7 != 0，则 PC += 16，跳转到 rom_mem[11]
        rom_mem[8] = 32'h3e700393;  // addi x7, x0, 999  ; x7 = 999（被上一条分支跳过，通常不执行）
        rom_mem[9] = 32'h37800313;  // addi x6, x0, 888  ; x6 = 888（被跳过，通常不执行）
        rom_mem[10]= 32'h00000013;  // addi x0, x0, 0    ; NOP（被跳过，通常不执行）
        rom_mem[11]= 32'h00000463;  // beq  x0, x0, 8    ; 无条件跳转 PC += 8，跳到 rom_mem[13]
        rom_mem[12]= 32'h01022083;  // lw   x1, 16(x4)   ; x1 = 内存[16]（被上一条跳转跳过，不执行）
        rom_mem[13]= 32'h00100413;  // addi x8, x0, 1    ; x8 = 1
        */
        
            // GROUP 1
    rom_mem[0]  = 32'h12345537;  // lui   x10, 0x12345
    rom_mem[1]  = 32'h123455b7;  // auipc x11, 0x12345
    rom_mem[2]  = 32'hf9c50613;  // addi  x12, x10, -100

    // GROUP 2
    rom_mem[3]  = 32'h00a00093;  // addi  x1, x0, 10
    rom_mem[4]  = 32'hff600113;  // addi  x2, x0, -10
    rom_mem[5]  = 32'h00200193;  // addi  x3, x0, 2
    rom_mem[6]  = 32'h002086b3;  // add   x13, x1, x2
    rom_mem[7]  = 32'h40308733;  // sub   x14, x1, x3
    rom_mem[8]  = 32'h003097b3;  // sll   x15, x1, x3
    rom_mem[9]  = 32'h00112833;  // slt   x16, x2, x1
    rom_mem[10] = 32'h001138b3;  // sltu  x17, x2, x1
    rom_mem[11] = 32'h0020c933;  // xor   x18, x1, x2
    rom_mem[12] = 32'h003129b3;  // srl   x19, x2, x3
    rom_mem[13] = 32'h40312a33;  // sra   x20, x2, x3
    rom_mem[14] = 32'h0020ea33;  // or    x21, x1, x2
    rom_mem[15] = 32'h0020fb33;  // and   x22, x1, x2

    // GROUP 3
    rom_mem[16] = 32'h00512b93;  // slti  x23, x2, 5
    rom_mem[17] = 32'h00513c13;  // sltiu x24, x2, 5
    rom_mem[18] = 32'hfff0c493;  // xori  x25, x1, -1
    rom_mem[19] = 32'h0050e513;  // ori   x26, x1, 5
    rom_mem[20] = 32'h0050f593;  // andi  x27, x1, 5
    rom_mem[21] = 32'h00409e13;  // slli  x28, x1, 4
    rom_mem[22] = 32'h00411e93;  // srli  x29, x2, 4
    rom_mem[23] = 32'h40411f13;  // srai  x30, x2, 4

    // GROUP 4
    rom_mem[24] = 32'h10000237;  // lui   x4, 0x10000
    rom_mem[25] = 32'h123452b7;  // lui   x5, 0x12345
    rom_mem[26] = 32'h6782ea13;  // ori   x5, x5, 0x678
    rom_mem[27] = 32'h00522023;  // sw    x5, 0(x4)
    rom_mem[28] = 32'h00022303;  // lw    x6, 0(x4)
    rom_mem[29] = 32'h00021383;  // lh    x7, 0(x4)
    rom_mem[30] = 32'h00025403;  // lhu   x8, 0(x4)
    rom_mem[31] = 32'h00020483;  // lb    x9, 0(x4)
    rom_mem[32] = 32'h00024f83;  // lbu   x31, 0(x4)
    rom_mem[33] = 32'habcdf2b7;  // lui   x5, 0xABCDF
    rom_mem[34] = 32'hf8528293;  // addi  x5, x5, -123
    rom_mem[35] = 32'h00522223;  // sw    x5, 4(x4)
    rom_mem[36] = 32'h00420303;  // lb    x6, 4(x4)
    rom_mem[37] = 32'h00424383;  // lbu   x7, 4(x4)
    rom_mem[38] = 32'h00421403;  // lh    x8, 4(x4)
    rom_mem[39] = 32'h00425483;  // lhu   x9, 4(x4)
    rom_mem[40] = 32'h03f00293;  // addi  x5, x0, 0x3F
    rom_mem[41] = 32'h2a300313;  // addi  x6, x0, 0x2A3
    rom_mem[42] = 32'h00520423;  // sb    x5, 8(x4)
    rom_mem[43] = 32'h00621523;  // sh    x6, 10(x4)
    rom_mem[44] = 32'h00824f03;  // lbu   x30, 8(x4)
    rom_mem[45] = 32'h00a25e83;  // lhu   x29, 10(x4)

    // GROUP 5
    rom_mem[46] = 32'h00500093;  // addi  x1, x0, 5
    rom_mem[47] = 32'h00500113;  // addi  x2, x0, 5
    rom_mem[48] = 32'hffb00193;  // addi  x3, x0, -5
    rom_mem[49] = 32'h00a00213;  // addi  x4, x0, 10
    rom_mem[50] = 32'h00208463;  // beq   x1, x2, 8
    rom_mem[51] = 32'h00100f93;  // addi  x31, x0, 1 (TRAP 1)
    rom_mem[52] = 32'h00309463;  // bne   x1, x3, 8
    rom_mem[53] = 32'h00200f93;  // addi  x31, x0, 2 (TRAP 2)
    rom_mem[54] = 32'h00114463;  // blt   x3, x1, 8
    rom_mem[55] = 32'h00300f93;  // addi  x31, x0, 3 (TRAP 3)
    rom_mem[56] = 32'h0030d463;  // bge   x1, x3, 8
    rom_mem[57] = 32'h00400f93;  // addi  x31, x0, 4 (TRAP 4)
    rom_mem[58] = 32'h0030e463;  // bltu  x1, x3, 8
    rom_mem[59] = 32'h00500f93;  // addi  x31, x0, 5 (TRAP 5)
    rom_mem[60] = 32'h0011f463;  // bgeu  x3, x1, 8
    rom_mem[61] = 32'h00600f93;  // addi  x31, x0, 6 (TRAP 6)
    rom_mem[62] = 32'h006002ef;  // jal   x5, 12
    rom_mem[63] = 32'h06f00f13;  // addi  x30, x0, 111
    rom_mem[64] = 32'h0080006f;  // jal   x0, 8
    rom_mem[65] = 32'h00028067;  // jalr  x0, 0(x5)
    rom_mem[66] = 32'h00100413;  // addi  x8, x0, 1 (SUCCESS!)
    
    /*
    rom_mem[0] = 32'h00100093;  // addi x1, x0, 1   (期望：x1 = 1)
    rom_mem[1] = 32'h00200113;  // addi x2, x0, 2   (期望：x2 = 2)
    rom_mem[2] = 32'h00a00513;  // addi x10, x0, 10 (期望：x10 = 10)
    rom_mem[3] = 32'h01000813;  // addi x16, x0, 16 (期望：x16 = 16)
    rom_mem[4] = 32'h01400a13;  // addi x20, x0, 20 (期望：x20 = 20)
    rom_mem[5] = 32'h01a00d13;  // addi x26, x0, 26 (期望：x26 = 26)
    pass
    */
        /*
        rom_mem[0] = 32'h123455b7;  // auipc x11, 0x12345 (期望：x11 = 0x12345000)
        rom_mem[1] = 32'h00100413;  // addi  x8, x0, 1     (用来在仿真中标记结束)
        pass
        */
        /*
        rom_mem[0] = 32'h00500093;  // addi x1, x0, 5    (x1 = 5)
        rom_mem[1] = 32'hffb00193;  // addi x3, x0, -5   (x3 = -5 = 32'hfffffffb)
        rom_mem[2] = 32'h0011f463;  // bgeu x3, x1, 8    (无符号比较：-5 >= 5 为真，应该跳过下一条)
        rom_mem[3] = 32'h06300413;  // addi x8, x0, 99   (如果没跳过，x8 写入 99，代表失败)
        rom_mem[4] = 32'h00100413;  // addi x8, x0, 1    (如果跳过了，x8 写入 1，代表成功)
        pass
        */
        /*
        rom_mem[0] = 32'h00a00093; // addi x1, x0, 10 (x1 = 10)
        rom_mem[1] = 32'h00108133; // add  x2, x1, x1 (x2 = x1 + x1 = 20)
        */

        /*
       // 1. U型指令 (大立即数测试)
        // [PC = 0x00] LUI x1, 0x12345        -> x1 = 32'h12345000
        rom_mem[0]  = 32'h123450b7; 
        // [PC = 0x04] AUIPC x2, 0x00001      -> x2 = 0x04 + 0x00001000 = 32'h00001004
        rom_mem[1]  = 32'h00001117; 

        // 2. I型基础算术指令测试
        // [PC = 0x08] ADDI x3, x0, 15        -> x3 = 15
        rom_mem[2]  = 32'h00f00193; 
        // [PC = 0x0C] XORI x4, x3, -1        -> x4 = 15 ^ 32'hFFFFFFFF = 32'hFFFFFFF0 (取反，此行机器码已修正)
        rom_mem[3]  = 32'hfff1c213; 
        // [PC = 0x10] ORI  x5, x0, 5         -> x5 = 5
        rom_mem[4]  = 32'h00506293; 
        // [PC = 0x14] ANDI x5, x5, 4         -> x5 = 5 & 4 = 4
        rom_mem[5]  = 32'h0042f293; 

        // 3. I型移位指令测试 (SLLI / SRLI / SRAI)
        // [PC = 0x18] SLLI x6, x3, 4         -> x6 = 15 << 4 = 240 (32'h000000F0)
        rom_mem[6]  = 32'h00419313; 
        // [PC = 0x1C] SRLI x7, x4, 4         -> x7 = 32'hFFFFFFF0 无符号右移 4 位 = 32'h0FFFFFFF
        rom_mem[7]  = 32'h00425393; 
        // [PC = 0x20] SRAI x8, x4, 4         -> x8 = 32'hFFFFFFF0 算术右移 4 位 = 32'hFFFFFFFF
        rom_mem[8]  = 32'h40425413; 

        // 4. R型三目运算指令测试 (ADD/SUB/SLL/SLT/SLTU/XOR/SRL/SRA/OR/AND)
        // [PC = 0x24] ADD  x9, x3, x5        -> x9 = 15 + 4 = 19
        rom_mem[9]  = 32'h005184b3; 
        // [PC = 0x28] SUB  x10, x3, x5       -> x10 = 15 - 4 = 11
        rom_mem[10] = 32'h40518533; 
        // [PC = 0x2C] SLL  x11, x3, x5       -> x11 = 15 << 4 = 240
        rom_mem[11] = 32'h005195b3; 
        // [PC = 0x30] SLT  x12, x4, x3       -> 比较有符号数: -16 < 15, 成立! x12 = 1
        rom_mem[12] = 32'h00322633; 
        // [PC = 0x34] SLTU x13, x4, x3       -> 比较无符号数: 32'hFFFFFFF0 < 15, 不成立! x13 = 0
        rom_mem[13] = 32'h003236b3; 
        // [PC = 0x38] SLTI x14, x4, 0        -> 比较有符号立即数: -16 < 0, 成立! x14 = 1
        rom_mem[14] = 32'h00022713;

        // 5. I型/S型访存指令测试 (LB/LH/LW/LBU/LHU 与 SB/SH/SW)
        // [PC = 0x3C] SW   x3, 0(x0)         -> 把 15 (32'h0000000F) 写入 RAM[0]
        rom_mem[15] = 32'h00302023; 
        // [PC = 0x40] SB   x4, 4(x0)         -> 把 -16 (最低字节 32'hF0) 写入 RAM[4]
        rom_mem[16] = 32'h00400223; 
        // [PC = 0x44] LW   x15, 0(x0)        -> 从 RAM[0] 读出 32 位 -> x15 = 15
        rom_mem[17] = 32'h00002783; 
        // [PC = 0x48] LB   x16, 4(x0)        -> 从 RAM[4] 读出 8 位并符号扩展 -> x16 = 32'hFFFFFFF0 (-16)
        rom_mem[18] = 32'h00400803; 
        // [PC = 0x4C] LBU  x17, 4(x0)        -> 从 RAM[4] 读出 8 位并零扩展   -> x17 = 32'h000000F0 (240)
        rom_mem[19] = 32'h00404883; 

        // 6. J型/I型无条件跳转与链接测试 (JAL / JALR)
        // [PC = 0x50] JAL  x18, 12           -> 跳过下一条指令, 目的地 = 0x50 + 12 = 0x5C. 同时 x18 = 0x54 (返回地址)
        rom_mem[20] = 32'h00c0096f; 
        // [PC = 0x54] ADDI x19, x0, 999      -> 【这句应该被跳过，x19 保持为 0】
        rom_mem[21] = 32'h3e700993; 
        // [PC = 0x58] NOP 
        rom_mem[22] = 32'h00000013; 
        
        // 7. B型条件分支指令全覆盖测试 (BEQ/BNE/BLT/BGE/BLTU/BGEU)
        // [PC = 0x5C] BEQ  x15, x3, 12       -> x15(15) == x3(15), 成立! 目的地 = 0x5C + 12 = 0x68
        rom_mem[23] = 32'h00378663; 
        // [PC = 0x60] ADDI x19, x0, 888      -> 【这句应该被跳过】
        rom_mem[24] = 32'h37800993; 
        // [PC = 0x64] NOP
        rom_mem[25] = 32'h00000013; 
        
        // [PC = 0x68] BNE  x15, x4, 12       -> x15(15) != x4(-16), 成立! 目的地 = 0x68 + 12 = 0x74
        rom_mem[26] = 32'h00479663; 
        // [PC = 0x6C] ADDI x19, x0, 777      -> 【这句应该被跳过】
        rom_mem[27] = 32'h30900993; 
        // [PC = 0x70] NOP
        rom_mem[28] = 32'h00000013; 

        // [PC = 0x74] BGE  x3, x4, 8         -> 有符号比较: 15 >= -16, 成立! 目的地 = 0x74 + 8 = 0x7C
        rom_mem[29] = 32'h0041d463; 
        // [PC = 0x78] ADDI x19, x0, 666      -> 【这句应该被跳过】
        rom_mem[30] = 32'h29a00993; 

        // [PC = 0x7C] ADDI x20, x0, 1        -> 运行到此，代表 37 条核心指令全部打通！x20 = 1 标志胜利！
        rom_mem[31] = 32'h00100a13;
        pass
        */
        /*
// =========================================================================
        // SECTION 1: 寄存器 x0 保护与对称数据冲突测试 (Forwarding / Stall)
        // =========================================================================
        // [PC = 0x000] LUI x1, 0x11111       -> x1 = 32'h11111000
        rom_mem[0]  = 32'h111110b7; 
        // [PC = 0x004] ADDI x2, x1, 0x111    -> x2 = 32'h11111111 (验证紧邻 RAW 冲突, 正确必为一串1)
        rom_mem[1]  = 32'h11108113; 
        // [PC = 0x008] LUI x3, 0x33333       -> x3 = 32'h33333000
        rom_mem[2]  = 32'h333331b7; 
        // [PC = 0x00C] ADDI x0, x0, 0x777    -> x0 写入测试：x0 必须硬编码为 0
        rom_mem[3]  = 32'h77700013; 
        // [PC = 0x010] ADDI x5, x3, 0x333    -> x5 = 32'h33333333 (验证间隔 1 条指令 RAW, 正确必为一串3)
        rom_mem[4]  = 32'h33318293; 

        // =========================================================================
        // SECTION 2: Load-Use 致命数据冲突测试 (Stall 检测)
        // =========================================================================
        // [PC = 0x014] LUI x6, 0x66666       -> x6 = 32'h66666000
        rom_mem[5]  = 32'h66666317; 
        // [PC = 0x018] SW   x6, 4(x0)        -> 写入 RAM[4] = 32'h66666000
        rom_mem[6]  = 32'h00602223; 
        // [PC = 0x01C] LW   x7, 4(x0)        -> 读出 x7 = 32'h66666000
        rom_mem[7]  = 32'h00402383; 
        // [PC = 0x020] ADDI x8, x7, 0x111    -> x8 = 32'h66666111 (若 Stall/Forward 失败，会变成 0x00000111 极易发现)
        rom_mem[8]  = 32'h11138413; 

        // =========================================================================
        // SECTION 3: 控制冲突与流水线冲刷测试 (Branch Taken / Not Taken)
        // =========================================================================
        // [PC = 0x024] LUI x9, 0xAAAAA       -> x9 = 32'hAAAAA000
        rom_mem[9]  = 32'haaaaa4b7; 
        // [PC = 0x028] LUI x10, 0xBBBBB      -> x10 = 32'hBBBBB000
        rom_mem[10] = 32'hbbbbb537; 
        // [PC = 0x02C] BEQ  x9, x10, 16      -> 不相等不跳转。
        rom_mem[11] = 32'h00a48863; 
        // [PC = 0x030] LUI x11, 0xCCCCC      -> 应该执行：x11 = 32'hCCCCC000
        rom_mem[12] = 32'hccccc5b7; 
        // [PC = 0x034] JAL  x0, 12           -> 跳过下一句
        rom_mem[13] = 32'h00c0006f; 
        // [PC = 0x038] LUI x11, 0xDDDDD      -> 【应该被跳过】若没有跳过，x11 变成 0xDDDDD000
        rom_mem[14] = 32'hddddd5b7; 
        // [PC = 0x03C] NOP
        rom_mem[15] = 32'h00000013; 
        // [PC = 0x040] BEQ  x9, x9, 16       -> 相等跳转至 PC = 0x050
        rom_mem[16] = 32'h00948863; 
        // [PC = 0x044] LUI x12, 0x99999      -> 【应该被 Flush 冲刷掉】若冲刷失败，x12 会显眼地变成 0x99999000
        rom_mem[17] = 32'h99999637; 
        // [PC = 0x048] LUI x13, 0x99999      -> 【应该被 Flush 冲刷掉】若冲刷失败，x13 会变成 0x99999000
        rom_mem[18] = 32'h999996b7; 
        // [PC = 0x04C] NOP
        rom_mem[19] = 32'h00000013; 
        // [PC = 0x050] LUI x14, 0xEEEEE      -> 跳转目的地：x14 = 32'hEEEEE000
        rom_mem[20] = 32'heeeee737; 

        // =========================================================================
        // SECTION 4: 间接跳转与子程序返回 (JAL / JALR)
        // =========================================================================
        // [PC = 0x054] JAL  x16, 16          -> 跳转至 0x064，保存返回 PC (0x058) 到 x16
        rom_mem[21] = 32'h0100086f; 
        // [PC = 0x058] LUI x17, 0x77777      -> 返回后执行：x17 = 32'h77777000
        rom_mem[22] = 32'h777778b7; 
        // [PC = 0x05C] JAL  x0, 20           -> 跳过子程序实体，去 0x070
        rom_mem[23] = 32'h0140006f; 
        // [PC = 0x060] NOP
        rom_mem[24] = 32'h00000013; 
        // [PC = 0x064] LUI x18, 0x88888      -> 子程序：x18 = 32'h88888000
        rom_mem[25] = 32'h88888937; 
        // [PC = 0x068] JALR x0, 0(x16)       -> 返回 0x058
        rom_mem[26] = 32'h00080067; 
        // [PC = 0x06C] NOP
        rom_mem[27] = 32'h00000013; 

        // =========================================================================
        // SECTION 5: 字节/符号扩展与经典 ALU 视觉测试 (LB/LBU/ADD/XOR)
        // =========================================================================
        // [PC = 0x070] LUI x19, 0xFFFFF      -> x19 = 32'hFFFFF000
        rom_mem[28] = 32'hfffff9b7; 
        // [PC = 0x074] SB  x19, 8(x0)        -> 写入 RAM[8] = 0x00 (x19 最低字节)
        rom_mem[29] = 32'h01300423; 
        // [PC = 0x078] LBU x20, 8(x0)        -> 读出：x20 = 32'h00000000
        rom_mem[30] = 32'h00804a83; 
        // [PC = 0x07C] ADDI x19, x19, -16    -> x19 = 32'hFFFFEFF0 (制造 F0 尾数，-16补码为 0xFF0)
        rom_mem[31] = 32'hfff98993; 
        // [PC = 0x080] SB  x19, 8(x0)        -> 写入 RAM[8] = 0xF0
        rom_mem[32] = 32'h01300423; 
        // [PC = 0x084] LB  x21, 8(x0)        -> 符号位扩展：x21 = 32'hFFFFFFF0 (肉眼极易识别)
        rom_mem[33] = 32'h00800a83; 
        // [PC = 0x088] LBU x22, 8(x0)        -> 零扩展：x22 = 32'h000000F0
        rom_mem[34] = 32'h00804b03; 

        // 极限极简 ALU 视觉运算：
        // [PC = 0x08C] ADD x23, x2, x5       -> 0x11111111 + 0x33333333 = 32'h44444444 !
        rom_mem[35] = 32'h00510bb3; 
        // [PC = 0x090] AND x24, x5, x8       -> 0x33333333 & 0x66666111 = 32'h22222011 !
        rom_mem[36] = 32'h0082fc33; 
        // [PC = 0x094] XOR x25, x2, x5       -> 0x11111111 ^ 0x33333333 = 32'h22222222 !
        rom_mem[37] = 32'h00514cb3; 

        // 结束自跳死循环
        // [PC = 0x098] JAL x0, 0             -> 停机
        rom_mem[38] = 32'h0000006f;
        */
        
        /*
        rom_mem[0] = 32'h00a00013;
        rom_mem[1] = 32'h00000233;
        rom_mem[2] = 32'h01420193;
        rom_mem[3] = 32'h00302823;
        rom_mem[4] = 32'h01002283;
        rom_mem[5] = 32'h00528313;
        rom_mem[6] = 32'h003303b3;
        rom_mem[7] = 32'h00039863;
        rom_mem[8] = 32'h3e700393;
        rom_mem[9] = 32'h37800313;
        rom_mem[10] = 32'h00000013;
        rom_mem[11] = 32'h00000463;
        rom_mem[12] = 32'h01002083;
        rom_mem[13] = 32'h00100413;
        */
        /*
        rom_mem[0] = 32'h89abc0b7; // [0x00] LUI  x1, 0x89ABC       -> x1 = 0x89ABC000
        rom_mem[1] = 32'heef08093; // [0x04] ADDI x1, x1, -273     -> 生成特定常数：x1 = 32'h89ABBEEF
        rom_mem[2] = 32'h00102623; // [0x08] SW   x1, 12(x0)       -> 写入 RAM[12] = 32'h89ABBEEF
        rom_mem[3] = 32'h00c04103; // [0x0C] LBU  x2, 12(x0)       -> 无符号读单字节：x2 = 32'h000000EF
        rom_mem[4] = 32'h00c00183; // [0x10] LB   x3, 12(x0)       -> 有符号读单字节：x3 = 32'hFFFFFFEF (符号扩展)
        rom_mem[5] = 32'h00c05203; // [0x14] LHU  x4, 12(x0)       -> 无符号读半字：  x4 = 32'h0000BEEF
        rom_mem[6] = 32'h00c01283; // [0x18] LH   x5, 12(x0)       -> 有符号读半字：  x5 = 32'hFFFFBEEF (符号扩展)
        rom_mem[7] = 32'h0000006f; // [0x1C] JAL  x0, 0             -> 自跳死循环
        */
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