`timescale 1ns / 1ps

module cpu_tb;

    reg CLK;
    reg RST_N;
    reg RDY;

    reg ext_hlt;

    tri0 HLT;
    tri [7:0] DATA_BUS;

    wire RW;
    wire [15:0] ADDR_BUS;

    reg [7:0] memory_data;

    integer errors;
    integer cycles;

    assign HLT =
        ext_hlt ? 1'b1 : 1'bz;

    assign DATA_BUS =
        RW ? memory_data : 8'bz;

    always @(*) begin
        case (ADDR_BUS)
            16'hfff0: memory_data = 8'h00;
            16'hfff1: memory_data = 8'h20;

            16'h2000: memory_data = 8'h00;
            16'h2001: memory_data = 8'h1f;

            default: memory_data = 8'h00;
        endcase
    end

    cpu uut (
        .CLK      (CLK),
        .RST_N    (RST_N),
        .RDY      (RDY),
        .HLT      (HLT),
        .DATA_BUS (DATA_BUS),
        .RW       (RW),
        .ADDR_BUS (ADDR_BUS)
    );

    always #5 CLK = ~CLK;

    task show_state;
        input [8*28-1:0] name;

        begin
            $display(
                "%0s | HLT=%b RW=%b ADDR=%04h DATA=%02h PC=%04h IR=%02h",
                name,
                HLT,
                RW,
                ADDR_BUS,
                DATA_BUS,
                uut.pc_q,
                uut.ir_q
            );
        end
    endtask

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, cpu_tb);

        CLK = 0;
        RST_N = 1;
        RDY = 1;
        ext_hlt = 0;

        errors = 0;

        #2;
        RST_N = 0;

        #12;
        RST_N = 1;

        cycles = 0;

        while ((ADDR_BUS !== 16'hfff0) && cycles < 30) begin
            @(negedge CLK);
            cycles = cycles + 1;
        end

        show_state("RESET VECTOR LOW");

        if (ADDR_BUS !== 16'hfff0)
            errors = errors + 1;

        cycles = 0;

        while ((ADDR_BUS !== 16'hfff1) && cycles < 30) begin
            @(negedge CLK);
            cycles = cycles + 1;
        end

        show_state("RESET VECTOR HIGH");

        if (ADDR_BUS !== 16'hfff1)
            errors = errors + 1;

        cycles = 0;

        while ((ADDR_BUS !== 16'h2000) && cycles < 50) begin
            @(negedge CLK);
            cycles = cycles + 1;
        end

        show_state("FETCH NOP");

        if (ADDR_BUS !== 16'h2000)
            errors = errors + 1;

        cycles = 0;

        while ((ADDR_BUS !== 16'h2001) && cycles < 50) begin
            @(negedge CLK);
            cycles = cycles + 1;
        end

        show_state("FETCH HLT");

        if (ADDR_BUS !== 16'h2001)
            errors = errors + 1;

        cycles = 0;

        while ((HLT !== 1'b1) && cycles < 50) begin
            @(negedge CLK);
            cycles = cycles + 1;
        end

        show_state("INTERNAL HLT");

        if (HLT !== 1'b1)
            errors = errors + 1;

        RST_N = 0;
        #12;
        RST_N = 1;

        ext_hlt = 1;

        @(posedge CLK);
        #1;

        show_state("EXTERNAL HLT");

        if (HLT !== 1'b1)
            errors = errors + 1;

        ext_hlt = 0;

        #2;

        show_state("CPU HOLDS HLT");

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
