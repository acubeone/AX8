`timescale 1ns / 1ps

module decode_jump_tb;

    reg        E;
    reg  [3:0] FR;
    reg  [7:0] IR;

    wire       HLT;
    wire [1:0] MODE;
    wire [1:0] PC_OP;

    integer errors;

    decode_jump dut (
        .E     (E),
        .FR    (FR),
        .IR    (IR),
        .HLT   (HLT),
        .MODE  (MODE),
        .PC_OP (PC_OP)
    );

    task check_case;
        input [8*32-1:0] test_name;
        input              e_i;
        input [3:0]        fr_i;
        input [7:0]        ir_i;
        input              exp_hlt;
        input [1:0]        exp_mode;
        input [1:0]        exp_pc_op;

        begin
            E  = e_i;
            FR = fr_i;
            IR = ir_i;

            #10;

            $display(
                "%0t | %0s | E=%b FR=%04b IR=%08b | HLT=%b MODE=%02b PC_OP=%02b",
                $time,
                test_name,
                E,
                FR,
                IR,
                HLT,
                MODE,
                PC_OP
            );

            if ({HLT, MODE, PC_OP} !==
                {exp_hlt, exp_mode, exp_pc_op}) begin

                errors = errors + 1;

                $display(
                    "ERRO: esperado HLT=%b MODE=%02b PC_OP=%02b",
                    exp_hlt,
                    exp_mode,
                    exp_pc_op
                );
            end
        end
    endtask

    initial begin
        $dumpfile("decode_jump.vcd");
        $dumpvars(0, decode_jump_tb);

        errors = 0;

        $display("============================================================");
        $display(" decode_jump testbench");
        $display("============================================================");

        // --------------------------------------------------------
        // E = 0: todas as saidas externas devem ficar zeradas
        // --------------------------------------------------------

        check_case(
            "E=0 bloqueia saidas",
            1'b0,
            4'b1111,
            8'b10011111,
            1'b0,
            2'b00,
            2'b00
        );

        // --------------------------------------------------------
        // Conditional Branch
        // --------------------------------------------------------

        // BNQ: branch se Z = 0
        check_case(
            "BNQ Z=0",
            1'b1,
            4'b0000,
            8'b10000000,
            1'b0,
            2'b10,
            2'b01
        );

        // BNQ: nao toma branch se Z = 1
        check_case(
            "BNQ Z=1",
            1'b1,
            4'b0001,
            8'b10000000,
            1'b0,
            2'b10,
            2'b00
        );

        // BEQ: branch se Z = 1
        check_case(
            "BEQ Z=1",
            1'b1,
            4'b0001,
            8'b10000100,
            1'b0,
            2'b10,
            2'b01
        );

        // BPL: branch se N = 0
        check_case(
            "BPL N=0",
            1'b1,
            4'b0000,
            8'b10000001,
            1'b0,
            2'b10,
            2'b01
        );

        // BPL: nao toma branch se N = 1
        check_case(
            "BPL N=1",
            1'b1,
            4'b0010,
            8'b10000001,
            1'b0,
            2'b10,
            2'b00
        );

        // BCS: branch se C = 1
        check_case(
            "BCS C=1",
            1'b1,
            4'b0100,
            8'b10000110,
            1'b0,
            2'b10,
            2'b01
        );

        // BVS: branch se V = 1
        check_case(
            "BVS V=1",
            1'b1,
            4'b1000,
            8'b10000111,
            1'b0,
            2'b10,
            2'b01
        );

        // --------------------------------------------------------
        // Unconditional Control Flow
        // --------------------------------------------------------

        // BRA
        check_case(
            "BRA",
            1'b1,
            4'b0000,
            8'b10010000,
            1'b0,
            2'b10,
            2'b01
        );

        // JMP
        check_case(
            "JMP",
            1'b1,
            4'b0000,
            8'b10010001,
            1'b0,
            2'b11,
            2'b10
        );

        // Reservado/NOP
        check_case(
            "Reservado 10010",
            1'b1,
            4'b0000,
            8'b10010010,
            1'b0,
            2'b10,
            2'b00
        );

        // --------------------------------------------------------
        // Instrucoes invalidas
        // --------------------------------------------------------

        // IR[4:3] = 01 -> HLT
        check_case(
            "Invalido 01xxx",
            1'b1,
            4'b0000,
            8'b10001000,
            1'b1,
            2'b10,
            2'b00
        );

        // 101xx -> HLT.
        // O DMX do circuito nao usa IR[2], portanto PC_OP ainda
        // reflete a selecao OO mesmo com HLT ativo.
        check_case(
            "Invalido 10100",
            1'b1,
            4'b0000,
            8'b10010100,
            1'b1,
            2'b10,
            2'b01
        );

        $display("============================================================");

        if (errors == 0) begin
            $display("PASS: todos os testes passaram.");
        end
        else begin
            $display("FAIL: %0d teste(s) falharam.", errors);
        end

        $display("============================================================");

        #10;
        $finish;
    end

endmodule
