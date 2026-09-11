module adder_subtractor_8 (
    input  [7:0] a,
    input  [7:0] b,
    input        cin,
    input        mode,
    output [7:0] y,
    output       cout,
    output       vout
);
    wire halfcarry[8:0];
    wire xored_b  [7:0];
    assign halfcarry[0] = cin;

    assign cout = halfcarry[8];
    assign vout = halfcarry[7] ^ halfcarry[8];

    genvar i;
    generate
        for (i = 0; i < 8; i++) begin : gen_partial_sum
            assign xored_b[i] = b[i] ^ mode;

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
