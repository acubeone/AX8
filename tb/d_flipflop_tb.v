/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module d_flipflop_tb;
  reg clk, d;
  wire q, nq;

  d_flipflop uut (
      .clk(clk),
      .d  (d),
      .q  (q),
      .nq (nq)
  );

  initial clk = 1'b0;
  always #10 clk = ~clk;

  integer errors = 0;
  task automatic check;
    input expected_q;
    input expected_nq;

    begin
      if (q !== expected_q || nq !== expected_nq) begin
        $display("FAIL: d=%b clk=%b -> got q=%b nq=%b, expected q=%b nq=%b", d, clk, q, nq,
                 expected_q, expected_nq);
        errors = errors + 1;
      end else $display("PASS: d=%b clk=%b -> q=%b nq=%b", d, clk, q, nq);
    end
  endtask

  initial begin
    $dumpfile("d_flipflop.vcd");
    $dumpvars(0, d_flipflop_tb);

    // verilog_format: off
    // Initial known state
    d = 1'b0;
    @(posedge clk); #1 // Wait for rising edge
    check(1'b0, 1'b1); // q=0, nq=1

    d = 1'b1; #5; // CLK still high, Q must stay 0
    check(1'b0, 1'b1); // q=0, nq=1 (latch is locked)
    @(posedge clk); #1 // next rising edge captures D=1
    check(1'b1, 1'b0); // q=1, nq=0

    d = 1'b0; #5; // CLK still high, Q must stay 1
    check(1'b1, 1'b0); // q=1, nq=0 (latch is locked)
    @(posedge clk); #1 // next rising edge captures D=0
    check(1'b0, 1'b1); // q=0, nq=1

    // Fast D changes between edges does nothing. Only last state is matters
    @(negedge clk);
    d = 1'b1; #3;
    d = 1'b0; #3;
    d = 1'b1; #3;
    @(posedge clk); #1;
    check(1'b1, 1'b0); // q=1, nq=0
    // verilog_format: on

    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("%0d TEST(S) FAILED", errors);

    $finish;
  end

endmodule
