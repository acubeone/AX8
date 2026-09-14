module adder_subtractor #(
    parameter WIDTH = 8
) (
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input              cin,
    input              op,    // 0=ADC, 1=SBC
    output [WIDTH-1:0] y,
    output             cout,
    output             vout
);
    wire halfcarry[  WIDTH:0];
    wire xored_b  [WIDTH-1:0];
    assign halfcarry[0] = cin;

    assign cout = halfcarry[WIDTH];
    assign vout = halfcarry[WIDTH-1] ^ halfcarry[WIDTH];

    genvar i;
    generate
        for (i = 0; i < WIDTH; i++) begin : gen_partial_sum
            assign xored_b[i] = b[i] ^ op;

            full_adder full_adder (
                .a   (a[i]),
                .b   (xored_b[i]),
                .cin (halfcarry[i]),
                .y   (y[i]),
                .cout(halfcarry[i+1])
            );
        end
    endgenerate
endmodule
