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

    // BUG 1: == instead of != on MSB
    assign full  = (wr_ptr[ADDR_W] == rd_ptr[ADDR_W]) &&
                   (wr_ptr[ADDR_W-1:0] == rd_ptr[ADDR_W-1:0]);
    assign empty = (wr_ptr == rd_ptr);
    // BUG 2: reversed subtraction
    assign count = rd_ptr - wr_ptr;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            wr_ptr <= 0;
        else if (wr_en) begin  // BUG 3: missing !full guard
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
    reg f_past_valid;
    initial f_past_valid = 0;
    always @(posedge clk) f_past_valid <= 1;

    initial assume(!rst_n);

    always @(posedge clk) begin
        if (!rst_n) begin
            assert(empty);
            assert(!full);
            assert(count == 0);
        end

        if (f_past_valid && $past(rst_n) && rst_n) begin
            assert(!(full && empty));
            assert(count <= DEPTH);
            assert(full == (count == DEPTH));
            assert(empty == (count == 0));

            if ($past(wr_en) && !$past(rd_en) && !$past(full))
                assert(count == $past(count) + 1);

            if ($past(rd_en) && !$past(wr_en) && !$past(empty))
                assert(count == $past(count) - 1);

            if ($past(wr_en) && $past(rd_en) && !$past(full) && !$past(empty))
                assert(count == $past(count));
        end
    end
`endif

endmodule
