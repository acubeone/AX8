`timescale 1ns / 1ps

module instruction_sequencer_tb;

    reg        CLK;
    reg        RESET;
    reg        ENABLE;
    reg        RW;
    reg  [1:0] PC_OP_IN;
    reg  [1:0] MODE;

    wire       COMMIT;
    wire       MEM_RW;
    wire       DL_WE;
    wire       IR_WE;
    wire       OP_LO_WE;
    wire       OP_HI_WE;
    wire [1:0] ADDR_SEL;
    wire [1:0] PC_OP;

    integer errors;

    instruction_sequencer uut (
        .CLK       (CLK),
        .RESET     (RESET),
        .ENABLE    (ENABLE),
        .RW        (RW),
        .PC_OP_IN  (PC_OP_IN),
        .MODE      (MODE),
        .COMMIT    (COMMIT),
        .MEM_RW    (MEM_RW),
        .DL_WE     (DL_WE),
        .IR_WE     (IR_WE),
        .OP_LO_WE  (OP_LO_WE),
        .OP_HI_WE  (OP_HI_WE),
        .ADDR_SEL  (ADDR_SEL),
        .PC_OP     (PC_OP)
    );

    task pulse_reset;
        begin
            RESET = 1'b1;
            #2;
            RESET = 1'b0;
            #2;
        end
    endtask

    task step;
        begin
            #4 CLK = 1'b1;
            #1 CLK = 1'b0;
            #1;
        end
    endtask

    task check_state;
        input [8*24-1:0] name;
        input             exp_commit;
        input             exp_mem_rw;
        input             exp_dl_we;
        input             exp_ir_we;
        input             exp_lo_we;
        input             exp_hi_we;
        input [1:0]       exp_addr;
        input [1:0]       exp_pc;

        begin
            $display(
                "%0s | STATE=%05b MODE=%02b RW=%b PC_IN=%02b | COMMIT=%b MEM_RW=%b DL_WE=%b IR_WE=%b LO_WE=%b HI_WE=%b ADDR=%02b PC_OP=%02b",
                name,
                {uut.ex, uut.f3, uut.f2, uut.f1, uut.ph},
                MODE,
                RW,
                PC_OP_IN,
                COMMIT,
                MEM_RW,
                DL_WE,
                IR_WE,
                OP_LO_WE,
                OP_HI_WE,
                ADDR_SEL,
                PC_OP
            );

            if ({
                COMMIT,
                MEM_RW,
                DL_WE,
                IR_WE,
                OP_LO_WE,
                OP_HI_WE,
                ADDR_SEL,
                PC_OP
            } !== {
                exp_commit,
                exp_mem_rw,
                exp_dl_we,
                exp_ir_we,
                exp_lo_we,
                exp_hi_we,
                exp_addr,
                exp_pc
            }) begin
                errors = errors + 1;
                $display("ERRO em %0s", name);
            end
        end
    endtask

    initial begin
        $dumpfile("instruction_sequencer.vcd");
        $dumpvars(0, instruction_sequencer_tb);

        CLK      = 1'b0;
        RESET    = 1'b0;
        ENABLE   = 1'b0;
        RW       = 1'b1;
        PC_OP_IN = 2'b00;
        MODE     = 2'b00;

        errors = 0;

        // ENABLE=0
        pulse_reset();

        check_state(
            "DISABLED F0a",
            0, 1, 0, 1, 0, 0, 2'b00, 2'b00
        );

        step();

        check_state(
            "DISABLED HOLD",
            0, 1, 0, 1, 0, 0, 2'b00, 2'b00
        );

        // Implied read
        pulse_reset();

        ENABLE   = 1'b1;
        MODE     = 2'b00;
        RW       = 1'b1;
        PC_OP_IN = 2'b10;

        check_state(
            "IMP F0a",
            0, 1, 0, 1, 0, 0, 2'b00, 2'b00
        );

        step();
        check_state(
            "IMP F0b",
            0, 1, 0, 0, 0, 0, 2'b00, 2'b11
        );

        step();
        check_state(
            "IMP EXa",
            1, 1, 0, 0, 0, 0, 2'b00, 2'b10
        );

        step();
        check_state(
            "IMP F0a RETURN",
            0, 1, 0, 1, 0, 0, 2'b00, 2'b00
        );

        // Indirect read
        pulse_reset();

        ENABLE   = 1'b1;
        MODE     = 2'b01;
        RW       = 1'b1;
        PC_OP_IN = 2'b01;

        step();
        check_state(
            "IND READ F0b",
            0, 1, 0, 0, 0, 0, 2'b00, 2'b11
        );

        step();
        check_state(
            "IND READ F3a",
            0, 1, 1, 0, 0, 0, 2'b10, 2'b00
        );

        step();
        check_state(
            "IND READ EXa",
            1, 1, 0, 0, 0, 0, 2'b00, 2'b01
        );

        step();
        check_state(
            "IND READ RETURN",
            0, 1, 0, 1, 0, 0, 2'b00, 2'b00
        );

        // Indirect write
        pulse_reset();

        ENABLE   = 1'b1;
        MODE     = 2'b01;
        RW       = 1'b0;
        PC_OP_IN = 2'b00;

        step();
        check_state(
            "IND WRITE F0b",
            0, 1, 0, 0, 0, 0, 2'b00, 2'b11
        );

        step();
        check_state(
            "IND WRITE EXa",
            1, 1, 0, 0, 0, 0, 2'b00, 2'b00
        );

        step();
        check_state(
            "IND WRITE EXb",
            0, 0, 0, 0, 0, 0, 2'b10, 2'b00
        );

        step();
        check_state(
            "IND WRITE RETURN",
            0, 1, 0, 1, 0, 0, 2'b00, 2'b00
        );

        // Immediate
        pulse_reset();

        ENABLE   = 1'b1;
        MODE     = 2'b10;
        RW       = 1'b1;
        PC_OP_IN = 2'b01;

        step();
        check_state(
            "IMM F0b",
            0, 1, 0, 0, 0, 0, 2'b00, 2'b11
        );

        step();
        check_state(
            "IMM F1a",
            0, 1, 1, 0, 1, 0, 2'b00, 2'b00
        );

        step();
        check_state(
            "IMM F1b",
            0, 1, 0, 0, 0, 0, 2'b00, 2'b11
        );

        step();
        check_state(
            "IMM EXa",
            1, 1, 0, 0, 0, 0, 2'b00, 2'b01
        );

        // Absolute read
        pulse_reset();

        ENABLE   = 1'b1;
        MODE     = 2'b11;
        RW       = 1'b1;
        PC_OP_IN = 2'b10;

        step();
        check_state(
            "ABS READ F0b",
            0, 1, 0, 0, 0, 0, 2'b00, 2'b11
        );

        step();
        check_state(
            "ABS READ F1a",
            0, 1, 1, 0, 1, 0, 2'b00, 2'b00
        );

        step();
        check_state(
            "ABS READ F1b",
            0, 1, 0, 0, 0, 0, 2'b00, 2'b11
        );

        step();
        check_state(
            "ABS READ F2a",
            0, 1, 1, 0, 0, 1, 2'b00, 2'b00
        );

        step();
        check_state(
            "ABS READ F2b",
            0, 1, 0, 0, 0, 0, 2'b00, 2'b11
        );

        step();
        check_state(
            "ABS READ F3a",
            0, 1, 1, 0, 0, 0, 2'b01, 2'b00
        );

        step();
        check_state(
            "ABS READ EXa",
            1, 1, 0, 0, 0, 0, 2'b00, 2'b10
        );

        // Absolute write
        pulse_reset();

        ENABLE   = 1'b1;
        MODE     = 2'b11;
        RW       = 1'b0;
        PC_OP_IN = 2'b00;

        step();
        step();
        step();
        step();
        step();

        check_state(
            "ABS WRITE F2b",
            0, 1, 0, 0, 0, 0, 2'b00, 2'b11
        );

        step();
        check_state(
            "ABS WRITE EXa",
            1, 1, 0, 0, 0, 0, 2'b00, 2'b00
        );

        step();
        check_state(
            "ABS WRITE EXb",
            0, 0, 0, 0, 0, 0, 2'b01, 2'b00
        );

        step();
        check_state(
            "ABS WRITE RETURN",
            0, 1, 0, 1, 0, 0, 2'b00, 2'b00
        );

        if (errors == 0)
            $display("PASS: todos os testes passaram.");
        else
            $display("FAIL: %0d teste(s) falharam.", errors);

        #10;
        $finish;
    end

endmodule
