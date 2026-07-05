`timescale 1ns / 1ps

module decode_unary_tb;

    reg        E;
    reg  [3:0] FR;
    reg  [7:0] IR;

    wire       HLT;
    wire       ALU_WB;
    wire [1:0] MODE;
    wire [1:0] DST_SEL;
    wire [2:0] SRC_SEL;
    wire [3:0] FR_WE;
    wire [3:0] FR_DATA;
    wire [3:0] ALU_OP;

    integer errors;

    decode_unary dut (
        .E        (E),
        .FR       (FR),
        .IR       (IR),

        .HLT      (HLT),
        .ALU_WB   (ALU_WB),
        .MODE     (MODE),
        .DST_SEL  (DST_SEL),
        .SRC_SEL  (SRC_SEL),
        .FR_WE    (FR_WE),
        .FR_DATA  (FR_DATA),
        .ALU_OP   (ALU_OP)
    );

    task check_case;
        input [8*32-1:0] test_name;

        input              e_i;
        input [3:0]        fr_i;
        input [7:0]        ir_i;

        input              exp_hlt;
        input              exp_alu_wb;
        input [1:0]        exp_mode;
        input [1:0]        exp_dst_sel;
        input [2:0]        exp_src_sel;
        input [3:0]        exp_fr_we;
        input [3:0]        exp_fr_data;
        input [3:0]        exp_alu_op;

        begin
            E  = e_i;
            FR = fr_i;
            IR = ir_i;

            #10;

            $display(
                "%0t | %0s | E=%b FR=%04b IR=%08b | HLT=%b ALU_WB=%b MODE=%02b DST=%02b SRC=%03b FR_WE=%04b FR_DATA=%04b ALU_OP=%04b",
                $time,
                test_name,
                E,
                FR,
                IR,
                HLT,
                ALU_WB,
                MODE,
                DST_SEL,
                SRC_SEL,
                FR_WE,
                FR_DATA,
                ALU_OP
            );

            if ({
                HLT,
                ALU_WB,
                MODE,
                DST_SEL,
                SRC_SEL,
                FR_WE,
                FR_DATA,
                ALU_OP
            } !== {
                exp_hlt,
                exp_alu_wb,
                exp_mode,
                exp_dst_sel,
                exp_src_sel,
                exp_fr_we,
                exp_fr_data,
                exp_alu_op
            }) begin

                errors = errors + 1;

                $display(
                    "ERRO: esperado HLT=%b ALU_WB=%b MODE=%02b DST=%02b SRC=%03b FR_WE=%04b FR_DATA=%04b ALU_OP=%04b",
                    exp_hlt,
                    exp_alu_wb,
                    exp_mode,
                    exp_dst_sel,
                    exp_src_sel,
                    exp_fr_we,
                    exp_fr_data,
                    exp_alu_op
                );
            end
        end
    endtask

    initial begin
        $dumpfile("decode_unary.vcd");
        $dumpvars(0, decode_unary_tb);

        errors = 0;

        $display("================================================================================================================");
        $display(" decode_unary testbench");
        $display("================================================================================================================");

        // --------------------------------------------------------
        // E = 0
        // Todas as saidas externas devem ser zero
        // --------------------------------------------------------

        check_case(
            "E=0 bloqueia saidas",
            1'b0,
            4'b1111,
            8'b00000000,

            1'b0,
            1'b0,
            2'b00,
            2'b00,
            3'b000,
            4'b0000,
            4'b0000,
            4'b0000
        );

        // --------------------------------------------------------
        // SHL
        //
        // ALU_OP = 0110
        // ALU_SHIFT limpa OUT_C
        // FR=1111 -> FR_DATA=1011
        // --------------------------------------------------------

        check_case(
            "SHL",
            1'b1,
            4'b1111,
            8'b00000000,

            1'b0,
            1'b1,
            2'b00,
            2'b00,
            3'b110,
            4'b0000,
            4'b1011,
            4'b0110
        );

        // --------------------------------------------------------
        // SHR
        // --------------------------------------------------------

        check_case(
            "SHR",
            1'b1,
            4'b1111,
            8'b00000001,

            1'b0,
            1'b1,
            2'b00,
            2'b00,
            3'b110,
            4'b0000,
            4'b1011,
            4'b0111
        );

        // --------------------------------------------------------
        // Opcode invalido 00010
        //
        // IS_HLT = 1
        // --------------------------------------------------------

        check_case(
            "HLT por IS_HLT",
            1'b1,
            4'b0101,
            8'b00000010,

            1'b1,
            1'b0,
            2'b00,
            2'b00,
            3'b110,
            4'b0000,
            4'b0101,
            4'b0010
        );

        // --------------------------------------------------------
        // NOT
        // --------------------------------------------------------

        check_case(
            "NOT",
            1'b1,
            4'b0101,
            8'b00000101,

            1'b0,
            1'b1,
            2'b00,
            2'b00,
            3'b111,
            4'b0000,
            4'b0101,
            4'b0101
        );

        // --------------------------------------------------------
        // ROL
        // --------------------------------------------------------

        check_case(
            "ROL",
            1'b1,
            4'b0101,
            8'b00000110,

            1'b0,
            1'b1,
            2'b00,
            2'b00,
            3'b110,
            4'b0000,
            4'b0101,
            4'b0110
        );

        // --------------------------------------------------------
        // ROR
        // --------------------------------------------------------

        check_case(
            "ROR",
            1'b1,
            4'b0101,
            8'b00000111,

            1'b0,
            1'b1,
            2'b00,
            2'b00,
            3'b110,
            4'b0000,
            4'b0101,
            4'b0111
        );

        // --------------------------------------------------------
        // INC IX
        //
        // IR[4:0] = 01001
        // DST_SEL = 01
        // I_INC força OUT_C = 1
        // --------------------------------------------------------

        check_case(
            "INC IX",
            1'b1,
            4'b0000,
            8'b00001001,

            1'b0,
            1'b1,
            2'b00,
            2'b01,
            3'b110,
            4'b0000,
            4'b0100,
            4'b0000
        );

        // --------------------------------------------------------
        // DEC IY
        //
        // IR[4:0] = 01110
        // DST_SEL = 10
        // SRC_SEL = 111
        // --------------------------------------------------------

        check_case(
            "DEC IY",
            1'b1,
            4'b0101,
            8'b00001110,

            1'b0,
            1'b1,
            2'b00,
            2'b10,
            3'b111,
            4'b0000,
            4'b0101,
            4'b0000
        );

        // --------------------------------------------------------
        // RR = 11 gera HLT
        //
        // IR[4:0] = 01011
        // --------------------------------------------------------

        check_case(
            "INC RR=11 HLT",
            1'b1,
            4'b0000,
            8'b00001011,

            1'b1,
            1'b0,
            2'b00,
            2'b11,
            3'b110,
            4'b0000,
            4'b0100,
            4'b0000
        );

        // --------------------------------------------------------
        // IR4 = 1 gera HLT
        // --------------------------------------------------------

        check_case(
            "IR4 gera HLT",
            1'b1,
            4'b1111,
            8'b00010000,

            1'b1,
            1'b0,
            2'b00,
            2'b00,
            3'b110,
            4'b0000,
            4'b1011,
            4'b0110
        );

        $display("================================================================================================================");

        if (errors == 0) begin
            $display("PASS: todos os testes passaram.");
        end
        else begin
            $display("FAIL: %0d teste(s) falharam.", errors);
        end

        $display("================================================================================================================");

        #10;
        $finish;
    end

endmodule
