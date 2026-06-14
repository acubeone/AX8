/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module full_adder_tb;
  reg a, b, cin;
  wire y, cout;

  full_adder fa0 (
      .a(a),
      .b(b),
      .cin(cin),
      .y(y),
      .cout(cout)
  );

  initial begin
    $dumpfile("full_adder.vcd");
    $dumpvars(0, full_adder_tb);

    // verilog_format: off
    a = 0; b = 0; cin = 0; #10;
    a = 0; b = 0; cin = 1; #10;
    a = 0; b = 1; cin = 0; #10;
    a = 0; b = 1; cin = 1; #10;
    a = 1; b = 0; cin = 0; #10;
    a = 1; b = 0; cin = 1; #10;
    a = 1; b = 1; cin = 0; #10;
    a = 1; b = 1; cin = 1; #10;
    // verilog_format: on

    $finish;
  end

endmodule
