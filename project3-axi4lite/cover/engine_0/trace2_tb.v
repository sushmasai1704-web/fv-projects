`ifndef VERILATOR
module testbench;
  reg [4095:0] vcdfile;
  reg clock;
`else
module testbench(input clock, output reg genclock);
  initial genclock = 1;
`endif
  reg genclock = 1;
  reg [31:0] cycle = 0;
  reg [31:0] PI_wdata;
  reg [0:0] PI_rready;
  reg [0:0] PI_aresetn;
  reg [0:0] PI_aclk;
  reg [0:0] PI_bready;
  reg [0:0] PI_wvalid;
  reg [3:0] PI_araddr;
  reg [0:0] PI_awvalid;
  reg [3:0] PI_awaddr;
  reg [0:0] PI_arvalid;
  axi4lite_slave UUT (
    .wdata(PI_wdata),
    .rready(PI_rready),
    .aresetn(PI_aresetn),
    .aclk(PI_aclk),
    .bready(PI_bready),
    .wvalid(PI_wvalid),
    .araddr(PI_araddr),
    .awvalid(PI_awvalid),
    .awaddr(PI_awaddr),
    .arvalid(PI_arvalid)
  );
`ifndef VERILATOR
  initial begin
    if ($value$plusargs("vcd=%s", vcdfile)) begin
      $dumpfile(vcdfile);
      $dumpvars(0, testbench);
    end
    #5 clock = 0;
    while (genclock) begin
      #5 clock = 0;
      #5 clock = 1;
    end
  end
`endif
  initial begin
`ifndef VERILATOR
    #1;
`endif
    // UUT.$formal$axi4lite_slave.\sv:142$29_EN  = 1'b0;
    // UUT.$formal$axi4lite_slave.\sv:143$30_EN  = 1'b0;
    // UUT.$formal$axi4lite_slave.\sv:146$31_EN  = 1'b0;
    // UUT.$formal$axi4lite_slave.\sv:147$32_EN  = 1'b0;
    // UUT.$formal$axi4lite_slave.\sv:150$33_EN  = 1'b0;
    // UUT.$formal$axi4lite_slave.\sv:154$34_EN  = 1'b0;
    // UUT.$formal$axi4lite_slave.\sv:158$35_EN  = 1'b0;
    // UUT.$formal$axi4lite_slave.\sv:159$36_EN  = 1'b0;
    // UUT.$formal$axi4lite_slave.\sv:163$38_EN  = 1'b0;
    // UUT.$formal$axi4lite_slave.\sv:164$40_EN  = 1'b0;
    // UUT.$formal$axi4lite_slave.\sv:193$46_EN  = 1'b0;
    // UUT.$formal$axi4lite_slave.\sv:205$47_EN  = 1'b0;
    // UUT.$formal$axi4lite_slave.\sv:210$48_EN  = 1'b0;
    UUT._witness_.anyinit_procdff_878 = 1'b1;
    UUT._witness_.anyinit_procdff_879 = 1'b0;
    UUT._witness_.anyinit_procdff_880 = 1'b0;
    UUT._witness_.anyinit_procdff_882 = 1'b0;
    UUT._witness_.anyinit_procdff_885 = 1'b0;
    UUT._witness_.anyinit_procdff_888 = 1'b0;
    UUT._witness_.anyinit_procdff_890 = 1'b0;
    UUT._witness_.anyinit_procdff_892 = 1'b1;
    UUT._witness_.anyinit_procdff_893 = 1'b0;
    UUT._witness_.anyinit_procdff_894 = 1'b0;
    UUT._witness_.anyinit_procdff_895 = 1'b1;
    UUT._witness_.anyinit_procdff_896 = 1'b0;
    UUT._witness_.anyinit_procdff_897 = 1'b1;
    UUT._witness_.anyinit_procdff_898 = 1'b0;
    UUT._witness_.anyinit_procdff_899 = 1'b0;
    UUT._witness_.anyinit_procdff_900 = 1'b0;
    UUT._witness_.anyinit_procdff_901 = 1'b1;
    UUT._witness_.anyinit_procdff_902 = 1'b0;
    UUT._witness_.anyinit_procdff_903 = 1'b1;
    UUT._witness_.anyinit_procdff_904 = 1'b0;
    UUT._witness_.anyinit_procdff_905 = 32'b00000000000000000000000000000000;
    UUT._witness_.anyinit_procdff_906 = 1'b0;
    UUT._witness_.anyinit_procdff_907 = 1'b0;
    UUT._witness_.anyinit_procdff_908 = 2'b00;
    UUT._witness_.anyinit_procdff_915 = 1'b0;
    UUT._witness_.anyinit_procdff_917 = 1'b1;
    UUT._witness_.anyinit_procdff_919 = 1'b0;
    UUT._witness_.anyinit_procdff_921 = 1'b1;
    UUT._witness_.anyinit_procdff_923 = 1'b0;
    UUT._witness_.anyinit_procdff_925 = 1'b0;
    UUT._witness_.anyinit_procdff_927 = 1'b0;
    UUT._witness_.anyinit_procdff_929 = 1'b0;
    UUT._witness_.anyinit_procdff_931 = 1'b0;
    UUT._witness_.anyinit_procdff_933 = 1'b0;
    UUT._witness_.anyinit_procdff_935 = 1'b1;
    UUT._witness_.anyinit_procdff_937 = 1'b1;
    UUT._witness_.anyinit_procdff_939 = 1'b1;
    UUT._witness_.anyinit_procdff_941 = 1'b1;
    UUT._witness_.anyinit_procdff_943 = 1'b1;
    UUT._witness_.anyinit_procdff_948 = 1'b0;
    UUT._witness_.anyinit_procdff_949 = 32'b00000000000000000000000000000000;
    UUT._witness_.anyinit_procdff_950 = 2'b00;
    UUT._witness_.anyinit_procdff_951 = 1'b1;
    UUT._witness_.anyinit_procdff_953 = 2'b01;
    UUT._witness_.anyinit_procdff_956 = 1'b0;
    UUT._witness_.anyinit_procdff_957 = 1'b0;
    UUT._witness_.anyinit_procdff_958 = 2'b00;
    UUT._witness_.anyinit_procdff_959 = 1'b0;
    UUT._witness_.anyinit_procdff_960 = 4'b0000;
    UUT._witness_.anyinit_procdff_961 = 2'b00;
    UUT._witness_.anyinit_procdff_963 = 32'b00000000000000000000000000000001;
    UUT._witness_.anyinit_procdff_964 = 32'b00000000000000000000000000000000;
    UUT._witness_.anyinit_procdff_965 = 32'b00000000000000000000000000000000;
    UUT._witness_.anyinit_procdff_966 = 32'b00000000000000000000000000000000;
    UUT._witness_.anyinit_procdff_967 = 32'b00000000000000000000000000000000;
    UUT._witness_.anyinit_procdff_968 = 32'b00000000000000000000000000000000;
    UUT._witness_.anyinit_procdff_969 = 32'b00000000000000000000000000000000;
    UUT._witness_.anyinit_procdff_970 = 32'b00000000000000000000000000000000;
    UUT._witness_.anyinit_procdff_971 = 32'b00000000000000000000000000000000;
    UUT._witness_.anyinit_procdff_972 = 32'b00000000000000000000000000000000;
    UUT._witness_.anyinit_procdff_973 = 32'b00000000000000000000000000000000;
    UUT._witness_.anyinit_procdff_974 = 32'b00000000000000000000000000000000;
    UUT._witness_.anyinit_procdff_975 = 32'b00000000000000000000000000000000;
    UUT._witness_.anyinit_procdff_976 = 32'b00000000000000000000000000000000;
    UUT._witness_.anyinit_procdff_977 = 32'b00000000000000000000000000000000;
    UUT._witness_.anyinit_procdff_978 = 32'b00000000000000000000000000000000;
    UUT.f_past_valid = 1'b0;
    UUT.f_write_count = 2'b00;
    UUT.f_wrote_once = 1'b0;

    // state 0
    PI_wdata = 32'b00000000000000000000000000000010;
    PI_rready = 1'b1;
    PI_aresetn = 1'b0;
    PI_aclk = 1'b0;
    PI_bready = 1'b1;
    PI_wvalid = 1'b0;
    PI_araddr = 4'b0000;
    PI_awvalid = 1'b0;
    PI_awaddr = 4'b0000;
    PI_arvalid = 1'b0;
  end
  always @(posedge clock) begin
    // state 1
    if (cycle == 0) begin
      PI_wdata <= 32'b00000000000000000000000000000010;
      PI_rready <= 1'b0;
      PI_aresetn <= 1'b1;
      PI_aclk <= 1'b0;
      PI_bready <= 1'b0;
      PI_wvalid <= 1'b0;
      PI_araddr <= 4'b0000;
      PI_awvalid <= 1'b0;
      PI_awaddr <= 4'b0000;
      PI_arvalid <= 1'b0;
    end

    // state 2
    if (cycle == 1) begin
      PI_wdata <= 32'b00000000000000000000000000000010;
      PI_rready <= 1'b0;
      PI_aresetn <= 1'b1;
      PI_aclk <= 1'b0;
      PI_bready <= 1'b0;
      PI_wvalid <= 1'b1;
      PI_araddr <= 4'b0000;
      PI_awvalid <= 1'b1;
      PI_awaddr <= 4'b0000;
      PI_arvalid <= 1'b1;
    end

    // state 3
    if (cycle == 2) begin
      PI_wdata <= 32'b00000000000000000000000000000001;
      PI_rready <= 1'b0;
      PI_aresetn <= 1'b1;
      PI_aclk <= 1'b0;
      PI_bready <= 1'b1;
      PI_wvalid <= 1'b1;
      PI_araddr <= 4'b0000;
      PI_awvalid <= 1'b0;
      PI_awaddr <= 4'b0001;
      PI_arvalid <= 1'b1;
    end

    // state 4
    if (cycle == 3) begin
      PI_wdata <= 32'b00000000000000000000001000000001;
      PI_rready <= 1'b0;
      PI_aresetn <= 1'b1;
      PI_aclk <= 1'b0;
      PI_bready <= 1'b1;
      PI_wvalid <= 1'b0;
      PI_araddr <= 4'b0000;
      PI_awvalid <= 1'b0;
      PI_awaddr <= 4'b0001;
      PI_arvalid <= 1'b1;
    end

    // state 5
    if (cycle == 4) begin
      PI_wdata <= 32'b01000000000000000000000000000001;
      PI_rready <= 1'b0;
      PI_aresetn <= 1'b1;
      PI_aclk <= 1'b0;
      PI_bready <= 1'b0;
      PI_wvalid <= 1'b0;
      PI_araddr <= 4'b0000;
      PI_awvalid <= 1'b0;
      PI_awaddr <= 4'b0001;
      PI_arvalid <= 1'b1;
    end

    // state 6
    if (cycle == 5) begin
      PI_wdata <= 32'b00000000000000000000000000000010;
      PI_rready <= 1'b0;
      PI_aresetn <= 1'b1;
      PI_aclk <= 1'b0;
      PI_bready <= 1'b0;
      PI_wvalid <= 1'b1;
      PI_araddr <= 4'b0010;
      PI_awvalid <= 1'b1;
      PI_awaddr <= 4'b1101;
      PI_arvalid <= 1'b1;
    end

    // state 7
    if (cycle == 6) begin
      PI_wdata <= 32'b00000000000001000000000000000000;
      PI_rready <= 1'b0;
      PI_aresetn <= 1'b1;
      PI_aclk <= 1'b0;
      PI_bready <= 1'b0;
      PI_wvalid <= 1'b1;
      PI_araddr <= 4'b0000;
      PI_awvalid <= 1'b1;
      PI_awaddr <= 4'b0000;
      PI_arvalid <= 1'b1;
    end

    // state 8
    if (cycle == 7) begin
      PI_wdata <= 32'b00000000000000000000000000000010;
      PI_rready <= 1'b0;
      PI_aresetn <= 1'b1;
      PI_aclk <= 1'b0;
      PI_bready <= 1'b1;
      PI_wvalid <= 1'b1;
      PI_araddr <= 4'b1101;
      PI_awvalid <= 1'b1;
      PI_awaddr <= 4'b0000;
      PI_arvalid <= 1'b1;
    end

    // state 9
    if (cycle == 8) begin
      PI_wdata <= 32'b00000000000000000000000000000010;
      PI_rready <= 1'b1;
      PI_aresetn <= 1'b1;
      PI_aclk <= 1'b0;
      PI_bready <= 1'b0;
      PI_wvalid <= 1'b1;
      PI_araddr <= 4'b0000;
      PI_awvalid <= 1'b1;
      PI_awaddr <= 4'b0000;
      PI_arvalid <= 1'b1;
    end

    // state 10
    if (cycle == 9) begin
      PI_wdata <= 32'b00000000000000000000000000000010;
      PI_rready <= 1'b0;
      PI_aresetn <= 1'b0;
      PI_aclk <= 1'b0;
      PI_bready <= 1'b0;
      PI_wvalid <= 1'b0;
      PI_araddr <= 4'b0000;
      PI_awvalid <= 1'b0;
      PI_awaddr <= 4'b0000;
      PI_arvalid <= 1'b0;
    end

    genclock <= cycle < 10;
    cycle <= cycle + 1;
  end
endmodule
