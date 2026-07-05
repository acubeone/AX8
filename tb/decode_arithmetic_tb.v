`timescale 1ns / 1ps

module decode_arithmetic_tb;

    reg        E;
    reg  [3:0] FR;
    reg  [7:0] IR;

    wire       HLT;
    wire       ALU_WB;
    wire [1:0] MODE;
    wire [1:0] DST_SEL;
    wire [2:0] SRC_SEL;
    wire [3:0] ALU_OP;

    integer errors;

    decode_arithmetic dut (
        .E       (E),
        .FR      (FR),
        .IR      (IR),
        .HLT     (HLT),
        .ALU_WB  (ALU_WB),
        .MODE    (MODE),
        .DST_SEL (DST_SEL),
        .SRC_SEL (SRC_SEL),
        .ALU_OP  (ALU_OP)
    );

    task check_case;
        input [8*32-1:0] name;
        input             e_i;
        input [3:0]       fr_i;
        input [7:0]       ir_i;
        input             exp_hlt;
        input             exp_wb;
        input [1:0]       exp_mode;
        input [1:0]       exp_dst;
        input [2:0]       exp_src;
        input [3:0]       exp_op;

        begin
            E  = e_i;
            FR = fr_i;
            IR = ir_i;

            #10;

            $display(
                "%0s | E=%b FR=%04b IR=%08b | HLT=%b ALU_WB=%b MODE=%02b DST=%02b SRC=%03b ALU_OP=%04b",
                name, E, FR, IR,
                HLT, ALU_WB, MODE, DST_SEL, SRC_SEL, ALU_OP
            );

            if ({
                HLT,
                ALU_WB,
                MODE,
                DST_SEL,
                SRC_SEL,
                ALU_OP
            } !== {
                exp_hlt,
                exp_wb,
                exp_mode,
                exp_dst,
                exp_src,
                exp_op
            }) begin
                errors = errors + 1;
                $display("ERRO em %0s", name);
            end
        end
    endtask

    initial begin
        $dumpfile("decode_arithmetic.vcd");
        $dumpvars(0, decode_arithmetic_tb);

        errors = 0;

        check_case(
            "E=0",
            1'b0, 4'b1111, 8'b00010111,
            1'b0, 1'b0, 2'b00, 2'b00, 3'b000, 4'b0000
        );

        check_case(
            "ADC MODE00",
            1'b1, 4'b0000, 8'b00000000,
            1'b0, 1'b1, 2'b00, 2'b00, 3'b001, 4'b0000
        );

        check_case(
            "SBC MODE00",
            1'b1, 4'b1111, 8'b00000001,
            1'b0, 1'b1, 2'b00, 2'b00, 3'b001, 4'b0001
        );

        check_case(
            "CMP MODE00",
            1'b1, 4'b0101, 8'b00000110,
            1'b0, 1'b0, 2'b00, 2'b00, 3'b001, 4'b0001
        );

        check_case(
            "HLT OOO111",
            1'b1, 4'b0000, 8'b00000111,
            1'b1, 1'b0, 2'b00, 2'b00, 3'b001, 4'b0000
        );

        check_case(
            "ADC MODE01",
            1'b1, 4'b0000, 8'b00001000,
            1'b0, 1'b1, 2'b01, 2'b00, 3'b011, 4'b0000
        );

        check_case(
            "LDI SPECIAL",
            1'b1, 4'b1010, 8'b00010111,
            1'b0, 1'b1, 2'b10, 2'b00, 3'b011, 4'b1000
        );

        check_case(
            "CMP MODE10",
            1'b1, 4'b0011, 8'b00010110,
            1'b0, 1'b0, 2'b10, 2'b00, 3'b011, 4'b0001
        );

        check_case(
            "MUL MODE11",
            1'b1, 4'b1001, 8'b00011010,
            1'b0, 1'b1, 2'b11, 2'b00, 3'b011, 4'b0010
        );

        check_case(
            "HLT MODE11",
            1'b1, 4'b0000, 8'b00011111,
            1'b1, 1'b0, 2'b11, 2'b00, 3'b011, 4'b0000
        );

        if (errors == 0)
            $display("PASS: todos os testes passaram.");
        else
            $display("FAIL: %0d teste(s) falharam.", errors);

        #10;
        $finish;
    end

endmodule
