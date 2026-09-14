module shift_rotator #(
    parameter WIDTH = 8
) (
    input  [WIDTH-1:0] a,
    input              dir,  // 0=left, 1=right
    input              cin,
    output [WIDTH-1:0] y,
    output             cout
);
    wire [WIDTH+1:0] barrel = {cin, a, cin};

    genvar i;
    generate
        for (i = 0; i < WIDTH; i += 1) begin : gen_rotation
            assign y[i] = dir ? barrel[i+2] : barrel[i];
        end
    endgenerate

    assign cout = dir ? a[0] : a[WIDTH-1];
endmodule
