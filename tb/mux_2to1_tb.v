/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module mux_2to1_tb;
  reg s, a, b;
  wire y;

  mux_2to1 uut (
      .s(s),
      .a(a),
      .b(b),
      .y(y)
  );

  initial begin
    $dumpfile("mux_2to1.vcd");
    $dumpvars(0, mux_2to1_tb);

    // verilog_format: off
    s = 1'b0; a = 1'b0; b = 1'b0; #10 // a=0, b=0, y=a -> 0
    s = 1'b0; a = 1'b0; b = 1'b1; #10 // a=0, b=1, y=a -> 0
    s = 1'b0; a = 1'b1; b = 1'b0; #10 // a=1, b=0, y=a -> 1
    s = 1'b0; a = 1'b1; b = 1'b1; #10 // a=1, b=1, y=a -> 1

    s = 1'b1; a = 1'b0; b = 1'b0; #10 // a=0, b=0, y=b -> 0
    s = 1'b1; a = 1'b0; b = 1'b1; #10 // a=0, b=1, y=b -> 1
    s = 1'b1; a = 1'b1; b = 1'b0; #10 // a=1, b=0, y=b -> 0
    s = 1'b1; a = 1'b1; b = 1'b1; #10 // a=1, b=1, y=b -> 1
    // verilog_format: on

    $finish;
  end

endmodule
