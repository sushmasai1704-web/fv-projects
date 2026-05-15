module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16,
    parameter ADDR_W     = $clog2(DEPTH)
) (
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire                   wr_en,
    input  wire [DATA_WIDTH-1:0]  wr_data,
    input  wire                   rd_en,
    output reg  [DATA_WIDTH-1:0]  rd_data,
    output wire                   full,
    output wire                   empty,
    output wire [ADDR_W:0]        count
);
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_W:0]       wr_ptr;
    reg [ADDR_W:0]       rd_ptr;

    assign full  = (wr_ptr[ADDR_W] != rd_ptr[ADDR_W]) &&
                   (wr_ptr[ADDR_W-1:0] == rd_ptr[ADDR_W-1:0]);
    assign empty = (wr_ptr == rd_ptr);
    assign count = wr_ptr - rd_ptr;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            wr_ptr <= 0;
        else if (wr_en && !full) begin
            mem[wr_ptr[ADDR_W-1:0]] <= wr_data;
            wr_ptr <= wr_ptr + 1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr  <= 0;
            rd_data <= 0;
        end else if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr[ADDR_W-1:0]];
            rd_ptr  <= rd_ptr + 1;
        end
    end

`ifdef FORMAL
    // Track how many cycles have passed since reset
    // Use a saturating counter: 0,1,2,3 — stops at 3
    reg [1:0] f_cycle;
    initial f_cycle = 0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            f_cycle <= 0;
        else if (f_cycle < 3)
            f_cycle <= f_cycle + 1;
    end

    // Force reset at startup
    initial assume(!rst_n);

    always @(posedge clk) begin

        // --- Assertions that apply during reset ---
        if (!rst_n) begin
            assert(empty);
            assert(!full);
            assert(count == 0);
        end

        // --- Assertions that need one past sample (f_cycle >= 2 means
        //     reset released and at least one post-reset clock edge done) ---
        if (rst_n && f_cycle >= 2) begin

            // 2. full and empty never both high
            assert(!(full && empty));

            // 3. count always in range
            assert(count <= DEPTH);

            // 4. full iff count == DEPTH
            assert(full == (count == DEPTH));

            // 5. empty iff count == 0
            assert(empty == (count == 0));

            // 6. No overflow
            if ($past(full) && $past(wr_en))
                assert(count <= DEPTH);

            // 7. No underflow: if FIFO was empty and a read was attempted,
            //    count must still be 0 (read ignored)
            if ($past(empty) && $past(rd_en) && !$past(wr_en))
                assert(count == 0);

            // 8. Count increments on write-only
            if ($past(wr_en) && !$past(rd_en) && !$past(full))
                assert(count == $past(count) + 1);

            // 9. Count decrements on read-only
            if ($past(rd_en) && !$past(wr_en) && !$past(empty))
                assert(count == $past(count) - 1);

            // 10. Count stable on simultaneous R+W (both valid)
            if ($past(wr_en) && $past(rd_en) && !$past(full) && !$past(empty))
                assert(count == $past(count));
        end
    end

    // Cover: reachability checks
    always @(posedge clk) begin
        if (rst_n && f_cycle >= 2) begin
            cover(full);
            cover(empty && $past(!empty));
            cover(count == DEPTH/2);
        end
    end
`endif

endmodule
