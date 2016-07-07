
//////////////////////////////////////////////////////////////////////////////////
// Company: MiXIL
// Engineer: Samuel Prager
//
// Create Date: 06/22/2016 02:25:19 PM
// Design Name:
// Module Name: config_reg_map
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

//--------------DDS Chirp Generation Parameters-------------------
//-- period = 4.17 us, BW = 46.08 MHz
//-- 491.52 Mhz clock, 4096 samples, 16 bit phase accumulator (n = 16)
//-- ch_tuning_coef = 3      for BW = 46.08 MHz (2048 samples)
//-- ch_tuning_coef = 4      for BW = 61.44 MHz (2048 samples)
//-- ch_tuning_coef = 1.5    for BW = 46.08 MHz (4096 samples)
//-- ch_tuning_coef = 2      for BW = 61.44 MHz (4096 samples)
//-- Calculated Using:
//--    ch_tuning_coef = BW*(2^n)/(num_samples*fClock)
//-- Taken From:
//--    ch_tuning_coef = period*slope*(2^n)/(num_samples*fClock)
//-- Where:
//--    slope = BW/period
//--    num_samples = period*fclock
//--
//-- Note: Derived From:
//--    tuning_word = rect[t/period] t*slope*(2^n)/fclock
//-- And:
//--     t = sample_count*period/num_samples
//-- Therefore:
//--    tuning_word = sample_count*tuning_coeff
//-- Push the initial freq beyon baseband:
//  min_freq = freq_offset*fclock/2^n
//-------------------------------------------------------------------
`timescale 1 ps/1 ps


// -----------------------
// -- Module Definition --
// -----------------------

module control_module # (
parameter REG_ADDR_WIDTH                            = 8,
parameter CORE_DATA_WIDTH                           = 32,
parameter CORE_BE_WIDTH                             = CORE_DATA_WIDTH/8,
parameter ADC_CLK_FREQ                              = 245.7,
parameter RX_PKT_CMD_DWIDTH                         = 192
)
(


  input   s_axi_aclk,
  input   s_axi_resetn,
// for future use

  // input                               eth_ctrl_en,
  // input [8:0]                         axis_eth_ctrl_tdata,
  // input [8:0]                         axis_eth_ctrl_tkeep,
  // input                               axis_eth_ctrl_tvalid,
  // output                              axis_eth_ctrl_tready,

  input [7:0]                          gpio_dip_sw,
  output [7:0]                         gpio_led,

//  input clk_mig,              // 200 MHZ OR 100 MHz
//  input mig_init_calib_complete,


  input clk_fmc150,           // 245.76 MHz
  input resetn_fmc150,

  input [3:0] fmc150_status_vector, // {pll_status,

  output [127:0]                    chirp_parameters,

  input chirp_ready,          // continuous high when dac ready
  input chirp_active,         // continuous high while chirping
  input chirp_done,           // single pulse when chirp finished
  output chirp_init,          // single pulse to initiate chirp
  output chirp_enable,        // continuous high while chirp enabled
  output adc_enable,          // high while adc samples saved

  // Decoded Commands from RGMII RX fifo
  input [RX_PKT_CMD_DWIDTH-1:0]         cmd_axis_tdata,
  input                                 cmd_axis_tvalid,
  input                                 cmd_axis_tlast,
  input [RX_PKT_CMD_DWIDTH/8-1:0]       cmd_axis_tkeep,
  output                                cmd_axis_tready,


  output [7:0] fmc150_ctrl_bus,
  // output reg ddc_duc_bypass                         = 1'b1, // dip_sw(3)
  // output reg digital_mode                           = 1'b0,
  // output reg adc_out_dac_in                         = 1'b0,
  // output reg external_clock                         = 1'b0,
  // output reg gen_adc_test_pattern                   = 1'b0,
  // Ethernet Control Signals

  input gtx_clk_bufg,
  input gtx_resetn,

  output [7:0] ethernet_ctrl_bus
  // output reg enable_rx_decode                      = 1'b1,
  // output reg enable_adc_pkt                         = 1'b1, //dip_sw(1)
  // output reg gen_tx_data                            = 1'b0,
  // output reg chk_tx_data                            = 1'b0,
  // output reg [1:0] mac_speed                        = 2'b10 // {dip_sw(0),~dip_sw(0)}


);

// Chirp Control registers
wire [31:0]          chirp_freq_offset;
wire [31:0]    chirp_tuning_word_coeff;
wire [31:0]            chirp_count_max;

wire [31:0]                 ch_prf_int; // prf in sec
wire [31:0]                 ch_prf_frac;

wire [31:0]                 adc_sample_time;

wire                  reg_map_wr_cmd;
wire [7:0]           reg_map_wr_addr;
wire [31:0]           reg_map_wr_data;
wire [31:0]           reg_map_wr_keep;
wire                  reg_map_wr_valid;
wire                  reg_map_wr_ready;
wire [1:0]            reg_map_wr_err;

wire [127:0] chirp_parameters_axiclk;

wire data_tx_ready;        // high when ready to transmit
wire data_tx_active;       // high while data being transmitted
wire data_tx_done;         // single pule when done transmitting
wire data_tx_init;        // single pulse to start tx data
wire data_tx_enable;      // continuous high while transmit enabled

  // Decoded Commands from RGMII RX fifo
wire [RX_PKT_CMD_DWIDTH-1:0]         cmd_axis_tdata_ila;
wire                                 cmd_axis_tvalid_ila;
wire                                 cmd_axis_tlast_ila;
wire [RX_PKT_CMD_DWIDTH/8-1:0]       cmd_axis_tkeep_ila;
wire                                cmd_axis_tready_ila;
  
assign gpio_led[0] = gpio_dip_sw[0];          // mac speed =  {gpio_dip_sw[0],~gpio_dip_sw[0]};
assign gpio_led[1] = gpio_dip_sw[1];          // enable adc pkt
assign gpio_led[2] = gpio_dip_sw[2];          // chirp rate control
assign gpio_led[3] = gpio_dip_sw[3];          //ddc_duc_bypass
assign gpio_led[4] = fmc150_status_vector[3]; //pll_status
assign gpio_led[5] = fmc150_status_vector[2]; //mmcm_adac_locked
assign gpio_led[6] = fmc150_status_vector[1]; //mmcm_locked
assign gpio_led[7] = fmc150_status_vector[0]; // ADC_calibration_good

radar_pulse_controller radar_pulse_controller_inst (
  //.aclk(sysclk_bufg),
  //.aresetn(sysclk_resetn),
  .aclk(clk_fmc150),
  .aresetn(resetn_fmc150),

  //input clk_mig,              // 200 MHZ OR 100 MHz
  //input mig_init_calib_complete (init_calib_complete),

  .clk_fmc150 (clk_fmc150),           // 245.76 MHz
  .resetn_fmc150(resetn_fmc150),
  .chirp_time_int (ch_prf_int),
  .chirp_time_frac (ch_prf_frac),
  .adc_sample_time  (adc_sample_time),
  .chirp_parameters_in (chirp_parameters_axiclk),
  .chirp_parameters_out (chirp_parameters),

  .fmc150_status_vector (fmc150_status_vector), // {pll_status, mmcm_adac_locked, mmcm_locked, ADC_calibration_good};
  .chirp_ready (chirp_ready),
  .chirp_done (chirp_done),
  .chirp_active (chirp_active),
  .chirp_init  (chirp_init),
  .chirp_enable  (chirp_enable),
  .adc_enable   (adc_enable),

  .clk_eth (gtx_clk_bufg),              // gtx_clk : 125 MHz
  .eth_resetn (gtx_resetn),
  .data_tx_ready  (1'b1),        // high when ready to transmit
  .data_tx_active (1'b1),       // high while data being transmitted
  .data_tx_done   (1'b0),         // single pule when done transmitting
  .data_tx_init (data_tx_init),        // single pulse to start tx data
  .data_tx_enable (data_tx_enable)     // continuous high while transmit enabled
);

assign chirp_parameters_axiclk = {32'b0,chirp_freq_offset,chirp_tuning_word_coeff,chirp_count_max};

reg_map_cmd_gen reg_map_cmd_gen_inst (
  .aclk (s_axi_aclk),
  .aresetn (s_axi_resetn),

 // .gpio_dip_sw (gpio_dip_sw),
  .gpio_dip_sw ({4'b0,4'b1011}),

  .reg_map_wr_cmd               (reg_map_wr_cmd),
  .reg_map_wr_addr              (reg_map_wr_addr),
  .reg_map_wr_data              (reg_map_wr_data),
  .reg_map_wr_keep              (reg_map_wr_keep),
  .reg_map_wr_valid             (reg_map_wr_valid),
  .reg_map_wr_ready             (reg_map_wr_ready),
  .reg_map_wr_err               (reg_map_wr_err)

);

config_reg_map #(
  .RX_PKT_CMD_DWIDTH (RX_PKT_CMD_DWIDTH)
)
config_reg_map_inst (
  .rst_n    (s_axi_resetn),
  .clk      (s_axi_aclk),


  .wr_cmd             (reg_map_wr_cmd),
  .wr_addr            (reg_map_wr_addr),
  .wr_data            (reg_map_wr_data),
  .wr_keep            (reg_map_wr_keep),
  .wr_valid           (reg_map_wr_valid),
  .wr_ready           (reg_map_wr_ready),
  .wr_err             (reg_map_wr_err),

  .network_cmd_en     (1'b1),

  // Decoded Commands from RGMII RX fifo
  .cmd_axis_tdata        (cmd_axis_tdata),
  .cmd_axis_tvalid       (cmd_axis_tvalid),
  .cmd_axis_tlast        (cmd_axis_tlast),
  .cmd_axis_tkeep        (cmd_axis_tkeep),
  .cmd_axis_tready       (cmd_axis_tready),

 // .gpio_dip_sw (gpio_dip_sw),
  // Chirp Control registers
  .ch_prf_int (ch_prf_int), // prf in sec
  .ch_prf_frac (ch_prf_frac),

  .ch_tuning_coef (chirp_tuning_word_coeff),
  .ch_counter_max  (chirp_count_max),
  .ch_freq_offset (chirp_freq_offset),


  .adc_sample_time                        (adc_sample_time),


  // FMC150 Mode Control
  .fmc150_ctrl_bus (fmc150_ctrl_bus),

  //  Ethernet Control Signals
  .ethernet_ctrl_bus (ethernet_ctrl_bus)

);

ila_regmap ila_regmap_inst (
.clk (s_axi_aclk),
//.clk (sysclk_bufg),              // input wire M00_AXIS_ACLK
.probe0             (reg_map_wr_cmd),
.probe1            (reg_map_wr_addr),
//.probe2            (reg_map_wr_data),
//.probe3            (reg_map_wr_keep),
//.probe4           (reg_map_wr_valid),
//.probe5           (reg_map_wr_ready),
//.probe6             (reg_map_wr_err),
.probe2             (cmd_axis_tdata_ila),
.probe3            (cmd_axis_tvalid_ila),
.probe4            (cmd_axis_tlast_ila),
.probe5            (cmd_axis_tkeep_ila),
.probe6           (cmd_axis_tready_ila),
// Chirp Control registers
.probe7 (ch_prf_int), // prf in sec
.probe8 (ch_prf_frac),

.probe9 (chirp_tuning_word_coeff),
.probe10  (chirp_count_max),
.probe11 (chirp_freq_offset),

.probe12                        (adc_sample_time),
//  . Control Signals
.probe13                         (ethernet_ctrl_bus),
.probe14                         (fmc150_ctrl_bus)
);
  // Decoded Commands from RGMII RX fifo
assign cmd_axis_tdata_ila =         cmd_axis_tdata;
assign cmd_axis_tvalid_ila = cmd_axis_tvalid;
assign cmd_axis_tlast_ila = cmd_axis_tlast;
assign cmd_axis_tkeep_ila =       cmd_axis_tkeep;
assign cmd_axis_tready_ila = cmd_axis_tready;


endmodule
