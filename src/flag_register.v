`timescale 1ns / 1ps

module flag_register (
    input  wire       clk,
    input  wire [3:0] fr_data,
    input  wire [3:0] fr_we,
    output reg  [3:0] fr_q
);

    initial begin
        fr_q = 4'b0000;
    end

    always @(posedge clk) begin
        if (fr_we[0])
            fr_q[0] <= fr_data[0]; // Z

        if (fr_we[1])
            fr_q[1] <= fr_data[1]; // N

        if (fr_we[2])
            fr_q[2] <= fr_data[2]; // C

        if (fr_we[3])
            fr_q[3] <= fr_data[3]; // V
    end

endmodule
