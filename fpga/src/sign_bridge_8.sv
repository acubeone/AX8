module sign_bridge_8 (
    input  [7:0] a,
    input        sign,
    input        chain_in,
    output [7:0] y,
    output       chain_out
);
    // Generate lookahead inversion-mask
    wire [7:0] mask;
    assign mask[0] = chain_in;  // If chaining, do not apply +1
    genvar i;
    generate
        for (i = 1; i <= 7; i += 1) begin : gen_mask
            assign mask[i] = mask[i-1] | a[i-1];
        end
    endgenerate

    // If sign then apply inversion-mask, if not, just pass bit through
    assign y = a ^ (mask & {8{sign}});
    assign chain_out = mask[7] | a[7]; // Continue chain if byte is all-zeroes
endmodule
