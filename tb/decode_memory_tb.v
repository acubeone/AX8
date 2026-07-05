`timescale 1ns / 1ps

module decode_memory_tb;

    reg        E;
    reg  [3:0] FR;
    reg  [7:0] IR;

    wire       HLT;
    wire       MEM_RW;
    wire       ALU_WB;
    wire [1:0] MODE;
    wire [1:0] DST_SEL;
    wire [2:0] SRC_SEL;
    wire [3:0] ALU_OP;

    integer errors;

    decode_memory uut (
        .E(E),
        .FR(FR),
        .IR(IR),
        .HLT(HLT),
        .MEM_RW(MEM_RW),
        .ALU_WB(ALU_WB),
        .MODE(MODE),
        .DST_SEL(DST_SEL),
        .SRC_SEL(SRC_SEL),
        .ALU_OP(ALU_OP)
    );

    task test_case;
        input [8*32-1:0] name;
        input             e_i;
        input [3:0]       fr_i;
        input [7:0]       ir_i;
        begin
            E  = e_i;
            FR = fr_i;
            IR = ir_i;

            #10;

            $display(
                "%0s | E=%b FR=%04b IR=%08b | HLT=%b MEM_RW=%b ALU_WB=%b MODE=%02b DST=%02b SRC=%03b ALU_OP=%04b",
                name, E, FR, IR,
                HLT, MEM_RW, ALU_WB,
                MODE, DST_SEL, SRC_SEL, ALU_OP
            );
        end
    endtask

    initial begin
        $dumpfile("decode_memory.vcd");
        $dumpvars(0, decode_memory_tb);

        errors = 0;

        test_case(
            "E=0",
            1'b0,
            4'b1111,
            8'b00011100
        );

        test_case(
            "DIRECT READ",
            1'b1,
            4'b0000,
            8'b00000000
        );

        test_case(
            "DIRECT WRITE",
            1'b1,
            4'b0000,
            8'b00000101
        );

        test_case(
            "INDIRECT READ",
            1'b1,
            4'b0000,
            8'b00001000
        );

        test_case(
            "INDIRECT WRITE",
            1'b1,
            4'b0000,
            8'b00001101
        );

        test_case(
            "TRX",
            1'b1,
            4'b0000,
            8'b00010110
        );

        test_case(
            "HLT 1",
            1'b1,
            4'b0000,
            8'b00000011
        );

        test_case(
            "HLT 2",
            1'b1,
            4'b0000,
            8'b00011100
        );

        #10;
        $finish;
    end

endmodule
