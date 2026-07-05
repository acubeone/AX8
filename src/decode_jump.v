`timescale 1ns / 1ps

module decode_jump (
    input  wire       E,
    input  wire [3:0] FR,
    input  wire [7:0] IR,

    output wire       HLT,
    output wire [1:0] MODE,
    output wire [1:0] PC_OP
);

    wire is_cb;
    wire is_ucf;

    wire selected_flag;
    wire condition_match;

    wire cb_bra;
    wire i_bra;
    wire i_jmp;
    wire take_branch;

    wire hlt_internal;
    wire [1:0] mode_internal;
    wire [1:0] pc_op_internal;

    // ------------------------------------------------------------
    // Identificacao dos subgrupos
    //
    // IR[4:3] = 00 -> Conditional Branch
    // IR[4:3] = 10 -> Unconditional Control Flow
    // ------------------------------------------------------------

    assign is_cb  = ~(IR[4] | IR[3]);
    assign is_ucf =  IR[4] & ~IR[3];

    // ------------------------------------------------------------
    // MUX das flags
    //
    // 00 -> Z = FR[0]
    // 01 -> N = FR[1]
    // 10 -> C = FR[2]
    // 11 -> V = FR[3]
    // ------------------------------------------------------------

    assign selected_flag =
        (IR[1:0] == 2'b00) ? FR[0] :
        (IR[1:0] == 2'b01) ? FR[1] :
        (IR[1:0] == 2'b10) ? FR[2] :
                             FR[3];

    // IR[2] seleciona teste Clear/Set.
    // A porta XOR seguida de inversor do circuito equivale a XNOR.
    assign condition_match = ~(selected_flag ^ IR[2]);

    assign cb_bra = is_cb & condition_match;

    // ------------------------------------------------------------
    // DMX do fluxo incondicional
    //
    // OO = 00 -> BRA
    // OO = 01 -> JMP
    // OO = 10/11 -> reservado
    // ------------------------------------------------------------

    assign i_bra = is_ucf & ~IR[1] & ~IR[0];
    assign i_jmp = is_ucf & ~IR[1] &  IR[0];

    assign take_branch = cb_bra | i_bra;

    // ------------------------------------------------------------
    // HLT interno
    // ------------------------------------------------------------

    assign hlt_internal =
        ~(is_cb | is_ucf) |
        (is_ucf & IR[2]);

    // ------------------------------------------------------------
    // MODE
    //
    // Bit 1 = constante 1
    // Bit 0 = I_JMP
    // ------------------------------------------------------------

    assign mode_internal[1] = 1'b1;
    assign mode_internal[0] = i_jmp;

    // ------------------------------------------------------------
    // PC_OP
    //
    // PC_OP[0] = TAKE_BRANCH & ~I_JMP
    // PC_OP[1] = I_JMP & ~TAKE_BRANCH
    // ------------------------------------------------------------

    assign pc_op_internal[0] = take_branch & ~i_jmp;
    assign pc_op_internal[1] = i_jmp & ~take_branch;

    // ------------------------------------------------------------
    // Habilitacao pelo grupo Jump
    // ------------------------------------------------------------

    assign HLT   = E & hlt_internal;
    assign MODE  = mode_internal  & {2{E}};
    assign PC_OP = pc_op_internal & {2{E}};

endmodule
