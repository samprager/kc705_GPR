`timescale 1ps/1ps

module fmc150_dac_adc #
  (
     parameter ADC_AXI_DATA_WIDTH = 64,
     parameter ADC_AXI_TID_WIDTH = 1,
     parameter ADC_AXI_TDEST_WIDTH = 1,
     parameter ADC_AXI_TUSER_WIDTH = 1,
     parameter ADC_AXI_STREAM_ID = 1'b0,
     parameter ADC_AXI_STREAM_DEST = 1'b0

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

  localparam DDS_LATENCY = 4;
  
  wire rd_fifo_clk;
  wire clk_245_76MHz;
  wire clk_491_52MHz;

//  wire [15:0] adc_data_i;
//  wire [15:0] adc_data_q;
  wire [31:0] adc_data_iq;
  wire [31:0] dac_data_iq;
  wire [31:0] adc_counter;
  //wire adc_data_valid;
  wire data_valid;
  reg [7:0] dds_route_ctrl_reg;
  wire [7:0] dds_route_ctrl;

  wire [63:0] adc_fifo_wr_tdata;
  wire       adc_fifo_wr_tvalid;
  wire       adc_fifo_wr_tlast;
  reg        adc_fifo_wr_tlast_r;
  reg        adc_fifo_wr_tlast_rr;



     wire [12:0]              adc_fifo_wr_tdata_count;
     wire [9:0]               adc_fifo_rd_data_count;
     wire                       adc_fifo_wr_ack;
     wire                       adc_fifo_valid;
     wire                       adc_fifo_almost_full;
     wire                       adc_fifo_almost_empty;
     wire                      adc_fifo_wr_en;
     wire                      adc_fifo_rd_en;
     wire [ADC_AXI_DATA_WIDTH-1:0]  adc_fifo_data_out;
     wire                     adc_fifo_full;
     wire                     adc_fifo_empty;

     reg                      adc_enable_r;
     reg                      adc_enable_rr;
     
     reg [3:0] dds_latency_counter;
     reg [31:0] glbl_counter_reg;
     reg [31:0] adc_counter_reg;
     
     reg [31:0] data_out_upper;
     reg [31:0] data_out_lower;
     reg data_out_upper_valid;
     reg data_out_lower_valid;



   KC705_fmc150 #(
    .DDS_LATENCY(DDS_LATENCY)
   ) KC705_fmc150_inst
   (
        // --KC705 Resources - from fmc150 example design
//        .adc_data_out_i (adc_data_i),
//        .adc_data_out_q (adc_data_q),
//        .adc_counter_out (adc_counter),
//        .adc_data_out_valid (adc_data_valid),
        
        .adc_data_out_iq (adc_data_iq),
        .dac_data_out_iq (dac_data_iq),
        .data_out_valid  (data_valid),

        .clk_out_245_76MHz  (clk_245_76MHz),
        .clk_out_491_52MHz  (clk_491_52MHz),
        .clk_245_rst (clk_245_rst),

//        .clk_100Mhz_out (clk_100Mhz),
//        .clk_100Mhz_rst (clk_100Mhz_rst),

        .clk_100Mhz (clk_100Mhz),
        .clk_200Mhz (clk_200Mhz),
        .mmcm_locked (mmcm_locked),

        .fmc150_status_vector (fmc150_status_vector),
        .chirp_ready (chirp_ready),
        .chirp_done (chirp_done),
        .chirp_active (chirp_active),
        .chirp_init  (chirp_init),
        .chirp_enable  (chirp_enable),
        .adc_enable    (adc_enable),

        .dac_loopback               (chirp_control_word[0]),
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

//   always @(posedge clk_245_76MHz) begin
//    if (cpu_reset) begin
//      adc_enable_r <= 1'b0;
//      adc_enable_rr <= 1'b0;
//    end else begin
//      adc_enable_r <= adc_enable;
//      adc_enable_rr <= adc_enable_r;
//    end
//   end

//   always @(posedge clk_245_76MHz) begin
//    if (cpu_reset)
//      adc_fifo_wr_tlast_reg <= 1'b0;
//    else if (adc_enable_r & !adc_enable)
//      adc_fifo_wr_tlast_reg <= 1'b1;
//    else
//      adc_fifo_wr_tlast_reg <= 1'b0;
//   end

//assign dds_route_ctrl = chirp_control_word[7:0];  
  always @(posedge clk_245_76MHz) begin
    if (clk_245_rst) 
      dds_route_ctrl_reg <= 8'h20;
    else if (chirp_init) 
      dds_route_ctrl_reg <= chirp_control_word[7:0];
  end  
 assign dds_route_ctrl = dds_route_ctrl_reg; 
    
  always @(posedge clk_245_76MHz) begin
    if (clk_245_rst) begin
      data_out_lower <= 'b0;
      data_out_lower_valid <= 1'b0;
    end
    else begin 
        data_out_lower_valid <= data_valid;
        if( dds_route_ctrl[3:0] == 4'b0001)
          data_out_lower <= dac_data_iq;
        else if( dds_route_ctrl[3:0] == 4'b0010)
            data_out_lower <= adc_counter_reg;  
        else if( dds_route_ctrl[3:0] == 4'b0011)
            data_out_lower <= glbl_counter_reg; 
        else
            data_out_lower <= adc_data_iq; 
    end                
  end
  
 always @(posedge clk_245_76MHz) begin
    if (clk_245_rst) begin
      data_out_upper <= 'b0;
      data_out_upper_valid <= 1'b0;
    end
    else begin 
        data_out_upper_valid <= data_valid;
        if( dds_route_ctrl[7:4] == 4'b0001)
          data_out_upper <= dac_data_iq;
        else if( dds_route_ctrl[7:4] == 4'b0010)
            data_out_upper <= adc_counter_reg;  
        else if( dds_route_ctrl[7:4] == 4'b0011)
            data_out_upper <= glbl_counter_reg; 
        else
            data_out_upper <= adc_data_iq; 
    end                
  end
  
   always @(posedge clk_245_76MHz) begin
    if (clk_245_rst) begin
      adc_enable_r <= 1'b0;
      adc_enable_rr <= 1'b0;
    end else begin
      adc_enable_r <= adc_enable;
      if (!(|dds_latency_counter))
        adc_enable_rr <= adc_enable_r;
      else 
        adc_enable_rr <=adc_enable_rr;
    end
   end
   
  always @(posedge clk_245_76MHz) begin
    if (clk_245_rst) 
      dds_latency_counter <= 'b0;
    else if( chirp_init)
      dds_latency_counter <= DDS_LATENCY-1;
    else if(|dds_latency_counter)
      dds_latency_counter <= dds_latency_counter-1;
  end

   always @(posedge clk_245_76MHz) begin
    if (clk_245_rst)
      adc_fifo_wr_tlast_r <= 1'b0;
    else if (adc_enable_r & !adc_enable)
      adc_fifo_wr_tlast_r <= 1'b1;
    else
      adc_fifo_wr_tlast_r <= 1'b0;
   end
   
  always @(posedge clk_245_76MHz) begin
    if (clk_245_rst)
      adc_fifo_wr_tlast_rr <= 1'b0;
    else if (!(|dds_latency_counter))
      adc_fifo_wr_tlast_rr <= adc_fifo_wr_tlast_r;
    else
      adc_fifo_wr_tlast_rr <= adc_fifo_wr_tlast_rr;
   end
   
   always @(posedge clk_245_76MHz) begin
    if (clk_245_rst) begin
      adc_counter_reg <= 'b0;
    end
    else begin
      if (adc_enable_rr & data_valid)
        adc_counter_reg <= adc_counter_reg+1;
    end
   end
   
   always @(posedge clk_245_76MHz) begin
    if (clk_245_rst) begin
      glbl_counter_reg <= 'b0;
    end
    else begin
      glbl_counter_reg <= glbl_counter_reg+1;
    end
   end
   
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
      .adc_data                   (adc_fifo_data_out),
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

//   assign adc_data_iq = {adc_data_i,adc_data_q};
//   assign adc_fifo_wr_tdata = {adc_counter,adc_data_iq};
//   assign adc_fifo_wr_tvalid = adc_data_valid & adc_enable_rr;

   assign adc_fifo_wr_tdata = {data_out_upper,data_out_lower};
   assign adc_fifo_wr_tvalid = data_out_upper_valid & data_out_lower_valid & adc_enable_rr;
   
   
   assign adc_fifo_wr_tlast = adc_fifo_wr_tlast_rr;

//   assign adc_fifo_wr_en = adc_enable_rr & adc_data_valid;
   assign adc_fifo_wr_en = adc_enable_rr & data_out_upper_valid & data_out_lower_valid;

assign rd_fifo_clk = aclk;

assign clk_out_245_76MHz = clk_245_76MHz;
//assign clk_out_491_52MHz = clk_491_52MHz;

ila_adc_wr_fifo ila_adc_wr_fifo_inst(
    //.clk (ui_clk),
     .clk(clk_245_76MHz),
     .probe0(adc_fifo_wr_tdata),
     .probe1(adc_fifo_wr_tdata_count),
     .probe2(adc_fifo_wr_ack),
     .probe3(adc_fifo_wr_en),
     .probe4(adc_fifo_almost_full),
     .probe5(adc_fifo_full)
);

ila_adc_rd_fifo ila_adc_rd_fifo_inst(
    //.clk (ui_clk),
     .clk(rd_fifo_clk),
     .probe0(adc_fifo_data_out),
     .probe1(adc_fifo_rd_data_count),
     .probe2(adc_fifo_valid),
     .probe3(adc_fifo_rd_en),
     .probe4(adc_fifo_almost_empty),
     .probe5(adc_fifo_empty),

     .probe6                      (axis_adc_tdata),
     .probe7                     (axis_adc_tvalid),
     .probe8                      (axis_adc_tlast),
     .probe9                     (axis_adc_tready)
);


   endmodule
