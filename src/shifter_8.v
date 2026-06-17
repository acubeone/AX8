/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module shifter_8 (
    input [7:0] a,
    input cin,
    input m,
    output [7:0] y,
    output cout
);
    // ROL (m=0) > Shifts everything to the left, Cin fills Y[0]:
    // A: [6][5][4][3][2][1][0][Cin]
    // v
    // Y: [7][6][5][4][3][2][1][0]    Cout <- A[7]
    //
    // ROR (m=1) > Shifts everything to the right, Cin fills Y[7]:
    // A: [Cin][7][6][5][4][3][2][1]
    // v
    // Y: [7]  [6][5][4][3][2][1][0]  Cout <- A[0]

    // verilog_format: off
    mux_2to1 mx0 (.a(cin),  .b(a[1]), .s(m), .y(y[0]));
    mux_2to1 mx1 (.a(a[0]), .b(a[2]), .s(m), .y(y[1]));
    mux_2to1 mx2 (.a(a[1]), .b(a[3]), .s(m), .y(y[2]));
    mux_2to1 mx3 (.a(a[2]), .b(a[4]), .s(m), .y(y[3]));
    mux_2to1 mx4 (.a(a[3]), .b(a[5]), .s(m), .y(y[4]));
    mux_2to1 mx5 (.a(a[4]), .b(a[6]), .s(m), .y(y[5]));
    mux_2to1 mx6 (.a(a[5]), .b(a[7]), .s(m), .y(y[6]));
    mux_2to1 mx7 (.a(a[6]), .b(cin),  .s(m), .y(y[7]));

    mux_2to1 mxc (.a(a[7]), .b(a[0]), .s(m), .y(cout));
    // verilog_format: on

endmodule
