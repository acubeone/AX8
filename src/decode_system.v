/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module decode_system (
    input        E,
    input  [3:0] FR,
    input  [7:0] IR,
    output       HLT,
    output [3:0] FR_WE,
    output [3:0] FR_DATA
);
    wire ir01_or;
    wire n_ir2;
    wire hlt_low;
    wire hlt_high;
    wire hlt_internal;

    wire n_hlt;
    wire n_ir1;
    wire fr_we_c;
    wire fr_we_v;

    wire [3:0] fr_we_internal;
    wire [3:0] fr_data_internal;

    // HLT detection
    or  o0 (ir01_or, IR[0], IR[1]);
    not n0 (n_ir2, IR[2]);
    and a0 (hlt_low, ir01_or, n_ir2);

    or  o1 (hlt_high, IR[3], IR[4]);
    or  o2 (hlt_internal, hlt_low, hlt_high);

    // Flag register write enable
    not n1 (n_hlt, hlt_internal);
    not n2 (n_ir1, IR[1]);

    and a1 (fr_we_c, n_hlt, IR[2], n_ir1);
    and a2 (fr_we_v, n_hlt, IR[2], IR[1]);

    assign fr_we_internal = {
        fr_we_v,
        fr_we_c,
        1'b0,
        1'b0
    };

    assign fr_data_internal = {
        IR[0],
        IR[0],
        FR[1],
        FR[0]
    };

    // Group enable
    and g0 (HLT, E, hlt_internal);

    assign FR_WE   = fr_we_internal   & {4{E}};
    assign FR_DATA = fr_data_internal & {4{E}};

endmodule
