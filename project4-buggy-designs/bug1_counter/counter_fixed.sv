module counter #(
    parameter WIDTH = 8,
    parameter MAX   = 200
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire             inc,
    input  wire             dec,
    output reg [WIDTH-1:0]  count
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
        end else begin
            if (inc && !dec) begin
                if (count < MAX)        // FIXED: was count < MAX+1
                    count <= count + 1;
            end else if (dec && !inc) begin
                if (count > 0)
                    count <= count - 1;
            end else if (inc && dec) begin
                count <= count;
            end
        end
    end

`ifdef FORMAL
    reg f_past_valid;
    initial f_past_valid = 0;
    always @(posedge clk) f_past_valid <= 1;

    initial assume(!rst_n);
    always @(posedge clk)
        if (!f_past_valid) assume(!rst_n);

    always @(posedge clk) begin
        if (f_past_valid && $past(rst_n) && rst_n) begin
            assume(count <= MAX + 2);

            assert(count <= MAX);

            if ($past(inc) && !$past(dec) && $past(count) < MAX)
                assert(count == $past(count) + 1);

            if ($past(dec) && !$past(inc) && $past(count) > 0)
                assert(count == $past(count) - 1);

            if ($past(count) == MAX && $past(inc) && !$past(dec))
                assert(count == MAX);

            if ($past(count) == 0 && $past(dec) && !$past(inc))
                assert(count == 0);

            if ($past(inc) && $past(dec))
                assert(count == $past(count));
        end
    end

    always @(posedge clk) begin
        if (f_past_valid && rst_n) begin
            cover(count == MAX);
            cover(count == 0 && $past(count) > 0);
        end
    end
`endif

endmodule
