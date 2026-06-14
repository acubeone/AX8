/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module d_flipflop (
    input  clk,
    input  d,
    output q,
    output nq
);
  wire nclk;
  wire mq;

  not n0 (nclk, clk);  // !clk

  // Master: when CLK=0, locks on rising edge
  d_latch master (
      .clk(nclk),
      .d  (d),
      .q  (mq),
      .nq ()
  );

  // Slave: when CLK=1, captures master on rising edge
  d_latch slave (
      .clk(clk),
      .d  (mq),
      .q  (q),
      .nq (nq)
  );
endmodule
