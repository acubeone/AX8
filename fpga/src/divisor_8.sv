module divisor_8 (
    input        done,
    input  [7:0] in_q,    // Dividend
    input  [7:0] in_m,    // Divisor
    input  [8:0] in_acc,
    output [7:0] out_q,
    output [8:0] out_acc
);
    wire [7:0] shifted_q;
    wire [8:0] shifted_acc;

    wire [7:0] divisor;
    wire       math_sub;
    wire [8:0] math_out;

    // Shift left
    assign shifted_q = {in_q[6:0], 1'b0};
    // bypass shift when in correction
    assign shifted_acc = done ? in_acc : {in_acc[7:0], in_q[7]};

    assign divisor = in_m & {8{(~done) | in_acc[8]}}; //  in_m & (1 if done else acc.sign)
    assign math_sub = ~(done | in_acc[8]); // 0 if done else !acc.sign

    adder_subtractor #(
        .WIDTH(9)
    ) math (
        .a   (shifted_acc),
        .b   ({1'b0, divisor}),
        .cin (math_sub),
        .op  (math_sub),
        .y   (math_out),
        .cout(),
        .vout()
    );

    assign out_acc = math_out;
    assign out_q = done ? in_q : {shifted_q[7:1], (~math_out[8])};
endmodule
