/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module ripple_adder_4 (
    input [3:0] a,
    input [3:0] b,
    input cin,
    output [3:0] y,
    output cout
);
  wire [4:0] carry;

  assign carry[0] = cin;
  assign cout = carry[4];

  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : gen_adder
      full_adder fa0 (
          .a(a[i]),
          .b(b[i]),
          .cin(carry[i]),
          .y(y[i]),
          .cout(carry[i+1])
      );
    end
  endgenerate
endmodule
