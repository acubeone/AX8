/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module mux_2to1 (
    input  s,
    input  a,
    input  b,
    output y
);
  // y = (~s & a) | (s & b)
  wire w0, w1;

  not n0 (ns, s);

  nand na0 (w0, ns, a);  // w0 = ~(~s & a)
  nand na1 (w1, s, b);  // w1 = ~(s & b)

  nand na2 (y, w0, w1);

endmodule
