
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

module config_reg_map # (
parameter REG_ADDR_WIDTH                            = 8,
parameter CORE_DATA_WIDTH                           = 32,
parameter CORE_BE_WIDTH                             = CORE_DATA_WIDTH/8,

parameter ADC_CLK_FREQ                              = 245.7
)
(

  input                               rst_n,
  input                               clk,


  input                                   wr_cmd,
  input [7:0]                             wr_addr,
  input [31:0]                            wr_data,
  input [31:0]                            wr_keep,
  output                                   wr_valid,
  output                                  wr_ready,
  output reg [1:0]                        wr_err,

 // input [7:0]                             gpio_dip_sw,
  // Chirp Control registers
  output reg [31:0]                 ch_prf_int = 32'b10, // prf in sec
  output reg [31:0]                 ch_prf_frac = 32'b0,

  // Chirp Waveform Configuration registers
  output reg [31:0]                 ch_tuning_coef = 32'b1,
  output reg [31:0]                 ch_counter_max = 32'h00000fff,
  output reg [31:0]                 ch_freq_offset = 32'd1536,

  // ADC Sample time after chirp data_tx_done -
  output reg [31:0]                 adc_sample_time = 32'b1,
  // FMC150 Mode Control
  output [7:0] fmc150_ctrl_bus,
  // output reg ddc_duc_bypass                         = 1'b1, // dip_sw(3)
  // output reg digital_mode                           = 1'b0,
  // output reg adc_out_dac_in                         = 1'b0,
  // output reg external_clock                         = 1'b0,
  // output reg gen_adc_test_pattern                   = 1'b0,

  // Ethernet Control Signals
  output [7:0] ethernet_ctrl_bus
  // output reg enable_adc_pkt                         = 1'b1, //dip_sw(1)
  // output reg gen_tx_data                            = 1'b0,
  // output reg chk_tx_data                            = 1'b0,
  // output reg [1:0] mac_speed                        = 2'b10 // {dip_sw(0),~dip_sw(0)}

);

reg wr_ready_reg                                    = 1'b0;
reg wr_valid_reg                                    = 1'b0;
reg wr_cmd_reg                                      = 1'b0;
reg [7:0] wr_addr_reg;
reg [31:0] wr_data_reg;
reg [31:0] wr_keep_reg;

reg ddc_duc_bypass_r = 1'b1;                        // dip_sw(3)
wire ddc_duc_bypass;
wire digital_mode;
wire adc_out_dac_in;
wire external_clock;
wire gen_adc_test_pattern;


wire gen_tx_data;                           // depricated
wire chk_tx_data;                          // depticated
wire enable_adc_pkt;
wire [1:0] mac_speed;
reg enable_adc_pkt_r = 1'b1;                        //dip_sw(1)
reg [1:0] mac_speed_r = 2'b10;                        // {dip_sw[0],~dip_sw[0]};

wire [3:0] addr_up;
wire [3:0] addr_low;

assign wr_ready                                     = wr_ready_reg;
assign wr_valid                                     = wr_valid_reg;

assign fmc150_ctrl_bus = {3'b0,ddc_duc_bypass,digital_mode,adc_out_dac_in,external_clock,gen_adc_test_pattern};
assign ddc_duc_bypass = ddc_duc_bypass_r;
assign digital_mode                           = 1'b0;
assign adc_out_dac_in                         = 1'b0;
assign external_clock                         = 1'b0;
assign gen_adc_test_pattern                   = 1'b0;

assign ethernet_ctrl_bus = {3'b0,enable_adc_pkt,gen_tx_data,chk_tx_data,mac_speed};
assign enable_adc_pkt = enable_adc_pkt_r;
assign mac_speed = mac_speed_r;
assign gen_tx_data = 1'b0;
assign chk_tx_data = 1'b0;

always @(posedge clk)
begin
    ddc_duc_bypass_r <= 1'b1;//gpio_dip_sw[3];
end

always @(posedge clk)
begin
    enable_adc_pkt_r <= 1'b1;//gpio_dip_sw[1];
    mac_speed_r <= 2'b10; //{gpio_dip_sw[0],~gpio_dip_sw[0]};
end  

always @(posedge clk)
begin
  if (!rst_n) begin
    wr_ready_reg                                   <= 1'b0;
    wr_cmd_reg                                     <= 1'b0;
  end else if (wr_cmd & wr_ready_reg) begin
    wr_cmd_reg                                     <= wr_cmd;
    wr_addr_reg                                    <= wr_addr;
    wr_data_reg                                    <= wr_data;
    wr_keep_reg                                    <= wr_keep;
    //wr_valid_reg <= 1'b1;
  end else begin
    wr_cmd_reg                                     <= 1'b0;
    wr_ready_reg                                   <= 1'b1;
  end
end

assign addr_up                                      = wr_addr[7:4];
assign addr_low                                     = wr_addr[3:0];

always @(posedge clk)
begin
  if (!rst_n) begin
        wr_valid_reg                                   <= 1'b0;
        wr_err                                   <= 2'b0;
      // Chirp Control registers
      ch_prf_int           <= 32'd10; // prf in sec
      ch_prf_frac          <= 32'b0;
      ch_tuning_coef       <= 32'b1;
      ch_counter_max      <= 32'h00000fff;
      ch_freq_offset       <= 32'd1536;
      adc_sample_time      <= 32'b1;

  end else if(wr_cmd & wr_ready_reg) begin

    if (addr_up == 4'b0000) begin
      if (addr_low == 4'b0000) begin
        if (&wr_keep[31:0]) begin
          ch_prf_int                               <= wr_data;
          wr_valid_reg                             <= 1'b1;
          wr_err                                   <= 2'b0;
        end else begin
          wr_valid_reg                             <= 1'b0;
          wr_err                                   <= 2'b01;
        end
      end else if (addr_low == 4'b0001) begin
        if (&wr_keep[31:0]) begin
          ch_prf_frac                              <= wr_data;
          wr_valid_reg                             <= 1'b1;
          wr_err                                   <= 2'b0;
        end else begin
          wr_valid_reg                             <= 1'b0;
          wr_err                                   <= 2'b01;
        end
      end else if (addr_low == 4'b0010) begin
        if (&wr_keep[31:0]) begin
          ch_tuning_coef                           <= wr_data;
          wr_valid_reg                             <= 1'b1;
          wr_err                                   <= 2'b0;
        end else begin
          wr_valid_reg                             <= 1'b0;
          wr_err                                   <= 2'b01;
        end
      end else if (addr_low == 4'b0011) begin
        if (&wr_keep[31:0]) begin
          ch_counter_max                          <= wr_data;
          wr_valid_reg                             <= 1'b1;
          wr_err                                   <= 2'b0;
        end else begin
          wr_valid_reg                             <= 1'b0;
          wr_err                                   <= 2'b01;
        end
      end else if (addr_low == 4'b0100) begin
        if (&wr_keep[31:0]) begin
          ch_freq_offset                           <= wr_data;
          wr_valid_reg                             <= 1'b1;
          wr_err                                   <= 2'b0;
        end else begin
          wr_valid_reg                             <= 1'b0;
          wr_err                                   <= 2'b01;
        end
      end else if (addr_low == 4'b0101) begin
        if (&wr_keep[31:0]) begin
          adc_sample_time                          <= wr_data;
          wr_valid_reg                             <= 1'b1;
          wr_err                                   <= 2'b0;
        end else begin
          wr_valid_reg                             <= 1'b0;
          wr_err                                   <= 2'b01;
        end
      end else begin
        wr_valid_reg                               <= 1'b0;
        wr_err                                     <= 2'b11;
      end
    end else begin
      wr_valid_reg                                 <= 1'b0;
      wr_err                                       <= 2'b11;
    end
  end else begin
    wr_valid_reg                                   <= 1'b0;
  end
end





endmodule
