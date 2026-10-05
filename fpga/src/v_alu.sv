module v_alu (
    input        [1:0] phase,     // 00=LOAD, 01=RUN, 10=CORRECT, 11=UNUSED
    input        [1:0] op,        // 00=MULU, 01=DIVU, 10=MULS, 11=DIVS
    input        [8:0] in_acc,
    input        [7:0] in_q,
    input        [7:0] in_m,
    input        [7:0] in_a,      // Operand A
    input        [7:0] in_b,      // Operand B
    output             z_flag,
    output             n_flag,
    output             dbz_flag,  // Division by Zero, only valid when 'abort=1'
    output             abort,     // Skip RUN phase
    output logic [8:0] out_acc,
    output logic [7:0] out_m,
    output logic [7:0] out_q
);
    localparam PHASE_LOAD = 2'b00;
    localparam PHASE_RUN = 2'b01;
    localparam PHASE_CORRECT = 2'b1x;  // Shallow 'UNUSED'

    wire is_div = op[0];
    wire is_signed = op[1];

    wire a_sign = in_a[7] & is_signed;
    wire b_sign = in_b[7] & is_signed;
    wire result_sign = a_sign ^ b_sign;

    wire [7:0] load_q;
    wire [7:0] load_m;
    wire       load_cout;

    wire [7:0] run_mul_q;
    wire [8:0] run_mul_acc;
    wire [7:0] run_div_q;
    wire [8:0] run_div_acc;

    wire [7:0] correct_q;
    wire [8:0] correct_acc;
    wire correct_chain;

    // Phase: LOAD
    // Normalize A and B to unsigned before starting v-alu
    sign_bridge pre_correct_q (
        .a        (in_a),
        .sign     (a_sign),
        .chain_in (1'b0),
        .y        (load_q),
        .chain_out()
    );
    sign_bridge pre_correct_m (
        .a        (in_b),
        .sign     (b_sign),
        .chain_in (1'b0),
        .y        (load_m),
        .chain_out()
    );

    adder_subtractor check_overflow (
        .a   (load_q),
        .b   (load_m),
        .cin (1'b1),
        .op  (1'b1),           // Subtract
        .y   (),
        .cout(load_cout),
        .vout()
    );

    // Phase: RUN
    // Run modules and cache out result for next step
    multiplier_8 run_multiplier (
        .in_q   (in_q),
        .in_m   (in_m),
        .in_acc (in_acc[7:0]),
        .out_q  (run_mul_q),
        .out_acc(run_mul_acc[7:0])
    );
    assign run_mul_acc[8] = 1'b0;

    divisor_8 run_divisor (
        .done   (phase[1]),
        .in_q   (in_q),
        .in_m   (in_m),
        .in_acc (in_acc),
        .out_q  (run_div_q),
        .out_acc(run_div_acc)
    );

    // Phase: CORRECT
    sign_bridge post_correct_q (
        .a        (is_div ? run_div_q : in_q),
        .sign     (result_sign),
        .chain_in (1'b0),
        .y        (correct_q),
        .chain_out(correct_chain)
    );
    sign_bridge #(
        .WIDTH(9)
    ) post_correct_acc (
        .a        (is_div ? run_div_acc : in_acc),
        .sign     (is_div ? a_sign : result_sign),
        .chain_in ((~is_div) & correct_chain),
        .y        (correct_acc),
        .chain_out()
    );

    // Assign flags
    assign z_flag = (~|out_acc) & (~|out_q);
    assign n_flag = is_div ? out_q[7] : out_acc[7];
    assign dbz_flag = (~|load_m); // Check division by zero
    assign abort = is_div & (dbz_flag | (~load_cout));

    always_comb begin
        casex (phase)
            PHASE_LOAD: begin
                if (abort & (~dbz_flag)) begin
                    out_q = 8'b00;          // Quotient is always Zero
                    out_acc = {1'b0, in_a}; // Remainder is always Q
                end else begin
                    out_q = load_q;
                    out_acc = 9'h000;
                end
                out_m = load_m;
            end
            PHASE_RUN: begin
                if (is_div) begin
                    out_q = run_div_q;
                    out_acc = run_div_acc;
                end else begin
                    out_q = run_mul_q;
                    out_acc = run_mul_acc;
                end
                out_m = in_m;
            end
            PHASE_CORRECT: begin  // Shallow 'UNUSED'
                out_q = correct_q;
                out_acc = correct_acc;
                out_m = in_m;
            end
        endcase
    end
endmodule
