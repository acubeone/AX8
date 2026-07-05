/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module interrupt_sequencer (
    input        CLK,
    input        RESET,
    output       DONE,
    output       OUT_RST,
    output       MEM_RW,
    output       OP_LO_WE,
    output       OP_HI_WE,
    output [1:0] ADDR_SEL,
    output [1:0] PC_OP,
    output [3:0] FR_WE,
    output [3:0] FR_DATA,
    output [3:0] VEC
);
    reg q0;
    reg q1;

    wire nq0;
    wire nq1;

    wire r0a;
    wire r0b;
    wire rea;
    wire reb;

    wire d0_or;
    wire d1_or;
    wire n_reset;
    wire d0;
    wire d1;

    not n0 (nq0, q0);
    not n1 (nq1, q1);
    not n2 (n_reset, RESET);

    // State decoder
    and a0 (r0a, nq1, nq0);
    and a1 (r0b, nq1, q0);
    and a2 (rea, q1, nq0);
    and a3 (reb, q1, q0);

    // Next-state logic
    or o0 (d0_or, nq0, q1);
    or o1 (d1_or, q0, q1);

    and a4 (d0, n_reset, d0_or);
    and a5 (d1, n_reset, d1_or);

    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            q0 <= 1'b0;
            q1 <= 1'b0;
        end else begin
            q0 <= d0;
            q1 <= d1;
        end
    end

    // Outputs
    buf b0 (DONE, reb);
    buf b1 (OUT_RST, rea);

    assign MEM_RW = 1'b1;

    buf b2 (OP_LO_WE, r0a);
    buf b3 (OP_HI_WE, r0b);

    assign ADDR_SEL = {nq1, nq1};
    assign PC_OP = {rea, 1'b0};

    assign FR_WE = {4{rea}};
    assign FR_DATA = 4'b0000;

    assign VEC = {
        3'b000,
        r0b
    };

endmodule
