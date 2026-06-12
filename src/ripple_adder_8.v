module ripple_adder_8 (
    input [7:0] a,
    input [7:0] b,
    input cin,
    output [7:0] y,
    output cout
);
  wire w0;
  wire [3:0] lo_y;
  wire [3:0] hi_y;

  assign y = {hi_y, lo_y};

  ripple_adder_4 ra4_0 (
      .a(a[3:0]),
      .b(b[3:0]),
      .cin(cin),
      .y(lo_y),
      .cout(w0)
  );
  ripple_adder_4 ra4_1 (
      .a(a[7:4]),
      .b(b[7:4]),
      .cin(w0),
      .y(hi_y),
      .cout(cout)
  );
endmodule
