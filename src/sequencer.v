`timescale 1ns / 1ps

module sequencer (
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    input  wire       rw,
    input  wire [1:0] pc_op_in,
    input  wire [1:0] mode,

    output wire       commit,
    output wire       mem_re,
    output wire       mem_we,
    output wire       dl_we,
    output wire       ir_we,
    output wire       op_lo_we,
    output wire       op_hi_we,
    output wire [1:0] addr_sel,
    output wire [1:0] pc_op
);

    /*
        mode[1:0]:
        00 -> IS_JMP
        01 -> IS_IND
        10 -> IS_IMM
        11 -> IS_ABS
    */
    wire is_jmp;
    wire is_ind;
    wire is_imm;
    wire is_abs;

    wire re;
    wire wr;

    reg ph;
    reg f1;
    reg f2;
    reg f3;
    reg ex;

    wire f0;

    wire f0a;
    wire f0b;
    wire f1a;
    wire f1b;
    wire f2a;
    wire f2b;
    wire f3a;
    wire f3b;

    wire ph_next;
    wire f1_next;
    wire f2_next;
    wire f3_next;
    wire ex_next;

    wire commit_internal;
    wire mem_re_internal;
    wire mem_we_internal;
    wire dl_we_internal;
    wire ir_we_internal;
    wire op_lo_we_internal;
    wire op_hi_we_internal;
    wire [1:0] addr_sel_internal;
    wire [1:0] pc_op_internal;

    assign is_jmp = (mode == 2'b00);
    assign is_ind = (mode == 2'b01);
    assign is_imm = (mode == 2'b10);
    assign is_abs = (mode == 2'b11);

    assign wr = rw;
    assign re = ~rw;

    /*
        F0 não é um flip-flop.
        F0 existe quando F1, F2, F3 e EX estão todos zerados.
    */
    assign f0 = ~(f1 | f2 | f3 | ex);

    /*
        Fases A/B.
        PH = 0 -> fase A
        PH = 1 -> fase B
    */
    assign f0a = f0 & ~ph;
    assign f0b = f0 &  ph;

    assign f1a = f1 & ~ph;
    assign f1b = f1 &  ph;

    assign f2a = f2 & ~ph;
    assign f2b = f2 &  ph;

    assign f3a = f3 & ~ph;
    assign f3b = f3 &  ph;

    /*
        Próximo estado, baseado na parte "State Machine" da imagem.
    */
    assign ph_next = ~(ph | ex | (f3 & wr));

    assign f1_next = f1a | (f0b & mode[1]);

    assign f2_next = f2a | (f1b & is_abs);

    assign f3_next = (f3a & re) |
                     f2b |
                     (f0b & is_ind);

    assign ex_next = (f3a & wr) |
                     f3b |
                     (f1b & is_imm) |
                     (f0b & is_jmp);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ph <= 1'b0;
            f1 <= 1'b0;
            f2 <= 1'b0;
            f3 <= 1'b0;
            ex <= 1'b0;
        end else if (enable) begin
            ph <= ph_next;
            f1 <= f1_next;
            f2 <= f2_next;
            f3 <= f3_next;
            ex <= ex_next;
        end
    end

    /*
        State Decoder.
    */
    assign commit_internal = ex;

    /*
        Pela imagem, MEM_RE recebe:
        F0a, F1a, F2b e F3a & RE.

        Observação: se no Logisim você perceber que o correto era F2a,
        basta trocar f2b por f2a aqui.
    */
    assign mem_re_internal = f0a |
                             f1a |
                             f2b |
                             (f3a & re);

    assign mem_we_internal = f3a & wr;

    assign dl_we_internal = mem_re_internal;

    assign ir_we_internal = f0b;

    assign op_lo_we_internal = f1b;

    assign op_hi_we_internal = f2b;

    /*
        ADDR_SEL:
        bit0 -> IS_IND durante F3
        bit1 -> IS_ABS durante F3
    */
    assign addr_sel_internal = {
        f3 & is_abs,
        f3 & is_ind
    };

    /*
        PC_OP:
        Durante EX, usa pc_op_in.
        Durante F0b/F1b/F2b, incrementa PC com 01.
        Fora disso, 00.
    */
    assign pc_op_internal = ex ? pc_op_in :
                            ((f0b | f1b | f2b) ? 2'b01 : 2'b00);

    /*
        Saídas finais passam por ENABLE, como aparece no lado direito.
    */
    assign commit   = enable & commit_internal;
    assign mem_re   = enable & mem_re_internal;
    assign mem_we   = enable & mem_we_internal;
    assign dl_we    = enable & dl_we_internal;
    assign ir_we    = enable & ir_we_internal;
    assign op_lo_we = enable & op_lo_we_internal;
    assign op_hi_we = enable & op_hi_we_internal;

    assign addr_sel = enable ? addr_sel_internal : 2'b00;
    assign pc_op    = enable ? pc_op_internal    : 2'b00;

endmodule
