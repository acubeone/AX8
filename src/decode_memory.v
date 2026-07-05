/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module decode_memory (
    input        E,
    input  [3:0] FR,
    input  [7:0] IR,
    output       HLT,
    output       MEM_RW,
    output       ALU_WB,
    output [1:0] MODE,
    output [1:0] DST_SEL,
    output [2:0] SRC_SEL,
    output [3:0] ALU_OP
);
    wire n_ir4;
    wire is_trx;
    wire is_ind;
    wire mem_rw_internal;

    wire hlt_a;
    wire hlt_b;
    wire hlt_internal;
    wire alu_wb_internal;

    wire src_reg0;
    wire src_reg1;
    wire n_is_trx;
    wire n_is_ind;
    wire n_mem_rw;
    wire src_mux_sel;

    wire [1:0] mode_internal;
    wire [1:0] dst_sel_internal;
    wire [2:0] src_sel_internal;
    wire [3:0] alu_op_internal;

    not n0 (n_ir4, IR[4]);
    buf b0 (is_trx, IR[4]);

    nand n1 (mem_rw_internal, IR[2], n_ir4);
    and  a0 (is_ind, IR[3], n_ir4);

    // HLT detection
    and a1 (hlt_a, IR[0], IR[1]);
    and a2 (hlt_b, IR[2], IR[3], IR[4]);
    or  o0 (hlt_internal, hlt_a, hlt_b);

    not n2 (alu_wb_internal, hlt_internal);

    // Source register selection
    assign src_reg0 = is_trx ? IR[2] : IR[0];
    assign src_reg1 = is_trx ? IR[3] : IR[1];

    not n3 (n_is_trx, is_trx);
    not n4 (n_is_ind, is_ind);

    buf b1 (mode_internal[0], n_is_trx);
    and a3 (mode_internal[1], n_is_trx, n_is_ind);

    assign dst_sel_internal[0] =
        mem_rw_internal ? IR[0] : 1'b1;

    assign dst_sel_internal[1] =
        mem_rw_internal ? IR[1] : 1'b1;

    not n5 (n_mem_rw, mem_rw_internal);
    or  o1 (src_mux_sel, is_trx, n_mem_rw);

    assign src_sel_internal[0] =
        src_mux_sel ? src_reg0 : 1'b1;

    assign src_sel_internal[1] =
        src_mux_sel ? src_reg1 : 1'b1;

    assign src_sel_internal[2] = 1'b0;

    assign alu_op_internal = 4'b1000;

    // Group enable
    and g0 (HLT, E, hlt_internal);
    and g1 (MEM_RW, E, mem_rw_internal);
    and g2 (ALU_WB, E, alu_wb_internal);

    assign MODE =
        mode_internal & {2{E}};

    assign DST_SEL =
        dst_sel_internal & {2{E}};

    assign SRC_SEL =
        src_sel_internal & {3{E}};

    assign ALU_OP =
        alu_op_internal & {4{E}};

endmodule
