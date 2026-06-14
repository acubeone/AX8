/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module full_adder (
    input  a,
    input  b,
    input  cin,
    output y,
    output cout
);
  wire w0, w1, w2, w3, w4;

  // y = a ^ b ^ cin
  xor x0 (w0, a, b);
  xor x1 (y, w0, cin);

  // cout = (a & b) | (cin & (a ^ b))
  and a0 (w1, a, b);
  and a1 (w2, w0, cin);
  or o0 (cout, w1, w2);
endmodule
