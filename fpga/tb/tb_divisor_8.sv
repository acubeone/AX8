`include "utils.svh"

module tb_divisor_8;
    logic clk = 0;
    logic rst_n = 1;
    logic done = 0;

    logic [7:0] in_q;
    logic [7:0] in_m;
    logic [8:0] in_acc;

    logic [7:0] out_q;
    logic [8:0] out_acc;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            in_q <= 8'h00;
            in_m <= 8'h00;
            in_acc <= 9'h000;
        end else begin
            in_q <= out_q;
            in_acc <= out_acc;
        end
    end

    divisor_8 uut (
        .done   (done),
        .in_q   (in_q),
        .in_m   (in_m),
        .in_acc (in_acc),
        .out_q  (out_q),
        .out_acc(out_acc)
    );

    task automatic drive;
        input logic [7:0] tin_q;
        input logic [7:0] tin_m;
        input logic [15:0] texp_y;

        logic [MAXWIDTH-1:0] gotbits, expbits;

        rst_n = 0;
        done = 0;
        #10 rst_n = 1;
        in_q = tin_q;
        in_m = tin_m;

        for (int i = 0; i < 8; i += 1) begin
            #10 clk = 1;
            #10 clk = 0;
        end
        #10 done = 1;
        #10 clk = 1;
        #10 clk = 0;

        gotbits = MAXWIDTH'({in_acc[7:0], in_q});
        expbits = MAXWIDTH'(texp_y);
        check($sformatf("q=%h m=%h", tin_q, tin_m), gotbits, expbits, $bits(texp_y));
    endtask

    initial begin
        $dumpfile("divisor_8.vcd");
        $dumpvars(0, tb_divisor_8);

        // drive(8'h00, 8'hff, 16'h0000);
        // drive(8'h01, 8'hff, 16'h0100);
        // drive(8'hff, 8'h01, 16'h00ff);
        // drive(8'hff, 8'hff, 16'h0001);
        // drive(8'h80, 8'h01, 16'h0080);
        // drive(8'h01, 8'h01, 16'h0001);
        // drive(8'h80, 8'h80, 16'h0001);
        // drive(8'hff, 8'h80, 16'h7f01);
        // drive(8'h80, 8'hff, 16'h8000);
        // drive(8'h7f, 8'h80, 16'h7f00);
        // drive(8'h80, 8'h7f, 16'h0101);
        // drive(8'hfe, 8'h02, 16'h007f);
        // drive(8'hfd, 8'h02, 16'h017e);
        // drive(8'hfe, 8'h03, 16'h0254);
        // drive(8'hff, 8'h03, 16'h0055);
        // drive(8'haa, 8'h55, 16'h0002);

        // Test all 65280 possible results
        for (logic [7:0] q = 0; q < 256; q += 1) begin
            for (logic [7:0] m = 1; m < 256; m += 1) begin
                drive(q, m, {q % m, q / m});
                if (m == 255) break;
            end
            if (q == 255) break;
        end

        report();
        $finish;
    end
endmodule
