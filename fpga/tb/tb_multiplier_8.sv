`include "utils.svh"

module tb_multiplier_8;
    reg         clk = 0;
    reg         rst_n = 1;
    logic [7:0] in_m;
    logic [7:0] in_q;

    logic [15:0] out_y;
    logic [ 7:0] out_m;
    logic [ 7:0] out_q;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            in_m <= 8'h00;
            in_q <= 8'h00;
        end else begin
            in_m <= out_m;
            in_q <= out_q;
        end
    end

    multiplier_8 uut (
        .clk  (clk),
        .rst_n(rst_n),
        .in_m (in_m),
        .in_q (in_q),
        .y    (out_y),
        .out_m(out_m),
        .out_q(out_q)
    );

    task automatic drive;
        input logic [7:0] tin_m;
        input logic [7:0] tin_q;
        input logic [15:0] texp_y;

        logic [MAXWIDTH-1:0] gotbits, expbits;

        rst_n = 0;
        #10 rst_n = 1;
        in_m = tin_m;
        in_q = tin_q;

        for (int i = 0; i < 8; i += 1) begin
            #10 clk = 1;
            #10 clk = 0;
        end

        gotbits = MAXWIDTH'(out_y);
        expbits = MAXWIDTH'(texp_y);
        check($sformatf("m=%h q=%h", tin_m, tin_q), gotbits, expbits, $bits(texp_y));
    endtask

    initial begin
        $dumpfile("multiplier_8.vcd");
        $dumpvars(0, tb_multiplier_8);

        drive(8'h00, 8'h00, 16'h0000);
        drive(8'h00, 8'hff, 16'h0000);
        drive(8'hff, 8'h00, 16'h0000);
        drive(8'h01, 8'h01, 16'h0001);
        drive(8'h01, 8'hff, 16'h00ff);
        drive(8'hff, 8'h01, 16'h00ff);
        drive(8'h02, 8'h80, 16'h0100);
        drive(8'h80, 8'h02, 16'h0100);
        drive(8'h10, 8'h10, 16'h0100);
        drive(8'h0f, 8'h0f, 16'h00e1);
        drive(8'h55, 8'haa, 16'h3872);
        drive(8'hff, 8'hff, 16'hfe01);
        drive(8'h80, 8'h80, 16'h4000);
        drive(8'hc8, 8'hc8, 16'h9c40);
        drive(8'h0a, 8'h0a, 16'h0064);
        drive(8'h7f, 8'h02, 16'h00fe);

        report();
        $finish;
    end
endmodule
