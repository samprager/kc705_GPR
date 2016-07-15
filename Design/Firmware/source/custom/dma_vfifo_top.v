`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 07/14/2016 12:44:52 AM
// Design Name:
// Module Name: dma_vfifo_top
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module dma_vfifo_top #(
 // parameter SYN_BLACK_BOX = 1,
  //parameter BLACK_BOX_PAD_PIN = "s_aclk),s_aresetn),s_axi_awid[3:0]),s_axi_awaddr[31:0]),s_axi_awlen[7:0]),s_axi_awsize[2:0]),s_axi_awburst[1:0]),s_axi_awvalid),s_axi_awready),s_axi_wdata[31:0]),s_axi_wstrb[3:0]),s_axi_wlast),s_axi_wvalid),s_axi_wready),s_axi_bid[3:0]),s_axi_bresp[1:0]),s_axi_bvalid),s_axi_bready),s_axi_arid[3:0]),s_axi_araddr[31:0]),s_axi_arlen[7:0]),s_axi_arsize[2:0]),s_axi_arburst[1:0]),s_axi_arvalid),s_axi_arready),s_axi_rid[3:0]),s_axi_rdata[31:0]),s_axi_rresp[1:0]),s_axi_rlast),s_axi_rvalid),s_axi_rready"
  )(
  // input clock),
  // input clock_lite),
  // input resetn),
  // input start),
  // output reg done),
  // output reg status
  input clk_in1_p,
  input clk_in1_n,
  input reset,
  input start,
  output reg done,
  output reg status
    );


    localparam BRAM_ADDR_WIDTH = 16;
    localparam BRAM_ADDR_WIDTH_S2MM = 16;


    localparam C_USE_LITE = 0;
    localparam AXI_LITE_ADDR_WIDTH = 10;
    localparam MM2S_AXI_DATA_WIDTH = 512;
    localparam MM2S_AXIS_DATA_WIDTH = 512;
    localparam S2MM_AXI_DATA_WIDTH = 512;
    localparam S2MM_AXIS_DATA_WIDTH = 512;
    localparam C_M_AXI_ADDR_WIDTH = 32;
    localparam C_M_AXI_SG_ADDR_WIDTH = 32;
    localparam C_M_AXI_SG_DATA_WIDTH = 32;

    //  wire s_axi_lite_aclk;
    //  wire m_axi_sg_aclk;
    //  wire m_axi_mm2s_aclk;
    //  wire m_axi_s2mm_aclk;
    //  wire axi_resetn;
    //  wire s_axi_lite_awvalid;
    //  wire s_axi_lite_awready;
    //  wire [9 : 0] s_axi_lite_awaddr;
    //  wire s_axi_lite_wvalid;
    //  wire s_axi_lite_wready;
    //  wire [31 : 0] s_axi_lite_wdata;
    //  wire [1 : 0] s_axi_lite_bresp;
    //  wire s_axi_lite_bvalid;
    //  wire s_axi_lite_bready;
    //  wire s_axi_lite_arvalid;
    //  wire s_axi_lite_arready;
    //  wire [9 : 0] s_axi_lite_araddr;
    //  wire s_axi_lite_rvalid;
    //  wire s_axi_lite_rready;
    //  wire [31 : 0] s_axi_lite_rdata;
    //  wire [1 : 0] s_axi_lite_rresp;
    //  wire [31 : 0] m_axi_sg_awaddr;
    //  wire [7 : 0] m_axi_sg_awlen;
    //  wire [2 : 0] m_axi_sg_awsize;
    //  wire [1 : 0] m_axi_sg_awburst;
    //  wire [2 : 0] m_axi_sg_awprot;
    //  wire [3 : 0] m_axi_sg_awcache;
    //  wire m_axi_sg_awvalid;
    //  wire m_axi_sg_awready;
    //  wire [31 : 0] m_axi_sg_wdata;
    //  wire [3 : 0] m_axi_sg_wstrb;
    //  wire m_axi_sg_wlast;
    //  wire m_axi_sg_wvalid;
    //  wire m_axi_sg_wready;
    //  wire [1 : 0] m_axi_sg_bresp;
    //  wire m_axi_sg_bvalid;
    //  wire m_axi_sg_bready;
    //  wire [31 : 0] m_axi_sg_araddr;
    //  wire [7 : 0] m_axi_sg_arlen;
    //  wire [2 : 0] m_axi_sg_arsize;
    //  wire [1 : 0] m_axi_sg_arburst;
    //  wire [2 : 0] m_axi_sg_arprot;
    //  wire [3 : 0] m_axi_sg_arcache;
    //  wire m_axi_sg_arvalid;
    //  wire m_axi_sg_arready;
    //  wire [31 : 0] m_axi_sg_rdata;
    //  wire [1 : 0] m_axi_sg_rresp;
    //  wire m_axi_sg_rlast;
    //  wire m_axi_sg_rvalid;
    //  wire m_axi_sg_rready;
    //  wire [31 : 0] m_axi_mm2s_araddr;
    //  wire [7 : 0] m_axi_mm2s_arlen;
    //  wire [2 : 0] m_axi_mm2s_arsize;
    //  wire [1 : 0] m_axi_mm2s_arburst;
    //  wire [2 : 0] m_axi_mm2s_arprot;
    //  wire [3 : 0] m_axi_mm2s_arcache;
    //  wire m_axi_mm2s_arvalid;
    //  wire m_axi_mm2s_arready;
    //  wire [511 : 0] m_axi_mm2s_rdata;
    //  wire [1 : 0] m_axi_mm2s_rresp;
    //  wire m_axi_mm2s_rlast;
    //  wire m_axi_mm2s_rvalid;
    //  wire m_axi_mm2s_rready;
    //  wire mm2s_prmry_reset_out_n;
    //  wire [511 : 0] m_axis_mm2s_tdata;
    //  wire [63 : 0] m_axis_mm2s_tkeep;
    //  wire m_axis_mm2s_tvalid;
    //  wire m_axis_mm2s_tready;
    //  wire m_axis_mm2s_tlast;
    //  wire mm2s_cntrl_reset_out_n;
    //  wire [31 : 0] m_axis_mm2s_cntrl_tdata;
    //  wire [3 : 0] m_axis_mm2s_cntrl_tkeep;
    //  wire m_axis_mm2s_cntrl_tvalid;
    //  wire m_axis_mm2s_cntrl_tready;
    //  wire m_axis_mm2s_cntrl_tlast;
    //  wire [31 : 0] m_axi_s2mm_awaddr;
    //  wire [7 : 0] m_axi_s2mm_awlen;
    //  wire [2 : 0] m_axi_s2mm_awsize;
    //  wire [1 : 0] m_axi_s2mm_awburst;
    //  wire [2 : 0] m_axi_s2mm_awprot;
    //  wire [3 : 0] m_axi_s2mm_awcache;
    //  wire m_axi_s2mm_awvalid;
    //  wire m_axi_s2mm_awready;
    //  wire [511 : 0] m_axi_s2mm_wdata;
    //  wire [63 : 0] m_axi_s2mm_wstrb;
    //  wire m_axi_s2mm_wlast;
    //  wire m_axi_s2mm_wvalid;
    //  wire m_axi_s2mm_wready;
    //  wire [1 : 0] m_axi_s2mm_bresp;
    //  wire m_axi_s2mm_bvalid;
    //  wire m_axi_s2mm_bready;
    //  wire s2mm_prmry_reset_out_n;
    //  wire [511 : 0] s_axis_s2mm_tdata;
    //  wire [63 : 0] s_axis_s2mm_tkeep;
    //  wire s_axis_s2mm_tvalid;
    //  wire s_axis_s2mm_tready;
    //  wire s_axis_s2mm_tlast;
    //  wire s2mm_sts_reset_out_n;
    //  wire [31 : 0] s_axis_s2mm_sts_tdata;
    //  wire [3 : 0] s_axis_s2mm_sts_tkeep;
    //  wire s_axis_s2mm_sts_tvalid;
    //  wire s_axis_s2mm_sts_tready;
    //  wire s_axis_s2mm_sts_tlast;
    //  wire mm2s_introut;
    //  wire s2mm_introut;
    //  wire [31 : 0] axi_dma_tstvec;

    wire m_axi_lite_awready          ;
    wire m_axi_lite_awvalid          ;
    wire             [31 : 0] m_axi_lite_awaddr;
    wire m_axi_lite_wready           ;
    wire m_axi_lite_wvalid           ;
    wire              [31 : 0] m_axi_lite_wdata;
    wire m_axi_lite_bready           ;
    wire m_axi_lite_bvalid           ;
    wire             [1 : 0] m_axi_lite_bresp     ;
    wire s_axi_lite_arready          ;
    wire s_axi_lite_arvalid          ;
    wire             [31 : 0] s_axi_lite_araddr;
    wire s_axi_lite_rready           ;
    wire s_axi_lite_rvalid           ;
    wire              [31 : 0] s_axi_lite_rdata;
    wire             [1 : 0]   s_axi_lite_rresp;
    wire m_axi_arready               ;
    wire m_axi_arvalid               ;
    wire                  [31 : 0]   m_axi_araddr;
    wire                  [7 : 0]      m_axi_arlen;
    wire                 [2 : 0]      m_axi_arsize;
    wire                [1 : 0]      m_axi_arburst;
    wire                 [2 : 0]      m_axi_arprot;
    wire                [3 : 0]      m_axi_arcache;
    wire                [3 : 0]      m_axi_aruser;
    wire m_axi_rready                ;
    wire m_axi_rvalid                ;
    wire    [MM2S_AXI_DATA_WIDTH-1 : 0]   m_axi_rdata;
    wire                  [1 : 0]        m_axi_rresp;
    wire m_axi_rlast                 ;


    wire s_axi_awready                ;
    wire s_axi_awvalid                ;
    wire                   [31 : 0]    s_axi_awaddr;
    wire                  [7 : 0]       s_axi_awlen;
    wire                 [2 : 0]       s_axi_awsize;
    wire                [1 : 0]       s_axi_awburst;
    wire                 [2 : 0]      s_axi_awprot ;
    wire                [3 : 0]       s_axi_awcache;
    wire                [3 : 0]       s_axi_awuser;
    wire s_axi_wready                 ;
    wire s_axi_wvalid                 ;
    wire                    [MM2S_AXI_DATA_WIDTH-1 : 0]    s_axi_wdata;
    wire                    [MM2S_AXI_DATA_WIDTH/8-1 : 0] s_axi_wstrb;
    wire s_axi_wlast                  ;
    wire s_axi_bready                 ;
    wire s_axi_bvalid                 ;
    wire                  [1 : 0]       s_axi_bresp;




    wire s_axi_arready               ;
    wire s_axi_arvalid               ;
    wire                  [31 : 0]   s_axi_araddr;
    wire                  [7 : 0]    s_axi_arlen  ;
    wire                 [2 : 0]    s_axi_arsize  ;
    wire                [1 : 0]     s_axi_arburst ;
    wire                 [2 : 0]      s_axi_arprot;
    wire                [3 : 0]      s_axi_arcache;
    wire s_axi_rready                ;
    wire s_axi_rvalid                ;
    wire                      [S2MM_AXI_DATA_WIDTH-1 : 0]   s_axi_rdata;
    wire                  [1 : 0]     s_axi_rresp ;
    wire s_axi_rlast                 ;

    wire m_axi_awready                ;
    wire m_axi_awvalid                ;
    wire                   [31 : 0]   m_axi_awaddr ;
    wire                  [7 : 0]      m_axi_awlen ;
    wire                 [2 : 0]      m_axi_awsize ;
    wire                [1 : 0]      m_axi_awburst ;
    wire                 [2 : 0]     m_axi_awprot  ;
    wire                [3 : 0]      m_axi_awcache ;
    wire                [3 : 0]      m_axi_awuser ;
    wire m_axi_wready                 ;
    wire m_axi_wvalid                 ;
    wire                    [S2MM_AXI_DATA_WIDTH-1 : 0]   m_axi_wdata ;
    wire                    [S2MM_AXI_DATA_WIDTH/8-1 : 0] m_axi_wstrb;
    wire m_axi_wlast                  ;
    wire m_axi_bready                 ;
    wire m_axi_bvalid                 ;
    wire                  [1 : 0]    m_axi_bresp   ;
    wire m_axi_sg_awready            ;
    wire m_axi_sg_awvalid            ;
    wire               [C_M_AXI_SG_ADDR_WIDTH-1 : 0] m_axi_sg_awaddr ;
    wire               [7 : 0]     m_axi_sg_awlen ;
    wire              [2 : 0]   m_axi_sg_awsize   ;
    wire             [1 : 0]    m_axi_sg_awburst  ;
    wire              [2 : 0]    m_axi_sg_awprot  ;
    wire             [3 : 0]     m_axi_sg_awcache ;
    wire             [3 : 0]     m_axi_sg_awuser ;
    wire m_axi_sg_wready             ;
    wire m_axi_sg_wvalid             ;
    wire                [C_M_AXI_SG_DATA_WIDTH-1 : 0] m_axi_sg_wdata;
    wire                [C_M_AXI_SG_DATA_WIDTH/8-1 : 0] m_axi_sg_wstrb;
    wire m_axi_sg_wlast              ;
    wire m_axi_sg_bready             ;
    wire m_axi_sg_bvalid             ;
    wire               [1 : 0]     m_axi_sg_bresp ;
    wire m_axi_sg_arready            ;
    wire m_axi_sg_arvalid            ;
    wire               [C_M_AXI_SG_ADDR_WIDTH-1 : 0] m_axi_sg_araddr ;
    wire               [7 : 0]     m_axi_sg_arlen ;
    wire              [2 : 0]     m_axi_sg_arsize ;
    wire             [1 : 0]      m_axi_sg_arburst;
    wire              [2 : 0]     m_axi_sg_arprot ;
    wire             [3 : 0]     m_axi_sg_arcache ;
    wire             [3 : 0]      m_axi_sg_aruser;
    wire m_axi_sg_rready             ;
    wire m_axi_sg_rvalid             ;
    wire                [C_M_AXI_SG_DATA_WIDTH-1 : 0]  m_axi_sg_rdata;
    wire               [1 : 0]      m_axi_sg_rresp;
    wire m_axi_sg_rlast              ;


    wire locked   ;
    wire  clock_lite ;
    wire clock;
    wire reset_lock;

    wire [11:0] address;
    wire [7:0] awlen;
    wire awvalid ;
    wire init_done ;
    wire [7:0] counter;
    wire wvalid ;

    wire [MM2S_AXIS_DATA_WIDTH-1 : 0] m_axis_tdata;
    wire [MM2S_AXIS_DATA_WIDTH/8-1 : 0] m_axis_tkeep;
    wire m_axis_tvalid   ;
    wire m_axis_tready   ;
    wire m_axis_tlast  ;
    wire  [3 : 0] m_axis_tuser;
    wire     [4 : 0] m_axis_tid;
    wire    [4 : 0] m_axis_tdest;

    wire     [31 : 0] m_axis_ctrl_tdata;
    wire     [3 : 0] m_axis_ctrl_tkeep;
    wire m_axis_ctrl_tvalid   ;
    wire m_axis_ctrl_tready   ;
    wire m_axis_ctrl_tlast   ;

    wire     [S2MM_AXIS_DATA_WIDTH-1 : 0] s_axis_tdata;
    wire     [S2MM_AXIS_DATA_WIDTH/8-1 : 0] s_axis_tkeep;
    wire s_axis_tvalid   ;
    wire s_axis_tready   ;
    wire s_axis_tlast  ;
    wire     [3 : 0] s_axis_tuser;
    wire     [4 : 0] s_axis_tid;
    wire    [4 : 0] s_axis_tdest;
    wire s2mm_writes_done ;

    wire     [31 : 0] s_axis_ctrl_tdata;
    wire     [3 : 0] s_axis_ctrl_tkeep;
    wire s_axis_ctrl_tvalid   ;
    wire s_axis_ctrl_tready   ;
    wire s_axis_ctrl_tlast   ;

    wire pass, fail;
    wire pass_ctrl, fail_ctrl ;
    wire pass_s2mm, fail_s2mm ;
    wire mm2s_intr ;
    wire s2mm_intr ;
    reg done_int ;
    reg  [0 : 0] zero = 0;
    reg one_gnd = 0;
    wire  [3 : 0] four_gnd = 4'b0;
    wire lite_done ;
    wire [31 : 0] atg_status;


clock_gen CLOCK_GEN_INST(
.clk_in1_p (clk_in1_p),
.clk_in1_n (clk_in1_n),
.reset    (reset),
.locked   (locked),
.clock_lite (clock_lite),
.clock (clock)
);

  assign  reset_lock = locked;
  //  assign reset_lock = resetn;


    axi_dma_0 DUT (
      .m_axi_sg_aclk   (clock),
      .m_axi_mm2s_aclk (clock),
      .m_axi_s2mm_aclk (clock),
      .s_axi_lite_aclk (clock_lite),
      .axi_resetn (reset_lock),
      .s_axi_lite_awready (m_axi_lite_awready),
      .s_axi_lite_awvalid (m_axi_lite_awvalid),
      .s_axi_lite_awaddr  (m_axi_lite_awaddr [AXI_LITE_ADDR_WIDTH-1 : 0]),
      .s_axi_lite_wready  (m_axi_lite_wready),
      .s_axi_lite_wvalid  (m_axi_lite_wvalid),
      .s_axi_lite_wdata   (m_axi_lite_wdata),
      .s_axi_lite_bready  (m_axi_lite_bready),
      .s_axi_lite_bvalid  (m_axi_lite_bvalid),
      .s_axi_lite_bresp   (m_axi_lite_bresp),
      .s_axi_lite_arready (s_axi_lite_arready),
      .s_axi_lite_arvalid (s_axi_lite_arvalid),
      .s_axi_lite_araddr  (s_axi_lite_araddr [AXI_LITE_ADDR_WIDTH-1 : 0]),
      .s_axi_lite_rready  (s_axi_lite_rready),
      .s_axi_lite_rvalid  (s_axi_lite_rvalid),
      .s_axi_lite_rdata   (s_axi_lite_rdata),
      .s_axi_lite_rresp   (s_axi_lite_rresp),
// AXI4 read signals
      .m_axi_mm2s_arready      (m_axi_arready),
      .m_axi_mm2s_arvalid      (m_axi_arvalid),
      .m_axi_mm2s_araddr       (m_axi_araddr),
      .m_axi_mm2s_arlen        (m_axi_arlen),
      .m_axi_mm2s_arsize       (m_axi_arsize),
      .m_axi_mm2s_arburst      (m_axi_arburst),
      .m_axi_mm2s_arprot       (m_axi_arprot),
      .m_axi_mm2s_arcache      (m_axi_arcache),
      .m_axi_mm2s_rready       (m_axi_rready),
    .m_axi_mm2s_rvalid       (m_axi_rvalid),
    .m_axi_mm2s_rdata        (m_axi_rdata),
    .m_axi_mm2s_rresp        (m_axi_rresp),
    .m_axi_mm2s_rlast        (m_axi_rlast),
    .m_axis_mm2s_tdata       (m_axis_tdata),
    .m_axis_mm2s_tkeep       (m_axis_tkeep),
    .m_axis_mm2s_tvalid      (m_axis_tvalid),
    .m_axis_mm2s_tready      (m_axis_tready),
    .m_axis_mm2s_tlast       (m_axis_tlast),
    .m_axis_mm2s_cntrl_tdata  (m_axis_ctrl_tdata),
    .m_axis_mm2s_cntrl_tkeep  (m_axis_ctrl_tkeep),
    .m_axis_mm2s_cntrl_tvalid (m_axis_ctrl_tvalid),
    .m_axis_mm2s_cntrl_tready (m_axis_ctrl_tready),
    .m_axis_mm2s_cntrl_tlast  (m_axis_ctrl_tlast),
// AI4 write signal
    .m_axi_s2mm_awready      (m_axi_awready),
    .m_axi_s2mm_awvalid      (m_axi_awvalid),
    .m_axi_s2mm_awaddr       (m_axi_awaddr),
    .m_axi_s2mm_awlen        (m_axi_awlen),
    .m_axi_s2mm_awsize       (m_axi_awsize),
    .m_axi_s2mm_awburst      (m_axi_awburst),
    .m_axi_s2mm_awprot       (m_axi_awprot),
    .m_axi_s2mm_awcache      (m_axi_awcache),
    .m_axi_s2mm_wready       (m_axi_wready),
    .m_axi_s2mm_wvalid       (m_axi_wvalid),
    .m_axi_s2mm_wdata        (m_axi_wdata),
    .m_axi_s2mm_wstrb        (m_axi_wstrb),
    .m_axi_s2mm_wlast        (m_axi_wlast),
    .m_axi_s2mm_bready       (m_axi_bready),
    .m_axi_s2mm_bvalid       (m_axi_bvalid),
    .m_axi_s2mm_bresp        (m_axi_bresp),
    .s_axis_s2mm_tdata       (s_axis_tdata),
    .s_axis_s2mm_tkeep       (s_axis_tkeep),
    .s_axis_s2mm_tvalid      (s_axis_tvalid),
    .s_axis_s2mm_tready      (s_axis_tready),
    .s_axis_s2mm_tlast       (s_axis_tlast),
    .s_axis_s2mm_sts_tdata   (s_axis_ctrl_tdata),
    .s_axis_s2mm_sts_tkeep   (s_axis_ctrl_tkeep),
    .s_axis_s2mm_sts_tvalid  (s_axis_ctrl_tvalid),
    .s_axis_s2mm_sts_tready  (s_axis_ctrl_tready),
    .s_axis_s2mm_sts_tlast   (s_axis_ctrl_tlast),
// AI4 SG read), write signals
    .m_axi_sg_awready   (m_axi_sg_awready),
    .m_axi_sg_awvalid   (m_axi_sg_awvalid),
    .m_axi_sg_awaddr    (m_axi_sg_awaddr),
    .m_axi_sg_awlen     (m_axi_sg_awlen),
    .m_axi_sg_awsize    (m_axi_sg_awsize),
    .m_axi_sg_awburst   (m_axi_sg_awburst),
    .m_axi_sg_awprot    (m_axi_sg_awprot),
    .m_axi_sg_awcache   (m_axi_sg_awcache),
    .m_axi_sg_wready    (m_axi_sg_wready),
    .m_axi_sg_wvalid    (m_axi_sg_wvalid),
    .m_axi_sg_wdata     (m_axi_sg_wdata),
    .m_axi_sg_wstrb     (m_axi_sg_wstrb),
    .m_axi_sg_wlast     (m_axi_sg_wlast),
    .m_axi_sg_bready    (m_axi_sg_bready),
    .m_axi_sg_bvalid    (m_axi_sg_bvalid),
    .m_axi_sg_bresp     (m_axi_sg_bresp),
    .m_axi_sg_arready   (m_axi_sg_arready),
    .m_axi_sg_arvalid   (m_axi_sg_arvalid),
    .m_axi_sg_araddr    (m_axi_sg_araddr),
    .m_axi_sg_arlen     (m_axi_sg_arlen),
    .m_axi_sg_arsize    (m_axi_sg_arsize),
    .m_axi_sg_arburst   (m_axi_sg_arburst),
    .m_axi_sg_arprot    (m_axi_sg_arprot),
    .m_axi_sg_arcache   (m_axi_sg_arcache),
    .m_axi_sg_rready    (m_axi_sg_rready),
    .m_axi_sg_rvalid    (m_axi_sg_rvalid),
    .m_axi_sg_rdata     (m_axi_sg_rdata),
    .m_axi_sg_rresp     (m_axi_sg_rresp),
    .m_axi_sg_rlast     (m_axi_sg_rlast),
    .mm2s_introut       (mm2s_intr),
    .s2mm_introut       (s2mm_intr),
    .axi_dma_tstvec     ()
    );

  generate if (C_USE_LITE == 0) begin
    axi_traffic_gen_0 #(
   //   .SYN_BLACK_BOX (SYN_BLACK_BOX),
   //   .BLACK_BOX_PAD_PIN (BLACK_BOX_PAD_PIN)
   //  .BLACK_BOX_PAD_PIN("s_axi_aclk),s_axi_aresetn),irq_out),m_axi_lite_ch1_awaddr[31:0]),m_axi_lite_ch1_awprot[2:0]),m_axi_lite_ch1_awvalid),m_axi_lite_ch1_awready),m_axi_lite_ch1_wdata[31:0]),m_axi_lite_ch1_wstrb[3:0]),m_axi_lite_ch1_wvalid),m_axi_lite_ch1_wready),m_axi_lite_ch1_bresp[1:0]),m_axi_lite_ch1_bvalid),m_axi_lite_ch1_bready),m_axi_lite_ch1_araddr[31:0]),m_axi_lite_ch1_arvalid),m_axi_lite_ch1_arready),m_axi_lite_ch1_rdata[31:0]),m_axi_lite_ch1_rvalid),m_axi_lite_ch1_rready),m_axi_lite_ch1_rresp[1:0]")
      )ATG1 (
      .s_axi_aclk         (clock_lite),
      .s_axi_aresetn      (init_done),
      .m_axi_lite_ch1_awaddr   (m_axi_lite_awaddr),
      .m_axi_lite_ch1_awprot   (open),
      .m_axi_lite_ch1_awvalid  (m_axi_lite_awvalid),
      .m_axi_lite_ch1_awready  (m_axi_lite_awready),
      .m_axi_lite_ch1_wdata    (m_axi_lite_wdata),
      .m_axi_lite_ch1_wstrb    (open),
      .m_axi_lite_ch1_wvalid   (m_axi_lite_wvalid),
      .m_axi_lite_ch1_wready   (m_axi_lite_wready),
      .m_axi_lite_ch1_bresp    (m_axi_lite_bresp),
      .m_axi_lite_ch1_bvalid   (m_axi_lite_bvalid),
      .m_axi_lite_ch1_bready   (m_axi_lite_bready),
      .m_axi_lite_ch1_araddr   (s_axi_lite_araddr),
      .m_axi_lite_ch1_arvalid  (s_axi_lite_arvalid),
      .m_axi_lite_ch1_arready  (s_axi_lite_arready),
      .m_axi_lite_ch1_rdata    (s_axi_lite_rdata),
      .m_axi_lite_ch1_rvalid   (s_axi_lite_rvalid),
      .m_axi_lite_ch1_rready   (s_axi_lite_rready),
      .m_axi_lite_ch1_rresp    (s_axi_lite_rresp),
      .done                    (lite_done),
      .status                  (atg_status)
      );
      end
    endgenerate

generate if (C_USE_LITE == 1) begin
    axi_lite_sm  #(
      .C_M_AXI_ADDR_WIDTH(32),
      .C_M_AXI_DATA_WIDTH(32)
      )
    AXI_LIT_INTF (

        // System Signals
        .D_WIDTH (one_gnd),
        .M_AXI_ACLK (clock_lite),
        .M_AXI_ARESETN (init_done),

        // Master Interface Write Address
        .M_AXI_AWADDR (m_axi_lite_awaddr),
        .M_AXI_AWPROT (open),
        .M_AXI_AWVALID (m_axi_lite_awvalid),
        .M_AXI_AWREADY (m_axi_lite_awready),

        // Master Interface Write Data
        .M_AXI_WDATA (m_axi_lite_wdata),
        .M_AXI_WSTRB (open),
        .M_AXI_WVALID (m_axi_lite_wvalid),
        .M_AXI_WREADY (m_axi_lite_wready),

        // Master Interface Write Response
        .M_AXI_BRESP (m_axi_lite_bresp),
        .M_AXI_BVALID (m_axi_lite_bvalid),
        .M_AXI_BREADY (m_axi_lite_bready),

        // Master Interface Read Address
        .M_AXI_ARADDR (s_axi_lite_araddr),
        .M_AXI_ARPROT (open),
        .M_AXI_ARVALID (s_axi_lite_arvalid),
        .M_AXI_ARREADY (s_axi_lite_arready),

        // Master Interface Read Data
        .M_AXI_RDATA (s_axi_lite_rdata),
        .M_AXI_RRESP (s_axi_lite_rresp),
        .M_AXI_RVALID (s_axi_lite_rvalid),
        .M_AXI_RREADY (s_axi_lite_rready),

        //Example Output
        .DDRX_PHY_INIT_DONE (1),
        .CHRONTEL_INIT_DONE (1),
        .DONE_SUCCESS (lite_done)
        );
end
endgenerate

axi_bram_ctrl_0 #(
//   .SYN_BLACK_BOX (SYN_BLACK_BOX),
//   .BLACK_BOX_PAD_PIN (BLACK_BOX_PAD_PIN)
//.BLACK_BOX_PAD_PIN("s_axi_aclk),s_axi_aresetn),s_axi_awid[0:0]),s_axi_awaddr[15:0]),s_axi_awlen[7:0]),s_axi_awsize[2:0]),s_axi_awburst[1:0]),s_axi_awlock),s_axi_awcache[3:0]),s_axi_awprot[2:0]),s_axi_awvalid),s_axi_awready),s_axi_wdata[(512-1):0]),s_axi_wstrb[((512/8)-1):0]),s_axi_wlast),s_axi_wvalid),s_axi_wready),s_axi_bid[0:0]),s_axi_bresp[1:0]),s_axi_bvalid),s_axi_bready),s_axi_arid[0:0]),s_axi_araddr[15:0]),s_axi_arlen[7:0]),s_axi_arsize[2:0]),s_axi_arburst[1:0]),s_axi_arlock),s_axi_arcache[3:0]),s_axi_arprot[2:0]),s_axi_arvalid),s_axi_arready),s_axi_rid[0:0]),s_axi_rdata[(512-1):0]),s_axi_rresp[1:0]),s_axi_rlast),s_axi_rvalid),s_axi_rready")
  ) U0_read (
  .s_axi_aclk(clock),        // input wire s_axi_aclk
  .s_axi_aresetn(reset_lock),  // input wire s_axi_aresetn
  .s_axi_awid(zero),        // input wire [0 : 0] s_axi_awid
  .s_axi_awaddr(s_axi_awaddr[BRAM_ADDR_WIDTH-1: 0]),    // input wire [15 : 0] s_axi_awaddr
  .s_axi_awlen(s_axi_awlen),      // input wire [7 : 0] s_axi_awlen
  .s_axi_awsize(s_axi_awsize),    // input wire [2 : 0] s_axi_awsize
  .s_axi_awburst(s_axi_awburst),  // input wire [1 : 0] s_axi_awburst
  .s_axi_awlock(one_gnd),    // input wire s_axi_awlock
  .s_axi_awcache(s_axi_awcache),  // input wire [3 : 0] s_axi_awcache
  .s_axi_awprot(s_axi_awprot),    // input wire [2 : 0] s_axi_awprot
  .s_axi_awvalid(s_axi_awvalid),  // input wire s_axi_awvalid
  .s_axi_awready(s_axi_awready),  // output wire s_axi_awready
  .s_axi_wdata(s_axi_wdata),      // input wire [511 : 0] s_axi_wdata
  .s_axi_wstrb(s_axi_wstrb),      // input wire [63 : 0] s_axi_wstrb
  .s_axi_wlast(s_axi_wlast),      // input wire s_axi_wlast
  .s_axi_wvalid(s_axi_wvalid),    // input wire s_axi_wvalid
  .s_axi_wready(s_axi_wready),    // output wire s_axi_wready
  .s_axi_bid(),          // output wire [0 : 0] s_axi_bid
  .s_axi_bresp(s_axi_bresp),      // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid(s_axi_bvalid),    // output wire s_axi_bvalid
  .s_axi_bready(s_axi_bready),    // input wire s_axi_bready
  .s_axi_arid(zero),        // input wire [0 : 0] s_axi_arid
  .s_axi_araddr(m_axi_araddr[BRAM_ADDR_WIDTH-1: 0]),    // input wire [15 : 0] s_axi_araddr
  .s_axi_arlen(m_axi_arlen),      // input wire [7 : 0] s_axi_arlen
  .s_axi_arsize(m_axi_arsize),    // input wire [2 : 0] s_axi_arsize
  .s_axi_arburst(m_axi_arburst),  // input wire [1 : 0] s_axi_arburst
  .s_axi_arlock(one_gnd),    // input wire s_axi_arlock
  .s_axi_arcache(m_axi_arcache),  // input wire [3 : 0] s_axi_arcache
  .s_axi_arprot(m_axi_arprot),    // input wire [2 : 0] s_axi_arprot
  .s_axi_arvalid(m_axi_arvalid),  // input wire s_axi_arvalid
  .s_axi_arready(m_axi_arready),  // output wire s_axi_arready
  .s_axi_rid(),          // output wire [0 : 0] s_axi_rid
  .s_axi_rdata(m_axi_rdata),      // output wire [511 : 0] s_axi_rdata
  .s_axi_rresp(m_axi_rresp),      // output wire [1 : 0] s_axi_rresp
  .s_axi_rlast(m_axi_rlast),      // output wire s_axi_rlast
  .s_axi_rvalid(m_axi_rvalid),    // output wire s_axi_rvalid
  .s_axi_rready(m_axi_rready)    // input wire s_axi_rready
);

axi_bram_ctrl_1 #(
//  .SYN_BLACK_BOX (SYN_BLACK_BOX),
  //.BLACK_BOX_PAD_PIN (BLACK_BOX_PAD_PIN)
 // .BLACK_BOX_PAD_PIN ("s_axi_aclk),s_axi_aresetn),s_axi_awid[0:0]),s_axi_awaddr[15:0]),s_axi_awlen[7:0]),s_axi_awsize[2:0]),s_axi_awburst[1:0]),s_axi_awlock),s_axi_awcache[3:0]),s_axi_awprot[2:0]),s_axi_awvalid),s_axi_awready),s_axi_wdata[(512-1):0]),s_axi_wstrb[((512/8)-1):0]),s_axi_wlast),s_axi_wvalid),s_axi_wready),s_axi_bid[0:0]),s_axi_bresp[1:0]),s_axi_bvalid),s_axi_bready),s_axi_arid[0:0]),s_axi_araddr[15:0]),s_axi_arlen[7:0]),s_axi_arsize[2:0]),s_axi_arburst[1:0]),s_axi_arlock),s_axi_arcache[3:0]),s_axi_arprot[2:0]),s_axi_arvalid),s_axi_arready),s_axi_rid[0:0]),s_axi_rdata[(512-1):0]),s_axi_rresp[1:0]),s_axi_rlast),s_axi_rvalid),s_axi_rready")
  )U0_write (
  .s_axi_aclk(clock),        // input wire s_axi_aclk
  .s_axi_aresetn(reset_lock),  // input wire s_axi_aresetn
  .s_axi_awid(zero),        // input wire [0 : 0] s_axi_awid
  .s_axi_awaddr(m_axi_awaddr[BRAM_ADDR_WIDTH_S2MM-1 : 0]),    // input wire [15 : 0] s_axi_awaddr
  .s_axi_awlen(m_axi_awlen),      // input wire [7 : 0] s_axi_awlen
  .s_axi_awsize(m_axi_awsize),    // input wire [2 : 0] s_axi_awsize
  .s_axi_awburst(m_axi_awburst),  // input wire [1 : 0] s_axi_awburst
  .s_axi_awlock(one_gnd),    // input wire s_axi_awlock
  .s_axi_awcache(m_axi_awcache),  // input wire [3 : 0] s_axi_awcache
  .s_axi_awprot(m_axi_awprot),    // input wire [2 : 0] s_axi_awprot
  .s_axi_awvalid(m_axi_awvalid),  // input wire s_axi_awvalid
  .s_axi_awready(m_axi_awready),  // output wire s_axi_awready
  .s_axi_wdata(m_axi_wdata),      // input wire [511 : 0] s_axi_wdata
  .s_axi_wstrb(m_axi_wstrb),      // input wire [63 : 0] s_axi_wstrb
  .s_axi_wlast(m_axi_wlast),      // input wire s_axi_wlast
  .s_axi_wvalid(m_axi_wvalid),    // input wire s_axi_wvalid
  .s_axi_wready(m_axi_wready),    // output wire s_axi_wready
  .s_axi_bid(),          // output wire [0 : 0] s_axi_bid
  .s_axi_bresp(m_axi_bresp),      // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid(m_axi_bvalid),    // output wire s_axi_bvalid
  .s_axi_bready(m_axi_bready),    // input wire s_axi_bready

  .s_axi_arid(zero),        // input wire [0 : 0] s_axi_arid
  .s_axi_araddr(s_axi_araddr[BRAM_ADDR_WIDTH_S2MM-1: 0]),    // input wire [15 : 0] s_axi_araddr
  .s_axi_arlen(s_axi_arlen),      // input wire [7 : 0] s_axi_arlen
  .s_axi_arsize(s_axi_arsize),    // input wire [2 : 0] s_axi_arsize
  .s_axi_arburst(s_axi_arburst),  // input wire [1 : 0] s_axi_arburst
  .s_axi_arlock(one_gnd),    // input wire s_axi_arlock
  .s_axi_arcache(s_axi_arcache),  // input wire [3 : 0] s_axi_arcache
  .s_axi_arprot(s_axi_arprot),    // input wire [2 : 0] s_axi_arprot
  .s_axi_arvalid(s_axi_arvalid),  // input wire s_axi_arvalid
  .s_axi_arready(),  // output wire s_axi_arready
  .s_axi_rid(),          // output wire [0 : 0] s_axi_rid
  .s_axi_rdata(),      // output wire [511 : 0] s_axi_rdata
  .s_axi_rresp(s_axi_rresp),      // output wire [1 : 0] s_axi_rresp
  .s_axi_rlast(),      // output wire s_axi_rlast
  .s_axi_rvalid(),    // output wire s_axi_rvalid
  .s_axi_rready(s_axi_rready)    // input wire s_axi_rready
);

assign s_axi_araddr = 'b0;
assign s_axi_arlen = 'b0;
assign s_axi_arsize = 'b0;
assign s_axi_arburst = 'b0;
assign s_axi_arcache = 'b0;
assign s_axi_arprot = 'b0;
assign s_axi_arvalid = 'b0;
assign s_axi_rresp = 2'b00;
assign s_axi_rready = 'b0;

blk_mem_gen_0 #(
//  .SYN_BLACK_BOX (SYN_BLACK_BOX),
  //.BLACK_BOX_PAD_PIN (BLACK_BOX_PAD_PIN)
//  .BLACK_BOX_PAD_PIN("s_aclk),s_aresetn),s_axi_awid[3:0]),s_axi_awaddr[31:0]),s_axi_awlen[7:0]),s_axi_awsize[2:0]),s_axi_awburst[1:0]),s_axi_awvalid),s_axi_awready),s_axi_wdata[31:0]),s_axi_wstrb[3:0]),s_axi_wlast),s_axi_wvalid),s_axi_wready),s_axi_bid[3:0]),s_axi_bresp[1:0]),s_axi_bvalid),s_axi_bready),s_axi_arid[3:0]),s_axi_araddr[31:0]),s_axi_arlen[7:0]),s_axi_arsize[2:0]),s_axi_arburst[1:0]),s_axi_arvalid),s_axi_arready),s_axi_rid[3:0]),s_axi_rdata[31:0]),s_axi_rresp[1:0]),s_axi_rlast),s_axi_rvalid),s_axi_rready")
  )SG_BLK (
  .s_aclk         (clock),
  .s_aresetn      (reset_lock),
  .s_axi_awid     (four_gnd),
  .s_axi_awaddr   (m_axi_sg_awaddr),
  .s_axi_awlen    (m_axi_sg_awlen),
  .s_axi_awsize   (m_axi_sg_awsize),
  .s_axi_awburst  (m_axi_sg_awburst),
  .s_axi_awvalid  (m_axi_sg_awvalid),
  .s_axi_awready  (m_axi_sg_awready),
  .s_axi_wdata    (m_axi_sg_wdata),
  .s_axi_wstrb    (m_axi_sg_wstrb),
  .s_axi_wlast    (m_axi_sg_wlast),
  .s_axi_wvalid   (m_axi_sg_wvalid),
  .s_axi_wready   (m_axi_sg_wready),
  .s_axi_bid      (),
  .s_axi_bresp    (m_axi_sg_bresp),
  .s_axi_bvalid   (m_axi_sg_bvalid),
  .s_axi_bready   (m_axi_sg_bready),
  .s_axi_arid     (four_gnd),
  .s_axi_araddr   (m_axi_sg_araddr),
  .s_axi_arlen    (m_axi_sg_arlen),
  .s_axi_arsize   (m_axi_sg_arsize),
  .s_axi_arburst  (m_axi_sg_arburst),
  .s_axi_arvalid  (m_axi_sg_arvalid),
  .s_axi_arready  (m_axi_sg_arready),
  .s_axi_rid      (),
  .s_axi_rdata    (m_axi_sg_rdata),
  .s_axi_rresp    (m_axi_sg_rresp),
  .s_axi_rlast    (m_axi_sg_rlast),
  .s_axi_rvalid   (m_axi_sg_rvalid),
  .s_axi_rready   (m_axi_sg_rready)
);

//We need to have some logic to fill the Read BRAM
//This logic would start as soon as MMCM is locked

axi4_write_master #(
        .MEM_DATA_WIDTH (512),
        .BURST_LENGTH   (2),
        .C_NUM_BURST    (2)
  )
  MM2S_AXI4_BRAM_FILL (
        .clock           (clock),
        .resetn          (reset_lock),
      //  -----------------------------------------------------------------------                 --
      //  -- AXI Write Channel                                                                     --
      //  -----------------------------------------------------------------------                 --
      //  -- Write Address Channel                                           --
        .awaddr           (s_axi_awaddr),
        .awlen            (s_axi_awlen),
        .awsize           (s_axi_awsize),
        .awburst          (s_axi_awburst),
        .awprot           (s_axi_awprot),
        .awcache          (s_axi_awcache),
        .awvalid          (s_axi_awvalid),
        .awready          (s_axi_awready),
    //    -- Write Data Channel                                              --
        .wdata            (s_axi_wdata),
        .wstrb            (s_axi_wstrb),
        .wlast            (s_axi_wlast),
        .wvalid           (s_axi_wvalid),
        .wready           (s_axi_wready),
    //    -- Write Response Channel                                          --
        .bresp            (s_axi_bresp),
        .bvalid           (s_axi_bvalid),
        .bready           (s_axi_bready),
    //    -- Stream to Memory Map Steam Interface                                                 --
        .done_write_success     (init_done)
    );


    axis_ctrl_read MM2S_AXIS_CTRL_CHECK(
           .s_axi_clk (clock),
           .s_axi_resetn (reset_lock),
           .s_axis_tdata   (m_axis_ctrl_tdata),
           .s_axis_tkeep   (m_axis_ctrl_tkeep),
           .s_axis_tvalid  (m_axis_ctrl_tvalid),
           .s_axis_tlast   (m_axis_ctrl_tlast),
           .m_axis_tready  (m_axis_ctrl_tready),
           .pass           (pass_ctrl),
           .fail           (fail_ctrl)
    );

  // This logic checks the MM2S stream data

axis_data_read #(
   .MMAP_DATA_WIDTH (512),
   .AXIS_TDATA_WIDTH (512)
 ) MM2S_AXIS_DATA_CHECK (
  .s_axi_clk (clock),

  .s_axi_resetn (reset_lock),
  .s_axis_tdata   (m_axis_tdata),
  .s_axis_tkeep   (m_axis_tkeep),
  .s_axis_tvalid  (m_axis_tvalid),
  .s_axis_tlast   (m_axis_tlast),
  .m_axis_tready  (m_axis_tready),
  .pass           (pass),
  .fail           (fail)
);

//Following logic generates S2MM AXIS data

axis_write_master #(
    .MEM_DATA_WIDTH         (512),
    .STREAM_DATA_WIDTH      (512),
    .C_BYPASS_START_DELAY   (1),
    .C_START_DELAY          (1024),
    .SINGLE_TUSER_PULSE     (0),
    .BURST_LENGTH           (16),
    .C_NUM_BURST            (2)
)
S2MM_AXIS_DATA_GEN (
    .clock           (clock),
    .resetn          (reset_lock),
    //Write Data Channel                                              --
    .tdest           (s_axis_tdest),
    .tuser           (s_axis_tuser),
    .tid             (s_axis_tid),
    .tdata           (s_axis_tdata),
    .tkeep           (s_axis_tkeep),
    .tlast           (s_axis_tlast),
    .tvalid          (s_axis_tvalid),
    .tready          (s_axis_tready),
    .done_write_success     (s2mm_writes_done)
);


// We need to have some logic to check the Write data


axi_s2mm_read #(
   .MMAP_DATA_WIDTH (512)
 )
 S2MM_DATA_CHECK (
   .s_axi_clk (clock),

   .s_axi_resetn (reset_lock),
   .s_axi_data   (m_axi_wdata),
   .s_axi_strb   (m_axi_wstrb),
   .s_axi_valid  (m_axi_wvalid),
   .s_axi_last   (m_axi_wlast),
   .m_axi_ready  (m_axi_wready),
   .pass         (pass_s2mm),
   .fail         (fail_s2mm)
 );

axis_sts_master S2MM_STS_GEN (
   .s_axi_clk (clock),
   .s_axi_resetn (reset_lock),
   .s_axis_tdata   (s_axis_ctrl_tdata),
   .s_axis_tkeep   (s_axis_ctrl_tkeep),
   .s_axis_tvalid  (s_axis_ctrl_tvalid),
   .s_axis_tlast   (s_axis_ctrl_tlast),
   .m_axis_tready  (s_axis_ctrl_tready)
);

always @(posedge clock)
begin
  if (reset_lock == 0) begin
   done_int <= 0;
   status <= 0;
  end else if (mm2s_intr == 1 & s2mm_intr == 1) begin
     if (fail == 1 | fail_ctrl == 1 | fail_s2mm == 1) begin
        status <= 0;
        done_int <= 1;
     end else if (pass == 1 & pass_ctrl == 1 & pass_s2mm == 1) begin
        status <= 1;
        done_int <= 1;
     end
  end
end

always @(posedge clock)
begin
  if (reset_lock == 0)
   done <= 0;
  else
   done <= done_int;
end

endmodule
