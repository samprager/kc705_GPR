`timescale 1ps/1ps

module fft_dsp #
  (
     parameter FFT_LEN = 8192,
     parameter FFT_CHANNELS = 2,
     parameter FFT_AXI_DATA_WIDTH = 32,
     parameter FFT_AXI_TID_WIDTH = 1,
     parameter FFT_AXI_TDEST_WIDTH = 1,
     parameter FFT_AXI_TUSER_WIDTH = 1,
     parameter FFT_AXI_STREAM_ID = 1'b0,
     parameter FFT_AXI_STREAM_DEST = 1'b0,
     parameter FFT_INDEX_LEN = 32

   )
  (

   input    aclk, // AXI input clock
   input    aresetn, // Active low AXI reset signal
     // : in    std_logic; -- CPU RST button, SW7 on KC705
 // input sysclk_p,        // : in    std_logic;
 // input sysclk_n,        // : in    std_logic;
   // --ADC Data Out Signals
  input [FFT_CHANNELS*FFT_AXI_DATA_WIDTH-1:0]     s_axis_tdata,
  input s_axis_tvalid,
  input s_axis_tlast,
  output s_axis_tready,

  output [FFT_CHANNELS*FFT_AXI_DATA_WIDTH-1:0]     m_axis_tdata,
  output m_axis_tvalid,
  output m_axis_tlast,
  input m_axis_tready,

  output[FFT_INDEX_LEN-1:0] m_index,

  input chirp_ready,
  input chirp_done,
  input chirp_active,
  input  chirp_init,
  input  chirp_enable,
  input  adc_enable


   );
localparam NEED_SCALING = 0;

localparam CONFIG_LATENCY = 16;
localparam LOG_2_FFT_LEN = clogb2(FFT_LEN);
localparam SCH_SIZE_DIV = ceildiv(LOG_2_FFT_LEN,2);
localparam SCH_SIZE = 2*SCH_SIZE_DIV;

localparam CONFIG_DATA_SIZE = (NEED_SCALING==1) ? 24: 16;       //24;

localparam     IDLE        = 3'b000,
               CONFIG      = 3'b001,
               WR_DATA    = 3'b010,
               ZP_DATA    = 3'b011,
               RD_DATA    = 3'b100;


function integer clogb2 (input integer size);
    begin
      size = size - 1;
      for (clogb2=1; size>1; clogb2=clogb2+1)
        size = size >> 1;
    end
endfunction // clogb2

function integer ceildiv (input integer x,y);
    begin
      if (x == 0)
        ceildiv = 0;
      else
        ceildiv = 1+(x-1)/y;
    end
endfunction // ceildiv


reg [2:0] next_gen_state;
reg [2:0] gen_state;


wire [CONFIG_DATA_SIZE-1 : 0] s_axis_fft_config_tdata;
 wire s_axis_fft_config_tvalid;
 wire s_axis_fft_config_tready;
 wire [FFT_CHANNELS*FFT_AXI_DATA_WIDTH-1 : 0] s_axis_fft_data_tdata;
 wire s_axis_fft_data_tvalid;
 wire s_axis_fft_data_tready;
 wire s_axis_fft_data_tlast;
 wire [FFT_CHANNELS*FFT_AXI_DATA_WIDTH-1 : 0] m_axis_fft_data_tdata;
 wire m_axis_fft_data_tvalid;
 wire m_axis_fft_data_tready;
 wire m_axis_fft_data_tlast;
 wire [FFT_CHANNELS*8-1:0] m_axis_fft_data_tuser;
 wire fft_event_frame_started;
 wire fft_event_tlast_unexpected;
 wire fft_event_tlast_missing;
 wire fft_event_status_channel_halt;
 wire fft_event_data_in_channel_halt;
 wire fft_event_data_out_channel_halt;
wire [FFT_CHANNELS*8-1 : 0] m_axis_fft_status_tdata;
wire m_axis_fft_status_tvalid;
wire m_axis_fft_status_tready;

 reg [CONFIG_DATA_SIZE-1 : 0] s_axis_fft_config_tdata_r;
 reg s_axis_fft_config_tvalid_r;
 reg [FFT_CHANNELS*FFT_AXI_DATA_WIDTH-1 : 0] s_axis_fft_data_tdata_r;
 reg s_axis_fft_data_tvalid_r;
 reg s_axis_fft_data_tlast_r;

 reg [31:0] fft_len_counter;
 reg [7:0] config_wait_counter;
 reg [FFT_INDEX_LEN-1:0] m_index_r;

 wire fwd_inv;
 wire [SCH_SIZE-1:0] scale_sch;
 wire [4:0] nfft;

 assign fwd_inv = 1'b1;
 assign scale_sch = {2'b01,{(SCH_SIZE_DIV-1){2'b10}}};
 assign nfft = LOG_2_FFT_LEN;

always @(posedge aclk) begin
 if (!aresetn)
    fft_len_counter <= 'b0;
else if(gen_state == CONFIG)
    fft_len_counter <= FFT_LEN-1;
else if ((gen_state == WR_DATA | gen_state == ZP_DATA)&(|fft_len_counter) & s_axis_fft_data_tvalid & s_axis_fft_data_tready)
    fft_len_counter <= fft_len_counter-1;
end


always @(posedge aclk)begin
    if(!aresetn) begin
        config_wait_counter <= 0;
    end
    else if (gen_state == CONFIG & ((s_axis_fft_config_tvalid & s_axis_fft_config_tready) | (|config_wait_counter))) begin
        config_wait_counter <= config_wait_counter+1;
    end
    else begin
        config_wait_counter <= 0;
    end
end

always @(posedge aclk) begin
 if (!aresetn)
    s_axis_fft_config_tvalid_r <= 'b0;
else if(gen_state == CONFIG & !(s_axis_fft_config_tvalid & s_axis_fft_config_tready)&!(|config_wait_counter))
    s_axis_fft_config_tvalid_r <= 1'b1;
else
    s_axis_fft_config_tvalid_r <= 'b0;
end
assign s_axis_fft_config_tvalid = s_axis_fft_config_tvalid_r;

always @(posedge aclk) begin
 if (!aresetn)
    s_axis_fft_config_tdata_r <= 'b0;
else if(gen_state == CONFIG & s_axis_fft_config_tready) begin
    //s_axis_fft_config_tdata_r[8+SCH_SIZE-:SCH_SIZE] <= scale_sch;
    s_axis_fft_config_tdata_r[9:9] <= fwd_inv;
    s_axis_fft_config_tdata_r[8:8] <= fwd_inv;
    s_axis_fft_config_tdata_r[4:0] <= nfft;
    end
end
assign s_axis_fft_config_tdata = s_axis_fft_config_tdata_r; // {pad,scale_sh,fwd/inv,pad,cp_len,pad,nfft}

assign s_axis_tready = s_axis_fft_data_tready;

always @(posedge aclk) begin
 if (!aresetn)
    s_axis_fft_data_tvalid_r <= 'b0;
else if(gen_state == WR_DATA & s_axis_tvalid)
    s_axis_fft_data_tvalid_r <= 1'b1;
else if(gen_state == ZP_DATA)
    s_axis_fft_data_tvalid_r <= 1'b1;
else if(s_axis_fft_data_tready)
    s_axis_fft_data_tvalid_r <= 'b0;
end
assign s_axis_fft_data_tvalid = s_axis_fft_data_tvalid_r;

always @(posedge aclk) begin
 if (!aresetn)
    s_axis_fft_data_tlast_r <= 'b0;
else if((gen_state == WR_DATA | gen_state == ZP_DATA) & (fft_len_counter == 32'b1))
    s_axis_fft_data_tlast_r <= 1'b1;
else if(s_axis_fft_data_tready)
    s_axis_fft_data_tlast_r <= 1'b0;
end
assign s_axis_fft_data_tlast = s_axis_fft_data_tlast_r;

always @(posedge aclk) begin
     if (!aresetn)
        s_axis_fft_data_tdata_r <= 'b0;
    else if(gen_state == WR_DATA & s_axis_tvalid & s_axis_fft_data_tready) begin
//        s_axis_fft_data_tdata_r[15:0] <= {{8{s_axis_tdata[15]}},s_axis_tdata[15:8]};
//        s_axis_fft_data_tdata_r[31:16] <= 16'b0;
            s_axis_fft_data_tdata_r <= s_axis_tdata;
    end
    else if(gen_state == ZP_DATA & s_axis_fft_data_tready & s_axis_fft_data_tvalid)
        s_axis_fft_data_tdata_r <= 'b0;
end
assign s_axis_fft_data_tdata = s_axis_fft_data_tdata_r;

always @(gen_state or chirp_init or chirp_ready or fft_len_counter or s_axis_fft_config_tvalid or s_axis_fft_config_tready or s_axis_fft_data_tready or s_axis_fft_data_tlast or m_axis_fft_data_tlast or m_axis_fft_data_tready or s_axis_tlast or config_wait_counter)
begin
   next_gen_state = gen_state;
   case (gen_state)
      IDLE : begin
        if (chirp_init & chirp_ready)
            next_gen_state = CONFIG;
      end
      CONFIG : begin
        //if (s_axis_fft_config_tvalid & s_axis_fft_config_tready)
        if (config_wait_counter>=(CONFIG_LATENCY-1))
            next_gen_state = WR_DATA;
      end
      WR_DATA : begin
         if (fft_len_counter==1)
            next_gen_state = RD_DATA;
         else if (s_axis_tlast & s_axis_fft_data_tready)
            next_gen_state = ZP_DATA;
      end
      ZP_DATA : begin
         //if (s_axis_fft_data_tready & s_axis_fft_data_tlast)
         if (fft_len_counter==1)
            next_gen_state = RD_DATA;
      end
      RD_DATA : begin
        if (m_axis_fft_data_tlast & m_axis_fft_data_tready)
            next_gen_state = IDLE;
      end
      default : begin
         next_gen_state = IDLE;
      end
   endcase
end

always @(posedge aclk)
begin
   if (!aresetn) begin
      gen_state <= IDLE;
   end
   else begin
      gen_state <= next_gen_state;
   end
end

always @(posedge aclk)
begin
   if (!aresetn) begin
      m_index_r <= 'b0;
   end
   else if (gen_state == IDLE) begin
      m_index_r <= 'b0;
   end
   else if ((gen_state == RD_DATA) & m_axis_tvalid & m_axis_tready) begin
    m_index_r <= m_index_r + 1'b1;
  end
end

 assign m_axis_tdata = m_axis_fft_data_tdata;
 assign m_axis_tvalid = m_axis_fft_data_tvalid;
 assign m_axis_tlast = m_axis_fft_data_tlast;
 assign m_axis_fft_data_tready = m_axis_tready;

 assign m_index = m_index_r;

 assign m_axis_fft_status_tready = 1'b1;

xfft_0 xfft_0_inst (
  .aclk(aclk),                                              // input wire aclk
.aresetn(aresetn),                                        // input wire aresetn
.s_axis_config_tdata(s_axis_fft_config_tdata),                // input wire [15:0] (block) [23 : 0] s_axis_config_tdata
.s_axis_config_tvalid(s_axis_fft_config_tvalid),              // input wire s_axis_config_tvalid
.s_axis_config_tready(s_axis_fft_config_tready),              // output wire s_axis_config_tready
.s_axis_data_tdata(s_axis_fft_data_tdata),                    // input wire [31 : 0] s_axis_data_tdata
.s_axis_data_tvalid(s_axis_fft_data_tvalid),                  // input wire s_axis_data_tvalid
.s_axis_data_tready(s_axis_fft_data_tready),                  // output wire s_axis_data_tready
.s_axis_data_tlast(s_axis_fft_data_tlast),                    // input wire s_axis_data_tlast
.m_axis_data_tdata(m_axis_fft_data_tdata),                    // output wire [31 : 0] m_axis_data_tdata
.m_axis_data_tvalid(m_axis_fft_data_tvalid),                  // output wire m_axis_data_tvalid
.m_axis_data_tready(m_axis_fft_data_tready),                    // input wire m_axis_data_tready
.m_axis_data_tlast(m_axis_fft_data_tlast),                    // output wire m_axis_data_tlast
.m_axis_data_tuser(m_axis_fft_data_tuser),                    // output wire m_axis_data_tuser
 .m_axis_status_tdata(m_axis_fft_status_tdata),                  // output wire [7 : 0] m_axis_status_tdata
 .m_axis_status_tvalid(m_axis_fft_status_tvalid),                // output wire m_axis_status_tvalid
 .m_axis_status_tready(m_axis_fft_status_tready),                // input wire m_axis_status_tready
 .event_frame_started(fft_event_frame_started),                  // output wire event_frame_started
 .event_tlast_unexpected(fft_event_tlast_unexpected),            // output wire event_tlast_unexpected
 .event_tlast_missing(fft_event_tlast_missing),                  // output wire event_tlast_missing
 .event_status_channel_halt(fft_event_status_channel_halt),      // output wire event_status_channel_halt
 .event_data_in_channel_halt(fft_event_data_in_channel_halt),    // output wire event_data_in_channel_halt
 .event_data_out_channel_halt(fft_event_data_out_channel_halt)  // output wire event_data_out_channel_halt
);


endmodule
