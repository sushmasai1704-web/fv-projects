`ifdef FORMAL

    // 1. After reset: empty=1, full=0, count=0
    assert property (@(posedge clk) !rst_n |-> empty);
    assert property (@(posedge clk) !rst_n |-> !full);
    assert property (@(posedge clk) !rst_n |-> (count == 0));

    // 2. full and empty never both high
    assert property (@(posedge clk) !(full && empty));

    // 3. count always in range
    assert property (@(posedge clk) disable iff (!rst_n)
        count <= DEPTH);

    // 4. full iff count == DEPTH
    assert property (@(posedge clk) disable iff (!rst_n)
        full == (count == DEPTH));

    // 5. empty iff count == 0
    assert property (@(posedge clk) disable iff (!rst_n)
        empty == (count == 0));

    // 6. No overflow
    assert property (@(posedge clk) disable iff (!rst_n)
        (full && wr_en) |=> (count <= DEPTH));

    // 7. No underflow
    assert property (@(posedge clk) disable iff (!rst_n)
        (empty && rd_en) |=> (count == 0));

    // 8. Count increments on write-only
    assert property (@(posedge clk) disable iff (!rst_n)
        (wr_en && !rd_en && !full) |=> (count == $past(count) + 1));

    // 9. Count decrements on read-only
    assert property (@(posedge clk) disable iff (!rst_n)
        (rd_en && !wr_en && !empty) |=> (count == $past(count) - 1));

    // 10. Count stable on simultaneous R+W
    assert property (@(posedge clk) disable iff (!rst_n)
        (wr_en && rd_en && !full && !empty) |=> (count == $past(count)));

    // Cover points
    cover property (@(posedge clk) disable iff (!rst_n) full);
    cover property (@(posedge clk) disable iff (!rst_n) empty && $past(!empty));
    cover property (@(posedge clk) disable iff (!rst_n)
        wr_en && rd_en && !full && !empty);

`endif
