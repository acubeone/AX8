/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module instruction_sequencer (
    input        CLK,
    input        RESET,
    input        ENABLE,
    input        RW,
    input  [1:0] PC_OP_IN,
    input  [1:0] MODE,
    output       COMMIT,
    output       MEM_RW,
    output       DL_WE,
    output       IR_WE,
    output       OP_LO_WE,
    output       OP_HI_WE,
    output [1:0] ADDR_SEL,
    output [1:0] PC_OP
);
    reg rst_q = 1'b0;

    reg ph;
    reg f1;
    reg f2;
    reg f3;
    reg ex;

    wire state_clk;
    wire rst_req;

    wire is_jmp;
    wire is_ind;
    wire is_imm;
    wire is_abs;

    wire re;
    wire wr;

    wire n_ph;

    wire f0;
    wire f0a;
    wire f0b;
    wire f1a;
    wire f1b;
    wire f2a;
    wire f2b;
    wire f3a;
    wire exa;
    wire exb;

    wire ph_next;
    wire f1_next;
    wire f2_next;
    wire f3_next;
    wire ex_next;

    wire ex_re;
    wire ind_read;
    wire ind_wr;
    wire ex_wr_path;

    wire addr_active;
    wire fetch_b;

    // Mode decoder
    assign is_jmp = ENABLE & (MODE == 2'b00);
    assign is_ind = ENABLE & (MODE == 2'b01);
    assign is_imm = ENABLE & (MODE == 2'b10);
    assign is_abs = ENABLE & (MODE == 2'b11);

    buf b0 (re, RW);
    not n0 (wr, RW);
    not n1 (n_ph, ph);

    // State decoder
    nor o0 (f0, f1, f2, f3, ex);

    and a0 (f0a, f0, n_ph);
    and a1 (f0b, f0, ph);

    and a2 (f1a, f1, n_ph);
    and a3 (f1b, f1, ph);

    and a4 (f2a, f2, n_ph);
    and a5 (f2b, f2, ph);

    and a6 (f3a, f3, n_ph);

    and a7 (exa, ex, n_ph);
    and a8 (exb, ex, ph);

    // Next-state logic
    and a9 (ex_re, ex, re);
    nor o1 (ph_next, ph, f3a, ex_re);

    assign f1_next =
        f1a |
        (f0b & MODE[1]);

    assign f2_next =
        f2a |
        (f1b & is_abs);

    and a10 (ind_read, f0b, is_ind, re);

    assign f3_next =
        (f2b & re) |
        ind_read;

    and a11 (ind_wr, f0b, is_ind);
    or  o2  (ex_wr_path, exa, f2b, ind_wr);

    assign ex_next =
        (wr & ex_wr_path) |
        f3a |
        (f1b & is_imm) |
        (f0b & is_jmp);

    // Reset request and gated clock
    and g0 (state_clk, CLK, ENABLE);

    assign rst_req = RESET & ~rst_q;

    always @(posedge CLK)
        rst_q <= RESET;

    always @(posedge state_clk or posedge rst_req) begin
        if (rst_req) begin
            ph <= 1'b0;
            f1 <= 1'b0;
            f2 <= 1'b0;
            f3 <= 1'b0;
            ex <= 1'b0;
        end else begin
            ph <= ph_next;
            f1 <= f1_next;
            f2 <= f2_next;
            f3 <= f3_next;
            ex <= ex_next;
        end
    end

    // Output decoder
    buf b1 (COMMIT, exa);
    not n2 (MEM_RW, exb);

    or  o3 (DL_WE, f1a, f2a, f3a);

    buf b2 (IR_WE, f0a);
    buf b3 (OP_LO_WE, f1a);
    buf b4 (OP_HI_WE, f2a);

    or o4 (addr_active, f3a, exb);

    assign ADDR_SEL[0] =
        addr_active & is_abs;

    assign ADDR_SEL[1] =
        addr_active & is_ind;

    or o5 (fetch_b, f0b, f1b, f2b);

    assign PC_OP =
        fetch_b ? 2'b11 :
        exa     ? PC_OP_IN :
                  2'b00;

endmodule
