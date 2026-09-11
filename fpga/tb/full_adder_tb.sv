`include "utils.svh"

module full_adder_tb;
    typedef struct packed {
        logic a, b, cin;  //
    } Input;

    typedef struct packed {
        logic y, cout;  //
    } Output;

    Input  in;
    Output out;

    wire w_in_a = in.a;
    wire w_in_b = in.b;
    wire w_in_cin = in.cin;
    wire w_out_y = out.y;
    wire w_out_cout = out.cout;

    full_adder uut (
        .a   (in.a),
        .b   (in.b),
        .cin (in.cin),
        .y   (out.y),
        .cout(out.cout)
    );

    task automatic drive;
        input Input tin;
        input Output texpected;

        logic [MAXWIDTH-1:0] gotbits, expbits;

        in.a = tin.a;
        in.b = tin.b;
        in.cin = tin.cin;
        #10;

        gotbits = MAXWIDTH'(out);
        expbits = MAXWIDTH'(texpected);
        check($sformatf("a=%b b=%b cin=%b", tin.a, tin.b, tin.cin), gotbits, expbits,
              $bits(Output));
    endtask

    initial begin
        $dumpfile("full_adder.vcd");
        $dumpvars(0, full_adder_tb);

        drive('{0, 0, 0}, '{0, 0});
        drive('{1, 0, 0}, '{1, 0});
        drive('{0, 1, 0}, '{1, 0});
        drive('{1, 1, 0}, '{0, 1});
        drive('{0, 0, 1}, '{1, 0});
        drive('{1, 0, 1}, '{0, 1});
        drive('{1, 1, 1}, '{1, 1});

        report();
        $finish;
    end
endmodule
