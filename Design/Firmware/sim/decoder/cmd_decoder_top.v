`timescale 1ps/1ps

module cmd_decoder_top #(
    parameter DEST_ADDR       =48'h985aebdb066f,
    parameter SRC_ADDR        = 48'h5a0102030405
)
(
input s_axi_aclk,
input s_axi_resetn,

input clk_fmc150,
input resetn_fmc150,

input gtx_clk_bufg,
input gtx_resetn,

output [7:0]  gpio_led,        // : out   std_logic_vector(7 downto 0);
input [7:0]  gpio_dip_sw,   //   : in    std_logic_vector(7 downto 0);
    // data from ADC Data fifo
output       [7:0]                     tx_axis_tdata,
output                                 tx_axis_tvalid,
output                                 tx_axis_tlast,
input                                  tx_axis_tready,

input       [7:0]                     rx_axis_tdata,
input                                 rx_axis_tvalid,
input                                 rx_axis_tlast,
output                                rx_axis_tready

);

  localparam RX_PKT_CMD_DWIDTH = 192;


// Control Module Signals
wire [3:0] fmc150_status_vector;
wire chirp_ready;          // continuous high when dac ready
wire chirp_active;         // continuous high while chirping
wire chirp_done;           // single pulse when chirp finished
wire chirp_init;          // single pulse to initiate chirp
wire chirp_enable;        // continuous high while chirp enabled
wire adc_enable;          // high while adc samples saved


wire [7:0] fmc150_ctrl_bus;
wire [7:0] fmc150_ctrl_bus_bypass;
//fmc150_ctrl_bus = {3'b0,ddc_duc_bypass,digital_mode,adc_out_dac_in,external_clock,gen_adc_test_pattern};

wire [67:0] fmc150_spi_ctrl_bus_in;
wire [47:0] fmc150_spi_ctrl_bus_out = 48'b0;

wire [7:0] ethernet_ctrl_bus;
wire [7:0] ethernet_ctrl_bus_bypass;
// ethernet_ctrl_bus = {3'b0,enable_adc_pkt,gen_tx_data,chk_tx_data,mac_speed};

wire [127:0] chirp_parameters;
// chirp_parameters = {32'b0,chirp_freq_offset,chirp_tuning_word_coeff,chirp_count_max};

wire [31:0]   cmd_pkt_s_axis_tdata;
wire          cmd_pkt_s_axis_tvalid;
wire          cmd_pkt_s_axis_tlast;
wire          cmd_pkt_s_axis_tready;

wire [31:0]   cmd_pkt_axis_tdata;
wire          cmd_pkt_axis_tvalid;
wire          cmd_pkt_axis_tlast;
wire          cmd_pkt_axis_tready;

wire [RX_PKT_CMD_DWIDTH-1:0]   cmd_pkt_m_axis_tdata;
wire          cmd_pkt_m_axis_tvalid;
wire          cmd_pkt_m_axis_tlast;
wire          cmd_pkt_m_axis_tready;
wire [RX_PKT_CMD_DWIDTH/8-1:0]   cmd_pkt_m_axis_tkeep;

wire [RX_PKT_CMD_DWIDTH-1:0]   cmd_axis_tdata;
wire          cmd_axis_tvalid;
wire          cmd_axis_tlast;
wire          cmd_axis_tready;
wire [RX_PKT_CMD_DWIDTH/8-1:0]   cmd_axis_tkeep;


wire [31:0] cmd_fifo_axis_data_count;        // output wire [31 : 0] axis_data_count
wire [31:0] cmd_fifo_axis_wr_data_count;  // output wire [31 : 0] axis_wr_data_count
wire [31:0] cmd_fifo_axis_rd_data_count;  // output wire [31 : 0] axis_rd_data_count



wire data_tx_ready;        // high when ready to transmit
wire data_tx_active;       // high while data being transmitted
wire data_tx_done;         // single pule when done transmitting
wire data_tx_init;        // single pulse to start tx data
wire data_tx_enable;      // continuous high while transmit enabled

wire tlast_hold0;
wire tlast_hold1;
wire tlast_hold2;
wire tlast_hold8;

reg tlast_hold_en;
reg hold_en = 0;

// Start of User Design top instance
//***************************************************************************
// The User design is instantiated below. The memory interface ports are
// connected to the top-level and the application interface ports are
// connected to the traffic generator module. This provides a reference
// for connecting the memory controller to system.
//***************************************************************************

assign tx_axis_tdata = 'b0;
assign tx_axis_tvalid = 'b0;
assign tx_axis_tlast = 'b0;

control_module #(
    .RX_PKT_CMD_DWIDTH (RX_PKT_CMD_DWIDTH)
)control_module_inst(
  .s_axi_aclk   (s_axi_aclk),
  .s_axi_resetn  (s_axi_resetn),
// for future use

  // input                               eth_ctrl_en,
  // input [8:0]                         axis_eth_ctrl_tdata,
  // input [8:0]                         axis_eth_ctrl_tkeep,
  // input                               axis_eth_ctrl_tvalid,
  // output                              axis_eth_ctrl_tready,

  .gpio_dip_sw                       (gpio_dip_sw),
  .gpio_led                         (gpio_led),

//  input clk_mig,              // 200 MHZ OR 100 MHz
//  input mig_init_calib_complete,
  .clk_fmc150 (clk_fmc150),           // 245.76 MHz
  .resetn_fmc150(resetn_fmc150),

//input clk_mig,              // 200 MHZ OR 100 MHz
//input mig_init_calib_complete (init_calib_complete),
  .fmc150_status_vector (fmc150_status_vector), // {pll_status, mmcm_adac_locked, mmcm_locked, ADC_calibration_good};
  .chirp_ready (chirp_ready),
  .chirp_done (chirp_done),
  .chirp_active (chirp_active),
  .chirp_init  (chirp_init),
  .chirp_enable  (chirp_enable),
  .adc_enable   (adc_enable),

  .chirp_parameters                   (chirp_parameters),
  //chirp_parameters = {32'b0,chirp_freq_offset,chirp_tuning_word_coeff,chirp_count_max};

  // Decoded Commands from RGMII RX fifo
  .cmd_axis_tdata        (cmd_axis_tdata),
  .cmd_axis_tvalid       (cmd_axis_tvalid),
  .cmd_axis_tlast        (cmd_axis_tlast),
  .cmd_axis_tkeep        (cmd_axis_tkeep),
  .cmd_axis_tready       (cmd_axis_tready),

  .fmc150_spi_ctrl_bus_in (fmc150_spi_ctrl_bus_in),
  .fmc150_spi_ctrl_bus_out (fmc150_spi_ctrl_bus_out),
  //fmc150_ctrl_bus = {3'b0,ddc_duc_bypass,digital_mode,adc_out_dac_in,external_clock,gen_adc_test_pattern};
  .fmc150_ctrl_bus (fmc150_ctrl_bus),
  // output reg ddc_duc_bypass                         = 1'b1, // dip_sw(3)
  // output reg digital_mode                           = 1'b0,
  // output reg adc_out_dac_in                         = 1'b0,
  // output reg external_clock                         = 1'b0,
  // output reg gen_adc_test_pattern                   = 1'b0,
  // Ethernet Control Signals

  .gtx_clk_bufg (gtx_clk_bufg),
  .gtx_resetn       (gtx_resetn),
  .ethernet_ctrl_bus (ethernet_ctrl_bus)
  // output reg enable_rx_decode                         = 1'b1, //dip_sw(1)
  // output reg enable_adc_pkt                         = 1'b1, //dip_sw(1)
  // output reg gen_tx_data                            = 1'b0,
  // output reg chk_tx_data                            = 1'b0,
  // output reg [1:0] mac_speed                        = 2'b10 // {dip_sw(0),~dip_sw(0)}


);

rx_cmd_axis_data_fifo rx_cmd_axis_data_fifo_inst (
  .s_axis_aresetn(gtx_resetn),          // input wire s_axis_aresetn
  .m_axis_aresetn(s_axi_resetn),          // input wire m_axis_aresetn
  .s_axis_aclk(gtx_clk_bufg),                // input wire s_axis_aclk
  .s_axis_tvalid(cmd_pkt_m_axis_tvalid),            // input wire s_axis_tvalid
  .s_axis_tready(cmd_pkt_m_axis_tready),            // output wire s_axis_tready
  .s_axis_tdata(cmd_pkt_m_axis_tdata),              // input wire [191 : 0] s_axis_tdata
  .s_axis_tkeep(cmd_pkt_m_axis_tkeep),              // input wire [23 : 0] s_axis_tkeep
  .s_axis_tlast(cmd_pkt_m_axis_tlast),              // input wire s_axis_tlast

  .m_axis_aclk(s_axi_aclk),                // input wire m_axis_aclk
  .m_axis_tvalid(cmd_axis_tvalid),            // output wire m_axis_tvalid
  .m_axis_tready(cmd_axis_tready),            // input wire m_axis_tready
  .m_axis_tdata(cmd_axis_tdata),              // output wire [191 : 0] m_axis_tdata
  .m_axis_tkeep(cmd_axis_tkeep),              // output wire [23 : 0] m_axis_tkeep
  .m_axis_tlast(cmd_axis_tlast),              // input wire m_axis_tlast
  .axis_data_count(cmd_fifo_axis_data_count),        // output wire [31 : 0] axis_data_count
  .axis_wr_data_count(cmd_fifo_axis_wr_data_count),  // output wire [31 : 0] axis_wr_data_count
  .axis_rd_data_count(cmd_fifo_axis_rd_data_count)  // output wire [31 : 0] axis_rd_data_count
);

rx_cmd_axis_dwidth_converter rx_cmd_axis_dwidth_converter_inst (
  .aclk(gtx_clk_bufg),                    // input wire aclk
  .aresetn(gtx_resetn),              // input wire aresetn
  .s_axis_tvalid(cmd_pkt_s_axis_tvalid),  // input wire s_axis_tvalid
  .s_axis_tready(cmd_pkt_s_axis_tready),  // output wire s_axis_tready
  .s_axis_tdata(cmd_pkt_s_axis_tdata),    // input wire [31 : 0] s_axis_tdata
  .s_axis_tlast(cmd_pkt_s_axis_tlast),    // input wire s_axis_tlast
  .m_axis_tvalid(cmd_pkt_m_axis_tvalid),  // output wire m_axis_tvalid
  .m_axis_tready(cmd_pkt_m_axis_tready),  // input wire m_axis_tready
  .m_axis_tdata(cmd_pkt_m_axis_tdata),    // output wire [191 : 0] m_axis_tdata
  .m_axis_tkeep(cmd_pkt_m_axis_tkeep),    // output wire [23 : 0] m_axis_tkeep
  .m_axis_tlast(cmd_pkt_m_axis_tlast)    // output wire m_axis_tlast
);

assign fmc150_ctrl_bus_bypass = {3'b0,gpio_dip_sw[3],1'b0,1'b0,1'b0,1'b0};
//fmc150_ctrl_bus = {3'b0,ddc_duc_bypass,digital_mode,adc_out_dac_in,external_clock,gen_adc_test_pattern};

assign ethernet_ctrl_bus_bypass = {2'b0,1'b1,gpio_dip_sw[1],1'b0,1'b0,gpio_dip_sw[0],~gpio_dip_sw[0]};
// ethernet_ctrl_bus = {2'b0,enable_rx_decode,enable_adc_pkt,gen_tx_data,chk_tx_data,mac_speed};

kc705_ethernet_rgmii_axi_rx_decoder #(
  //   parameter                            DEST_ADDR       = 48'hda0102030405,
     .DEST_ADDR       (DEST_ADDR),
     .SRC_ADDR        (SRC_ADDR),
     .MAX_SIZE        (16'd500),
  //   parameter                            MIN_SIZE        = 16'd64,
    .MIN_SIZE         (16'd500),
    .ENABLE_VLAN      (1'b0),
    .VLAN_ID          (12'd2),
    .VLAN_PRIORITY    (3'd2)
 ) rx_cmd_decoder_inst (
     .axi_tclk (gtx_clk_bufg),
     .axi_tresetn (gtx_resetn),

     .enable_rx_decode        (1'b1),
     .speed                  (2'b10),

   // data from the RX data path
     .rx_axis_tdata       (rx_axis_tdata),
     .rx_axis_tvalid       (rx_axis_tvalid),
     .rx_axis_tlast       (rx_axis_tlast),
     .rx_axis_tready      (rx_axis_tready),

   // data TO the TX data path
     .tdata       (cmd_pkt_axis_tdata),
     .tvalid       (cmd_pkt_axis_tvalid),
     .tlast       (cmd_pkt_axis_tlast),
     .tready      (cmd_pkt_axis_tready)
);


axi_rx_command_gen #(
 ) axi_rx_command_gen_inst (
       .axi_tclk (gtx_clk_bufg),
       .axi_tresetn (gtx_resetn),

       .enable_rx_decode        (1'b1),
   // data from the RX data path
           .cmd_axis_tdata       (cmd_pkt_axis_tdata),
           .cmd_axis_tvalid       (cmd_pkt_axis_tvalid),
           .cmd_axis_tlast       (cmd_pkt_axis_tlast),
           .cmd_axis_tready      (cmd_pkt_axis_tready),

   // data TO the TX data path
           .tdata       (cmd_pkt_s_axis_tdata),
           .tvalid       (cmd_pkt_s_axis_tvalid),
           .tlast       (cmd_pkt_s_axis_tlast),
           .tready      (cmd_pkt_s_axis_tready)

);

signal_hold #(
    .HOLD_CLOCKS (0),
    .DATA_WIDTH (1)
) signal_hold_tlast0 (
    .clk(gtx_clk_bufg),
    .aresetn(gtx_resetn),
    .data_in(rx_axis_tlast),
    .data_out (tlast_hold0)
);

signal_hold #(
    .HOLD_CLOCKS (1),
    .DATA_WIDTH (1)
) signal_hold_tlast1 (
    .clk(gtx_clk_bufg),
    .aresetn(gtx_resetn),
    .data_in(rx_axis_tlast),
    .data_out (tlast_hold1)
);

signal_hold #(
    .HOLD_CLOCKS (2),
    .DATA_WIDTH (1)
) signal_hold_tlast2 (
    .clk(gtx_clk_bufg),
    .aresetn(gtx_resetn),
    .data_in(rx_axis_tlast),
    .data_out (tlast_hold2)
);

signal_hold #(
    .HOLD_CLOCKS (2),
    .DATA_WIDTH (1)
) signal_hold_tlast8 (
    .clk(gtx_clk_bufg),
    .aresetn(gtx_resetn),
    .data_in((rx_axis_tdata[0]^rx_axis_tdata[1])),
    .data_out (tlast_hold8)
);

always @(posedge gtx_clk_bufg) begin
if (!gtx_resetn)    
    hold_en <= 0;
else 
    hold_en <= !hold_en;
end    

always @(posedge hold_en) begin
    tlast_hold_en = tlast_hold2;
end


endmodule
