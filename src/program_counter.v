`timescale 1ns / 1ps

module program_counter (
    input  wire        clk,
    input  wire        we,
    input  wire [1:0]  op,
    input  wire [15:0] data,
    output reg  [15:0] pc
);

    wire is_add;
    wire is_load;
    wire is_inc;

    wire [15:0] pc_next;

    /*
        Mapeamento confirmado no Logisim:

        OP = 00 -> mantém PC
        OP = 01 -> PC = PC + DATA
        OP = 10 -> PC = DATA
        OP = 11 -> PC = PC + 1
    */

    assign is_add  = ~op[1] &  op[0]; // OP = 01
    assign is_load =  op[1] & ~op[0]; // OP = 10
    assign is_inc  =  op[1] &  op[0]; // OP = 11

    assign pc_next = is_add  ? (pc + data) :
                     is_load ? data :
                     is_inc  ? (pc + 16'h0001) :
                               pc;

    initial begin
        pc = 16'h0000;
    end

    always @(posedge clk) begin
        if (we)
            pc <= pc_next;
    end

endmodule
