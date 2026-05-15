// Bug 3: FSM missing default — illegal state reachable
// A 2-bit state register can hold 4 values but FSM only
// defines 3. Without a default, state 2'b11 produces
// undefined output and the FSM never recovers.

module fsm_buggy (
    input  wire clk,
    input  wire resetn,
    input  wire req,
    output reg  grant,
    output reg  busy
);
    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        WORK  = 2'b01,
        DONE  = 2'b10
        // 2'b11 is unencoded — no default handles it
    } state_t;
    state_t state;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state <= IDLE;
            grant <= 0;
            busy  <= 0;
        end else begin
            case (state)
                IDLE: begin
                    grant <= 0;
                    busy  <= 0;
                    if (req) state <= WORK;
                end
                WORK: begin
                    grant <= 1;
                    busy  <= 1;
                    state <= DONE;
                end
                DONE: begin
                    grant <= 0;
                    busy  <= 0;
                    state <= IDLE;
                end
                // BUG: no default — state 2'b11 is unhandled
                // outputs float, FSM stuck forever
            endcase
        end
    end

`ifdef FORMAL
    reg f_past_valid;
    initial f_past_valid = 0;
    always @(posedge clk) f_past_valid <= 1;

    initial assume(!resetn);
    always @(posedge clk)
        if (!f_past_valid) assume(!resetn);

    // Property 1: FSM must always be in a known state
    always @(posedge clk)
        if (f_past_valid && resetn)
            assert(state == IDLE || state == WORK || state == DONE);

    // Property 2: grant only asserted in WORK state
    always @(posedge clk)
        if (f_past_valid && resetn)
            assert(grant == (state == WORK));

    // Property 3: busy only asserted in WORK state
    always @(posedge clk)
        if (f_past_valid && resetn)
            assert(busy == (state == WORK));

    // Cover: full IDLE->WORK->DONE->IDLE cycle completes
    always @(posedge clk)
        if (f_past_valid && resetn)
            cover(state == IDLE && $past(state) == DONE);
`endif

endmodule
