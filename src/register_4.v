`timescale 1ns / 1ps

module register_4 (
    input  wire       clk,
    input  wire       we,
    input  wire [3:0] d,
    output reg  [3:0] q
);

    initial begin
        q = 4'b0000;
    end

    always @(posedge clk) begin
        if (we)
            q <= d;
        else
            q <= q;
    end

endmodule
