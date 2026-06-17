/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module multiplier_4_tb;
    reg [3:0] a, b;
    wire [7:0] y;
    wire v;

    multiplier_4 uut (
        .a(a),
        .b(b),
        .y(y),
        .v(v)
    );

    integer errors = 0;
    task automatic check;
        input [3:0] ta, tb;
        input [7:0] expected_y;
        input expected_v;

        begin
            a = ta;
            b = tb;
            #10;

            if (y !== expected_y || v !== expected_v) begin
                $display("FAIL: a=%h b=%h -> got y=%h v=%b, expected y=%h v=%b", ta, tb,
                         y, v, expected_y, expected_v);
                errors = errors + 1;
            end else $display("PASS: a=%h b=%h -> y=%h v=%b", ta, tb, y, v);
        end
    endtask

    initial begin
        $dumpfile("multiplier_4.vcd");
        $dumpvars(0, multiplier_4_tb);

        // V = 0 (result <= 0x0F, fits in nibble)
        check(4'h0, 4'h0, 8'h00, 1'b0);  // 0  * 0  = 0
        check(4'h1, 4'h1, 8'h01, 1'b0);  // 1  * 1  = 1
        check(4'h2, 4'h2, 8'h04, 1'b0);  // 2  * 2  = 4
        check(4'h3, 4'h3, 8'h09, 1'b0);  // 3  * 3  = 9
        check(4'h1, 4'hF, 8'h0F, 1'b0);  // 1  * 15 = 15  (boundary, no overflow)
        check(4'hF, 4'h1, 8'h0F, 1'b0);  // 15 * 1  = 15  (boundary, no overflow)
        check(4'h3, 4'h5, 8'h0F, 1'b0);  // 3  * 5  = 15  (boundary, no overflow)
        check(4'h5, 4'h3, 8'h0F, 1'b0);  // 5  * 3  = 15  (commutativity)
        check(4'hF, 4'h0, 8'h00, 1'b0);  // 15 * 0  = 0
        check(4'h0, 4'hF, 8'h00, 1'b0);  // 0  * 15 = 0

        // V = 1 (result > 0x0F, overflow)
        check(4'h2, 4'h8, 8'h10, 1'b1);  // 2  * 8  = 16  (first overflow)
        check(4'hF, 4'h2, 8'h1E, 1'b1);  // 15 * 2  = 30
        check(4'hF, 4'h4, 8'h3C, 1'b1);  // 15 * 4  = 60
        check(4'hF, 4'h8, 8'h78, 1'b1);  // 15 * 8  = 120
        check(4'h8, 4'h8, 8'h40, 1'b1);  // 8  * 8  = 64
        check(4'h6, 4'h7, 8'h2A, 1'b1);  // 6  * 7  = 42
        check(4'h7, 4'h6, 8'h2A, 1'b1);  // 7  * 6  = 42  (commutativity)
        check(4'hF, 4'hF, 8'hE1, 1'b1);  // 15 * 15 = 225 (maximum)
        check(4'hF, 4'hE, 8'hD2, 1'b1);  // 15 * 14 = 210
        check(4'hE, 4'hF, 8'hD2, 1'b1);  // 14 * 15 = 210 (commutativity)

        $finish;
    end

endmodule
