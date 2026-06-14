`timescale 1ns / 1ps

module d_latch_tb;
  reg clk, d;
  wire q, nq;

  d_latch dl0 (
      .clk(clk),
      .d  (d),
      .q  (q),
      .nq (nq)
  );

  initial begin
    $dumpfile("d_latch.vcd");
    $dumpvars(0, d_latch_tb);

    // Initial known state
    clk = 1;
    d   = 0;
    #10;

    // verilog_format: off
    clk = 0; d = 0; #10; // q=0, nq=1 (hold D=0)
    clk = 0; d = 1; #10; // q=0, nq=1 (hold D=0, clk isn't active)
    clk = 1; d = 1; #10; // q=1, nq=0 (capture D=1)
    clk = 0; d = 0; #10; // q=0, nq=1 (hold D=1)
    clk = 1; d = 0; #10; // q=0, nq=1 (capture D=0)
    // verilog_format: on

    $finish;
  end

endmodule
