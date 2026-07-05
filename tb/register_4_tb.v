`timescale 1ns / 1ps

module register_4_tb;

    reg        clk;
    reg        we;
    reg  [3:0] d;
    wire [3:0] q;

    register_4 uut (
        .clk(clk),
        .we(we),
        .d(d),
        .q(q)
    );

    task tick;
        begin
            #5 clk = 1;
            #5 clk = 0;
        end
    endtask

    initial begin
        $dumpfile("register_4.vcd");
        $dumpvars(0, register_4_tb);

        clk = 0;
        we  = 0;
        d   = 4'b0000;

        $display("==============================");
        $display(" we |   d   |   q   | status");
        $display("==============================");

        #1;
        $display(" %b  |  %b  |  %b  | inicial", we, d, q);

        // WE=0, tenta mudar D, mas Q deve continuar 0000
        we = 0;
        d  = 4'b1010;
        tick();
        $display(" %b  |  %b  |  %b  | WE=0, deve manter", we, d, q);

        // WE=1, carrega D=1010
        we = 1;
        d  = 4'b1010;
        tick();
        $display(" %b  |  %b  |  %b  | WE=1, carrega D", we, d, q);

        // WE=0, muda D para 0101, mas Q deve continuar 1010
        we = 0;
        d  = 4'b0101;
        tick();
        $display(" %b  |  %b  |  %b  | WE=0, mantém Q", we, d, q);

        // WE=1, carrega D=0101
        we = 1;
        d  = 4'b0101;
        tick();
        $display(" %b  |  %b  |  %b  | WE=1, carrega novo D", we, d, q);

        // WE=1, carrega D=1111
        we = 1;
        d  = 4'b1111;
        tick();
        $display(" %b  |  %b  |  %b  | WE=1, carrega 1111", we, d, q);

        $display("==============================");
        $finish;
    end

endmodule
