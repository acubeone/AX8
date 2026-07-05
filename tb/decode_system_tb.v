`timescale 1ns / 1ps

module decode_system_tb;

    reg        E;
    reg  [3:0] FR;
    reg  [7:0] IR;

    wire       HLT;
    wire [3:0] FR_WE;
    wire [3:0] FR_DATA;

    integer errors;

    decode_system uut (
        .E(E),
        .FR(FR),
        .IR(IR),
        .HLT(HLT),
        .FR_WE(FR_WE),
        .FR_DATA(FR_DATA)
    );

    task check_case;
        input [8*32-1:0] name;
        input             e_i;
        input [3:0]       fr_i;
        input [7:0]       ir_i;
        input             exp_hlt;
        input [3:0]       exp_fr_we;
        input [3:0]       exp_fr_data;

        begin
            E  = e_i;
            FR = fr_i;
            IR = ir_i;

            #10;

            $display(
                "%0s | E=%b FR=%04b IR=%08b | HLT=%b FR_WE=%04b FR_DATA=%04b",
                name, E, FR, IR,
                HLT, FR_WE, FR_DATA
            );

            if ({HLT, FR_WE, FR_DATA} !==
                {exp_hlt, exp_fr_we, exp_fr_data}) begin

                errors = errors + 1;

                $display(
                    "ERRO: esperado HLT=%b FR_WE=%04b FR_DATA=%04b",
                    exp_hlt, exp_fr_we, exp_fr_data
                );
            end
        end
    endtask

    initial begin
        $dumpfile("decode_system.vcd");
        $dumpvars(0, decode_system_tb);

        errors = 0;

        check_case(
            "E=0",
            1'b0,
            4'b1111,
            8'b00000111,
            1'b0,
            4'b0000,
            4'b0000
        );

        check_case(
            "NOP",
            1'b1,
            4'b1010,
            8'b00000000,
            1'b0,
            4'b0000,
            4'b0010
        );

        check_case(
            "FR_WE_C",
            1'b1,
            4'b0011,
            8'b00000100,
            1'b0,
            4'b0100,
            4'b0011
        );

        check_case(
            "FR_WE_V",
            1'b1,
            4'b0101,
            8'b00000110,
            1'b0,
            4'b1000,
            4'b0001
        );

        check_case(
            "FR_WE_C IR0=1",
            1'b1,
            4'b0010,
            8'b00000101,
            1'b0,
            4'b0100,
            4'b1110
        );

        check_case(
            "FR_WE_V IR0=1",
            1'b1,
            4'b0001,
            8'b00000111,
            1'b0,
            4'b1000,
            4'b1101
        );

        check_case(
            "HLT por IR0",
            1'b1,
            4'b0011,
            8'b00000001,
            1'b1,
            4'b0000,
            4'b1111
        );

        check_case(
            "HLT por IR3",
            1'b1,
            4'b0011,
            8'b00001000,
            1'b1,
            4'b0000,
            4'b0011
        );

        check_case(
            "HLT por IR4",
            1'b1,
            4'b0011,
            8'b00010000,
            1'b1,
            4'b0000,
            4'b0011
        );

        if (errors == 0)
            $display("PASS: todos os testes passaram.");
        else
            $display("FAIL: %0d teste(s) falharam.", errors);

        #10;
        $finish;
    end

endmodule
