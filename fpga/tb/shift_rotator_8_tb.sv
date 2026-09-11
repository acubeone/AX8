`include "utils.svh"

module shift_rotator_8_tb;
    typedef struct packed {
        logic [7:0] a;
        logic dir, cin;
    } Input;

    typedef struct packed {
        logic [7:0] y;
        logic cout;
    } Output;

    Input  in;
    Output out;

    wire [7:0] w_in_a = in.a;
    wire       w_in_dir = in.dir;
    wire       w_in_cin = in.cin;
    wire [7:0] w_out_y = out.y;
    wire       w_out_cout = out.cout;

    shift_rotator_8 uut (
        .a   (in.a),
        .dir (in.dir),
        .cin (in.cin),
        .y   (out.y),
        .cout(out.cout)
    );

    task automatic drive;
        input Input tin;
        input Output texpected;

        logic [MAXWIDTH-1:0] gotbits, expbits;

        in.a = tin.a;
        in.cin = tin.cin;
        in.dir = tin.dir;
        #10;

        gotbits = MAXWIDTH'(out);
        expbits = MAXWIDTH'(texpected);
        check($sformatf("a=%h dir=%b cin=%b", tin.a, tin.dir, tin.cin), gotbits, expbits,
              $bits(Output));
    endtask

    initial begin
        $dumpfile("shift_rotator_8.vcd");
        $dumpvars(0, shift_rotator_8_tb);

        // dir="left", cin=0 -> cout=0
        drive('{8'h01, 0, 0}, '{8'h02, 0});
        drive('{8'h03, 0, 0}, '{8'h06, 0});

        // dir="right", cin=0 -> cout=0
        drive('{8'h70, 1, 0}, '{8'h38, 0});
        drive('{8'hf0, 1, 0}, '{8'h78, 0});

        // dir="left", cin=1 -> cout=0
        drive('{8'h01, 0, 1}, '{8'h03, 0});
        drive('{8'h03, 0, 1}, '{8'h07, 0});

        // dir="right", cin=1 -> cout=0
        drive('{8'h70, 1, 1}, '{8'hb8, 0});
        drive('{8'hf0, 1, 1}, '{8'hf8, 0});

        // dir="left", cin=0 -> cout=1
        drive('{8'h81, 0, 0}, '{8'h02, 1});
        drive('{8'h83, 0, 0}, '{8'h06, 1});

        // dir="right", cin=0 -> cout=1
        drive('{8'h71, 1, 0}, '{8'h38, 1});
        drive('{8'hf1, 1, 0}, '{8'h78, 1});

        // dir="left", cin=1 -> cout=1
        drive('{8'h81, 0, 1}, '{8'h03, 1});
        drive('{8'h83, 0, 1}, '{8'h07, 1});

        // dir="right", cin=1 -> cout=1
        drive('{8'h71, 1, 1}, '{8'hb8, 1});
        drive('{8'hf1, 1, 1}, '{8'hf8, 1});

        report();
        $finish;
    end
endmodule
