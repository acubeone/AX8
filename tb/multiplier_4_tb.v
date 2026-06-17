/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module multiplier_4_tb;
  reg [3:0] a, b;
  wire [7:0] y;

  multiplier_4 uut (
      .a(a),
      .b(b),
      .y(y)
  );

  integer errors = 0;
  task automatic check;
    input [3:0] ta, tb;
    input [7:0] expected_y;

    begin
      a = ta;
      b = tb;
      #10;

      if (y !== expected_y) begin
        $display("FAIL: a=%h b=%h -> got y=%h, expected y=%h", ta, tb, y, expected_y);
        errors = errors + 1;
      end else $display("PASS: a=%h b=%h -> y=%h", ta, tb, y);
    end
  endtask

  initial begin
    $dumpfile("multiplier_4.vcd");
    $dumpvars(0, multiplier_4_tb);

    check(4'h0, 4'h0, 8'h00);  // 0  * 0  -> 0
    check(4'h1, 4'h1, 8'h01);  // 1  * 1  -> 1
    check(4'h2, 4'h2, 8'h04);  // 2  * 2  -> 4
    check(4'h3, 4'h3, 8'h09);  // 3  * 3  -> 9
    check(4'hF, 4'h1, 8'h0F);  // 15 * 1  -> 15
    check(4'h1, 4'hF, 8'h0F);  // 1  * 15 -> 15

    check(4'hF, 4'h2, 8'h1E);  // 15 * 2 -> 30
    check(4'hF, 4'h4, 8'h3C);  // 15 * 4 -> 60
    check(4'hF, 4'h8, 8'h78);  // 15 * 8 -> 120
    check(4'h8, 4'h8, 8'h40);  // 8  * 8 -> 64

    check(4'h3, 4'h5, 8'h0F);  // 3 * 5 -> 15
    check(4'h5, 4'h3, 8'h0F);  // 5 * 3 -> 15
    check(4'h6, 4'h7, 8'h2A);  // 6 * 7 -> 42
    check(4'h7, 4'h6, 8'h2A);  // 7 * 6 -> 42

    check(4'hF, 4'h0, 8'h00);  // 15 * 0  -> 0
    check(4'h0, 4'hF, 8'h00);  // 0  * 15 -> 0

    check(4'hF, 4'h1, 8'h0F);  // 15 * 1 -> 15
    check(4'hF, 4'h2, 8'h1E);  // 15 * 2 -> 30
    check(4'hF, 4'h4, 8'h3C);  // 15 * 4 -> 60
    check(4'hF, 4'h8, 8'h78);  // 15 * 8 -> 120

    $finish;
  end

endmodule
