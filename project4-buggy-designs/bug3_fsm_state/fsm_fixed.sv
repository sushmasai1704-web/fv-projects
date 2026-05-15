module fsm_fixed (
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
                default: begin
                    grant <= 0;
                    busy  <= 0;
                    state <= IDLE;
                end
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

    always @(posedge clk) begin
        if (f_past_valid && resetn) begin
            assume(state == IDLE || state == WORK || state == DONE);
            assume(grant == (state == WORK));
            assume(busy  == (state == WORK));
        end
    end

    always @(posedge clk)
        if (f_past_valid && resetn)
            assert(state == IDLE || state == WORK || state == DONE);

    always @(posedge clk)
        if (f_past_valid && resetn)
            assert(grant == (state == WORK));

    always @(posedge clk)
        if (f_past_valid && resetn)
            assert(busy == (state == WORK));

    always @(posedge clk)
        if (f_past_valid && resetn)
            cover(state == IDLE && $past(state) == DONE);
`endif

endmodule
