/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module adder_subtractor (
    input [7:0] a,
    input [7:0] b,
    input cin,
    input m,
    output [7:0] y,
    output cout
);
  // b_in = (m & !b) | (!m & b)
  //      = m ^ b
  wire [7:0] b_in;

  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : gen_mode
      xor xn (b_in[i], m, b[i]);
    end
  endgenerate

  ripple_adder_8 ra0 (
      .a(a),
      .b(b_in),
      .cin(cin),
      .y(y),
      .cout(cout)
  );

endmodule
