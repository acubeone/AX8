`timescale 1ns / 1ps

module d_latch (
    input  clk,
    input  d,
    output q,
    output nq
);
  wire nd;  // !d
  wire set, reset;

  not n0 (nd, d);

  nand na0 (set, clk, d);  // set = !(d & clk)
  nand na1 (reset, clk, nd);  // reset = !(!d & clk)

  // SR-Latch
  nand na2 (q, set, nq);
  nand na3 (nq, reset, q);
endmodule
