/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module decode_arithmetic (
    input        E,
    input  [3:0] FR,
    input  [7:0] IR,
    output       HLT,
    output       ALU_WB,
    output [1:0] MODE,
    output [1:0] DST_SEL,
    output [2:0] SRC_SEL,
    output [3:0] ALU_OP
);
    wire n_ir3;
    wire maybe_hlt;
    wire ldi_mode;
    wire is_ldi;
    wire n_is_ldi;

    wire hlt_internal;
    wire i_cmp;
    wire cmp_or_hlt;
    wire normal_wb;
    wire alu_wb_internal;

    wire src1;

    wire op0_x;
    wire op1_x;
    wire op2_x;

    wire [1:0] mode_internal;
    wire [1:0] dst_sel_internal;
    wire [2:0] src_sel_internal;
    wire [3:0] alu_op_internal;

    // HLT and LDI detection
    and a0 (maybe_hlt, IR[0], IR[1], IR[2]);

    not n0 (n_ir3, IR[3]);
    and a1 (ldi_mode, n_ir3, IR[4]);
    and a2 (is_ldi, maybe_hlt, ldi_mode);

    not n1 (n_is_ldi, is_ldi);
    and a3 (hlt_internal, maybe_hlt, n_is_ldi);

    // Compare disables ALU writeback
    and a4 (i_cmp, IR[1], IR[2]);

    or  o0 (cmp_or_hlt, i_cmp, hlt_internal);
    not n2 (normal_wb, cmp_or_hlt);
    or  o1 (alu_wb_internal, normal_wb, is_ldi);

    // ALU operation
    xor x0 (op0_x, IR[0], i_cmp);
    xor x1 (op1_x, IR[1], i_cmp);
    xor x2 (op2_x, IR[2], i_cmp);

    and a5 (alu_op_internal[0], op0_x, n_is_ldi);
    and a6 (alu_op_internal[1], op1_x, n_is_ldi);
    and a7 (alu_op_internal[2], op2_x, n_is_ldi);
    buf b0 (alu_op_internal[3], is_ldi);

    assign mode_internal = {IR[4], IR[3]};
    assign dst_sel_internal = 2'b00;

    or o2 (src1, IR[3], IR[4]);
    assign src_sel_internal = {1'b0, src1, 1'b1};

    // Group enable
    and g0 (HLT, E, hlt_internal);
    and g1 (ALU_WB, E, alu_wb_internal);

    assign MODE    = mode_internal    & {2{E}};
    assign DST_SEL = dst_sel_internal & {2{E}};
    assign SRC_SEL = src_sel_internal & {3{E}};
    assign ALU_OP  = alu_op_internal  & {4{E}};

endmodule
