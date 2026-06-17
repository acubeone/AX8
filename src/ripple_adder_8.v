/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module ripple_adder_8 (
    input [7:0] a,
    input [7:0] b,
    input cin,
    output [7:0] y,
    output cout,
    output c6
);
    wire [8:0] carry;

    assign carry[0] = cin;
    assign cout = carry[8];
    assign c6 = carry[7];

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_ripple
            full_adder fan (
                .a   (a[i]),
                .b   (b[i]),
                .cin (carry[i]),
                .y   (y[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate
endmodule
