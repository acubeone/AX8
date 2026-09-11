`include "utils.svh"

module adder_subtractor_8_tb;
    typedef struct packed {
        logic [7:0] a, b;
        logic cin, mode;
    } Input;

    typedef struct packed {
        logic [7:0] y;
        logic cout, vout;
    } Output;

    Input  in;
    Output out;

    wire [7:0] w_in_a = in.a;
    wire [7:0] w_in_b = in.b;
    wire       w_in_cin = in.cin;
    wire       w_in_mode = in.mode;
    wire [7:0] w_out_y = out.y;
    wire       w_out_cout = out.cout;
    wire       w_out_vout = out.vout;

    adder_subtractor_8 uut (
        .a   (in.a),
        .b   (in.b),
        .cin (in.cin),
        .mode(in.mode),
        .y   (out.y),
        .cout(out.cout),
        .vout(out.vout)
    );

    task automatic drive;
        input Input tin;
        input Output texpected;

        logic [MAXWIDTH-1:0] gotbits, expbits;

        in.a = tin.a;
        in.b = tin.b;
        in.cin = tin.cin;
        in.mode = tin.mode;
        #10;

        gotbits = MAXWIDTH'(out);
        expbits = MAXWIDTH'(texpected);
        check($sformatf("a=%h b=%h cin=%b mode=%b", tin.a, tin.b, tin.cin, tin.mode),
              gotbits, expbits, $bits(Output));
    endtask

    initial begin
        $dumpfile("adder_subtractor_8.vcd");
        $dumpvars(0, adder_subtractor_8_tb);

        // ADD (m=0) - basic
        drive('{8'h00, 8'h00, 0, 0}, '{8'h00, 0, 0});  // 0 + 0 = 0
        drive('{8'h01, 8'h01, 0, 0}, '{8'h02, 0, 0});  // 1 + 1 = 2
        drive('{8'h00, 8'h10, 0, 0}, '{8'h10, 0, 0});  // 0 + 16 = 16
        drive('{8'hF0, 8'h10, 0, 0}, '{8'h00, 1, 0});  // carry out
        drive('{8'hFF, 8'hFF, 0, 0}, '{8'hFE, 1, 0});  // max + max
        drive('{8'hFF, 8'hFF, 1, 0}, '{8'hFF, 1, 0});  // max + max + cin

        // ADD (m=0) - cin
        drive('{8'h00, 8'h00, 1, 0}, '{8'h01, 0, 0});  // 0 + 0 + 1 = 1
        drive('{8'h00, 8'h10, 1, 0}, '{8'h11, 0, 0});  // 0 + 16 + 1 = 17
        drive('{8'hF0, 8'h10, 1, 0}, '{8'h01, 1, 0});  // carry out with cin

        // ADD (m=0) - signed overflow (V=1)
        drive('{8'h70, 8'h10, 0, 0}, '{8'h80, 0, 1});  // +112 + +16 = -128 overflow
        drive('{8'h7F, 8'h01, 0, 0}, '{8'h80, 0, 1});  // +127 + +1  = -128 overflow
        drive('{8'h90, 8'h90, 0, 0}, '{8'h20, 1, 1});  // -112 + -112 = +32 overflow
        drive('{8'h80, 8'h80, 0, 0}, '{8'h00, 1, 1});  // -128 + -128 = 0 no overflow

        // ADD (m=0) - no signed overflow
        drive('{8'h70, 8'h0F, 0, 0}, '{8'h7F, 0, 0});  // +112 + +15 = +127 no overflow
        drive('{8'h80, 8'h0E, 0, 0}, '{8'h8E, 0, 0});  // -128 + +15 = -114 no overflow

        // SUB (m=1) - basic, cin=1 means no borrow
        drive('{8'h10, 8'h10, 1, 1}, '{8'h00, 1, 0});  // 16 - 16 = 0
        drive('{8'h20, 8'h10, 1, 1}, '{8'h10, 1, 0});  // 32 - 16 = 16
        drive('{8'hFF, 8'h01, 1, 1}, '{8'hFE, 1, 0});  // 255 - 1 = 254
        drive('{8'h00, 8'h01, 1, 1}, '{8'hFF, 0, 0});  // 0 - 1 = borrow

        // SUB (m=1) - cin=0 means borrow in
        drive('{8'h10, 8'h10, 0, 1}, '{8'hFF, 0, 0});  // 16 - 16 - 1 = -1
        drive('{8'h20, 8'h10, 0, 1}, '{8'h0F, 1, 0});  // 32 - 16 - 1 = 15

        // SUB (m=1) - signed overflow (V=1)
        drive('{8'h80, 8'h01, 1, 1}, '{8'h7F, 1, 1});  // -128 - +1  = +127 overflow
        drive('{8'h7F, 8'hFF, 1, 1}, '{8'h80, 0, 1});  // +127 - -1  = -128 overflow

        // SUB (m=1) - no signed overflow
        drive('{8'h70, 8'h10, 1, 1}, '{8'h60, 1, 0});  // +112 - +16 = +96
        drive('{8'h80, 8'h90, 1, 1}, '{8'hF0, 0, 0});  // -128 - -112 = -16

        report();
        $finish;
    end
endmodule
