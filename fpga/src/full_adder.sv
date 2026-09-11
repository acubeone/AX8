module full_adder (
    input  a,
    input  b,
    input  cin,
    output y,
    output cout
);
    wire halfadd;
    assign halfadd = a ^ b;

    assign y = halfadd ^ cin;
    assign cout = (a & b) | (halfadd & cin);
endmodule
