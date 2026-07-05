`timescale 1ns / 1ps

module toplevel_tb;

    reg CLK;
    reg RESET;
    reg RDY;
    reg ext_hlt;

    tri0 HLT;
    tri [7:0] DATA_BUS;

    wire RW;
    wire [15:0] ADDR_BUS;

    integer errors;
    integer cycles;

    reg saw_fff0;
    reg saw_fff1;
    reg saw_8000;
    reg saw_8001;

    assign HLT =
        ext_hlt ? 1'b1 : 1'bz;

    toplevel #(
        .ROM_FILE("../tb/toplevel_test.hex")
    ) uut (
        .CLK      (CLK),
        .RESET    (RESET),
        .RDY      (RDY),
        .HLT      (HLT),
        .DATA_BUS (DATA_BUS),
        .RW       (RW),
        .ADDR_BUS (ADDR_BUS)
    );

    always #5 CLK = ~CLK;

    always @(negedge CLK) begin
        if (ADDR_BUS == 16'hfff0)
            saw_fff0 = 1;

        if (ADDR_BUS == 16'hfff1)
            saw_fff1 = 1;

        if (ADDR_BUS == 16'h8000)
            saw_8000 = 1;

        if (ADDR_BUS == 16'h8001)
            saw_8001 = 1;
    end

    initial begin
        $dumpfile("toplevel.vcd");
        $dumpvars(0, toplevel_tb);

        CLK = 0;
        RESET = 0;
        RDY = 1;
        ext_hlt = 0;

        errors = 0;
        cycles = 0;

        saw_fff0 = 0;
        saw_fff1 = 0;
        saw_8000 = 0;
        saw_8001 = 0;

        #2;
        RESET = 1;

        #12;
        RESET = 0;

        while ((HLT !== 1'b1) && cycles < 150) begin
            @(negedge CLK);
            #1;

            cycles = cycles + 1;

            $display(
                "CYCLE=%0d ADDR=%04h DATA=%02h RW=%b HLT=%b",
                cycles,
                ADDR_BUS,
                DATA_BUS,
                RW,
                HLT
            );
        end

        $display("----------------------------------------");
        $display("FFF0=%b", saw_fff0);
        $display("FFF1=%b", saw_fff1);
        $display("8000=%b", saw_8000);
        $display("8001=%b", saw_8001);
        $display("HLT=%b", HLT);
        $display("----------------------------------------");

        if (!saw_fff0)
            errors = errors + 1;

        if (!saw_fff1)
            errors = errors + 1;

        if (!saw_8000)
            errors = errors + 1;

        if (!saw_8001)
            errors = errors + 1;

        if (HLT !== 1'b1)
            errors = errors + 1;

        if (errors == 0)
            $display("PASS: todos os testes passaram.");
        else
            $display("FAIL: %0d teste(s) falharam.", errors);

        #10;
        $finish;
    end

endmodule
