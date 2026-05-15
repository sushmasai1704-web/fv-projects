module axi4lite_slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 4,
    parameter NUM_REGS   = 16
)(
    input  wire                   aclk,
    input  wire                   aresetn,
    input  wire [ADDR_WIDTH-1:0]  awaddr,
    input  wire                   awvalid,
    output reg                    awready,
    input  wire [DATA_WIDTH-1:0]  wdata,
    input  wire                   wvalid,
    output reg                    wready,
    output reg  [1:0]             bresp,
    output reg                    bvalid,
    input  wire                   bready,
    input  wire [ADDR_WIDTH-1:0]  araddr,
    input  wire                   arvalid,
    output reg                    arready,
    output reg  [DATA_WIDTH-1:0]  rdata,
    output reg  [1:0]             rresp,
    output reg                    rvalid,
    input  wire                   rready
);
    reg [DATA_WIDTH-1:0] regfile [0:NUM_REGS-1];
    reg [ADDR_WIDTH-1:0] aw_addr_lat;
    reg [ADDR_WIDTH-1:0] ar_addr_lat;

    typedef enum logic [1:0] {
        WR_IDLE = 2'b00,
        WR_DATA = 2'b01,
        WR_RESP = 2'b10
    } wr_state_t;
    wr_state_t wr_state;

    typedef enum logic [1:0] {
        RD_IDLE = 2'b00,
        RD_DATA = 2'b01
    } rd_state_t;
    rd_state_t rd_state;

    integer i;

    // Write path
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            awready     <= 0;
            wready      <= 0;
            bvalid      <= 0;
            bresp       <= 2'b00;
            wr_state    <= WR_IDLE;
            aw_addr_lat <= 0;
            for (i = 0; i < NUM_REGS; i = i + 1)
                regfile[i] <= 0;
        end else begin
            case (wr_state)
                WR_IDLE: begin
                    awready <= 1;
                    wready  <= 0;
                    bvalid  <= 0;
                    if (awvalid && awready) begin
                        aw_addr_lat <= awaddr;
                        awready     <= 0;
                        wready      <= 1;
                        wr_state    <= WR_DATA;
                    end
                end
                WR_DATA: begin
                    if (wvalid && wready) begin
                        regfile[aw_addr_lat[ADDR_WIDTH-1:0]] <= wdata;
                        wready   <= 0;
                        bvalid   <= 1;
                        bresp    <= 2'b00;
                        wr_state <= WR_RESP;
                    end
                end
                WR_RESP: begin
                    if (bvalid && bready) begin
                        bvalid   <= 0;
                        wr_state <= WR_IDLE;
                    end
                end
                default: wr_state <= WR_IDLE;
            endcase
        end
    end

    // Read path — rdata latched at address capture, not recomputed every cycle
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            arready     <= 0;
            rvalid      <= 0;
            rdata       <= 0;
            rresp       <= 2'b00;
            rd_state    <= RD_IDLE;
            ar_addr_lat <= 0;
        end else begin
            case (rd_state)
                RD_IDLE: begin
                    arready <= 1;
                    rvalid  <= 0;
                    if (arvalid && arready) begin
                        ar_addr_lat <= araddr;
                        // Latch rdata immediately at address capture
                        rdata       <= regfile[araddr[ADDR_WIDTH-1:0]];
                        arready     <= 0;
                        rd_state    <= RD_DATA;
                    end
                end
                RD_DATA: begin
                    rvalid <= 1;
                    rresp  <= 2'b00;
                    // rdata held stable — not recomputed here
                    if (rvalid && rready) begin
                        rvalid   <= 0;
                        rd_state <= RD_IDLE;
                    end
                end
                default: rd_state <= RD_IDLE;
            endcase
        end
    end

`ifdef FORMAL
    reg f_past_valid;
    initial f_past_valid = 0;
    always @(posedge aclk) f_past_valid <= 1;

    initial assume(!aresetn);
    always @(posedge aclk)
        if (!f_past_valid) assume(!aresetn);

    always @(posedge aclk) begin
        if (f_past_valid && $past(aresetn) && aresetn) begin

            // Rule 1: Master VALID stable until handshake
            if ($past(awvalid) && !$past(awready)) assume(awvalid);
            if ($past(wvalid)  && !$past(wready))  assume(wvalid);
            if ($past(arvalid) && !$past(arready)) assume(arvalid);

            // Rule 2: Slave VALID stable until handshake
            if ($past(bvalid) && !$past(bready)) assert(bvalid);
            if ($past(rvalid) && !$past(rready)) assert(rvalid);

            // Rule 3: RESP always OKAY
            if (bvalid) assert(bresp == 2'b00);
            if (rvalid) assert(rresp == 2'b00);

            // Rule 4: RDATA stable while rvalid high, rready low
            if ($past(rvalid) && !$past(rready) && rvalid)
                assert(rdata == $past(rdata));

            // Rule 5: BRESP stable while bvalid high, bready low
            if ($past(bvalid) && !$past(bready) && bvalid)
                assert(bresp == $past(bresp));

            // Rule 6: FSM output consistency — write path
            if (awready) assert(wr_state == WR_IDLE);
            if (wready)  assert(wr_state == WR_DATA);
            if (bvalid)  assert(wr_state == WR_RESP);

            // Rule 7: FSM output consistency — read path
            if (arready) assert(rd_state == RD_IDLE);
            if (rvalid)  assert(rd_state == RD_DATA);

            // Rule 8: Write channel outputs one-hot by FSM state
            assert(!(awready && wready));
            assert(!(awready && bvalid));
            assert(!(wready  && bvalid));

            // Rule 9: Read channel outputs one-hot by FSM state
            assert(!(arready && rvalid));
        end
    end
// C1: basic write transaction completes
    always @(posedge aclk)
        if (f_past_valid && aresetn)
            cover(bvalid && bready);

    // C2: basic read transaction completes
    always @(posedge aclk)
        if (f_past_valid && aresetn)
            cover(rvalid && rready);

    // C3: write-then-read sequence
    reg f_wrote_once;
    initial f_wrote_once = 0;
    always @(posedge aclk)
        if (!aresetn) f_wrote_once <= 0;
        else if (bvalid && bready) f_wrote_once <= 1;

    always @(posedge aclk)
        if (f_past_valid && aresetn && f_wrote_once)
            cover(rvalid && rready);

    // C4: two complete write transactions
    reg [1:0] f_write_count;
    initial f_write_count = 0;
    always @(posedge aclk)
        if (!aresetn) f_write_count <= 0;
        else if (bvalid && bready && f_write_count < 2)
            f_write_count <= f_write_count + 1;

    always @(posedge aclk)
        if (f_past_valid && aresetn)
            cover(f_write_count == 2);

    // C5: read OKAY with rdata stable through handshake
    always @(posedge aclk)
        if (f_past_valid && aresetn && $past(rvalid) && !$past(rready))
            cover(rvalid && rready && rresp == 2'b00);
`endif

endmodule
