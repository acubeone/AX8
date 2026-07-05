/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module decode_unary (
    input        E,
    input  [3:0] FR,
    input  [7:0] IR,
    output       HLT,
    output       ALU_WB,
    output [1:0] MODE,
    output [1:0] DST_SEL,
    output [2:0] SRC_SEL,
    output [3:0] FR_WE,
    output [3:0] FR_DATA,
    output [3:0] ALU_OP
);
    wire n_ir3;
    wire n_ir2;
    wire n_ir1;
    wire n_ir0;

    wire [7:0] dec;

    wire alu_shift;
    wire alu_rotate;
    wire is_hlt;
    wire i_not;
    wire i_inc;
    wire i_dec;

    wire rr_invalid;
    wire hlt_internal;
    wire alu_wb_internal;

    wire c_or_inc;
    wire n_alu_shift;
    wire out_c;

    wire alu_x1;
    wire alu_x2;
    wire src0;

    wire [1:0] mode_internal;
    wire [1:0] dst_sel_internal;
    wire [2:0] src_sel_internal;
    wire [3:0] fr_we_internal;
    wire [3:0] fr_data_internal;
    wire [3:0] alu_op_internal;

    not n0 (n_ir3, IR[3]);
    not n1 (n_ir2, IR[2]);
    not n2 (n_ir1, IR[1]);
    not n3 (n_ir0, IR[0]);

    // Unary instruction groups
    and d0 (dec[0], n_ir3, n_ir2, n_ir1, n_ir0);
    and d1 (dec[1], n_ir3, n_ir2, n_ir1, IR[0]);
    and d2 (dec[2], n_ir3, n_ir2, IR[1], n_ir0);
    and d3 (dec[3], n_ir3, n_ir2, IR[1], IR[0]);
    and d4 (dec[4], n_ir3, IR[2], n_ir1, n_ir0);
    and d5 (dec[5], n_ir3, IR[2], n_ir1, IR[0]);
    and d6 (dec[6], n_ir3, IR[2], IR[1], n_ir0);
    and d7 (dec[7], n_ir3, IR[2], IR[1], IR[0]);

    or  o0 (alu_shift, dec[0], dec[1]);
    or  o1 (is_hlt, dec[2], dec[3], dec[4]);
    buf b0 (i_not, dec[5]);
    or  o2 (alu_rotate, dec[6], dec[7]);

    // INC / DEC
    and a0 (i_inc, IR[3], n_ir2);
    and a1 (i_dec, IR[3], IR[2]);

    and a2 (rr_invalid, IR[3], IR[1], IR[0]);
    or  o3 (hlt_internal, IR[4], is_hlt, rr_invalid);
    not n4 (alu_wb_internal, hlt_internal);

    or  o4 (c_or_inc, FR[2], i_inc);
    not n5 (n_alu_shift, alu_shift);
    and a3 (out_c, c_or_inc, n_alu_shift);

    assign mode_internal = 2'b00;

    and a4 (dst_sel_internal[0], IR[3], IR[0]);
    and a5 (dst_sel_internal[1], IR[3], IR[1]);

    or o5 (src0, i_dec, i_not);

    assign src_sel_internal[0] = src0;
    assign src_sel_internal[1] = 1'b1;
    assign src_sel_internal[2] = 1'b1;

    assign fr_we_internal = 4'b0000;

    buf b1 (fr_data_internal[0], FR[0]);
    buf b2 (fr_data_internal[1], FR[1]);
    buf b3 (fr_data_internal[2], out_c);
    buf b4 (fr_data_internal[3], FR[3]);

    xor x0 (alu_x1, IR[1], alu_shift);
    xor x1 (alu_x2, IR[2], alu_shift);

    and a6 (alu_op_internal[0], n_ir3, IR[0]);
    and a7 (alu_op_internal[1], n_ir3, alu_x1);
    and a8 (alu_op_internal[2], n_ir3, alu_x2);

    assign alu_op_internal[3] = 1'b0;

    // Group enable
    and g0 (HLT, E, hlt_internal);
    and g1 (ALU_WB, E, alu_wb_internal);

    assign MODE     = mode_internal    & {2{E}};
    assign DST_SEL  = dst_sel_internal & {2{E}};
    assign SRC_SEL  = src_sel_internal & {3{E}};
    assign FR_WE    = fr_we_internal   & {4{E}};
    assign FR_DATA  = fr_data_internal & {4{E}};
    assign ALU_OP   = alu_op_internal  & {4{E}};

endmodule
