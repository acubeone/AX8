/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module multiplier_4 (
    input  [3:0] a,
    input  [3:0] b,
    output [7:0] y
);
    // P0 = A & B[0]
    // P1 = A & B[1]
    // P2 = A & B[2]
    // P3 = A & B[3]
    //
    // bit: 7   6   5   4   3   2   1   0
    // P0 : 0   0   0   0  P03 P02 P01 P00
    // P1 : 0   0   C  P13 P12 P11 P10  0
    // P2 : 0   C  P23 P22 P21 P20  0   0
    // P3 : C  P33 P32 P31 P30  0   0   0
    //
    // Y[0] = P00
    // Y[1] = P01 + P10
    // Y[2] = P02 + P11 + P20 + C
    // Y[3] = P03 + P12 + P21 + P30 + C
    // Y[4] = P13 + P22 + P31 + C
    // Y[5] = P23 + P32 + C
    // Y[6] = P33 + C
    // Y[7] = C
    //
    // sum0, C0 = {0, P03, P02, P01} + {P13, P12, P11, P10}
    // sum1, C1 = {C0, sum03, sum02, sum01} + {P23, P22, P21, P20}
    // sum2, C2 = {C1, sum13, sum12, sum11} + {P33, P32, P31, P30}
    // Y = {C2, sum23, sum22, sum21, sum20, sum10, sum00, P00}

    wire [3:0] product[4];

    wire c0, c1, c2;
    wire [3:0] sum0;
    wire [3:0] sum1;
    wire [3:0] sum2;

    assign y = {c2, sum2[3], sum2[2], sum2[1], sum2[0], sum1[0], sum0[0], product[0][0]};

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_partial_products
            and a0n (product[0][i], b[0], a[i]);
            and a1n (product[1][i], b[1], a[i]);
            and a2n (product[2][i], b[2], a[i]);
            and a3n (product[3][i], b[3], a[i]);
        end
    endgenerate

    ripple_adder_4 rp0 (
        .a({1'b0, product[0][3:1]}),
        .b(product[1]),
        .cin(1'b0),
        .y(sum0),
        .cout(c0)
    );
    ripple_adder_4 rp1 (
        .a({c0, sum0[3:1]}),
        .b(product[2]),
        .cin(1'b0),
        .y(sum1),
        .cout(c1)
    );
    ripple_adder_4 rp2 (
        .a({c1, sum1[3:1]}),
        .b(product[3]),
        .cin(1'b0),
        .y(sum2),
        .cout(c2)
    );

endmodule
