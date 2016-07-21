`timescale 1ps/1ps

module chirp_dds_top #
  (
     parameter FFT_AXI_DATA_WIDTH = 32,
     parameter FFT_AXI_TID_WIDTH = 1,
     parameter FFT_AXI_TDEST_WIDTH = 1,
     parameter FFT_AXI_TUSER_WIDTH = 1,
     parameter FFT_AXI_STREAM_ID = 1'b0,
     parameter FFT_AXI_STREAM_DEST = 1'b0

   )
  (

   input    aclk, // AXI input clock
   input    aresetn, // Active low AXI reset signal

 // --KC705 Resources - from fmc150 example design
 input clk_245,
 input clk_245_rst,
input cpu_reset,       // : in    std_logic; -- CPU RST button, SW7 on KC705
 // input sysclk_p,        // : in    std_logic;
 // input sysclk_n,        // : in    std_logic;
   // --ADC Data Out Signals
  input [FFT_AXI_DATA_WIDTH-1:0]     s_axis_tdata,
  input s_axis_tvalid,
  input s_axis_tlast,
  output s_axis_tready,

  output [FFT_AXI_DATA_WIDTH-1:0]     m_axis_tdata,
  output m_axis_tvalid,
  output m_axis_tlast,
  input m_axis_tready,

// Control Module signals
  output [3:0] fmc150_status_vector,
  output chirp_ready,
  output chirp_done,
  output chirp_active,
  input  chirp_init,
  input  chirp_enable,
  input  adc_enable,

  input [31:0] chirp_control_word,
  input [31:0] chirp_freq_offset,
  input [31:0] chirp_tuning_word_coeff,
  input [31:0] chirp_count_max,

  input [7:0] fmc150_ctrl_bus,
  input [67:0] fmc150_spi_ctrl_bus_in,
  output [47:0] fmc150_spi_ctrl_bus_out


   );

localparam DDS_LATENCY = 2;

  wire clk_245_76MHz;
  wire clk_491_52MHz;

 wire [23 : 0] s_axis_fft_config_tdata;
 wire s_axis_fft_config_tvalid;
 wire s_axis_fft_config_tready;
 wire [31 : 0] s_axis_fft_data_tdata;
 wire s_axis_fft_data_tvalid;
 wire s_axis_fft_data_tready;
 wire s_axis_fft_data_tlast;
 wire [31 : 0] m_axis_fft_data_tdata;
 wire m_axis_fft_data_tvalid;
 wire m_axis_fft_data_tlast;
 wire fft_event_frame_started;
 wire fft_event_tlast_unexpected;
 wire fft_event_tlast_missing;
 wire fft_event_data_in_channel_halt;


xfft_0 xfft_0_inst (
  .aclk(clk_245_76MHz),                                              // input wire aclk
.aresetn(!cpu_reset),                                        // input wire aresetn
.s_axis_config_tdata(s_axis_fft_config_tdata),                // input wire [23 : 0] s_axis_config_tdata
.s_axis_config_tvalid(s_axis_fft_config_tvalid),              // input wire s_axis_config_tvalid
.s_axis_config_tready(s_axis_fft_config_tready),              // output wire s_axis_config_tready
.s_axis_data_tdata(s_axis_fft_data_tdata),                    // input wire [31 : 0] s_axis_data_tdata
.s_axis_data_tvalid(s_axis_fft_data_tvalid),                  // input wire s_axis_data_tvalid
.s_axis_data_tready(s_axis_fft_data_tready),                  // output wire s_axis_data_tready
.s_axis_data_tlast(s_axis_fft_data_tlast),                    // input wire s_axis_data_tlast
.m_axis_data_tdata(m_axis_fft_data_tdata),                    // output wire [31 : 0] m_axis_data_tdata
.m_axis_data_tvalid(m_axis_fft_data_tvalid),                  // output wire m_axis_data_tvalid
.m_axis_data_tlast(m_axis_fft_data_tlast),                    // output wire m_axis_data_tlast
.event_frame_started(fft_event_frame_started),                // output wire event_frame_started
.event_tlast_unexpected(fft_event_tlast_unexpected),          // output wire event_tlast_unexpected
.event_tlast_missing(fft_event_tlast_missing),                // output wire event_tlast_missing
.event_data_in_channel_halt(fft_event_data_in_channel_halt)  // output wire event_data_in_channel_halt
);

assign s_axis_fft_config_tdata = {1'b0,6'b0,1'b1,1'b0,13'b0,1'b0,5'd13}; // {pad,scale_sh,fwd/inv,pad,cp_len,pad,nfft}
assign s_axis_fft_config_tvalid = 1'b1;
assign s_axis_fft_data_tdata = {dac_data_q,dac_data_i};
assign s_axis_fft_data_tvalid = adc_data_valid_rr;
assign s_axis_fft_data_tlast = adc_fifo_wr_tlast;




endmodule
