module axi_resp_fixed (
    input  wire clk,
    input  wire resetn,
    input  wire start_write,
    input  wire bready,
    output reg  bvalid,
    output reg  [1:0] bresp
);
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        RESP = 2'b01,
        DONE = 2'b10
    } state_t;
    state_t state;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            bvalid <= 0;
            bresp  <= 2'b00;
            state  <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (start_write) begin
                        bvalid <= 1;
                        bresp  <= 2'b00;
                        state  <= RESP;
                    end
                end
                RESP: begin
                    // FIX: only deassert bvalid when bready is seen
                    if (bready) begin
                        bvalid <= 0;
                        state  <= DONE;
                    end
                end
                DONE: begin
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

    // AXI rule: bvalid must stay high until bready is seen
    always @(posedge clk) begin
        if (f_past_valid && $past(resetn) && resetn) begin
            if ($past(bvalid) && !$past(bready))
                assert(bvalid);  // PASSES on fixed design
        end
    end

    // Cover: response handshake completes
    always @(posedge clk)
        if (f_past_valid && resetn)
            cover(bvalid && bready);
`endif

endmodule
