`timescale 1ns / 1ps

module instruction_decoder_tb;

    reg  [3:0] FR;
    reg  [7:0] IR;

    wire       HLT;
    wire       RW;
    wire       ALU_WB;
    wire [1:0] PC_OP;
    wire [1:0] MODE;
    wire [1:0] DST_SEL;
    wire [2:0] SRC_SEL;
    wire [3:0] FR_WE;
    wire [3:0] FR_DATA;
    wire [3:0] ALU_OP;

    integer errors;

    instruction_decoder uut (
        .FR      (FR),
        .IR      (IR),
        .HLT     (HLT),
        .RW      (RW),
        .ALU_WB  (ALU_WB),
        .PC_OP   (PC_OP),
        .MODE    (MODE),
        .DST_SEL (DST_SEL),
        .SRC_SEL (SRC_SEL),
        .FR_WE   (FR_WE),
        .FR_DATA (FR_DATA),
        .ALU_OP  (ALU_OP)
    );

    task check_case;
        input [8*32-1:0] name;
        input [3:0]       fr_i;
        input [7:0]       ir_i;

        input             exp_hlt;
        input             exp_rw;
        input             exp_wb;
        input [1:0]       exp_pc;
        input [1:0]       exp_mode;
        input [1:0]       exp_dst;
        input [2:0]       exp_src;
        input [3:0]       exp_fr_we;
        input [3:0]       exp_fr_data;
        input [3:0]       exp_alu_op;

        begin
            FR = fr_i;
            IR = ir_i;

            #10;

            $display(
                "%0s | FR=%04b IR=%08b | HLT=%b RW=%b ALU_WB=%b PC=%02b MODE=%02b DST=%02b SRC=%03b FR_WE=%04b FR_DATA=%04b ALU_OP=%04b",
                name, FR, IR,
                HLT, RW, ALU_WB,
                PC_OP, MODE, DST_SEL, SRC_SEL,
                FR_WE, FR_DATA, ALU_OP
            );

            if ({
                HLT,
                RW,
                ALU_WB,
                PC_OP,
                MODE,
                DST_SEL,
                SRC_SEL,
                FR_WE,
                FR_DATA,
                ALU_OP
            } !== {
                exp_hlt,
                exp_rw,
                exp_wb,
                exp_pc,
                exp_mode,
                exp_dst,
                exp_src,
                exp_fr_we,
                exp_fr_data,
                exp_alu_op
            }) begin
                errors = errors + 1;
                $display("ERRO em %0s", name);
            end
        end
    endtask

    initial begin
        $dumpfile("instruction_decoder.vcd");
        $dumpvars(0, instruction_decoder_tb);

        errors = 0;

        check_case(
            "SYS FR_WE_C",
            4'b0011,
            8'b00000100,
            1'b0, 1'b1, 1'b0,
            2'b00, 2'b00, 2'b00, 3'b000,
            4'b0100, 4'b0011, 4'b0000
        );

        check_case(
            "MEM READ",
            4'b0000,
            8'b00100000,
            1'b0, 1'b1, 1'b1,
            2'b00, 2'b11, 2'b00, 3'b011,
            4'b0000, 4'b0000, 4'b1000
        );

        check_case(
            "MEM WRITE",
            4'b0000,
            8'b00100101,
            1'b0, 1'b0, 1'b1,
            2'b00, 2'b11, 2'b11, 3'b001,
            4'b0000, 4'b0000, 4'b1000
        );

        check_case(
            "ARI ADC",
            4'b0000,
            8'b01000000,
            1'b0, 1'b1, 1'b1,
            2'b00, 2'b00, 2'b00, 3'b001,
            4'b0000, 4'b0000, 4'b0000
        );

        check_case(
            "ARI CMP",
            4'b0000,
            8'b01000110,
            1'b0, 1'b1, 1'b0,
            2'b00, 2'b00, 2'b00, 3'b001,
            4'b0000, 4'b0000, 4'b0001
        );

        check_case(
            "UNY NOT",
            4'b0101,
            8'b01100101,
            1'b0, 1'b1, 1'b1,
            2'b00, 2'b00, 2'b00, 3'b111,
            4'b0000, 4'b0101, 4'b0101
        );

        check_case(
            "UNY INC IX",
            4'b0000,
            8'b01101001,
            1'b0, 1'b1, 1'b1,
            2'b00, 2'b00, 2'b01, 3'b110,
            4'b0000, 4'b0100, 4'b0000
        );

        check_case(
            "JMP BRA",
            4'b0000,
            8'b10010000,
            1'b0, 1'b1, 1'b0,
            2'b01, 2'b10, 2'b00, 3'b000,
            4'b0000, 4'b0000, 4'b0000
        );

        check_case(
            "JMP JMP",
            4'b0000,
            8'b10010001,
            1'b0, 1'b1, 1'b0,
            2'b10, 2'b11, 2'b00, 3'b000,
            4'b0000, 4'b0000, 4'b0000
        );

        check_case(
            "ARI HLT",
            4'b0000,
            8'b01000111,
            1'b1, 1'b1, 1'b0,
            2'b00, 2'b00, 2'b00, 3'b000,
            4'b0000, 4'b0000, 4'b0000
        );

        check_case(
            "INVALID GROUP 101",
            4'b0000,
            8'b10100000,
            1'b1, 1'b1, 1'b0,
            2'b00, 2'b00, 2'b00, 3'b000,
            4'b0000, 4'b0000, 4'b0000
        );

        check_case(
            "SYS HLT",
            4'b0011,
            8'b00000001,
            1'b1, 1'b1, 1'b0,
            2'b00, 2'b00, 2'b00, 3'b000,
            4'b0000, 4'b0000, 4'b0000
        );

        if (errors == 0)
            $display("PASS: todos os testes passaram.");
        else
            $display("FAIL: %0d teste(s) falharam.", errors);

        #10;
        $finish;
    end

endmodule
