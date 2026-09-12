`include "utils.svh"

module tb_sign_bridge_8;
    typedef struct packed {
        logic [7:0] a;
        logic sign, chain_in;
    } Input;

    typedef struct packed {
        logic [7:0] y;
        logic chain_out;
    } Output;

    Input  in;
    Output out;

    wire [7:0] w_in_a = in.a;
    wire       w_in_sign = in.sign;
    wire       w_in_chain_in = in.chain_in;
    wire [7:0] w_out_y = out.y;
    wire       w_out_chain_out = out.chain_out;

    sign_bridge_8 uut (
        .a        (in.a),
        .sign     (in.sign),
        .chain_in (in.chain_in),
        .y        (out.y),
        .chain_out(out.chain_out)
    );

    task automatic drive;
        input Input tin;
        input Output texpected;

        logic [MAXWIDTH-1:0] gotbits, expbits;

        in.a = tin.a;
        in.sign = tin.sign;
        in.chain_in = tin.chain_in;
        #10;

        gotbits = MAXWIDTH'(out);
        expbits = MAXWIDTH'(texpected);
        check($sformatf("a=%h sign=%b chain_in=%b", tin.a, tin.sign, tin.chain_in),
              gotbits, expbits, $bits(Output));
    endtask

    initial begin
        $dumpfile("sign_bridge_8");
        $dumpvars(0, tb_sign_bridge_8);

        drive('{8'h00, 0, 0}, '{8'h00, 0});
        drive('{8'h00, 0, 1}, '{8'h00, 1});
        drive('{8'h00, 1, 0}, '{8'h00, 0});
        drive('{8'h00, 1, 1}, '{8'hff, 1});
        drive('{8'h01, 1, 0}, '{8'hff, 1});
        drive('{8'h02, 1, 0}, '{8'hfe, 1});
        drive('{8'hff, 1, 0}, '{8'h01, 1});
        drive('{8'h80, 1, 0}, '{8'h80, 1});
        drive('{8'h55, 0, 0}, '{8'h55, 1});
        drive('{8'haa, 1, 1}, '{8'h55, 1});
        drive('{8'h10, 1, 1}, '{8'hef, 1});
        drive('{8'hff, 0, 1}, '{8'hff, 1});
        drive('{8'h7f, 1, 0}, '{8'h81, 1});
        drive('{8'h01, 1, 1}, '{8'hfe, 1});
        drive('{8'h03, 0, 1}, '{8'h03, 1});
        drive('{8'hc0, 1, 0}, '{8'h40, 1});

        report();
        $finish;
    end
endmodule
