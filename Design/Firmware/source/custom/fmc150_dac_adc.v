//////////////////////////////////////////////////////////////////////////////////
// Company:MiXIL
// Engineer: Samuel Prager
//
// Create Date: 07/14/2016 04:32:51 PM
// Design Name:
// Module Name: fmc150_dac_adc
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

`timescale 1ps/1ps

module fmc150_dac_adc #
  (
     parameter ADC_AXI_DATA_WIDTH = 64,
     parameter ADC_AXI_TID_WIDTH = 1,
     parameter ADC_AXI_TDEST_WIDTH = 1,
     parameter ADC_AXI_TUSER_WIDTH = 1,
     parameter ADC_AXI_STREAM_ID = 1'b0,
     parameter ADC_AXI_STREAM_DEST = 1'b0,

     parameter PK_AXI_DATA_WIDTH = 512,
     parameter PK_AXI_TID_WIDTH = 1,
     parameter PK_AXI_TDEST_WIDTH = 1,
     parameter PK_AXI_TUSER_WIDTH = 1,
     parameter PK_AXI_STREAM_ID = 1'b0,
     parameter PK_AXI_STREAM_DEST = 1'b0,

     parameter SIMULATION = 0,
     parameter FFT_LEN = 4096//32768

   )
  (

   input    aclk, // AXI input clock
   input    aresetn, // Active low AXI reset signal

 // --KC705 Resources - from fmc150 example design

  input cpu_reset,       // : in    std_logic; -- CPU RST button, SW7 on KC705
 // input sysclk_p,        // : in    std_logic;
 // input sysclk_n,        // : in    std_logic;
  input sysclk_bufg,
   // --ADC Data Out Signals
  output [ADC_AXI_DATA_WIDTH-1:0]     axis_adc_tdata,
  output axis_adc_tvalid,
  output axis_adc_tlast,
  output [ADC_AXI_DATA_WIDTH/8-1:0]   axis_adc_tkeep,
  output [ADC_AXI_DATA_WIDTH/8-1:0]   axis_adc_tstrb,
  output [ADC_AXI_TID_WIDTH-1:0] axis_adc_tid,
  output [ADC_AXI_TDEST_WIDTH-1:0] axis_adc_tdest,
  output [ADC_AXI_TUSER_WIDTH-1:0] axis_adc_tuser,
  input axis_adc_tready,

  output [PK_AXI_DATA_WIDTH-1:0]     axis_pk_tdata,
  output axis_pk_tvalid,
  output axis_pk_tlast,
  output [PK_AXI_DATA_WIDTH/8-1:0]   axis_pk_tkeep,
  output [PK_AXI_DATA_WIDTH/8-1:0]   axis_pk_tstrb,
  output [PK_AXI_TID_WIDTH-1:0] axis_pk_tid,
  output [PK_AXI_TDEST_WIDTH-1:0] axis_pk_tdest,
  output [PK_AXI_TUSER_WIDTH-1:0] axis_pk_tuser,
  input axis_pk_tready,

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

  input                                 wf_read_ready,
  input       [31:0]                    wfrm_axis_tdata,
  input                                 wfrm_axis_tvalid,
  input                                 wfrm_axis_tlast,
  output                                wfrm_axis_tready,

  // output clk_100Mhz,
  // output clk_100Mhz_rst,

  input clk_100Mhz,
  input clk_200Mhz,
  input mmcm_locked,

  output clk_out_245_76MHz,
  output clk_245_rst,
//  output clk_out_491_52MHz,

//  output [7:0]  gpio_led,        // : out   std_logic_vector(7 downto 0);
//  input [7:0]  gpio_dip_sw,   //   : in    std_logic_vector(7 downto 0);
  output gpio_led_c,        //       : out   std_logic;
  output gpio_led_e,        //       : out   std_logic;
  output gpio_led_n,       //       : out   std_logic;
  output gpio_led_s,        //       : out   std_logic;
  output gpio_led_w,        //              : out   std_logic;
  input gpio_sw_c,        //               : in    std_logic;
  input gpio_sw_e,        //               : in    std_logic;
  input gpio_sw_n,        //               : in    std_logic;
  input gpio_sw_s,        //               : in    std_logic;
  input gpio_sw_w,        //               : in    std_logic;

  input [7:0] fmc150_ctrl_bus,
  input [67:0] fmc150_spi_ctrl_bus_in,
  output [47:0] fmc150_spi_ctrl_bus_out,

 // --Clock/Data connection to ADC on FMC150 (ADS62P49)
  input clk_ab_p,        //                : in    std_logic;
  input clk_ab_n,        //                : in    std_logic;
  input[6:0] cha_p,        //                   : in    std_logic_vector(6 downto 0);
  input[6:0] cha_n,        //                   : in    std_logic_vector(6 downto 0);
  input[6:0] chb_p,        //                   : in    std_logic_vector(6 downto 0);
  input[6:0] chb_n,        //                   : in    std_logic_vector(6 downto 0);

//  --Clock/Data connection to DAC on FMC150 (DAC3283)
  output dac_dclk_p,        //              : out   std_logic;
  output dac_dclk_n,        //              : out   std_logic;
  output[7:0] dac_data_p,        //              : out   std_logic_vector(7 downto 0);
  output[7:0] dac_data_n,        //              : out   std_logic_vector(7 downto 0);
  output dac_frame_p,        //             : out   std_logic;
  output dac_frame_n,        //             : out   std_logic;
  output txenable,        //                : out   std_logic;

 // --Clock/Trigger connection to FMC150
 // --clk_to_fpga_p    : in    std_logic;
 // --clk_to_fpga_n    : in    std_logic;
 // --ext_trigger_p    : in    std_logic;
 // --ext_trigger_n    : in    std_logic;

//  --Serial Peripheral Interface (SPI)
  output spi_sclk,        //                : out   std_logic; -- Shared SPI clock line
  output spi_sdata,        //               : out   std_logic; -- Shared SPI sata line

//  -- ADC specific signals
  output adc_n_en,        //                : out   std_logic; -- SPI chip select
 input adc_sdo,        //                 : in    std_logic; -- SPI data out
  output adc_reset,        //               : out   std_logic; -- SPI reset

 // -- CDCE specific signals
  output cdce_n_en,        //               : out   std_logic; -- SPI chip select
  input cdce_sdo,        //                : in    std_logic; -- SPI data out
  output cdce_n_reset,        //            : out   std_logic;
  output cdce_n_pd,        //               : out   std_logic;
  output ref_en,        //                  : out   std_logic;
 input pll_status,        //             : in    std_logic;

//  -- DAC specific signals
  output dac_n_en,        //                : out   std_logic; -- SPI chip select
 input dac_sdo,        //                 : in    std_logic; -- SPI data out

//  -- Monitoring specific signals
  output mon_n_en,        //                : out   std_logic; -- SPI chip select
 input mon_sdo,        //                 : in    std_logic; -- SPI data out
  output mon_n_reset,        //             : out   std_logic;
  input mon_n_int,        //               : in    std_logic;

 // --FMC Present status
 input prsnt_m2c_l        //             : in    std_logic



   );

  localparam DDS_LATENCY = 2;
  localparam DDS_CHIRP_DELAY = 4;
  localparam DDS_WFRM_DELAY = 19;
  localparam DDS_WFRM_DELAY_END = 2;
  localparam FCUTOFF_IND = FFT_LEN/2;
  
  localparam     DATA_FIRST_COMMAND = 32'h46525354;     //Ascii FRST
  localparam     DATA_LAST_COMMAND = 32'h4c415354;     //Ascii LAST

  wire rd_fifo_clk;
  wire clk_245_76MHz;
  wire clk_491_52MHz;

  wire [15:0] adc_data_i;
  wire [15:0] adc_data_q;
  wire [15:0] dac_data_i;
  wire [15:0] dac_data_q;
  wire [31:0] adc_data_iq;
  wire [31:0] dac_data_iq;

  wire [15:0] wfrm_data_i;
  wire [15:0] wfrm_data_q;
  wire wfrm_data_valid;

  wire [31:0] adc_counter;
  wire adc_data_valid;

 // wire data_valid;
//  reg [7:0] dds_route_ctrl_reg;
  wire [1:0] dds_route_ctrl_u;
  wire [1:0] dds_route_ctrl_l;
  wire [1:0] dds_source_ctrl;
  wire dds_source_select;

  wire wfrm_ready;
  wire wfrm_done;
  wire wfrm_active;
  wire wfrm_init;
  wire wfrm_enable;

  wire dds_ready;
  wire dds_done;
  wire dds_active;
  wire dds_init;
  wire dds_enable;

  reg [1:0] dds_route_ctrl_u_r;
  reg [1:0] dds_route_ctrl_l_r;
  reg [1:0] dds_source_ctrl_r;

  wire [63:0] adc_fifo_wr_tdata;
  wire       adc_fifo_wr_tvalid;
  wire       adc_fifo_wr_tlast;
  wire       adc_fifo_wr_pre_tlast;

  wire       adc_fifo_wr_first;
  reg        adc_fifo_wr_first_r;


     wire [12:0]              adc_fifo_wr_tdata_count;
     wire [9:0]               adc_fifo_rd_data_count;
     wire                       adc_fifo_wr_ack;
     wire                       adc_fifo_valid;
     wire                       adc_fifo_almost_full;
     wire                       adc_fifo_almost_empty;
     wire                      adc_fifo_wr_en;
     wire                      adc_fifo_rd_en;
     wire [ADC_AXI_DATA_WIDTH-1:0]  adc_fifo_data_out;
     wire [ADC_AXI_DATA_WIDTH-1:0]  adc_fifo_data_out_reversed;
     wire                     adc_fifo_full;
     wire                     adc_fifo_empty;

     reg                      adc_enable_r;
     reg                      adc_enable_rr;

     reg [7:0] dds_latency_counter;
     reg [31:0] glbl_counter_reg;
     reg [5:0] data_alignment_counter;
     reg [5:0] data_word_counter;
     wire align_data;

     reg [31:0] adc_counter_reg;
     wire [31:0] glbl_counter;
     wire [31:0] data_command_word;

     wire [31:0] data_out_upper;
     wire [31:0] data_out_lower;
//     reg data_out_upper_valid;
//     reg data_out_lower_valid;
    wire [31:0] lpf_cutoff_ind;
    wire [63:0] peak_threshold_i;
    wire [63:0] peak_threshold_q;

    wire [PK_AXI_DATA_WIDTH-1:0]     dw_axis_tdata;
    wire dw_axis_tvalid;
    wire dw_axis_tlast;
    wire [PK_AXI_DATA_WIDTH/8-1:0]   dw_axis_tkeep;
    wire [PK_AXI_DATA_WIDTH/8-1:0]   dw_axis_tstrb;
    wire [PK_AXI_TID_WIDTH-1:0] dw_axis_tid;
    wire [PK_AXI_TDEST_WIDTH-1:0] dw_axis_tdest;
    wire [PK_AXI_TUSER_WIDTH-1:0] dw_axis_tuser;
    wire dw_axis_tready;

    //  reg dw_axis_tvalid_r;
    //  reg dw_axis_tlast_r;

    wire data_iq_tvalid;
    wire data_iq_tlast;
    wire data_iq_first;
    wire[63:0] data_counter_id;
    wire[7:0] threshold_ctrl_i;
    wire[7:0] threshold_ctrl_q;



   KC705_fmc150 #(
    .DDS_LATENCY(DDS_LATENCY)
   ) KC705_fmc150_inst
   (
        // --KC705 Resources - from fmc150 example design
        .adc_data_out_i (adc_data_i),
        .adc_data_out_q (adc_data_q),
    //    .adc_counter_out (adc_counter),
        .adc_data_out_valid (adc_data_valid),

        .dac_data_out_i (dac_data_i),
        .dac_data_out_q (dac_data_q),


        .wfrm_data_in_i (wfrm_data_i),
        .wfrm_data_in_q (wfrm_data_q),
        .wfrm_data_in_valid(wfrm_data_valid),

        .dds_source_select(dds_source_select),

//        .adc_data_out_iq (adc_data_iq),
//        .dac_data_out_iq (dac_data_iq),
//        .data_out_valid  (data_valid),

        .clk_out_245_76MHz  (clk_245_76MHz),
        .clk_out_491_52MHz  (clk_491_52MHz),
        .clk_245_rst (clk_245_rst),

//        .clk_100Mhz_out (clk_100Mhz),
//        .clk_100Mhz_rst (clk_100Mhz_rst),

        .clk_100Mhz (clk_100Mhz),
        .clk_200Mhz (clk_200Mhz),
        .mmcm_locked (mmcm_locked),

        .fmc150_status_vector (fmc150_status_vector),
        .chirp_ready (dds_ready),
        .chirp_done (dds_done),
        .chirp_active (dds_active),
        .chirp_init  (dds_init),
        .chirp_enable  (dds_enable),
        .adc_enable    (adc_enable),

//        .dac_loopback               (chirp_control_word[0]),
        .chirp_freq_offset          (chirp_freq_offset),
        .chirp_tuning_word_coeff    (chirp_tuning_word_coeff),
        .chirp_count_max            (chirp_count_max),

       .cpu_reset (cpu_reset),       // : in    std_logic; -- CPU RST button, SW7 on KC705
  //     .sysclk_p (sysclk_p),        // : in    std_logic;
 //      .sysclk_n (sysclk_n),        // : in    std_logic;

       .sysclk_bufg (sysclk_bufg),
  //     .gpio_led (gpio_led),        // : out   std_logic_vector(7 downto 0);
  //     .gpio_dip_sw (gpio_dip_sw),   //   : in    std_logic_vector(7 downto 0);
       .gpio_led_c (gpio_led_c),        //       : out   std_logic;
        .gpio_led_e (gpio_led_e),        //       : out   std_logic;
        .gpio_led_n (gpio_led_n),       //       : out   std_logic;
        .gpio_led_s (gpio_led_s),        //       : out   std_logic;
        .gpio_led_w (gpio_led_w),        //              : out   std_logic;
        .gpio_sw_c (gpio_sw_c),        //               : in    std_logic;
        .gpio_sw_e (gpio_sw_e),        //               : in    std_logic;
        .gpio_sw_n (gpio_sw_n),        //               : in    std_logic;
        .gpio_sw_s (gpio_sw_s),        //               : in    std_logic;
        .gpio_sw_w (gpio_sw_w),        //               : in    std_logic;

        .fmc150_ctrl_bus (fmc150_ctrl_bus),
        .fmc150_spi_ctrl_bus_in (fmc150_spi_ctrl_bus_in),
        .fmc150_spi_ctrl_bus_out (fmc150_spi_ctrl_bus_out),

       // --Clock/Data connection to ADC on FMC150 (ADS62P49)
        .clk_ab_p (clk_ab_p),        //                : in    std_logic;
        .clk_ab_n (clk_ab_n),        //                : in    std_logic;
        .cha_p (cha_p),        //                   : in    std_logic_vector(6 downto 0);
        .cha_n (cha_n),        //                   : in    std_logic_vector(6 downto 0);
        .chb_p (chb_p),        //                   : in    std_logic_vector(6 downto 0);
        .chb_n (chb_n),        //                   : in    std_logic_vector(6 downto 0);

       //  --Clock/Data connection to DAC on FMC150 (DAC3283)
        .dac_dclk_p (dac_dclk_p),        //              : out   std_logic;
        .dac_dclk_n (dac_dclk_n),        //              : out   std_logic;
        .dac_data_p (dac_data_p),        //              : out   std_logic_vector(7 downto 0);
        .dac_data_n (dac_data_n),        //              : out   std_logic_vector(7 downto 0);
        .dac_frame_p (dac_frame_p),        //             : out   std_logic;
        .dac_frame_n (dac_frame_n),        //             : out   std_logic;
        .txenable (txenable),        //                : out   std_logic;

       // --Clock/Trigger connection to FMC150
       // --clk_to_fpga_p    : in    std_logic;
       // --clk_to_fpga_n    : in    std_logic;
       // --ext_trigger_p    : in    std_logic;
       // --ext_trigger_n    : in    std_logic;

       //  --Serial Peripheral Interface (SPI)
        .spi_sclk (spi_sclk),        //                : out   std_logic; -- Shared SPI clock line
        .spi_sdata (spi_sdata),        //               : out   std_logic; -- Shared SPI sata line

       //  -- ADC specific signals
        .adc_n_en (adc_n_en),        //                : out   std_logic; -- SPI chip select
        .adc_sdo (adc_sdo),        //                 : in    std_logic; -- SPI data out
        .adc_reset (adc_reset),        //               : out   std_logic; -- SPI reset

       // -- CDCE specific signals
        .cdce_n_en (cdce_n_en),        //               : out   std_logic; -- SPI chip select
        .cdce_sdo (cdce_sdo),        //                : in    std_logic; -- SPI data out
        .cdce_n_reset (cdce_n_reset),        //            : out   std_logic;
        .cdce_n_pd (cdce_n_pd),        //               : out   std_logic;
        .ref_en (ref_en),        //                  : out   std_logic;
        .pll_status (pll_status),        //             : in    std_logic;

       //  -- DAC specific signals
        .dac_n_en (dac_n_en),        //                : out   std_logic; -- SPI chip select
        .dac_sdo (dac_sdo),        //                 : in    std_logic; -- SPI data out

       //  -- Monitoring specific signals
         .mon_n_en (mon_n_en),        //                : out   std_logic; -- SPI chip select
         .mon_sdo (mon_sdo),        //                 : in    std_logic; -- SPI data out
         .mon_n_reset (mon_n_reset),        //             : out   std_logic;
         .mon_n_int (mon_n_int),        //               : in    std_logic;

       // --FMC Present status
        .prsnt_m2c_l (prsnt_m2c_l)        //             : in    std_logic

   );

   waveform_dds waveform_dds_inst(
       .axi_tclk(clk_245_76MHz),
       .axi_tresetn(!clk_245_rst),
       .wf_read_ready(wf_read_ready),

       .chirp_ready (wfrm_ready),
       .chirp_done (wfrm_done),
       .chirp_active (wfrm_active),
       .chirp_init  (wfrm_init),
       .chirp_enable  (wfrm_enable),

       .dds_source_select(dds_source_select),

       .wfrm_axis_tdata(wfrm_axis_tdata),
       .wfrm_axis_tvalid(wfrm_axis_tvalid),
       .wfrm_axis_tlast(wfrm_axis_tlast),
       .wfrm_axis_tready(wfrm_axis_tready),

       .wfrm_data_valid(wfrm_data_valid),
       .wfrm_data_i(wfrm_data_i),
       .wfrm_data_q(wfrm_data_q)
   );

//assign wfrm_init = (dds_source_select) ? chirp_init : 1'b0;
//assign dds_init = (!dds_source_select) ? chirp_init : 1'b0;
//assign wfrm_enable = (dds_source_select) ? chirp_enable : 1'b0;
//assign dds_enable = (!dds_source_select) ? chirp_enable : 1'b0;

assign wfrm_init = (dds_source_select & chirp_init);
assign dds_init = (!dds_source_select & chirp_init);
assign wfrm_enable = (dds_source_select & chirp_enable);
assign dds_enable = (!dds_source_select & chirp_enable);

assign chirp_done = ((dds_source_select & wfrm_done)|(!dds_source_select & dds_done));
assign chirp_active = ((dds_source_select & wfrm_active)|(!dds_source_select & dds_active));
assign chirp_ready =  ((dds_source_select & wfrm_ready)|(!dds_source_select & dds_ready));

assign dds_source_select = (&dds_source_ctrl);

assign data_out_lower  = (dds_route_ctrl_l == 2'b00) ? adc_data_iq : 32'bz,
    data_out_lower  = (dds_route_ctrl_l == 2'b01) ? dac_data_iq : 32'bz,
    data_out_lower  = (dds_route_ctrl_l == 2'b10) ? adc_counter : 32'bz,
    data_out_lower  = (dds_route_ctrl_l == 2'b11) ? glbl_counter : 32'bz;

assign data_out_upper  = (dds_route_ctrl_u == 2'b00) ? adc_data_iq : 32'bz,
          data_out_upper  = (dds_route_ctrl_u == 2'b01) ? dac_data_iq : 32'bz,
          data_out_upper  = (dds_route_ctrl_u == 2'b10) ? adc_counter : 32'bz,
          data_out_upper  = (dds_route_ctrl_u == 2'b11) ? glbl_counter : 32'bz;

//assign dds_route_ctrl_l = chirp_control_word[1:0];
//assign dds_route_ctrl_u = chirp_control_word[5:4];
assign dds_route_ctrl_l = dds_route_ctrl_l_r;
assign dds_route_ctrl_u = dds_route_ctrl_u_r;
assign dds_source_ctrl = dds_source_ctrl_r;


  always @(posedge clk_245_76MHz) begin
     dds_route_ctrl_l_r <= chirp_control_word[1:0];
     dds_route_ctrl_u_r <= chirp_control_word[5:4];
  end

  always @(posedge clk_245_76MHz) begin
     if (!chirp_enable)
         dds_source_ctrl_r <= chirp_control_word[9:8];
  end

   always @(posedge clk_245_76MHz) begin
    if (clk_245_rst) begin
      adc_enable_r <= 1'b0;
      adc_enable_rr <= 1'b0;
    end else begin
      adc_enable_r <= adc_enable;
//      if (!(|dds_latency_counter))
      if (!(|dds_latency_counter) & (!align_data))
        adc_enable_rr <= adc_enable_r;
      else
        adc_enable_rr <=adc_enable_rr;
    end
   end

  always @(posedge clk_245_76MHz) begin
    if (clk_245_rst)
      dds_latency_counter <= 'b0;
    else if( chirp_init) begin
        if(dds_source_select )
            dds_latency_counter <= DDS_WFRM_DELAY;
         else
            dds_latency_counter <= DDS_CHIRP_DELAY;
   end else if(adc_enable_r & !adc_enable) begin
      if(dds_source_select )
        dds_latency_counter <= DDS_WFRM_DELAY_END;
      else
        dds_latency_counter <= DDS_CHIRP_DELAY;
   end else if(|dds_latency_counter) begin
      dds_latency_counter <= dds_latency_counter-1;
   end
  end

  always @(posedge clk_245_76MHz) begin
    if (clk_245_rst)
      data_word_counter <= 'b0;
   else if (!(|dds_latency_counter)&(adc_enable_r)&(!adc_enable_rr))
      data_word_counter <= 'b0;
    else if(adc_enable_rr & adc_data_valid)
      data_word_counter <= data_word_counter + 1'b1;
  end

   always @(posedge clk_245_76MHz) begin
      if (clk_245_rst)
        data_alignment_counter <= 'b0;
   //   else if(adc_fifo_wr_tlast)
   //      data_alignment_counter <= data_word_counter^3'b111;
      else if(adc_fifo_wr_pre_tlast)
         data_alignment_counter <= (data_word_counter+1'b1)^6'b111111;
      else if(|data_alignment_counter)
        data_alignment_counter <= data_alignment_counter - 1'b1;
    end

    assign align_data = |data_alignment_counter;

   always @(posedge clk_245_76MHz) begin
   if (cpu_reset) begin
     adc_fifo_wr_first_r <= 1'b0;
   end else begin
     if (!(|dds_latency_counter)&(adc_enable_r)&(!adc_enable_rr))
       adc_fifo_wr_first_r <= 1'b1;
     else
       adc_fifo_wr_first_r <= 1'b0;
   end
  end


   always @(posedge clk_245_76MHz) begin
    if (clk_245_rst) begin
      adc_counter_reg <= 'b0;
    end
    else begin
      if (adc_enable_rr & adc_data_valid)
        adc_counter_reg <= adc_counter_reg+1;
    end
   end
assign adc_counter = adc_counter_reg;

   always @(posedge clk_245_76MHz) begin
    if (clk_245_rst) begin
      glbl_counter_reg <= 'b0;
    end
    else begin
      glbl_counter_reg <= glbl_counter_reg+1;
    end
   end
   assign glbl_counter = glbl_counter_reg;

// asynchoronous fifo for converting 245.76 MHz 32 bit adc samples (16 i, 16 q)
// to rd clk domain 64 bit adc samples (i1 q1 i2 q2)
   fifo_generator_adc u_fifo_generator_adc
   (
   .wr_clk                    (clk_245_76MHz),
   .rd_clk                    (rd_fifo_clk),
   .wr_data_count             (adc_fifo_wr_tdata_count),
   .rd_data_count             (adc_fifo_rd_data_count),
   .wr_ack                    (adc_fifo_wr_ack),
   .valid                     (adc_fifo_valid),
   .almost_full               (adc_fifo_almost_full),
   .almost_empty              (adc_fifo_almost_empty),
   .rst                       (cpu_reset),
   //.wr_en                     (adc_fifo_wr_en),
   .wr_en                     (adc_fifo_wr_en),
   //.rd_en                     (adc_fifo_rd_en),
   .rd_en                     (adc_fifo_rd_en),
   .din                       (adc_fifo_wr_tdata),
   .dout                      (adc_fifo_data_out),
   .full                      (adc_fifo_full),
   .empty                     (adc_fifo_empty)

   );

   genvar i;
   generate
   for (i=0;i<ADC_AXI_DATA_WIDTH;i=i+64) begin
      assign adc_fifo_data_out_reversed[i+63-:64] = adc_fifo_data_out[ADC_AXI_DATA_WIDTH-i-1-:64];
   end
   endgenerate

   adc_data_axis_wrapper #(
     .ADC_AXI_DATA_WIDTH(ADC_AXI_DATA_WIDTH),
     .ADC_AXI_TID_WIDTH(ADC_AXI_TID_WIDTH),
     .ADC_AXI_TDEST_WIDTH(ADC_AXI_TDEST_WIDTH),
     .ADC_AXI_TUSER_WIDTH(ADC_AXI_TUSER_WIDTH),
     .ADC_AXI_STREAM_ID(ADC_AXI_STREAM_ID),
     .ADC_AXI_STREAM_DEST(ADC_AXI_STREAM_DEST)
    )
    adc_data_axis_wrapper_inst (
      .axi_tclk                   (aclk),
      .axi_tresetn                (aresetn),
//      .adc_data                   (adc_fifo_data_out),
      .adc_data                   (adc_fifo_data_out_reversed),
      .adc_fifo_data_valid        (adc_fifo_valid),
      .adc_fifo_empty             (adc_fifo_empty),
      .adc_fifo_almost_empty      (adc_fifo_almost_empty),
      .adc_fifo_rd_en             (adc_fifo_rd_en),

      .tdata                      (axis_adc_tdata),
      .tvalid                     (axis_adc_tvalid),
      .tlast                      (axis_adc_tlast),
      .tkeep                      (axis_adc_tkeep),
      .tstrb                      (axis_adc_tstrb),
      .tid                        (axis_adc_tid),
      .tdest                      (axis_adc_tdest),
      .tuser                      (axis_adc_tuser),
      .tready                     (axis_adc_tready)
      );

   assign adc_data_iq = {adc_data_i,adc_data_q};
   assign dac_data_iq = {dac_data_i,dac_data_q};

  //  assign adc_fifo_wr_tdata = {data_out_upper,data_out_lower};
  // assign adc_fifo_wr_tdata = {adc_counter,adc_data_iq};

 //  assign adc_fifo_wr_tvalid = adc_data_valid & adc_enable_rr;
// assign adc_fifo_wr_tdata  = (adc_fifo_wr_first | adc_fifo_wr_tlast) ? {glbl_counter,adc_counter} : {data_out_upper,data_out_lower};
 assign adc_fifo_wr_tdata  = (adc_fifo_wr_first | adc_fifo_wr_tlast) ? {glbl_counter,data_command_word} : {data_out_upper,data_out_lower};

 assign data_command_word = (adc_fifo_wr_tlast & !adc_fifo_wr_first) ? {DATA_LAST_COMMAND} : {DATA_FIRST_COMMAND};
//   assign adc_fifo_wr_tdata = {data_out_upper,data_out_lower};
//   assign adc_fifo_wr_tvalid = data_out_upper_valid & data_out_lower_valid & adc_enable_rr;

   assign adc_fifo_wr_first = adc_fifo_wr_first_r;
   assign adc_fifo_wr_tlast = (!(|dds_latency_counter))&(adc_enable_rr)&(!adc_enable_r)&(!align_data);
//   assign adc_fifo_wr_tlast = (!(|dds_latency_counter))&(adc_enable_rr)&(!adc_enable_r);

   assign adc_fifo_wr_pre_tlast = (dds_latency_counter==1)&(adc_enable_rr)&(!adc_enable_r);

   assign adc_fifo_wr_en = adc_enable_rr & adc_data_valid;
//   assign adc_fifo_wr_en = adc_enable_rr & data_out_upper_valid & data_out_lower_valid;

assign rd_fifo_clk = aclk;

assign clk_out_245_76MHz = clk_245_76MHz;
//assign clk_out_491_52MHz = clk_491_52MHz;

//assign data_iq_tvalid = adc_enable_rr & adc_data_valid & (!adc_fifo_wr_first);
assign data_iq_tvalid = adc_enable_rr & adc_data_valid&(!adc_fifo_wr_first)&(!adc_fifo_wr_tlast)&(!align_data);
assign data_iq_tlast = (dds_latency_counter==1)&(adc_enable_rr)&(!adc_enable_r);
assign data_iq_first = adc_fifo_wr_first_r;
assign data_counter_id = {glbl_counter[31:0],adc_counter};
//assign dw_axis_tready = 1'b1;
assign lpf_cutoff_ind = FCUTOFF_IND;
assign threshold_ctrl_i = {4'hf,4'h1};
assign threshold_ctrl_q = {4'hf,4'h1};
//assign peak_threshold_i = {{(60-4*threshold_ctrl_i[7:4]){1'b0}},threshold_ctrl_i[3:0],{(4*threshold_ctrl_i[7:4]){1'b0}}};
//assign peak_threshold_q = {{(60-4*threshold_ctrl_q[7:4]){1'b0}},threshold_ctrl_q[3:0],{(4*threshold_ctrl_q[7:4]){1'b0}}};

matched_filter_range_detector #
  (
     .PK_AXI_DATA_WIDTH(PK_AXI_DATA_WIDTH),
     .PK_AXI_TID_WIDTH (PK_AXI_TID_WIDTH),
     .PK_AXI_TDEST_WIDTH(PK_AXI_TDEST_WIDTH),
     .PK_AXI_TUSER_WIDTH(PK_AXI_TUSER_WIDTH),
     .PK_AXI_STREAM_ID (PK_AXI_STREAM_ID),
     .PK_AXI_STREAM_DEST (PK_AXI_STREAM_DEST),
     .FFT_LEN(FFT_LEN),
     .SIMULATION(SIMULATION)

  )matched_filter_range_detector_inst(

   .aclk(clk_245_76MHz), // AXI input clock
   .aresetn(!clk_245_rst), // Active low AXI reset signal

   // --ADC Data Out Signals
  .adc_iq_tdata(adc_data_iq),
  .dac_iq_tdata(dac_data_iq),
  .iq_tvalid(data_iq_tvalid),
  .iq_tlast(data_iq_tlast),
  .iq_tready(data_iq_tready),
  .iq_first(data_iq_first),
  .counter_id(data_counter_id),

//  .pk_axis_tdata(dw_axis_tdata),
//  .pk_axis_tvalid(dw_axis_tvalid),
//  .pk_axis_tlast(dw_axis_tlast),
//  .pk_axis_tkeep(dw_axis_tkeep),
//  .pk_axis_tdest(dw_axis_tdest),
//  .pk_axis_tid(dw_axis_tid),
//  .pk_axis_tstrb(dw_axis_tstrb),
//  .pk_axis_tuser(dw_axis_tuser),
//  .pk_axis_tready(dw_axis_tready),
    .pk_axis_tdata(axis_pk_tdata),
    .pk_axis_tvalid(axis_pk_tvalid),
    .pk_axis_tlast(axis_pk_tlast),
    .pk_axis_tkeep(axis_pk_tkeep),
    .pk_axis_tdest(axis_pk_tdest),
    .pk_axis_tid(axis_pk_tid),
    .pk_axis_tstrb(axis_pk_tstrb),
    .pk_axis_tuser(axis_pk_tuser),
    .pk_axis_tready(axis_pk_tready),

  .lpf_cutoff(lpf_cutoff_ind),
  .threshold_ctrl(threshold_ctrl_i),    // {4b word index, 4b word value} in 64bit threshold
 // .threshold_ctrl_q(threshold_ctrl_q),    // {4b word index, 4b word value} in 64bit threshold

// Control Module signals
 .chirp_ready                         (chirp_ready),
 .chirp_done                          (chirp_done),
 .chirp_active                        (chirp_active),
 .chirp_init                          (chirp_init),
 .chirp_enable                        (chirp_enable),
 .adc_enable                          (adc_enable),
 .chirp_control_word          (chirp_control_word),
 .chirp_freq_offset           (chirp_freq_offset),
 .chirp_tuning_word_coeff     (chirp_tuning_word_coeff),
 .chirp_count_max             (chirp_count_max)

   );
//dsp_range_detector #
//  (
//     .PK_AXI_DATA_WIDTH(PK_AXI_DATA_WIDTH),
//     .PK_AXI_TID_WIDTH (PK_AXI_TID_WIDTH),
//     .PK_AXI_TDEST_WIDTH(PK_AXI_TDEST_WIDTH),
//     .PK_AXI_TUSER_WIDTH(PK_AXI_TUSER_WIDTH),
//     .PK_AXI_STREAM_ID (PK_AXI_STREAM_ID),
//     .PK_AXI_STREAM_DEST (PK_AXI_STREAM_DEST),
//     .FFT_LEN(FFT_LEN),
//     .SIMULATION(SIMULATION)

//  )dsp_range_detector_inst(

//   .aclk(clk_245_76MHz), // AXI input clock
//   .aresetn(!clk_245_rst), // Active low AXI reset signal

//   // --ADC Data Out Signals
//  .adc_iq_tdata(adc_data_iq),
//  .dac_iq_tdata(dac_data_iq),
//  .iq_tvalid(data_iq_tvalid),
//  .iq_tlast(data_iq_tlast),
//  .iq_tready(data_iq_tready),
//  .iq_first(data_iq_first),
//  .counter_id(data_counter_id),

////  .pk_axis_tdata(dw_axis_tdata),
////  .pk_axis_tvalid(dw_axis_tvalid),
////  .pk_axis_tlast(dw_axis_tlast),
////  .pk_axis_tkeep(dw_axis_tkeep),
////  .pk_axis_tdest(dw_axis_tdest),
////  .pk_axis_tid(dw_axis_tid),
////  .pk_axis_tstrb(dw_axis_tstrb),
////  .pk_axis_tuser(dw_axis_tuser),
////  .pk_axis_tready(dw_axis_tready),
//    .pk_axis_tdata(axis_pk_tdata),
//    .pk_axis_tvalid(axis_pk_tvalid),
//    .pk_axis_tlast(axis_pk_tlast),
//    .pk_axis_tkeep(axis_pk_tkeep),
//    .pk_axis_tdest(axis_pk_tdest),
//    .pk_axis_tid(axis_pk_tid),
//    .pk_axis_tstrb(axis_pk_tstrb),
//    .pk_axis_tuser(axis_pk_tuser),
//    .pk_axis_tready(axis_pk_tready),

//  .lpf_cutoff(lpf_cutoff_ind),
//  .threshold_ctrl_i(threshold_ctrl_i),    // {4b word index, 4b word value} in 64bit threshold
//  .threshold_ctrl_q(threshold_ctrl_q),    // {4b word index, 4b word value} in 64bit threshold

//// Control Module signals
// .chirp_ready                         (chirp_ready),
// .chirp_done                          (chirp_done),
// .chirp_active                        (chirp_active),
// .chirp_init                          (chirp_init),
// .chirp_enable                        (chirp_enable),
// .adc_enable                          (adc_enable),
// .chirp_control_word          (chirp_control_word),
// .chirp_freq_offset           (chirp_freq_offset),
// .chirp_tuning_word_coeff     (chirp_tuning_word_coeff),
// .chirp_count_max             (chirp_count_max)

//   );

//   peak_axis_clock_converter_512 peak_axis_clock_converter_512_inst (
//     .s_axis_aresetn(!clk_245_rst),  // input wire s_axis_aresetn
//     .m_axis_aresetn(aresetn),  // input wire m_axis_aresetn
//     .s_axis_aclk(clk_245_76MHz),        // input wire s_axis_aclk
//     .s_axis_tvalid(dw_axis_tvalid),    // input wire s_axis_tvalid
//     .s_axis_tready(dw_axis_tready),    // output wire s_axis_tready
//     .s_axis_tdata(dw_axis_tdata),      // input wire [511: 0] s_axis_tdata
//     .s_axis_tlast(dw_axis_tlast),      // input wire s_axis_tlast
//     .s_axis_tkeep(dw_axis_tkeep),
//     .s_axis_tdest(dw_axis_tdest),
//     .s_axis_tid(dw_axis_tid),
//     .s_axis_tstrb(dw_axis_tstrb),
//     .s_axis_tuser(dw_axis_tuser),
//     .m_axis_aclk(aclk),        // input wire m_axis_aclk
//     .m_axis_tvalid(axis_pk_tvalid),    // output wire m_axis_tvalid
//     .m_axis_tready(axis_pk_tready),    // input wire m_axis_tready
//     .m_axis_tdata(axis_pk_tdata),      // output wire [511 : 0] m_axis_tdata
//     .m_axis_tlast(axis_pk_tlast),      // output wire m_axis_tlast
//     .m_axis_tkeep(axis_pk_tkeep),
//     .m_axis_tdest(axis_pk_tdest),
//     .m_axis_tid(axis_pk_tid),
//     .m_axis_tstrb(axis_pk_tstrb),
//     .m_axis_tuser(axis_pk_tuser)
//   );

//ila_adc_wr_fifo ila_adc_wr_fifo_inst(
//    //.clk (ui_clk),
//     .clk(clk_245_76MHz),
//     .probe0(adc_fifo_wr_tdata),
//     .probe1(adc_fifo_wr_tdata_count),
//     .probe2(adc_fifo_wr_ack),
//     .probe3(adc_fifo_wr_en),
//     .probe4(adc_fifo_almost_full),
//     .probe5(adc_fifo_full)
//);

//ila_adc_rd_fifo ila_adc_rd_fifo_inst(
//    //.clk (ui_clk),
//     .clk(rd_fifo_clk),
//     .probe0(adc_fifo_data_out),
//     .probe1(adc_fifo_rd_data_count),
//     .probe2(adc_fifo_valid),
//     .probe3(adc_fifo_rd_en),
//     .probe4(adc_fifo_almost_empty),
//     .probe5(adc_fifo_empty),

//     .probe6                      (axis_adc_tdata),
//     .probe7                     (axis_adc_tvalid),
//     .probe8                      (axis_adc_tlast),
//     .probe9                     (axis_adc_tready)
//);


   endmodule
