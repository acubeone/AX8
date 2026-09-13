module multiplier_8 (
    input  [7:0] in_q,    // Multiplier
    input  [7:0] in_m,    // Multiplicand
    input  [7:0] in_acc,
    output [7:0] out_q,
    output [7:0] out_acc
);
    wire       carry;
    wire [7:0] add_sum;

    wire [7:0] multiplicand = in_m & {8{in_q[0]}};

    adder_subtractor_8 adder (
        .a   (multiplicand),
        .b   (in_acc),
        .cin (1'b0),
        .op  (1'b0),
        .y   (add_sum),
        .cout(carry),
        .vout()
    );

    // Shift right
    assign out_acc = {carry, add_sum[7:1]};
    assign out_q = {add_sum[0], in_q[7:1]};
endmodule
