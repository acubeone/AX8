`timescale 1ns / 1ps

module flag_register_tb;

    reg        clk;
    reg  [3:0] fr_data;
    reg  [3:0] fr_we;
    wire [3:0] fr_q;

    flag_register uut (
        .clk(clk),
        .fr_data(fr_data),
        .fr_we(fr_we),
        .fr_q(fr_q)
    );

    task tick;
        begin
            #5 clk = 1;
            #5 clk = 0;
        end
    endtask

    initial begin
        $dumpfile("flag_register.vcd");
        $dumpvars(0, flag_register_tb);

        clk     = 0;
        fr_data = 4'b0000;
        fr_we   = 4'b0000;

        $display("======================================");
        $display(" fr_we | fr_data | fr_q | observacao");
        $display("======================================");

        #1;
        $display(" %b  |  %b   | %b | inicial", fr_we, fr_data, fr_q);

        // Tenta escrever 1111, mas FR_WE=0000, então não muda nada
        fr_data = 4'b1111;
        fr_we   = 4'b0000;
        tick();
        $display(" %b  |  %b   | %b | nao escreve nada", fr_we, fr_data, fr_q);

        // Escreve só Z
        fr_data = 4'b0001;
        fr_we   = 4'b0001;
        tick();
        $display(" %b  |  %b   | %b | escreve Z", fr_we, fr_data, fr_q);

        // Escreve só N
        fr_data = 4'b0010;
        fr_we   = 4'b0010;
        tick();
        $display(" %b  |  %b   | %b | escreve N", fr_we, fr_data, fr_q);

        // Escreve só C
        fr_data = 4'b0100;
        fr_we   = 4'b0100;
        tick();
        $display(" %b  |  %b   | %b | escreve C", fr_we, fr_data, fr_q);

        // Escreve só V
        fr_data = 4'b1000;
        fr_we   = 4'b1000;
        tick();
        $display(" %b  |  %b   | %b | escreve V", fr_we, fr_data, fr_q);

        // Escreve todas as flags
        fr_data = 4'b1010;
        fr_we   = 4'b1111;
        tick();
        $display(" %b  |  %b   | %b | escreve todas", fr_we, fr_data, fr_q);

        // Muda FR_DATA, mas sem WE, deve manter 1010
        fr_data = 4'b0101;
        fr_we   = 4'b0000;
        tick();
        $display(" %b  |  %b   | %b | mantem valor", fr_we, fr_data, fr_q);

        $display("======================================");
        $finish;
    end

endmodule
