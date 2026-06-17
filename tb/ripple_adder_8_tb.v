/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module ripple_adder_8_tb;
    reg [7:0] a, b;
    reg cin;
    wire [7:0] y;
    wire cout;

    ripple_adder_8 uut (
        .a   (a),
        .b   (b),
        .cin (cin),
        .y   (y),
        .cout(cout),
        .c6  ()
    );

    integer errors = 0;
    task automatic check;
        input [7:0] ta, tb;
        input tcin;
        input [7:0] expected_y;
        input expected_cout;

        begin
            a   = ta;
            b   = tb;
            cin = tcin;
            #10;

            if (y !== expected_y || cout !== expected_cout) begin
                $display(
                    "FAIL: a=%h b=%h cin=%b -> got y=%h cout=%b, expected y=%h cout=%b",
                    ta, tb, tcin, y, cout, expected_y, expected_cout);
                errors = errors + 1;
            end else
                $display("PASS: a=%h b=%h cin=%b -> y=%h cout=%b", ta, tb, tcin, y, cout);
        end
    endtask

    initial begin
        $dumpfile("ripple_adder_8.vcd");
        $dumpvars(0, ripple_adder_8_tb);


        check(8'h00, 8'h00, 1'b0, 8'h00, 1'b0);  // 00 + 0, C=00 -> 00, C=0
        check(8'h00, 8'h10, 1'b0, 8'h10, 1'b0);  // 00 + 1, C=00 -> 10, C=0
        check(8'hf0, 8'h10, 1'b0, 8'h00, 1'b1);  // f0 + 1, C=00 -> 00, C=1

        check(8'h00, 8'h00, 1'b1, 8'h01, 1'b0);  // 00 + 00, C=1 -> 01, C=0
        check(8'h00, 8'h10, 1'b1, 8'h11, 1'b0);  // 00 + 10, C=1 -> 11, C=0
        check(8'hf0, 8'h10, 1'b1, 8'h01, 1'b1);  // f0 + 10, C=1 -> 01, C=1

        check(8'hff, 8'hff, 1'b0, 8'hfe, 1'b1);  // ff + ff, C=0 -> fe, C=1
        check(8'hff, 8'hff, 1'b1, 8'hff, 1'b1);  // ff + ff, C=1 -> ff, C=1

        if (errors == 0) $display("ALL TESTS PASSED!");
        else $display("%0d TEST(S) FAILED", errors);

        $finish;
    end
endmodule
