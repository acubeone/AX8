module sign_bridge #(
    parameter WIDTH = 8
) (
    input  [WIDTH-1:0] a,
    input              sign,
    input              chain_in,
    output [WIDTH-1:0] y,
    output             chain_out
);
    // Generate lookahead inversion-mask
    wire [WIDTH-1:0] mask;
    assign mask[0] = chain_in;  // If chaining, do not apply +1
    genvar i;
    generate
        for (i = 1; i <= WIDTH - 1; i += 1) begin : gen_mask
            assign mask[i] = mask[i-1] | a[i-1];
        end
    endgenerate

    // If sign then apply inversion-mask, if not, just pass bit through
    assign y = a ^ (mask & {8{sign}});
    assign chain_out = mask[WIDTH-1] | a[WIDTH-1]; // Continue chain if byte is all-zeroes
endmodule
