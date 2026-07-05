/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module toplevel #(
    parameter ROM_FILE = ""
) (
    input         CLK,
    input         RESET,
    input         RDY,

    inout  tri0   HLT,
    inout  wire [7:0] DATA_BUS,

    output        RW,
    output [15:0] ADDR_BUS
);
    wire [14:0] decoded_addr;
    wire sel_rom;

    wire [7:0] ram_data;
    wire [7:0] rom_data;

    reg [7:0] ram [0:32767];
    reg [7:0] rom [0:32767];

    integer i;

    assign decoded_addr = ADDR_BUS[14:0];
    assign sel_rom = ADDR_BUS[15];

    assign ram_data = ram[decoded_addr];
    assign rom_data = rom[decoded_addr];

    // Memory drives the bus only during read
    assign DATA_BUS =
        (RW && !sel_rom) ? ram_data :
        (RW &&  sel_rom) ? rom_data :
                           8'bz;

    always @(posedge CLK) begin
        if (!RW && !sel_rom)
            ram[decoded_addr] <= DATA_BUS;
    end

    initial begin
        for (i = 0; i < 32768; i = i + 1) begin
            ram[i] = 8'h00;
            rom[i] = 8'h00;
        end

        if (ROM_FILE != "")
            $readmemh(ROM_FILE, rom);
    end

    cpu u_cpu (
        .CLK      (CLK),
        .RST_N    (~RESET),
        .RDY      (RDY),
        .HLT      (HLT),
        .DATA_BUS (DATA_BUS),
        .RW       (RW),
        .ADDR_BUS (ADDR_BUS)
    );

endmodule
