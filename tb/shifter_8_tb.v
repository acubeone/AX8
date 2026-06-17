/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module shifter_8_tb;
    reg [7:0] a;
    reg cin;
    reg m;
    wire [7:0] y;
    wire cout;

    shifter_8 uut (
        .a   (a),
        .cin (cin),
        .m   (m),
        .y   (y),
        .cout(cout)
    );

    integer errors = 0;
    task automatic check;
        input [7:0] ta;
        input tcin;
        input tm;
        input [7:0] expected_y;
        input expected_cout;

        begin
            a   = ta;
            cin = tcin;
            m   = tm;
            #10;

            if (y !== expected_y || cout !== expected_cout) begin
                $display(
                    "FAIL: a=%h cin=%b m=%b -> got y=%h cout=%b, expected y=%h cout=%b",
                    ta, tcin, tm, y, cout, expected_y, expected_cout);
                errors = errors + 1;
            end else
                $display("PASS: a=%h cin=%b m=%b -> y=%h cout=%b", ta, tcin, tm, y, cout);
        end
    endtask


    initial begin
        $dumpfile("shifter_8.vcd");
        $dumpvars(0, shifter_8_tb);

        // verilog_format: off
        // ROL (m=0, Cin=0)
        check(8'b0000_0001, 1'b0, 1'b0, 8'b0000_0010, 1'b0);
        check(8'b1000_0000, 1'b0, 1'b0, 8'b0000_0000, 1'b1);
        check(8'b1111_1111, 1'b0, 1'b0, 8'b1111_1110, 1'b1);
        check(8'b1010_1010, 1'b0, 1'b0, 8'b0101_0100, 1'b1);

        // ROL (m=0, Cin=1)
        check(8'b0000_0001, 1'b1, 1'b0, 8'b0000_0011, 1'b0);
        check(8'b1000_0000, 1'b1, 1'b0, 8'b0000_0001, 1'b1);
        check(8'b1111_1111, 1'b1, 1'b0, 8'b1111_1111, 1'b1);
        check(8'b1010_1010, 1'b1, 1'b0, 8'b0101_0101, 1'b1);

        // ROR (m=1, Cin=0)
        check(8'b0000_0001, 1'b0, 1'b1, 8'b0000_0000, 1'b1);
        check(8'b1000_0000, 1'b0, 1'b1, 8'b0100_0000, 1'b0);
        check(8'b1111_1111, 1'b0, 1'b1, 8'b0111_1111, 1'b1);
        check(8'b1010_1010, 1'b0, 1'b1, 8'b0101_0101, 1'b0);

        // ROR (m=1, Cin=1)
        check(8'b0000_0001, 1'b1, 1'b1, 8'b1000_0000, 1'b1);
        check(8'b1000_0000, 1'b1, 1'b1, 8'b1100_0000, 1'b0);
        check(8'b1111_1111, 1'b1, 1'b1, 8'b1111_1111, 1'b1);
        check(8'b1010_1010, 1'b1, 1'b1, 8'b1101_0101, 1'b0);
        // verilog_format: on

        if (errors == 0) $display("ALL TESTS PASSED!");
        else $display("%0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
