/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module alu_tb;
    reg [7:0] a, b;
    reg [3:0] op;
    reg cin, vin;
    wire [7:0] y;
    wire z, n, c, v;
    wire halt;

    alu uut (
        .a   (a),
        .b   (b),
        .op  (op),
        .cin (cin),
        .vin (vin),
        .y   (y),
        .z   (z),
        .n   (n),
        .c   (c),
        .v   (v),
        .halt(halt)
    );

    integer errors = 0;
    task automatic check;
        input [7:0] ta, tb;
        input [3:0] top;
        input tcin, tvin;
        input [7:0] expected_y;
        input expected_z, expected_n, expected_c, expected_v;

        begin
            a = ta;
            b = tb;
            op = top;
            cin = tcin;
            vin = tvin;
            #10;

            // verilog_format: off
            if (halt)
                $display("HALT: op=%b a=%h b=%h cin=%b vin=%b", top, ta, tb, tcin, tvin);
            else if (y !== expected_y || z !== expected_z || n !== expected_n || c !== expected_c ||
                v !== expected_v) begin
                $display(
                    "FAIL: op=%b a=%h b=%h cin=%b vin=%b -> got y=%h z=%b n=%b c=%b v=%b, expected y=%h z=%b n=%b c=%b v=%b",
                    top, ta, tb, tcin, tvin, y, z, n, c, v, expected_y, expected_z, expected_n,
                    expected_c, expected_v);
                errors = errors + 1;
            end else
                $display(
                    "PASS: op=%b a=%h b=%h cin=%b vin=%b -> y=%h z=%b n=%b c=%b v=%b",
                    top, ta, tb, tcin, tvin, y, z, n, c, v);
            // verilog_format: on
        end
    endtask

    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, alu_tb);

        // verilog_format: off
        // ===== ADC (op=0000) =====
        check(8'h05, 8'h03, 4'b0000, 1'b0, 1'b0, 8'h08, 1'b0, 1'b0, 1'b0, 1'b0);  // 5+3=8
        check(8'hFF, 8'h01, 4'b0000, 1'b0, 1'b0, 8'h00, 1'b1, 1'b0, 1'b1, 1'b0);  // carry out, Z=1
        check(8'h70, 8'h10, 4'b0000, 1'b0, 1'b0, 8'h80, 1'b0, 1'b1, 1'b0, 1'b1);  // signed overflow

        // ===== SBC (op=0001) =====
        check(8'h10, 8'h10, 4'b0001, 1'b1, 1'b0, 8'h00, 1'b1, 1'b0, 1'b1, 1'b0);  // 16-16=0, C=1(no borrow)
        check(8'h00, 8'h01, 4'b0001, 1'b1, 1'b0, 8'hFF, 1'b0, 1'b1, 1'b0, 1'b0);  // borrow
        check(8'h80, 8'h01, 4'b0001, 1'b1, 1'b0, 8'h7F, 1'b0, 1'b0, 1'b1, 1'b1);  // signed overflow

        // ===== MUL (op=0010) =====
        check(8'h03, 8'h05, 4'b0010, 1'b0, 1'b0, 8'h0F, 1'b0, 1'b0, 1'b0, 1'b0);  // 3*5=15, no overflow
        check(8'h0F, 8'h0F, 4'b0010, 1'b0, 1'b0, 8'hE1, 1'b0, 1'b1, 1'b0, 1'b1);  // 15*15=225, overflow

        // ===== AND (op=0011) =====
        check(8'hFF, 8'h0F, 4'b0011, 1'b0, 1'b0, 8'h0F, 1'b0, 1'b0, 1'b0, 1'b0);  // mask
        check(8'hAA, 8'h55, 4'b0011, 1'b0, 1'b0, 8'h00, 1'b1, 1'b0, 1'b0, 1'b0);  // result=0, Z=1

        // ===== OR (op=0100) =====
        check(8'hF0, 8'h0F, 4'b0100, 1'b0, 1'b0, 8'hFF, 1'b0, 1'b1, 1'b0, 1'b0);  // N=1 (Y[7]=1)
        check(8'h00, 8'h00, 4'b0100, 1'b0, 1'b0, 8'h00, 1'b1, 1'b0, 1'b0, 1'b0);  // Z=1

        // ===== XOR (op=0101) =====
        check(8'hFF, 8'hFF, 4'b0101, 1'b0, 1'b0, 8'h00, 1'b1, 1'b0, 1'b0, 1'b0);  // self-xor=0
        check(8'hAA, 8'h55, 4'b0101, 1'b0, 1'b0, 8'hFF, 1'b0, 1'b1, 1'b0, 1'b0);  // N=1

        // ===== ROL (op=0110) =====
        check(8'h81, 8'h00, 4'b0110, 1'b0, 1'b0, 8'h02, 1'b0, 1'b0, 1'b1, 1'b0);  // A[7]=1 falls to C
        check(8'h00, 8'h00, 4'b0110, 1'b1, 1'b0, 8'h01, 1'b0, 1'b0, 1'b0, 1'b0);  // Cin fills LSB

        // ===== ROR (op=0111) =====
        check(8'h01, 8'h00, 4'b0111, 1'b0, 1'b0, 8'h00, 1'b1, 1'b0, 1'b1, 1'b0);  // A[0]=1 falls to C, Z=1
        check(8'h00, 8'h00, 4'b0111, 1'b1, 1'b0, 8'h80, 1'b0, 1'b1, 1'b0, 1'b0);  // Cin fills MSB

        // ===== MOV (op=1000) =====
        check(8'hAA, 8'h7F, 4'b1000, 1'b1, 1'b1, 8'h7F, 1'b0, 1'b0, 1'b1, 1'b1);  // Y=B, C/V unchanged
        check(8'h00, 8'h00, 4'b1000, 1'b0, 1'b1, 8'h00, 1'b1, 1'b0, 1'b0, 1'b1);  // Z=1, C/V unchanged

        // ===== HALT cases (op[3]=1, op[2:0] != 000) =====
        check(8'h00, 8'h00, 4'b1001, 1'b0, 1'b0, 8'hxx, 1'bx, 1'bx, 1'bx, 1'bx);  // expect halt=1
        check(8'h00, 8'h00, 4'b1111, 1'b0, 1'b0, 8'hxx, 1'bx, 1'bx, 1'bx, 1'bx);  // expect halt=1
        // verilog_format: on

        if (errors == 0) $display("ALL TESTS PASSED!");
        else $display("%0d TEST(S) FAILED", errors);
        $finish;
    end
endmodule
