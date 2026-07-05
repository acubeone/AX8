/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module instruction_decoder (
    input  [3:0] FR,
    input  [7:0] IR,
    output       HLT,
    output       RW,
    output       ALU_WB,
    output [1:0] PC_OP,
    output [1:0] MODE,
    output [1:0] DST_SEL,
    output [2:0] SRC_SEL,
    output [3:0] FR_WE,
    output [3:0] FR_DATA,
    output [3:0] ALU_OP
);
    wire [2:0] op_group;

    wire n_op2;
    wire n_op1;
    wire n_op0;

    wire g_sys;
    wire g_mem;
    wire g_ari;
    wire g_uny;
    wire g_jmp;

    wire sys_hlt;
    wire [3:0] sys_fr_we;
    wire [3:0] sys_fr_data;

    wire mem_hlt;
    wire mem_rw;
    wire mem_alu_wb;
    wire [1:0] mem_mode;
    wire [1:0] mem_dst_sel;
    wire [2:0] mem_src_sel;
    wire [3:0] mem_alu_op;

    wire ari_hlt;
    wire ari_alu_wb;
    wire [1:0] ari_mode;
    wire [1:0] ari_dst_sel;
    wire [2:0] ari_src_sel;
    wire [3:0] ari_alu_op;

    wire uny_hlt;
    wire uny_alu_wb;
    wire [1:0] uny_mode;
    wire [1:0] uny_dst_sel;
    wire [2:0] uny_src_sel;
    wire [3:0] uny_fr_we;
    wire [3:0] uny_fr_data;
    wire [3:0] uny_alu_op;

    wire jmp_hlt;
    wire [1:0] jmp_mode;
    wire [1:0] jmp_pc_op;

    wire invalid_group;
    wire invalid_group_hlt;

    wire hlt_internal;
    wire n_hlt;

    wire n_g_mem;
    wire rw_internal;
    wire alu_wb_internal;

    wire [1:0] pc_op_internal;
    wire [1:0] mode_internal;
    wire [1:0] dst_sel_internal;
    wire [2:0] src_sel_internal;
    wire [3:0] fr_we_internal;
    wire [3:0] fr_data_internal;
    wire [3:0] alu_op_internal;

    assign op_group = IR[7:5];

    // Group decode
    not n0 (n_op2, op_group[2]);
    not n1 (n_op1, op_group[1]);
    not n2 (n_op0, op_group[0]);

    and g0 (g_sys, n_op2, n_op1, n_op0);
    and g1 (g_mem, n_op2, n_op1, op_group[0]);
    and g2 (g_ari, n_op2, op_group[1], n_op0);
    and g3 (g_uny, n_op2, op_group[1], op_group[0]);
    buf g4 (g_jmp, op_group[2]);

    decode_system u_sys (
        .E       (g_sys),
        .FR      (FR),
        .IR      (IR),
        .HLT     (sys_hlt),
        .FR_WE   (sys_fr_we),
        .FR_DATA (sys_fr_data)
    );

    decode_memory u_mem (
        .E       (g_mem),
        .FR      (FR),
        .IR      (IR),
        .HLT     (mem_hlt),
        .MEM_RW  (mem_rw),
        .ALU_WB  (mem_alu_wb),
        .MODE    (mem_mode),
        .DST_SEL (mem_dst_sel),
        .SRC_SEL (mem_src_sel),
        .ALU_OP  (mem_alu_op)
    );

    decode_arithmetic u_ari (
        .E       (g_ari),
        .FR      (FR),
        .IR      (IR),
        .HLT     (ari_hlt),
        .ALU_WB  (ari_alu_wb),
        .MODE    (ari_mode),
        .DST_SEL (ari_dst_sel),
        .SRC_SEL (ari_src_sel),
        .ALU_OP  (ari_alu_op)
    );

    decode_unary u_uny (
        .E       (g_uny),
        .FR      (FR),
        .IR      (IR),
        .HLT     (uny_hlt),
        .ALU_WB  (uny_alu_wb),
        .MODE    (uny_mode),
        .DST_SEL (uny_dst_sel),
        .SRC_SEL (uny_src_sel),
        .FR_WE   (uny_fr_we),
        .FR_DATA (uny_fr_data),
        .ALU_OP  (uny_alu_op)
    );

    decode_jump u_jmp (
        .E     (g_jmp),
        .FR    (FR),
        .IR    (IR),
        .HLT   (jmp_hlt),
        .MODE  (jmp_mode),
        .PC_OP (jmp_pc_op)
    );

    // Global control merge
    or  o0 (invalid_group, op_group[1], op_group[0]);
    and a0 (invalid_group_hlt, op_group[2], invalid_group);

    or o1 (
        hlt_internal,
        invalid_group_hlt,
        sys_hlt,
        mem_hlt,
        ari_hlt,
        uny_hlt,
        jmp_hlt
    );

    not n3 (n_g_mem, g_mem);
    or  o2 (rw_internal, n_g_mem, mem_rw);

    or o3 (
        alu_wb_internal,
        mem_alu_wb,
        ari_alu_wb,
        uny_alu_wb
    );

    assign pc_op_internal = jmp_pc_op;

    assign mode_internal =
        mem_mode |
        ari_mode |
        uny_mode |
        jmp_mode;

    assign dst_sel_internal =
        mem_dst_sel |
        ari_dst_sel |
        uny_dst_sel;

    assign src_sel_internal =
        mem_src_sel |
        ari_src_sel |
        uny_src_sel;

    assign fr_we_internal =
        sys_fr_we |
        uny_fr_we;

    assign fr_data_internal =
        sys_fr_data |
        uny_fr_data;

    assign alu_op_internal =
        mem_alu_op |
        ari_alu_op |
        uny_alu_op;

    // HLT masks control outputs
    not n4 (n_hlt, hlt_internal);

    buf b0 (HLT, hlt_internal);
    buf b1 (RW, rw_internal);

    and a1 (ALU_WB, alu_wb_internal, n_hlt);

    assign PC_OP   = pc_op_internal   & {2{n_hlt}};
    assign MODE    = mode_internal    & {2{n_hlt}};
    assign DST_SEL = dst_sel_internal & {2{n_hlt}};
    assign SRC_SEL = src_sel_internal & {3{n_hlt}};
    assign FR_WE   = fr_we_internal   & {4{n_hlt}};
    assign FR_DATA = fr_data_internal & {4{n_hlt}};
    assign ALU_OP  = alu_op_internal  & {4{n_hlt}};

endmodule
