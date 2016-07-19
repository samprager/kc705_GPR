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

  wire rd_fifo_clk;
  wire clk_245_76MHz;
  wire clk_491_52MHz;

  wire [15:0] adc_data_i;
  wire [15:0] adc_data_q;
  wire [31:0] adc_data_iq;
  wire [31:0] adc_counter;
  wire adc_data_valid;
  
  reg [15:0] adc_data_i_reg;
  reg [15:0] adc_data_q_reg;
  reg [31:0] adc_counter_reg;
  reg adc_data_valid_reg;

  wire [63:0] adc_fifo_wr_tdata;
  wire       adc_fifo_wr_tvalid;
  wire       adc_fifo_wr_tlast;
  reg        adc_fifo_wr_tlast_reg;

  wire [15:0] dds_out_i;
  wire [15:0] dds_out_q;
  wire dds_out_valid;



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


     assign clk_245_76MHz = clk_245;
     // simulate adc outputs from fmc150 module with dds loopback
     always @(posedge clk_245_76MHz) begin
        adc_data_i_reg <= dds_out_i;
        adc_data_q_reg <= dds_out_q;
        adc_data_valid_reg <= dds_out_valid;
     end
     always @(posedge clk_245_76MHz) begin
      if (cpu_reset) begin
        adc_counter_reg <= 'b0;
      end
      else begin
        if (adc_enable & adc_data_valid_reg)
          adc_counter_reg <= adc_counter_reg+1;
      end
     end
     assign adc_data_i = adc_data_i_reg;
     assign adc_data_q = adc_data_q_reg;
     assign adc_counter = adc_counter_reg;
     assign fmc150_spi_ctrl_bus_out = 'b0;
     assign fmc150_status_vector = 4'b1111;


     
     CHIRP_DDS u_chirp_dds(
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





   always @(posedge clk_245_76MHz) begin
    if (cpu_reset) begin
      adc_enable_r <= 1'b0;
      adc_enable_rr <= 1'b0;
    end else begin
      adc_enable_r <= adc_enable;
      adc_enable_rr <= adc_enable_r;
    end
   end

   always @(posedge clk_245_76MHz) begin
    if (cpu_reset)
      adc_fifo_wr_tlast_reg <= 1'b0;
    else if (adc_enable_r & !adc_enable)
      adc_fifo_wr_tlast_reg <= 1'b1;
    else
      adc_fifo_wr_tlast_reg <= 1'b0;
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

   //assign adc_fifo_rd_en = 1'b1;

   assign adc_data_iq = {adc_data_i,adc_data_q};
   assign adc_fifo_wr_tdata = {adc_counter,adc_data_iq};
   assign adc_fifo_wr_tvalid = adc_data_valid & adc_enable_rr;
 //  assign adc_fifo_wr_tvalid = adc_data_valid & adc_enable;

   assign adc_fifo_wr_tlast = adc_fifo_wr_tlast_reg;

 //  assign adc_fifo_wr_en = adc_enable & adc_data_valid;
   assign adc_fifo_wr_en = adc_enable_rr & adc_data_valid;

assign rd_fifo_clk = aclk;

//assign clk_out_491_52MHz = clk_491_52MHz;




   endmodule
