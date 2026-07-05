`timescale 1ns / 1ps

module sequencer_tb;

    reg        clk;
    reg        reset;
    reg        enable;
    reg        rw;
    reg  [1:0] pc_op_in;
    reg  [1:0] mode;

    wire       commit;
    wire       mem_re;
    wire       mem_we;
    wire       dl_we;
    wire       ir_we;
    wire       op_lo_we;
    wire       op_hi_we;
    wire [1:0] addr_sel;
    wire [1:0] pc_op;

    sequencer uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .rw(rw),
        .pc_op_in(pc_op_in),
        .mode(mode),
        .commit(commit),
        .mem_re(mem_re),
        .mem_we(mem_we),
        .dl_we(dl_we),
        .ir_we(ir_we),
        .op_lo_we(op_lo_we),
        .op_hi_we(op_hi_we),
        .addr_sel(addr_sel),
        .pc_op(pc_op)
    );

    task print_state;
        begin
            $display("t=%0t | mode=%b rw=%b | PH=%b F1=%b F2=%b F3=%b EX=%b | commit=%b mem_re=%b mem_we=%b dl_we=%b ir_we=%b op_lo=%b op_hi=%b addr=%b pc_op=%b",
                     $time, mode, rw,
                     uut.ph, uut.f1, uut.f2, uut.f3, uut.ex,
                     commit, mem_re, mem_we, dl_we, ir_we, op_lo_we, op_hi_we,
                     addr_sel, pc_op);
        end
    endtask

    task tick;
        begin
            #5 clk = 1;
            #5 clk = 0;
            #1 print_state();
        end
    endtask

    task run_case;
        input [1:0] case_mode;
        input       case_rw;
        input [1:0] case_pc_op_in;
        integer k;
        begin
            reset    = 1;
            enable   = 1;
            rw       = case_rw;
            pc_op_in = case_pc_op_in;
            mode     = case_mode;
            clk      = 0;

            #2;
            reset = 0;

            $display("");
            $display("==============================================================");
            $display("Novo caso: mode=%b rw=%b pc_op_in=%b", mode, rw, pc_op_in);
            $display("==============================================================");

            print_state();

            for (k = 0; k < 10; k = k + 1) begin
                tick();
            end
        end
    endtask

    initial begin
        $dumpfile("sequencer.vcd");
        $dumpvars(0, sequencer_tb);

        clk      = 0;
        reset    = 0;
        enable   = 1;
        rw       = 0;
        pc_op_in = 2'b00;
        mode     = 2'b00;

        /*
            mode:
            00 -> IS_JMP
            01 -> IS_IND
            10 -> IS_IMM
            11 -> IS_ABS
        */

        // JMP: deve ir F0a -> F0b -> EX
        run_case(2'b00, 1'b0, 2'b10);

        // IND leitura: deve passar por F3a/F3b antes de EX
        run_case(2'b01, 1'b0, 2'b00);

        // IMM: deve passar por F1a/F1b antes de EX
        run_case(2'b10, 1'b0, 2'b00);

        // ABS leitura: deve passar por F1, F2 e F3 antes de EX
        run_case(2'b11, 1'b0, 2'b00);

        // ABS escrita: em F3a deve gerar MEM_WE e ir para EX
        run_case(2'b11, 1'b1, 2'b00);

        $finish;
    end

endmodule
