/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module register_8_tb;
  reg clk, we;
  reg [7:0] d;
  reg [7:0] q;

  register_8 uut (
      .clk(clk),
      .we (we),
      .d  (d),
      .q  (q)
  );

  initial clk = 0;
  always #10 clk = ~clk;

  integer errors = 0;
  task automatic check;
    input [7:0] expected_q;

    begin
      if (q !== expected_q) begin
        $display("FAIL: we=%b d=%h -> got q=%h, expected q=%h", we, d, q, expected_q);
        errors = errors + 1;
      end else $display("PASS: we=%b d=%h -> q=%h", we, d, q);
    end
  endtask

  initial begin
    $dumpfile("register_8.vcd");
    $dumpvars(0, register_8_tb);

    // verilog_format: off
    we = 1'b1; d = 8'h00; // initial known state
    @(posedge clk); #1;
    check(8'h00);

    d = 8'hAB;
    @(posedge clk); #1;
    check(8'hAB);

    we = 1'b0; d = 8'hFF; // write-enable is low, no write is done
    @(posedge clk); #1;
    check(8'hAB);

    d = 8'h00; // write-enable still low
    @(posedge clk); #1;
    check(8'hAB);

    we = 1'b1; d = 8'h42;
    @(posedge clk); #1;
    check(8'h42);

    // WE changes while CLK=1 must not affect Q until next rising edge
    d = 8'hFF; #5;
    check(8'h42);
    @(posedge clk); #1;
    check(8'hFF); // Captured now

    d = 8'h00; // Check stale values
    @(posedge clk); #1;
    check(8'h00);

    we = 1'b0; d = 8'hAA; // Q will never be 0xAA
    @(posedge clk); #1;
    check(8'h00);
    // verilog_format: on

    if (errors == 0) $display("ALL TESTS PASSED!");
    else $display("%0d TEST(S) FAILED", errors);

    $finish;
  end



endmodule
