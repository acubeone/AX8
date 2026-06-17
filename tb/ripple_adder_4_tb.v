/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module ripple_adder_4_tb;
    reg [3:0] a, b;
    reg cin;
    wire [3:0] y;
    wire cout;

    ripple_adder_4 uut (
        .a(a),
        .b(b),
        .cin(cin),
        .y(y),
        .cout(cout)
    );

    integer errors = 0;
    task automatic check;
        input [3:0] ta, tb;
        input tcin;
        input [3:0] expected_y;
        input expected_cout;

        begin
            a   = ta;
            b   = tb;
            cin = tcin;
            #10;

            if (y !== expected_y || cout !== expected_cout) begin
                $display("FAIL: a=%h b=%h cin=%b -> got y=%h cout=%b, expected y=%h cout=%b", ta,
                         tb, tcin, y, cout, expected_y, expected_cout);
                errors = errors + 1;
            end else $display("PASS: a=%h b=%h cin=%b -> y=%h cout=%b", ta, tb, tcin, y, cout);
        end
    endtask

    initial begin
        $dumpfile("ripple_adder_4.vcd");
        $dumpvars(0, ripple_adder_4_tb);

        check(4'h0, 4'h0, 1'b0, 4'h0, 1'b0);  // 0 + 0, C=0 -> 0, C=0
        check(4'h0, 4'h1, 1'b0, 4'h1, 1'b0);  // 0 + 1, C=0 -> 1, C=0
        check(4'hf, 4'h1, 1'b0, 4'h0, 1'b1);  // f + 1, C=0 -> 0, C=1

        check(4'h0, 4'h0, 1'b1, 4'h1, 1'b0);  // 0 + 0, C=1 -> 1, C=0
        check(4'h0, 4'h1, 1'b1, 4'h2, 1'b0);  // 0 + 1, C=1 -> 2, C=0
        check(4'hf, 4'h1, 1'b1, 4'h1, 1'b1);  // f + 1, C=1 -> 1, C=1

        check(4'hf, 4'hf, 1'b0, 4'he, 1'b1);  // f + f, C=0 -> e, C=1
        check(4'hf, 4'hf, 1'b1, 4'hf, 1'b1);  // f + f, C=1 -> f, C=1

        if (errors == 0) $display("ALL TESTS PASSED!");
        else $display("%0d TEST(S) FAILED", errors);

        $finish;
    end
endmodule
