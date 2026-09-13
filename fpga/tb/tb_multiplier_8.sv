`include "utils.svh"

module tb_multiplier_8;
    logic clk = 0;
    logic rst_n = 1;

    logic [7:0] in_q;
    logic [7:0] in_m;
    logic [7:0] in_acc;

    logic [7:0] out_q;
    logic [7:0] out_acc;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            in_q <= 8'h00;
            in_m <= 8'h00;
            in_acc <= 8'h00;
        end else begin
            in_q <= out_q;
            in_acc <= out_acc;
        end
    end

    multiplier_8 uut (
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
        #10 rst_n = 1;
        in_q = tin_q;
        in_m = tin_m;

        for (int i = 0; i < 8; i += 1) begin
            #10 clk = 1;
            #10 clk = 0;
        end

        gotbits = MAXWIDTH'({in_acc, in_q});
        expbits = MAXWIDTH'(texp_y);
        check($sformatf("q=%h m=%h", tin_q, tin_m), gotbits, expbits, $bits(texp_y));
    endtask

    initial begin
        $dumpfile("multiplier_8.vcd");
        $dumpvars(0, tb_multiplier_8);

        // drive(8'h00, 8'h00, 16'h0000);
        // drive(8'h00, 8'hff, 16'h0000);
        // drive(8'hff, 8'h00, 16'h0000);
        // drive(8'h01, 8'h01, 16'h0001);
        // drive(8'h01, 8'hff, 16'h00ff);
        // drive(8'hff, 8'h01, 16'h00ff);
        // drive(8'h02, 8'h80, 16'h0100);
        // drive(8'h80, 8'h02, 16'h0100);
        // drive(8'h10, 8'h10, 16'h0100);
        // drive(8'h0f, 8'h0f, 16'h00e1);
        // drive(8'h55, 8'haa, 16'h3872);
        // drive(8'hff, 8'hff, 16'hfe01);
        // drive(8'h80, 8'h80, 16'h4000);
        // drive(8'hc8, 8'hc8, 16'h9c40);
        // drive(8'h0a, 8'h0a, 16'h0064);
        // drive(8'h7f, 8'h02, 16'h00fe);

        // Test all 65536 possible results
        for (logic [7:0] q = 0; q < 256; q += 1) begin
            for (logic [7:0] m = 0; m < 256; m += 1) begin
                drive(q, m, q * m);
                if (m == 255) break;
            end
            if (q == 255) break;
        end

        report();
        $finish;
    end
endmodule
