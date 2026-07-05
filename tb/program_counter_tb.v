`timescale 1ns / 1ps

module program_counter_tb;

    reg         clk;
    reg         we;
    reg  [1:0]  op;
    reg  [15:0] data;
    wire [15:0] pc;

    program_counter uut (
        .clk(clk),
        .we(we),
        .op(op),
        .data(data),
        .pc(pc)
    );

    task tick;
        begin
            #5 clk = 1;
            #5 clk = 0;
        end
    endtask

    initial begin
        $dumpfile("program_counter.vcd");
        $dumpvars(0, program_counter_tb);

        clk  = 0;
        we   = 0;
        op   = 2'b00;
        data = 16'h0000;

        $display("================================================");
        $display(" we | op |   data   |    pc    | observacao");
        $display("================================================");

        #1;
        $display(" %b  | %b |  %h   |  %h   | inicial", we, op, data, pc);

        // Teste WE=0: mesmo com OP=11, PC não muda
        we   = 0;
        op   = 2'b11;
        data = 16'h0000;
        tick();
        $display(" %b  | %b |  %h   |  %h   | WE=0, mantem", we, op, data, pc);

        // OP=00: mantém PC
        we   = 1;
        op   = 2'b00;
        data = 16'h0005;
        tick();
        $display(" %b  | %b |  %h   |  %h   | OP=00, mantem", we, op, data, pc);

        // OP=11: incrementa PC
        op   = 2'b11;
        data = 16'h0000;
        tick();
        $display(" %b  | %b |  %h   |  %h   | OP=11, incrementa", we, op, data, pc);

        tick();
        $display(" %b  | %b |  %h   |  %h   | OP=11, incrementa de novo", we, op, data, pc);

        tick();
        $display(" %b  | %b |  %h   |  %h   | OP=11, incrementa mais uma vez", we, op, data, pc);

        // Agora PC deve estar 0003

        // OP=01: PC = PC + DATA
        op   = 2'b01;
        data = 16'h0005;
        tick();
        $display(" %b  | %b |  %h   |  %h   | OP=01, PC = PC + DATA", we, op, data, pc);

        // Agora PC deve estar 0008

        tick();
        $display(" %b  | %b |  %h   |  %h   | OP=01, soma DATA de novo", we, op, data, pc);

        // Agora PC deve estar 000D

        // OP=10: PC = DATA
        op   = 2'b10;
        data = 16'h0005;
        tick();
        $display(" %b  | %b |  %h   |  %h   | OP=10, PC = DATA", we, op, data, pc);

        // OP=10 com outro valor
        op   = 2'b10;
        data = 16'h0100;
        tick();
        $display(" %b  | %b |  %h   |  %h   | OP=10, PC = DATA 0100", we, op, data, pc);

        // Teste carry: 00FF + 1 = 0100
        op   = 2'b10;
        data = 16'h00FF;
        tick();
        $display(" %b  | %b |  %h   |  %h   | carrega 00FF", we, op, data, pc);

        op   = 2'b11;
        data = 16'h0000;
        tick();
        $display(" %b  | %b |  %h   |  %h   | 00FF + 1", we, op, data, pc);

        $display("================================================");
        $finish;
    end

endmodule
