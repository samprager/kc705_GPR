`timescale 1ps/1ps

module chirp_dds_top #
  (
     parameter ADC_AXI_DATA_WIDTH = 512,
     parameter ADC_AXI_TID_WIDTH = 1,
     parameter ADC_AXI_TDEST_WIDTH = 1,
     parameter ADC_AXI_TUSER_WIDTH = 1,
     parameter ADC_AXI_STREAM_ID = 1'b0,
     parameter ADC_AXI_STREAM_DEST = 1'b0,

     parameter FFT_LEN = 8192

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
   localparam FCUTOFF_IND = FFT_LEN/2;
   localparam ADC_DELAY = 100;
   
   integer i;

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
  
  reg [31:0] adc_data_i_delay [ADC_DELAY-1:0];
  reg [31:0] adc_data_q_delay [ADC_DELAY-1:0];

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
  reg [63:0] glbl_counter_reg;
  wire [63:0] glbl_counter;

  wire [1:0] dds_route_ctrl_l;
  wire [1:0] dds_route_ctrl_u;

  reg [ADC_AXI_DATA_WIDTH-1:0]     chirp_header;
  reg [7:0]  chirp_header_counter;
  reg chirp_init_r;
  reg chirp_init_rr;



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

     wire [63:0] s_fft_i_axis_tdata;
     wire s_fft_i_axis_tvalid;
     wire s_fft_i_axis_tlast;
     wire s_fft_i_axis_tready;

     wire [63:0] s_fft_q_axis_tdata;
     wire s_fft_q_axis_tvalid;
     wire s_fft_q_axis_tlast;
     wire s_fft_q_axis_tready;

     wire [63:0] m_fft_i_axis_tdata;
     wire m_fft_i_axis_tvalid;
     wire m_fft_i_axis_tlast;
     wire m_fft_i_axis_tready;
     wire [31:0] m_fft_i_index;

     wire [63:0] m_fft_q_axis_tdata;
     wire m_fft_q_axis_tvalid;
     wire m_fft_q_axis_tlast;
     wire m_fft_q_axis_tready;
     wire [31:0] m_fft_q_index;

     wire [31:0] mixer_out_i;
     wire [31:0] mixer_out_q;

     wire [31:0] mag_i_axis_tdata;
     wire [31:0] mag_q_axis_tdata;

     wire [63:0] sq_mag_i_axis_tdata;
     wire        sq_mag_i_axis_tvalid;
     wire        sq_mag_i_axis_tlast;
     wire [63:0] sq_mag_q_axis_tdata;
     wire        sq_mag_q_axis_tvalid;
     wire        sq_mag_q_axis_tlast;
     wire       sq_mag_i_axis_tdata_overflow;
     wire       sq_mag_q_axis_tdata_overflow;
     wire [31:0] sq_mag_i_axis_tuser;
     wire [31:0] sq_mag_q_axis_tuser;
     wire [31:0] sq_mag_i_index;
     wire [31:0] sq_mag_q_index;

     wire [31:0] peak_index_i;
     wire [63:0] peak_tdata_i;
     wire peak_tvalid_i;
     wire peak_tlast_i;
     wire [31:0] peak_tuser_i;
     wire [31:0] num_peaks_i;

     wire [31:0] peak_index_q;
     wire [63:0] peak_tdata_q;
     wire peak_tvalid_q;
     wire peak_tlast_q;
     wire [31:0] peak_tuser_q;
     wire [31:0] num_peaks_q;

     reg [31:0] peak_result_i;
     reg [31:0] peak_result_q;
     reg [63:0] peak_val_i;
     reg [31:0] peak_num_i;
     reg [63:0] peak_val_q;
     reg [31:0] peak_num_q;
     reg new_peak_i;
     reg new_peak_q;

     wire [63:0] lpf_tdata_i;
     wire lpf_tvalid_i;
     wire lpf_tlast_i;
     wire [31:0] lpf_tuser_i;
     wire [31:0] lpf_index_i;

     wire [63:0] lpf_tdata_q;
     wire lpf_tvalid_q;
     wire lpf_tlast_q;
     wire [31:0] lpf_tuser_q;
     wire [31:0] lpf_index_q;

     wire [31:0] lpf_cuttof_ind;
     wire [63:0] peak_threshold_i;
     wire [63:0] peak_threshold_q;

     wire [255:0] dw_axis_tdata;
     wire dw_axis_tvalid;
     wire dw_axis_tlast;
     wire dw_axis_tready;

     reg dw_axis_tvalid_r;
     reg dw_axis_tlast_r;


     assign clk_245_76MHz = clk_245;
     // simulate adc outputs from fmc150 module with dds loopback
//     always @(posedge clk_245_76MHz) begin
//        adc_data_i_r <= dac_data_i_rr;
//        adc_data_q_r <= dac_data_q_rr;
//        adc_data_valid_r <= dds_out_valid;
//        adc_data_i_rr <= adc_data_i_r;
//        adc_data_q_rr <= adc_data_q_r;
//        adc_data_valid_rr <= adc_data_valid_r;
//     end
 always @(posedge clk_245_76MHz) begin
    if (clk_245_rst) 
        adc_data_valid_rr <= 1'b0;   
    else     
       adc_data_valid_rr <= 1'b1;
 end      
  
always @(posedge clk_245_76MHz) begin 
     if (clk_245_rst) begin
         adc_data_i_delay[0] <= 'b0;
         adc_data_q_delay[0] <= 'b0;
     end else begin
        // Divide adc sample magnitudes by 2
        adc_data_i_delay[0] <= {dac_data_i_rr[15],dac_data_i_rr[15:1]};
        adc_data_q_delay[0] <= {dac_data_q_rr[15],dac_data_q_rr[15:1]}; 
    end
end        
 always @(posedge clk_245_76MHz) begin 
    for (i=1;i<ADC_DELAY;i=i+1) begin
        if (clk_245_rst) begin
            adc_data_i_delay[i] <= 'b0;
            adc_data_q_delay[i] <= 'b0;
        end else begin    
            adc_data_i_delay[i] <= adc_data_i_delay[i-1];
            adc_data_q_delay[i] <= adc_data_q_delay[i-1];
        end    
    end
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
     assign adc_data_valid = adc_data_valid_rr;
     assign data_valid = adc_data_valid_rr;
//     assign adc_data_i = adc_data_i_rr;
//     assign adc_data_q = adc_data_q_rr;
     assign adc_data_i = adc_data_i_delay[ADC_DELAY-1];
     assign adc_data_q = adc_data_q_delay[ADC_DELAY-1];
     
     assign dac_data_i = dac_data_i_rr;
     assign dac_data_q = dac_data_q_rr;


     assign adc_counter = adc_counter_reg;
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
        data_out_lower  = (dds_route_ctrl_l == 2'b11) ? glbl_counter[31:0] : 32'bz;

   assign data_out_upper  = (dds_route_ctrl_u == 2'b00) ? adc_data_iq : 32'bz,
              data_out_upper  = (dds_route_ctrl_u == 2'b01) ? dac_data_iq : 32'bz,
              data_out_upper  = (dds_route_ctrl_u == 2'b10) ? adc_counter : 32'bz,
              data_out_upper  = (dds_route_ctrl_u == 2'b11) ? glbl_counter[31:0] : 32'bz;


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


   always @(posedge clk_245_76MHz) begin
    if (cpu_reset)
      chirp_header_counter <= 'b0;
     else if (chirp_init)
      chirp_header_counter <= ADC_AXI_DATA_WIDTH/64-1;
     else if (|chirp_header_counter)
      chirp_header_counter <= chirp_header_counter-1;
    end

    always @(posedge clk_245_76MHz) begin
     if (cpu_reset)
       chirp_init_r <= 1'b0;
     else if (chirp_init)
       chirp_init_r <= chirp_init;
    else if (!(|chirp_header_counter))
       chirp_init_r <= 1'b0;
    end

    always @(posedge clk_245_76MHz) begin
     if (cpu_reset)
       chirp_init_rr <= 1'b0;
     else if (!(|chirp_header_counter))
       chirp_init_rr <= chirp_init_r;
    end

    always @(posedge clk_245_76MHz) begin
     if (cpu_reset)
       chirp_header <= 'b0;
     else if (chirp_init_r)
       chirp_header[64+64*chirp_header_counter-1-:64] <= glbl_counter;
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

assign adc_fifo_wr_tdata  = (adc_fifo_wr_first | adc_fifo_wr_tlast) ? {glbl_counter[31:0],adc_counter} : {data_out_upper,data_out_lower};

//assign adc_fifo_wr_tdata = {data_out_upper,data_out_lower};

//   assign adc_fifo_wr_tvalid = data_out_upper_valid & data_out_lower_valid & adc_enable_rr;
    assign adc_fifo_wr_tvalid = data_valid & adc_enable_rr;

   assign adc_fifo_wr_first = adc_fifo_wr_first_r;

   assign adc_fifo_wr_tlast = (!(|dds_latency_counter))&(adc_enable_rr)&(!adc_enable_r);

//   assign adc_fifo_wr_en = adc_enable_rr & adc_data_valid;
 //  assign adc_fifo_wr_en = adc_enable_rr & data_out_upper_valid & data_out_lower_valid;
    assign adc_fifo_wr_en = adc_enable_rr & data_valid;



assign rd_fifo_clk = aclk;

//assign clk_out_491_52MHz = clk_491_52MHz;


//assign s_fft_axis_tdata = {dac_data_q,dac_data_i,adc_data_q,adc_data_i};
assign s_fft_i_axis_tdata = {32'b0,mixer_out_i};
assign s_fft_i_axis_tvalid = adc_fifo_wr_en&(!adc_fifo_wr_first);
assign s_fft_i_axis_tlast = adc_fifo_wr_tlast;

assign s_fft_q_axis_tdata = {32'b0,mixer_out_q};
assign s_fft_q_axis_tvalid = adc_fifo_wr_en&(!adc_fifo_wr_first);
assign s_fft_q_axis_tlast = adc_fifo_wr_tlast;

assign m_fft_i_axis_tready = 1'b1;
assign m_fft_q_axis_tready = 1'b1;

mixer_mult_gen mixer_i (
 .CLK(clk_245),  // input wire CLK
 .A(dac_data_i),      // input wire [15 : 0] A
 .B(adc_data_i),      // input wire [15 : 0] B
 //.P(s_fft_axis_tdata[31:0])      // output wire [31 : 0] P
  .P(mixer_out_i)       // output wire [31 : 0] P
);
mixer_mult_gen mixer_q (
 .CLK(clk_245),  // input wire CLK
 .A(dac_data_q),      // input wire [15 : 0] A
 .B(adc_data_q),      // input wire [15 : 0] B
 //.P(s_fft_axis_tdata[63:32])      // output wire [31 : 0] P
 .P(mixer_out_q)    // output wire [31 : 0] P
);

sq_mag_estimate#(
    .DATA_LEN(32),
    .DIV_OR_OVERFLOW(0),  // (1): Divide output by 2, (0): use overflow bit
    .REGISTER_OUTPUT(1)
)
 sq_mag_i (
    .clk(clk_245),
    .dataI(m_fft_i_axis_tdata[31:0]),
    .dataI_tvalid(m_fft_i_axis_tvalid),
    .dataI_tlast(m_fft_i_axis_tlast),
    .dataQ(m_fft_i_axis_tdata[63:32]),
    .dataQ_tvalid(m_fft_i_axis_tvalid),
    .dataQ_tlast(m_fft_i_axis_tlast),
    .data_index(m_fft_i_index),
    .data_tuser(chirp_tuning_word_coeff),
    .dataMagSq(sq_mag_i_axis_tdata),
    .dataMag_tvalid(sq_mag_i_axis_tvalid),
    .dataMag_tlast(sq_mag_i_axis_tlast),
    .dataMag_tuser(sq_mag_i_axis_tuser),
    .dataMag_index(sq_mag_i_index),
    .overflow(sq_mag_i_axis_tdata_overflow)
);

sq_mag_estimate#(
    .DATA_LEN(32),
    .DIV_OR_OVERFLOW(0),     // (1): Divide output by 2, (0): use overflow bit
    .REGISTER_OUTPUT(1)
)
 sq_mag_q (
   .clk(clk_245),
   .dataI(m_fft_q_axis_tdata[31:0]),
   .dataI_tvalid(m_fft_q_axis_tvalid),
   .dataI_tlast(m_fft_q_axis_tlast),
   .dataQ(m_fft_q_axis_tdata[63:32]),
   .dataQ_tvalid(m_fft_q_axis_tvalid),
   .dataQ_tlast(m_fft_q_axis_tlast),
   .data_index(m_fft_q_index),
   .data_tuser(chirp_tuning_word_coeff),
   .dataMagSq(sq_mag_q_axis_tdata),
   .dataMag_tvalid(sq_mag_q_axis_tvalid),
   .dataMag_tlast(sq_mag_q_axis_tlast),
   .dataMag_tuser(sq_mag_q_axis_tuser),
   .dataMag_index(sq_mag_q_index),
   .overflow(sq_mag_q_axis_tdata_overflow)
);

assign lpf_cuttof_ind = FCUTOFF_IND;
freq_domain_lpf #(
    .DATA_LEN(64)
) freq_lpf_i(
     .clk(clk_245),
     .aresetn(!clk_245_rst),
     .tdata(sq_mag_i_axis_tdata),
     .tvalid(sq_mag_i_axis_tvalid),
     .tlast(sq_mag_i_axis_tlast),
     .tuser(sq_mag_i_axis_tuser),
     .index(sq_mag_i_index),
     .cutoff(lpf_cuttof_ind),
     .lpf_index(lpf_index_i),
     .lpf_tdata(lpf_tdata_i),
     .lpf_tvalid(lpf_tvalid_i),
     .lpf_tlast(lpf_tlast_i),
     .lpf_tuser(lpf_tuser_i)
   );


 freq_domain_lpf #(
     .DATA_LEN(64)
 ) freq_lpf_q(
      .clk(clk_245),
      .aresetn(!clk_245_rst),
      .tdata(sq_mag_q_axis_tdata),
      .tvalid(sq_mag_q_axis_tvalid),
      .tlast(sq_mag_q_axis_tlast),
      .tuser(sq_mag_q_axis_tuser),
      .index(sq_mag_q_index),
      .cutoff(lpf_cuttof_ind),
      .lpf_index(lpf_index_q),
      .lpf_tdata(lpf_tdata_q),
      .lpf_tvalid(lpf_tvalid_q),
      .lpf_tlast(lpf_tlast_q),
      .lpf_tuser(lpf_tuser_q)
    );


assign peak_threshold_i = {4'b0001,60'b0};
assign peak_threshold_q = {4'b0001,60'b0};
peak_finder #(
  .DATA_LEN(64)
) peak_finder_i(
  .clk(clk_245),
  .aresetn(!clk_245_rst),
//      .tdata(sq_mag_i_axis_tdata),
//      .tvalid(sq_mag_i_axis_tvalid),
//      .tlast(sq_mag_i_axis_tlast),
//      .tuser(sq_mag_i_axis_tuser),
//      .index(sq_mag_i_index),
  .tdata(lpf_tdata_i),
  .tvalid(lpf_tvalid_i),
  .tlast(lpf_tlast_i),
  .tuser(lpf_tuser_i),
  .index(lpf_index_i),
  .threshold(peak_threshold_i),
  .peak_index(peak_index_i),
  .peak_tdata(peak_tdata_i),
  .peak_tvalid(peak_tvalid_i),
  .peak_tlast(peak_tlast_i),
  .peak_tuser(peak_tuser_i),
  .num_peaks(num_peaks_i)
);
peak_finder #(
  .DATA_LEN(64)
) peak_finder_q(
  .clk(clk_245),
  .aresetn(!clk_245_rst),
  .tdata(lpf_tdata_q),
  .tvalid(lpf_tvalid_q),
  .tlast(lpf_tlast_q),
  .tuser(lpf_tuser_q),
  .index(lpf_index_q),
  .threshold(peak_threshold_q),
  .peak_index(peak_index_q),
  .peak_tdata(peak_tdata_q),
  .peak_tvalid(peak_tvalid_q),
  .peak_tlast(peak_tlast_q),
  .peak_tuser(peak_tuser_q),
  .num_peaks(num_peaks_q)
);
always @(posedge clk_245) begin
  if (clk_245_rst) begin
    new_peak_i <= 1'b0;
  end else if (peak_tlast_i & peak_tvalid_i) begin
    peak_result_i <= peak_index_i;
    peak_val_i <= peak_tdata_i;
    peak_num_i <= num_peaks_i;
    new_peak_i <= 1'b1;
  end else if (dw_axis_tvalid_r)begin
    new_peak_i <= 1'b0;
  end
end

always @(posedge clk_245) begin
  if (clk_245_rst) begin
    new_peak_q <= 1'b0;
  end else if (peak_tlast_q & peak_tvalid_q) begin
    peak_result_q <= peak_index_q;
    peak_val_q <= peak_tdata_q;
    peak_num_q <= num_peaks_q;
    new_peak_q <= 1'b1;
  end else if (dw_axis_tvalid_r)begin
    new_peak_q <= 1'b0;
  end
end

always @(posedge clk_245) begin
  if (clk_245_rst) begin
    dw_axis_tvalid_r <= 1'b0;
    dw_axis_tlast_r <= 1'b0;
  end else if(new_peak_i & new_peak_q & !dw_axis_tvalid_r)begin
    dw_axis_tvalid_r <= 1'b1;
    dw_axis_tlast_r <= 1'b1;
  end else if (dw_axis_tready)begin
    dw_axis_tvalid_r <= 1'b0;
    dw_axis_tlast_r <= 1'b0;
  end
end

assign dw_axis_tdata = {peak_num_i,peak_num_q,peak_val_i,peak_val_q,peak_result_i,peak_result_q};
assign dw_axis_tvalid = dw_axis_tvalid_r;
assign dw_axis_tlast = dw_axis_tlast_r;
//c_mag_estimate#(
//    .DATA_LEN(32),
//    .ALPHA(0.9),
//    .BETA(0.4)
//)
// abs_i (
//    .clk(clk_245),
//    .dataI(m_fft_axis_tdata[31:0]),
//    .dataQ(m_fft_axis_tdata[63:32]),
//    .dataMag(mag_i_axis_tdata)
//);

//c_mag_estimate#(
//    .DATA_LEN(32),
//    .ALPHA(0.9),
//    .BETA(0.4)
//)
// abs_q (
//    .clk(clk_245),
//    .dataI(m_fft_axis_tdata[95:64]),
//    .dataQ(m_fft_axis_tdata[127:96]),
//    .dataMag(mag_q_axis_tdata)
//);

//assign m_fft_axis_tdata = {32'h80000000,32'h80000000,32'hefffffff,32'hefffffff};

fft_dsp #(
  .FFT_LEN(FFT_LEN),
  .FFT_CHANNELS(1),
  .FFT_AXI_DATA_WIDTH (64)
  )
  fft_dsp_i(

  .aclk (clk_245),
  .aresetn (!clk_245_rst),

 .s_axis_tdata(s_fft_i_axis_tdata),
 .s_axis_tvalid (s_fft_i_axis_tvalid),
 .s_axis_tlast(s_fft_i_axis_tlast),
 .s_axis_tready(s_fft_i_axis_tready),

.m_axis_tdata(m_fft_i_axis_tdata),
.m_axis_tvalid(m_fft_i_axis_tvalid),
.m_axis_tlast(m_fft_i_axis_tlast),
.m_axis_tready(m_fft_i_axis_tready),

.m_index(m_fft_i_index),

   .chirp_ready                         (chirp_ready),
   .chirp_done                          (chirp_done),
   .chirp_active                        (chirp_active),
   .chirp_init                          (chirp_init),
   .chirp_enable                        (chirp_enable),
   .adc_enable                          (adc_enable)

);

fft_dsp #(
  .FFT_LEN(8192),
  .FFT_CHANNELS(1),
  .FFT_AXI_DATA_WIDTH (64)
  )
  fft_dsp_q(

  .aclk (clk_245),
  .aresetn (!clk_245_rst),

 .s_axis_tdata(s_fft_q_axis_tdata),
 .s_axis_tvalid (s_fft_q_axis_tvalid),
 .s_axis_tlast(s_fft_q_axis_tlast),
 .s_axis_tready(s_fft_q_axis_tready),

.m_axis_tdata(m_fft_q_axis_tdata),
.m_axis_tvalid(m_fft_q_axis_tvalid),
.m_axis_tlast(m_fft_q_axis_tlast),
.m_axis_tready(m_fft_q_axis_tready),

.m_index(m_fft_q_index),

   .chirp_ready                         (chirp_ready),
   .chirp_done                          (chirp_done),
   .chirp_active                        (chirp_active),
   .chirp_init                          (chirp_init),
   .chirp_enable                        (chirp_enable),
   .adc_enable                          (adc_enable)

);

//assign chirp_ready_sig = chirp_ready;
//assign chirp_done_sig = chirp_done;
//assign chirp_active_sig = chirp_active;
//assign chirp_init_sig = chirp_init;
//assign chirp_enable_sig = chirp_enable;
//assign adc_enable_sig = adc_enable;




   endmodule
