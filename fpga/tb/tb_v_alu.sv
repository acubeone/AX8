`include "utils.svh"

module tb_v_alu;
    logic       clk = 0;
    logic       rst_n = 1;
    logic [1:0] phase;
    logic [1:0] op;
    logic [7:0] in_a, in_b;

    logic [7:0] in_q, in_m;
    logic [8:0] in_acc;

    logic z_flag, n_flag, dbz_flag, abort;
    logic [8:0] out_acc;
    logic [7:0] out_m, out_q;

    v_alu uut (.*);

    // Models the sequencer's register file: in_q/in_m/in_acc are only
    // updated on the clock edge, feeding back out_* into in_* each cycle.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            in_q   <= 8'h00;
            in_m   <= 8'h00;
            in_acc <= 9'h000;
        end else begin
            in_q   <= out_q;
            in_m   <= out_m;
            in_acc <= out_acc;
        end
    end

    task automatic tick;
        #10 clk = 1;
        #10 clk = 0;
    endtask

    // Normal check: compares final {acc, q} against an expected value.
    task automatic drive;
        input logic [1:0] t_op;
        input logic [7:0] t_a;
        input logic [7:0] t_b;
        input logic [7:0] exp_q;
        input logic [8:0] exp_acc;

        logic [MAXWIDTH-1:0] gotbits, expbits;

        rst_n = 0;
        op    = t_op;
        in_a  = t_a;
        in_b  = t_b;
        phase = 2'b00;  // LOAD
        #10 rst_n = 1;

        #1;  // let LOAD-phase combinational logic settle before sampling abort

        if (abort) begin
            tick();  // capture LOAD's already-assembled result into in_q/in_acc
        end else begin
            tick();  // capture load_q/load_m -> in_q/in_m, in_acc=0

            phase = 2'b01;  // RUN
            for (int i = 0; i < 8; i++) tick();

            phase = 2'b10;  // CORRECT
            tick();
        end

        gotbits = MAXWIDTH'({in_acc, in_q});
        expbits = MAXWIDTH'({exp_acc, exp_q});
        check($sformatf("op=%b a=%h b=%h", t_op, t_a, t_b), gotbits, expbits, $bits(
              expbits));
    endtask

    // Divide-by-zero check: only dbz_flag is defined behavior here —
    // out_q/out_acc are not asserted, since the sequencer is expected
    // to trap before ever reaching RUN/CORRECT in this case.
    task automatic drive_dbz;
        input logic [1:0] t_op;
        input logic [7:0] t_a;
        input logic [7:0] t_b;

        rst_n = 0;
        op    = t_op;
        in_a  = t_a;
        in_b  = t_b;
        phase = 2'b00;  // LOAD
        #10 rst_n = 1;

        #1;  // let LOAD-phase combinational logic settle

        if (dbz_flag !== 1'b1)
            $display(
                "FAIL: op=%b a=%h b=%h dbz expected=1 got=%b", t_op, t_a, t_b, dbz_flag
            );
        else $display("PASS: op=%b a=%h b=%h dbz=1", t_op, t_a, t_b);

        tick();  // let the cycle settle before the next drive() call starts fresh
    endtask

    initial begin
        $dumpfile("v_alu.vcd");
        $dumpvars(0, tb_v_alu);

        // op: 00=MULU 01=DIVU 10=MULS 11=DIVS
        drive(2'b00, 8'h05, 8'h03, 8'h0F, 9'h000);  // MULU 5*3=15
        drive(2'b00, 8'hFF, 8'hFF, 8'h01, 9'h0FE);  // MULU 255*255=0xFE01
        drive(2'b01, 8'h0D, 8'h03, 8'h04, 9'h001);  // DIVU 13/3 -> q=4 r=1
        drive(2'b01, 8'h02, 8'h05, 8'h00, 9'h002);  // DIVU abort: 2<5 -> q=0 r=2
        drive(2'b10, 8'hFE, 8'h05, 8'hF6, 9'h1FF);  // MULS -2*5=-10=0xFFF6
        drive(2'b10, 8'h7F, 8'hFE, 8'h02, 9'h1FF);  // MULS 127*-2=-254=0xFF02
        drive(2'b11, 8'hF3, 8'h03, 8'hFC, 9'h1FF);  // DIVS -13/3 -> q=-4 r=-1
        drive(2'b11, 8'h0D, 8'hFD, 8'hFC, 9'h001);  // DIVS 13/-3 -> q=-4 r=1

        drive_dbz(2'b01, 8'h0A, 8'h00);  // DIVU by zero -> dbz_flag only

        report();
        $finish;
    end
endmodule
