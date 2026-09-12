module multiplier_8 (
    input         clk,
    input         rst_n,
    input  [ 7:0] in_m,   // Multiplicand
    input  [ 7:0] in_q,   // Multiplier
    output [15:0] y,
    output [ 7:0] out_m,
    output [ 7:0] out_q
);
    logic [7:0] acc;

    wire [1:0] carry;
    wire [7:0] add_sum;
    wire [7:0] next_acc;
    wire [7:0] multiplicand = in_m & {8{in_q[0]}};

    adder_subtractor_8 adder (
        .a   (multiplicand),
        .b   (acc),
        .cin (1'b0),
        .mode(1'b0),
        .y   (add_sum),
        .cout(carry[0]),
        .vout()
    );

    shift_rotator_8 shift_acc (
        .a   (add_sum),
        .dir (1'b1),         // "right"
        .cin (carry[0]),
        .y   (next_acc),
        .cout(carry[1])
    );
    shift_rotator_8 shift_q (
        .a   (in_q),
        .dir (1'b1),         // "right"
        .cin (carry[1]),
        .y   (out_q),
        .cout()
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) acc <= 8'h00;
        else acc <= next_acc;
    end

    assign y = {acc, in_q};
    assign out_m = in_m;
endmodule
