`ifndef TB_UTILS_SVH
`define TB_UTILS_SVH

int errors = 0;
int tests = 0;

localparam int MAXWIDTH = 256;
task automatic check;
    input string desc;
    input [MAXWIDTH-1:0] got, expected;
    input integer width;

    logic [MAXWIDTH-1:0] mask = '1 >> (MAXWIDTH - width);

    tests += 1;
    if ((got & mask) !== (expected & mask)) begin
        $display("FAIL: %s -> got %h, expected %h", desc, got & mask, expected & mask);
        errors += 1;
    end else $display("PASS: %s -> %h", desc, got & mask);
endtask

task automatic report;
    $display("---- %0d/%0d passed ----", tests - errors, tests);
    if (errors > 0) $fatal(1, "%0d test(s) failed!", errors);
endtask

`endif
