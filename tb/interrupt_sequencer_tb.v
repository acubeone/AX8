`timescale 1ns / 1ps

module interrupt_sequencer_tb;

    reg CLK;
    reg RESET;

    wire       DONE;
    wire       OUT_RST;
    wire       MEM_RW;
    wire       OP_LO_WE;
    wire       OP_HI_WE;
    wire [1:0] ADDR_SEL;
    wire [1:0] PC_OP;
    wire [3:0] FR_WE;
    wire [3:0] FR_DATA;
    wire [3:0] VEC;

    integer errors;

    interrupt_sequencer uut (
        .CLK       (CLK),
        .RESET     (RESET),
        .DONE      (DONE),
        .OUT_RST   (OUT_RST),
        .MEM_RW    (MEM_RW),
        .OP_LO_WE  (OP_LO_WE),
        .OP_HI_WE  (OP_HI_WE),
        .ADDR_SEL  (ADDR_SEL),
        .PC_OP     (PC_OP),
        .FR_WE     (FR_WE),
        .FR_DATA   (FR_DATA),
        .VEC       (VEC)
    );

    task clock_step;
        begin
            #5 CLK = 1'b1;
            #1;
            CLK = 1'b0;
            #4;
        end
    endtask

    task check_case;
        input [8*20-1:0] name;
        input             exp_done;
        input             exp_out_rst;
        input             exp_mem_rw;
        input             exp_lo_we;
        input             exp_hi_we;
        input [1:0]       exp_addr;
        input [1:0]       exp_pc;
        input [3:0]       exp_fr_we;
        input [3:0]       exp_fr_data;
        input [3:0]       exp_vec;

        begin
            $display(
                "%0s | Q1Q0=%02b | DONE=%b OUT_RST=%b MEM_RW=%b OP_LO_WE=%b OP_HI_WE=%b ADDR_SEL=%02b PC_OP=%02b FR_WE=%04b FR_DATA=%04b VEC=%04b",
                name,
                {uut.q1, uut.q0},
                DONE,
                OUT_RST,
                MEM_RW,
                OP_LO_WE,
                OP_HI_WE,
                ADDR_SEL,
                PC_OP,
                FR_WE,
                FR_DATA,
                VEC
            );

            if ({
                DONE,
                OUT_RST,
                MEM_RW,
                OP_LO_WE,
                OP_HI_WE,
                ADDR_SEL,
                PC_OP,
                FR_WE,
                FR_DATA,
                VEC
            } !== {
                exp_done,
                exp_out_rst,
                exp_mem_rw,
                exp_lo_we,
                exp_hi_we,
                exp_addr,
                exp_pc,
                exp_fr_we,
                exp_fr_data,
                exp_vec
            }) begin
                errors = errors + 1;
                $display("ERRO em %0s", name);
            end
        end
    endtask

    initial begin
        $dumpfile("interrupt_sequencer.vcd");
        $dumpvars(0, interrupt_sequencer_tb);

        CLK = 1'b0;
        RESET = 1'b1;
        errors = 0;

        #2;
        RESET = 1'b0;
        #2;

        check_case(
            "R0a",
            1'b0,
            1'b0,
            1'b1,
            1'b1,
            1'b0,
            2'b11,
            2'b00,
            4'b0000,
            4'b0000,
            4'b0000
        );

        clock_step();

        check_case(
            "R0b",
            1'b0,
            1'b0,
            1'b1,
            1'b0,
            1'b1,
            2'b11,
            2'b00,
            4'b0000,
            4'b0000,
            4'b0001
        );

        clock_step();

        check_case(
            "REa",
            1'b0,
            1'b1,
            1'b1,
            1'b0,
            1'b0,
            2'b00,
            2'b10,
            4'b1111,
            4'b0000,
            4'b0000
        );

        clock_step();

        check_case(
            "REb",
            1'b1,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            2'b00,
            2'b00,
            4'b0000,
            4'b0000,
            4'b0000
        );

        clock_step();

        check_case(
            "REb HOLD",
            1'b1,
            1'b0,
            1'b1,
            1'b0,
            1'b0,
            2'b00,
            2'b00,
            4'b0000,
            4'b0000,
            4'b0000
        );

        RESET = 1'b1;
        #2;

        check_case(
            "RESET R0a",
            1'b0,
            1'b0,
            1'b1,
            1'b1,
            1'b0,
            2'b11,
            2'b00,
            4'b0000,
            4'b0000,
            4'b0000
        );

        RESET = 1'b0;

        if (errors == 0)
            $display("PASS: todos os testes passaram.");
        else
            $display("FAIL: %0d teste(s) falharam.", errors);

        #10;
        $finish;
    end

endmodule
