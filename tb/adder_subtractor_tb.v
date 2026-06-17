/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module adder_subtractor_tb;
  reg [7:0] a, b;
  reg cin;
  reg m;
  wire [7:0] y;
  wire cout;

  adder_subtractor uut (
      .a(a),
      .b(b),
      .cin(cin),
      .m(m),
      .y(y),
      .cout(cout)
  );

  integer errors = 0;
  task automatic check;
    input [7:0] ta, tb;
    input tcin;
    input tm;
    input [7:0] expected_y;
    input expected_cout;

    begin
      a   = ta;
      b   = tb;
      cin = tcin;
      m   = tm;
      #10;

      if (y !== expected_y || cout !== expected_cout) begin
        $display("FAIL: a=%h b=%h cin=%b m=%b -> got y=%h cout=%b, expected y=%h cout=%b", ta, tb,
                 tcin, tm, y, cout, expected_y, expected_cout);
        errors = errors + 1;
      end else $display("PASS: a=%h b=%h cin=%b m=%b -> y=%h cout=%b", ta, tb, tcin, tm, y, cout);
    end
  endtask

  initial begin
    $dumpfile("adder_subtractor_8.vcd");
    $dumpvars(0, adder_subtractor_8_tb);

    check(8'h96, 8'h4B, 1'b0, 1'b0, 8'hE1, 0);  // ADD: 0x96 + 0x4B + C=0 -> 0xE1, C=0
    check(8'hC8, 8'h64, 1'b0, 1'b0, 8'h2C, 1);  // ADD: 0xC8 + 0x64 + C=0 -> 0x2C, C=1
    check(8'hFF, 8'hFF, 1'b0, 1'b0, 8'hFE, 1);  // ADD: 0xFF + 0xFF + C=0 -> 0xFE, C=1

    check(8'hB4, 8'h3C, 1'b1, 1'b1, 8'h78, 1);  // SUB: 0xB4 - 0x3C - (~C=1) -> 0x78, C=1
    check(8'h2A, 8'h2A, 1'b1, 1'b1, 8'h00, 1);  // SUB: 0x2A - 0x2A - (~C=1) -> 0x00, C=1
    check(8'h32, 8'h78, 1'b0, 1'b1, 8'hB9, 0);  // SUB: 0x32 - 0x78 - (~C=0) -> 0xB9, C=0

    if (errors == 0) $display("ALL TESTS PASSED!");
    else $display("%0d TEST(S) FAILED", errors);

    $finish;
  end

endmodule
