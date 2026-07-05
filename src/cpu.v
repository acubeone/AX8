/* vim: set filetype=verilog : */
`timescale 1ns / 1ps

module cpu (
    input         CLK,
    input         RST_N,
    input         RDY,

    inout  tri0   HLT,
    inout  wire [7:0] DATA_BUS,

    output        RW,
    output [15:0] ADDR_BUS
);
    reg rst_sample = 1'b1;
    reg halted = 1'b0;
    reg seq_enable = 1'b0;

    reg [7:0] dl_q = 8'h00;
    reg [7:0] ir_q = 8'h00;
    reg [7:0] op_lo_q = 8'h00;
    reg [7:0] op_hi_q = 8'h00;

    reg [7:0] a_q = 8'h00;
    reg [7:0] ix_q = 8'h00;
    reg [7:0] iy_q = 8'h00;

    wire clk;
    wire rst_req;
    wire hlt_request;

    wire int_done;
    wire out_rst;
    wire int_mem_rw;
    wire int_op_lo_we;
    wire int_op_hi_we;
    wire [1:0] int_addr_sel;
    wire [1:0] int_pc_op;
    wire [3:0] int_fr_we;
    wire [3:0] int_fr_data;
    wire [3:0] int_vec;

    wire commit;
    wire seq_mem_rw;
    wire seq_dl_we;
    wire ir_we;
    wire seq_op_lo_we;
    wire seq_op_hi_we;
    wire [1:0] seq_addr_sel;
    wire [1:0] seq_pc_op;

    wire dec_hlt;
    wire dec_rw;
    wire alu_wb;
    wire [1:0] dec_pc_op;
    wire [1:0] dec_mode;
    wire [1:0] dst_sel;
    wire [2:0] src_sel;
    wire [3:0] dec_fr_we;
    wire [3:0] dec_fr_data;
    wire [3:0] alu_op;

    wire mem_rw;
    wire op_lo_we;
    wire op_hi_we;
    wire [1:0] addr_sel;
    wire [1:0] seq_int_pc_op;
    wire [1:0] pc_op;

    wire [3:0] pre_fr_we;
    wire [3:0] pre_fr_data;
    wire [3:0] fr_we;
    wire [3:0] fr_data;

    wire [7:0] alu_a;
    wire [7:0] alu_b;
    wire [7:0] alu_y;

    wire alu_z;
    wire alu_n;
    wire alu_c;
    wire alu_v;
    wire alu_hlt;

    wire [3:0] alu_fr_we;
    wire [3:0] alu_fr_data;

    wire alu_write;
    wire we_a;
    wire we_ix;
    wire we_iy;
    wire alu_dl_we;
    wire dl_we;
    wire [7:0] dl_data;

    wire [3:0] fr_q;
    wire [15:0] pc_q;

    wire [7:0] lo_pc;
    wire [7:0] hi_pc;
    wire [7:0] vec_lo;
    wire [7:0] lo_addr_bus;
    wire [7:0] hi_addr_bus;

    wire hlt_internal;

    assign clk = CLK & RDY & ~halted;

    assign rst_req = rst_sample & ~RST_N;

    always @(posedge CLK)
        rst_sample <= RST_N;

    // Bidirectional HLT line
    assign HLT = halted ? 1'b1 : 1'bz;
    assign hlt_request = HLT;

    assign hlt_internal =
        hlt_request |
        dec_hlt |
        alu_hlt;

    always @(posedge clk or posedge rst_req) begin
        if (rst_req)
            halted <= 1'b0;
        else
            halted <= halted |
                      hlt_request |
                      (commit & (dec_hlt | alu_hlt));
    end

    interrupt_sequencer u_interrupt_sequencer (
        .CLK       (clk),
        .RESET     (rst_req),
        .DONE      (int_done),
        .OUT_RST   (out_rst),
        .MEM_RW    (int_mem_rw),
        .OP_LO_WE  (int_op_lo_we),
        .OP_HI_WE  (int_op_hi_we),
        .ADDR_SEL  (int_addr_sel),
        .PC_OP     (int_pc_op),
        .FR_WE     (int_fr_we),
        .FR_DATA   (int_fr_data),
        .VEC       (int_vec)
    );

    always @(posedge clk or posedge rst_req) begin
        if (rst_req)
            seq_enable <= 1'b0;
        else
            seq_enable <= ~halted & int_done;
    end

    instruction_sequencer u_instruction_sequencer (
        .CLK       (clk),
        .RESET     (out_rst),
        .ENABLE    (seq_enable),
        .RW        (dec_rw),
        .PC_OP_IN  (dec_pc_op),
        .MODE      (dec_mode),
        .COMMIT    (commit),
        .MEM_RW    (seq_mem_rw),
        .DL_WE     (seq_dl_we),
        .IR_WE     (ir_we),
        .OP_LO_WE  (seq_op_lo_we),
        .OP_HI_WE  (seq_op_hi_we),
        .ADDR_SEL  (seq_addr_sel),
        .PC_OP     (seq_pc_op)
    );

    instruction_decoder u_instruction_decoder (
        .FR      (fr_q),
        .IR      (ir_q),
        .HLT     (dec_hlt),
        .RW      (dec_rw),
        .ALU_WB  (alu_wb),
        .PC_OP   (dec_pc_op),
        .MODE    (dec_mode),
        .DST_SEL (dst_sel),
        .SRC_SEL (src_sel),
        .FR_WE   (dec_fr_we),
        .FR_DATA (dec_fr_data),
        .ALU_OP  (alu_op)
    );

    assign mem_rw =
        int_done ? seq_mem_rw : int_mem_rw;

    assign op_lo_we =
        int_done ? seq_op_lo_we : int_op_lo_we;

    assign op_hi_we =
        int_done ? seq_op_hi_we : int_op_hi_we;

    assign addr_sel =
        int_done ? seq_addr_sel : int_addr_sel;

    assign seq_int_pc_op =
        int_done ? seq_pc_op : int_pc_op;

    assign pc_op =
        commit ? dec_pc_op : seq_int_pc_op;

    assign pre_fr_we =
        int_done ? dec_fr_we : int_fr_we;

    assign pre_fr_data =
        int_done ? dec_fr_data : int_fr_data;

    assign alu_a =
        (dst_sel == 2'b00) ? a_q :
        (dst_sel == 2'b01) ? ix_q :
        (dst_sel == 2'b10) ? iy_q :
                             dl_q;

    assign alu_b =
        (src_sel == 3'b000) ? a_q :
        (src_sel == 3'b001) ? ix_q :
        (src_sel == 3'b010) ? iy_q :
        (src_sel == 3'b011) ? dl_q :
        (src_sel == 3'b100) ? 8'h00 :
        (src_sel == 3'b101) ? 8'hff :
        (src_sel == 3'b110) ? 8'h00 :
                              8'hff;

    alu u_alu (
        .a    (alu_a),
        .b    (alu_b),
        .op   (alu_op),
        .cin  (fr_q[2]),
        .vin  (fr_q[3]),
        .y    (alu_y),
        .z    (alu_z),
        .n    (alu_n),
        .c    (alu_c),
        .v    (alu_v),
        .halt (alu_hlt)
    );

    assign alu_fr_data = {
        alu_v,
        alu_c,
        alu_n,
        alu_z
    };

    assign alu_fr_we =
        ((alu_op == 4'b0000) ||
         (alu_op == 4'b0001) ||
         (alu_op == 4'b0010)) ? 4'b1111 :
        ((alu_op == 4'b0110) ||
         (alu_op == 4'b0111)) ? 4'b0111 :
                                4'b0011;

    and a0 (alu_write, commit, alu_wb);

    assign we_a =
        alu_write & (dst_sel == 2'b00);

    assign we_ix =
        alu_write & (dst_sel == 2'b01);

    assign we_iy =
        alu_write & (dst_sel == 2'b10);

    assign alu_dl_we =
        alu_write & (dst_sel == 2'b11);

    or o0 (dl_we, seq_dl_we, alu_dl_we);

    assign dl_data =
        alu_write ? alu_y : DATA_BUS;

    assign fr_we =
        alu_write ? alu_fr_we : pre_fr_we;

    assign fr_data =
        alu_write ? alu_fr_data : pre_fr_data;

    always @(posedge clk or posedge rst_req) begin
        if (rst_req) begin
            dl_q    <= 8'h00;
            ir_q    <= 8'h00;
            op_lo_q <= 8'h00;
            op_hi_q <= 8'h00;
        end else begin
            if (dl_we)
                dl_q <= dl_data;

            if (ir_we)
                ir_q <= DATA_BUS;

            if (op_lo_we)
                op_lo_q <= DATA_BUS;

            if (op_hi_we)
                op_hi_q <= DATA_BUS;
        end
    end

    always @(posedge clk) begin
        if (we_a)
            a_q <= alu_y;

        if (we_ix)
            ix_q <= alu_y;

        if (we_iy)
            iy_q <= alu_y;
    end

    program_counter u_program_counter (
        .clk  (clk),
        .we   (1'b1),
        .op   (pc_op),
        .data ({op_hi_q, op_lo_q}),
        .pc   (pc_q)
    );

    flag_register u_flag_register (
        .clk     (clk),
        .fr_data (fr_data),
        .fr_we   (fr_we),
        .fr_q    (fr_q)
    );

    assign lo_pc = pc_q[7:0];
    assign hi_pc = pc_q[15:8];

    assign vec_lo = {
        4'hf,
        int_vec
    };

    assign lo_addr_bus =
        (addr_sel == 2'b00) ? lo_pc :
        (addr_sel == 2'b01) ? op_lo_q :
        (addr_sel == 2'b10) ? iy_q :
                              vec_lo;

    assign hi_addr_bus =
        (addr_sel == 2'b00) ? hi_pc :
        (addr_sel == 2'b01) ? op_hi_q :
        (addr_sel == 2'b10) ? 8'h00 :
                              8'hff;

    assign ADDR_BUS = {
        hi_addr_bus,
        lo_addr_bus
    };

    assign RW = mem_rw;

    // CPU releases DATA_BUS during read
    assign DATA_BUS =
        mem_rw ? 8'bz : dl_q;

endmodule
