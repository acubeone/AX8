module shift_rotator_8 (
    input  [7:0] a,
    input        dir,  // 0=left, 1=right
    input        cin,
    output [7:0] y,
    output       cout
);
    wire [9:0] barrel = {cin, a, cin};

    assign cout = dir ? a[0] : a[7];

    genvar i;
    generate
        for (i = 0; i <= 7; i += 1) begin : gen_rotation
            assign y[i] = dir ? barrel[i+2] : barrel[i];
        end
    endgenerate
endmodule
