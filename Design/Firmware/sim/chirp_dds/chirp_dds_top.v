`timescale 1ps/1ps

module chirp_dds_top #
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
 input clk_245,
 input clk_245_rst,
input cpu_reset,       // : in    std_logic; -- CPU RST button, SW7 on KC705
 // input sysclk_p,        // : in    std_logic;
 // input sysclk_n,        // : in    std_logic;
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

  input [7:0] fmc150_ctrl_bus,
  input [67:0] fmc150_spi_ctrl_bus_in,
  output [47:0] fmc150_spi_ctrl_bus_out


   );
   
   localparam DDS_LATENCY = 2;

  wire rd_fifo_clk;
  wire clk_245_76MHz;
  wire clk_491_52MHz;

  wire [15:0] adc_data_i;
  wire [15:0] adc_data_q;
 wire [15:0] dac_data_i;
  wire [15:0] dac_data_q;
  
  wire [31:0] adc_data_iq;
  wire [31:0] dac_data_iq;
  wire data_valid;
  
  wire [31:0] adc_counter;
  wire adc_data_valid;
  
  reg [15:0] adc_data_i_r;
  reg [15:0] adc_data_q_r;
  reg [15:0] adc_data_i_rr;
  reg [15:0] adc_data_q_rr;
  reg [15:0] dac_data_i_r;
  reg [15:0] dac_data_q_r;
  reg [15:0] dac_data_i_rr;
  reg [15:0] dac_data_q_rr;
  
  reg [31:0] adc_counter_reg;
  reg adc_data_valid_r;
  reg adc_data_valid_rr;

  wire [63:0] adc_fifo_wr_tdata;
  wire       adc_fifo_wr_tvalid;
  wire       adc_fifo_wr_tlast;
  wire       adc_fifo_wr_first;
  reg        adc_fifo_wr_first_r;


  wire [15:0] dds_out_i;
  wire [15:0] dds_out_q;
  wire dds_out_valid;
  
  wire [31:0] data_out_lower;
  wire [31:0] data_out_upper;
   reg [31:0] data_out_lower_r;
  reg [31:0] data_out_upper_r;
//  reg data_out_lower_valid;
//  reg data_out_upper_valid;
  reg [3:0] dds_latency_counter;
  reg [31:0] glbl_counter_reg;
  wire [31:0] glbl_counter;
  
  wire [1:0] dds_route_ctrl_l;
  wire [1:0] dds_route_ctrl_u;



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

wire [23 : 0] s_axis_fft_config_tdata
.s_axis_config_tvalid(s_axis_fft_config_tvalid),              // input wire s_axis_fft_config_tvalid
.s_axis_config_tready(s_axis_fft_config_tready),              // output wire s_axis_fft_config_tready
.s_axis_data_tdata(s_axis_fft_data_tdata),                    // input wire [31 : 0] s_axis_fft_data_tdata
.s_axis_data_tvalid(s_axis_fft_data_tvalid),                  // input wire s_axis_fft_data_tvalid
.s_axis_data_tready(s_axis_fft_data_tready),                  // output wire s_axis_fft_data_tready
.s_axis_data_tlast(s_axis_fft_data_tlast),                    // input wire s_axis_fft_data_tlast
.m_axis_data_tdata(m_axis_fft_data_tdata),                    // output wire [31 : 0] m_axis_fft_data_tdata
.m_axis_data_tvalid(m_axis_fft_data_tvalid),                  // output wire m_axis_fft_data_tvalid
.m_axis_data_tlast(m_axis_fft_data_tlast),                    // output wire m_axis_fft_data_tlast
.event_frame_started(fft_event_frame_started),                // output wire fft_event_frame_started
.event_tlast_unexpected(fft_event_tlast_unexpected),          // output wire fft_event_tlast_unexpected
.event_tlast_missing(fft_event_tlast_missing),                // output wire fft_event_tlast_missing
.event_data_in_channel_halt(fft_event_data_in_channel_halt)  // output wire fft_event_data_in_channel_halt


     assign clk_245_76MHz = clk_245;
     // simulate adc outputs from fmc150 module with dds loopback
     always @(posedge clk_245_76MHz) begin
        adc_data_i_r <= dac_data_i_rr;
        adc_data_q_r <= dac_data_q_rr;
        adc_data_valid_r <= dds_out_valid;
        adc_data_i_rr <= adc_data_i_r;
        adc_data_q_rr <= adc_data_q_r;
        adc_data_valid_rr <= adc_data_valid_r;
     end
     
     // simulate number of register stages in fmc150 module for dac (2)
     always @(posedge clk_245_76MHz) begin
        dac_data_i_r <= dds_out_i;
        dac_data_q_r <= dds_out_q;
        dac_data_i_rr <= dds_out_i;
        dac_data_q_rr <= dds_out_q;

     end
     
     always @(posedge clk_245_76MHz) begin
      if (cpu_reset) begin
        adc_counter_reg <= 'b0;
      end
      else begin
        if (adc_enable_rr & adc_data_valid_rr)
          adc_counter_reg <= adc_counter_reg+1;
      end
     end
     
     always @(posedge clk_245_76MHz) begin
      if (cpu_reset) begin
        glbl_counter_reg <= 'b0;
      end
      else begin
        glbl_counter_reg <= glbl_counter_reg+1;
      end
     end
     
     assign adc_data_iq = {adc_data_i,adc_data_q};
     assign dac_data_iq = {dac_data_i,dac_data_q};
     assign data_valid = adc_data_valid_rr;
     
     assign adc_data_i = adc_data_i_rr;
     assign adc_data_q = adc_data_q_rr;
     assign dac_data_i = dac_data_i_rr;
     assign dac_data_q = dac_data_q_rr;
     
     
     assign adc_counter = adc_counter_reg;
     assign adc_data_valid = adc_data_valid_rr;
     assign fmc150_spi_ctrl_bus_out = 'b0;
     assign fmc150_status_vector = 4'b1111;
     
     assign glbl_counter = glbl_counter_reg;


     
     CHIRP_DDS #(
     .DDS_LATENCY(DDS_LATENCY)
     ) u_chirp_dds(
         .CLOCK(clk_245),
         .RESET(clk_245_rst),
         .IF_OUT_I(dds_out_i),
         .IF_OUT_Q(dds_out_q),
         .IF_OUT_VALID(dds_out_valid),

         .chirp_ready (chirp_ready),
         .chirp_done  (chirp_done),
         .chirp_active (chirp_active),
         .chirp_init  (chirp_init),
         .chirp_enable (chirp_enable),

         .freq_offset_in          (chirp_freq_offset),
         .tuning_word_coeff_in    (chirp_tuning_word_coeff),
         .chirp_count_max_in      (chirp_count_max)

     );

  assign dds_route_ctrl_l = chirp_control_word[1:0];
  assign dds_route_ctrl_u = chirp_control_word[5:4];

//  always @(posedge clk_245_76MHz) begin
//    if (cpu_reset) begin
//      data_out_lower <= 'b0;
//      data_out_lower_valid <= 1'b0;
//    end
//    else begin 
//        data_out_lower_valid <= data_valid;
//        if( dds_route_ctrl[3:0] == 4'b0001)
//          data_out_lower <= dac_data_iq;
//        else if( dds_route_ctrl[3:0] == 4'b0010)
//            data_out_lower <= adc_counter_reg;  
//        else if( dds_route_ctrl[3:0] == 4'b0011)
//            data_out_lower <= glbl_counter_reg; 
//        else
//            data_out_lower <= adc_data_iq; 
//    end                
//  end
  
//  always @(dds_route_ctrl_l or adc_data_iq or dac_data_iq or adc_counter or glbl_counter  ) begin
//    case (dds_route_ctrl_l)
//    2'b00: data_out_lower_r = adc_data_iq; 
//    2'b01: data_out_lower_r = dac_data_iq; 
//    2'b10: data_out_lower_r = adc_counter; 
//    2'b11: data_out_lower_r = glbl_counter; 
//    default: data_out_lower_r = adc_data_iq; 
//    endcase 
//  end  

// always @(dds_route_ctrl_u or adc_data_iq or dac_data_iq or adc_counter or glbl_counter  ) begin
//    case (dds_route_ctrl_u)
//    2'b00: data_out_upper_r = adc_data_iq; 
//    2'b01: data_out_upper_r = dac_data_iq; 
//    2'b10: data_out_upper_r = adc_counter; 
//    2'b11: data_out_upper_r = glbl_counter; 
//    default: data_out_upper_r = adc_counter; 
//    endcase 
//  end  
//  assign data_out_lower = data_out_lower_r;
//  assign data_out_upper = data_out_upper_r;
  assign data_out_lower  = (dds_route_ctrl_l == 2'b00) ? adc_data_iq : 32'bz,
        data_out_lower  = (dds_route_ctrl_l == 2'b01) ? dac_data_iq : 32'bz,
        data_out_lower  = (dds_route_ctrl_l == 2'b10) ? adc_counter : 32'bz,
        data_out_lower  = (dds_route_ctrl_l == 2'b11) ? glbl_counter : 32'bz;
 
   assign data_out_upper  = (dds_route_ctrl_u == 2'b00) ? adc_data_iq : 32'bz,
              data_out_upper  = (dds_route_ctrl_u == 2'b01) ? dac_data_iq : 32'bz,
              data_out_upper  = (dds_route_ctrl_u == 2'b10) ? adc_counter_reg : 32'bz,
              data_out_upper  = (dds_route_ctrl_u == 2'b11) ? glbl_counter_reg : 32'bz;    
                 
  
// always @(posedge clk_245_76MHz) begin
//    if (cpu_reset) begin
//      data_out_upper <= 'b0;
//      data_out_upper_valid <= 1'b0;
//    end
//    else begin 
//        data_out_upper_valid <= data_valid;
//        if( dds_route_ctrl[7:4] == 4'b0001)
//          data_out_upper <= dac_data_iq;
//        else if( dds_route_ctrl[7:4] == 4'b0010)
//            data_out_upper <= adc_counter_reg;  
//        else if( dds_route_ctrl[7:4] == 4'b0011)
//            data_out_upper <= glbl_counter_reg; 
//        else
//            data_out_upper <= adc_data_iq; 
//    end                
//  end
  




   always @(posedge clk_245_76MHz) begin
    if (cpu_reset) begin
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
    if (cpu_reset) 
      dds_latency_counter <= 'b0;
    else if( chirp_init)
      dds_latency_counter <= DDS_LATENCY;
    else if(adc_enable_r & !adc_enable)
        dds_latency_counter <= DDS_LATENCY;  
    else if(|dds_latency_counter)
      dds_latency_counter <= dds_latency_counter-1;
  end
  
  
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
   
 assign adc_fifo_wr_tdata  = (adc_fifo_wr_first | adc_fifo_wr_tlast) ? {glbl_counter,adc_counter} : {data_out_upper,data_out_lower};
   
 //  assign adc_fifo_wr_tdata = {data_out_upper,data_out_lower};
 
//   assign adc_fifo_wr_tvalid = data_out_upper_valid & data_out_lower_valid & adc_enable_rr;
    assign adc_fifo_wr_tvalid = data_valid & adc_enable_rr;
   
   assign adc_fifo_wr_first = adc_fifo_wr_first_r;
   
   assign adc_fifo_wr_tlast = (!(|dds_latency_counter))&(adc_enable_rr)&(!adc_enable_r);

//   assign adc_fifo_wr_en = adc_enable_rr & adc_data_valid;
 //  assign adc_fifo_wr_en = adc_enable_rr & data_out_upper_valid & data_out_lower_valid;
    assign adc_fifo_wr_en = adc_enable_rr & data_valid;



assign rd_fifo_clk = aclk;

//assign clk_out_491_52MHz = clk_491_52MHz;

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






   endmodule
