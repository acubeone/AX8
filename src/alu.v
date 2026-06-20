/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module alu (
    // verilog_format: off
    input  [7:0] a, b,
    input  [3:0] op,
    input        cin, vin,
    output [7:0] y,
    output       z, n, c, v,
    output       halt
    // verilog_format: on
);
    wire [7:0] y_adder, y_mul, y_and, y_or, y_xor, y_shift, y_mov;
    wire c_adder, c_shift;
    wire v_adder, v_mul;
    wire [7:0] y_out;
    wire c_out, v_out, halt_out;

    // Units:
    adder_subtractor u_adder (
        .a   (a),
        .b   (b),
        .cin (cin),
        .m   (op[0]),
        .y   (y_adder),
        .cout(c_adder),
        .v   (v_adder)
    );
    multiplier_4 u_mul (
        .a(a[3:0]),
        .b(b[3:0]),
        .y(y_mul),
        .v(v_mul)
    );

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_logic
            and u_and (y_and[i], a[i], b[i]);
            or u_or (y_or[i], a[i], b[i]);
            xor u_xor (y_xor[i], a[i], b[i]);

            buf u_mov (y_mov[i], b[i]);
        end
    endgenerate

    shifter_8 u_shifter (
        .a   (a),
        .cin (cin),
        .m   (op[0]),
        .y   (y_shift),
        .cout(c_shift)
    );

    // Decoding:
    genvar j;
    generate
        for (j = 0; j < 8; j = j + 1) begin : gen_decode_y
            mux_8to1 muxn_8to1 (
                .sel(op[2:0]),
                .in0(y_adder[j]),  // ADC
                .in1(y_adder[j]),  // SBC
                .in2(y_mul[j]),    // MUL
                .in3(y_and[j]),    // AND
                .in4(y_or[j]),     // OR
                .in5(y_xor[j]),    // XOR
                .in6(y_shift[j]),  // ROL
                .in7(y_shift[j]),  // ROR
                .y  (y_out[j])
            );

            mux_2to1 muxn_2to1 (
                .sel(op[3]),
                .in0(y_out[j]),
                .in1(y_mov[j]),
                .y  (y[j])
            );
        end
    endgenerate

    // Generate flags
    nor no0 (z, y[0], y[1], y[2], y[3], y[4], y[5], y[6], y[7]);
    assign n = y[7];

    or o0 (halt_out, op[0], op[1], op[2]);
    and a0 (halt, halt_out, op[3]);

    mux_8to1 mux0_8to1 (
        .sel(op[2:0]),
        .in0(c_adder),  // ADC
        .in1(c_adder),  // SBC
        .in2(1'b0),     // MUL
        .in3(cin),      // AND -> Unchanged
        .in4(cin),      // OR  -> Unchanged
        .in5(cin),      // XOR -> Unchanged
        .in6(c_shift),  // ROL -> Unchanged
        .in7(c_shift),  // ROR -> Unchanged
        .y  (c_out)
    );
    mux_2to1 mux0_2to1 (
        .sel(op[3]),
        .in0(c_out),
        .in1(cin),    // when op[3]=1 (MOV), C=cin
        .y  (c)       // Output C-flag
    );

    mux_8to1 mux1_8to1 (
        .sel(op[2:0]),
        .in0(v_adder),  // ADC
        .in1(v_adder),  // SBC
        .in2(v_mul),    // MUL
        .in3(vin),      // AND -> Unchanged
        .in4(vin),      // OR  -> Unchanged
        .in5(vin),      // XOR -> Unchanged
        .in6(vin),      // ROL -> Unchanged
        .in7(vin),      // ROR -> Unchanged
        .y  (v_out)
    );
    mux_2to1 mux1_2to1 (
        .sel(op[3]),
        .in0(v_out),
        .in1(vin),    // when op[3]=1 (MOV), V=vin
        .y  (v)       // Output V-flag
    );
endmodule
