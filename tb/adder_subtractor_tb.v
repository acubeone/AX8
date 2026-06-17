/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module adder_subtractor_tb;
    reg [7:0] a, b;
    reg cin;
    reg m;
    wire [7:0] y;
    wire cout, v;

    adder_subtractor uut (
        .a   (a),
        .b   (b),
        .cin (cin),
        .m   (m),
        .y   (y),
        .cout(cout),
        .v   (v)
    );

    integer errors = 0;
    task automatic check;
        input [7:0] ta, tb;
        input tcin;
        input tm;
        input [7:0] expected_y;
        input expected_cout, expected_v;

        begin
            a   = ta;
            b   = tb;
            cin = tcin;
            m   = tm;
            #10;

            if (y !== expected_y || cout !== expected_cout || v !== expected_v) begin
                $display(
                    "FAIL: a=%h b=%h cin=%b m=%b -> got y=%h cout=%b v=%b, expected y=%h cout=%b v=%b",
                    ta, tb, tcin, tm, y, cout, v, expected_y, expected_cout, expected_v);
                errors = errors + 1;
            end else
                // verilog_format: off
                $display("PASS: a=%h b=%h cin=%b m=%b -> y=%h cout=%b v=%b",
                          ta, tb, tcin, tm, y, cout, v);
                // verilog_format: on
        end
    endtask

    initial begin
        $dumpfile("adder_subtractor.vcd");
        $dumpvars(0, adder_subtractor_tb);

        // verilog_format: off
        // ADD (m=0) - basic
        check(8'h00, 8'h00, 1'b0, 1'b0, 8'h00, 1'b0, 1'b0);  // 0 + 0 = 0
        check(8'h01, 8'h01, 1'b0, 1'b0, 8'h02, 1'b0, 1'b0);  // 1 + 1 = 2
        check(8'h00, 8'h10, 1'b0, 1'b0, 8'h10, 1'b0, 1'b0);  // 0 + 16 = 16
        check(8'hF0, 8'h10, 1'b0, 1'b0, 8'h00, 1'b1, 1'b0);  // carry out
        check(8'hFF, 8'hFF, 1'b0, 1'b0, 8'hFE, 1'b1, 1'b0);  // max + max
        check(8'hFF, 8'hFF, 1'b1, 1'b0, 8'hFF, 1'b1, 1'b0);  // max + max + cin

        // ADD (m=0) - cin
        check(8'h00, 8'h00, 1'b1, 1'b0, 8'h01, 1'b0, 1'b0);  // 0 + 0 + 1 = 1
        check(8'h00, 8'h10, 1'b1, 1'b0, 8'h11, 1'b0, 1'b0);  // 0 + 16 + 1 = 17
        check(8'hF0, 8'h10, 1'b1, 1'b0, 8'h01, 1'b1, 1'b0);  // carry out with cin

        // ADD (m=0) - signed overflow (V=1)
        check(8'h70, 8'h10, 1'b0, 1'b0, 8'h80, 1'b0, 1'b1);  // +112 + +16 = -128 overflow
        check(8'h7F, 8'h01, 1'b0, 1'b0, 8'h80, 1'b0, 1'b1);  // +127 + +1  = -128 overflow
        check(8'h90, 8'h90, 1'b0, 1'b0, 8'h20, 1'b1, 1'b1);  // -112 + -112 = +32 overflow
        check(8'h80, 8'h80, 1'b0, 1'b0, 8'h00, 1'b1, 1'b1);  // -128 + -128 = 0 no overflow

        // ADD (m=0) - no signed overflow
        check(8'h70, 8'h0F, 1'b0, 1'b0, 8'h7F, 1'b0, 1'b0);  // +112 + +15 = +127 no overflow
        check(8'h80, 8'h0E, 1'b0, 1'b0, 8'h8E, 1'b0, 1'b0);  // -128 + +15 = -114 no overflow

        // SUB (m=1) - basic, cin=1 means no borrow
        check(8'h10, 8'h10, 1'b1, 1'b1, 8'h00, 1'b1, 1'b0);  // 16 - 16 = 0
        check(8'h20, 8'h10, 1'b1, 1'b1, 8'h10, 1'b1, 1'b0);  // 32 - 16 = 16
        check(8'hFF, 8'h01, 1'b1, 1'b1, 8'hFE, 1'b1, 1'b0);  // 255 - 1 = 254
        check(8'h00, 8'h01, 1'b1, 1'b1, 8'hFF, 1'b0, 1'b0);  // 0 - 1 = borrow

        // SUB (m=1) - cin=0 means borrow in
        check(8'h10, 8'h10, 1'b0, 1'b1, 8'hFF, 1'b0, 1'b0);  // 16 - 16 - 1 = -1
        check(8'h20, 8'h10, 1'b0, 1'b1, 8'h0F, 1'b1, 1'b0);  // 32 - 16 - 1 = 15

        // SUB (m=1) - signed overflow (V=1)
        check(8'h80, 8'h01, 1'b1, 1'b1, 8'h7F, 1'b1, 1'b1);  // -128 - +1  = +127 overflow
        check(8'h7F, 8'hFF, 1'b1, 1'b1, 8'h80, 1'b0, 1'b1);  // +127 - -1  = -128 overflow

        // SUB (m=1) - no signed overflow
        check(8'h70, 8'h10, 1'b1, 1'b1, 8'h60, 1'b1, 1'b0);  // +112 - +16 = +96
        check(8'h80, 8'h90, 1'b1, 1'b1, 8'hF0, 1'b0, 1'b0);  // -128 - -112 = -16
        // verilog_format: on

        if (errors == 0) $display("ALL TESTS PASSED!");
        else $display("%0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
