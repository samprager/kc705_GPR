
//////////////////////////////////////////////////////////////////////////////////
// Company: MiXIL
// Engineer: Samuel Prager
//
// Create Date: 06/22/2016 02:25:19 PM
// Design Name:
// Module Name: reg_map_cmd_gen
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

`timescale 1 ps/1 ps


// -----------------------
// -- Module Definition --
// -----------------------

module reg_map_cmd_gen # (
parameter REG_ADDR_WIDTH                            = 8,
parameter CORE_DATA_WIDTH                           = 32,
parameter CORE_BE_WIDTH                             = CORE_DATA_WIDTH/8,

parameter ADC_CLK_FREQ                              = 245.7
)
(

  input                               aclk,
  input                               aresetn,

  input [7:0]                gpio_dip_sw,

  output                     reg_map_wr_cmd,
  output [7:0]               reg_map_wr_addr,
  output [31:0]              reg_map_wr_data,
  output [31:0]              reg_map_wr_keep,
  input                      reg_map_wr_valid,
  input                      reg_map_wr_ready,
  input [1:0]                reg_map_wr_err

);

reg [3:0] gpio_dip_sw_r;
reg [3:0] gpio_dip_sw_rr;
reg [3:0] gpio_dip_sw_rrr;
reg [3:0] dip_sw_chng = 4'b0;
reg [3:0] dip_sw_chng_r = 4'b0;
reg [15:0] dip_sw_debounce_ctr [3:0];

reg                  reg_map_wr_cmd_r;
reg                  reg_map_wr_cmd_rr;
reg [7:0]           reg_map_wr_addr_r;
reg [31:0]           reg_map_wr_data_r;
reg [31:0]           reg_map_wr_keep_r;

integer i;


always @(posedge aclk) begin
    gpio_dip_sw_r <= gpio_dip_sw;
end

always @(posedge aclk) begin
  if (~aresetn)
    dip_sw_chng <= 4'b0;
  else
    dip_sw_chng <= gpio_dip_sw_r ^ gpio_dip_sw;
end


// debounce switches
always @(posedge aclk) begin
  if (~aresetn)
    gpio_dip_sw_rr <= gpio_dip_sw;
  else begin
    for (i=0;i<4;i=i+1)begin
        if (&dip_sw_debounce_ctr[i])
             gpio_dip_sw_rr[i] <= gpio_dip_sw_r[i];
    end
  end
end

always @(posedge aclk) begin
  for (i=0;i<4;i=i+1)begin
    if (~aresetn)
        dip_sw_debounce_ctr[i] <= 16'hffff;
    else if (dip_sw_chng[i])
        dip_sw_debounce_ctr[i] <= 16'b0;
     else if (!(&dip_sw_debounce_ctr[i] ))
        dip_sw_debounce_ctr[i] <= dip_sw_debounce_ctr[i]+1'b1;
   end
end

always @(posedge aclk) begin
  if (~aresetn)
    dip_sw_chng_r <= 4'b0;
  else
    dip_sw_chng_r <= gpio_dip_sw_rrr ^ gpio_dip_sw_rr;
end

always @(posedge aclk) begin
  if (~aresetn)
    gpio_dip_sw_rrr <= gpio_dip_sw;
  else
    gpio_dip_sw_rrr <= gpio_dip_sw_rr;
end


always @(posedge  aclk) begin
   if (~aresetn) begin
       reg_map_wr_cmd_r <= 1'b0;
   end else begin
       if (reg_map_wr_ready & !reg_map_wr_cmd_r & |dip_sw_chng_r[3:0]) begin
           reg_map_wr_cmd_r <= 1'b1;
      end else begin
           reg_map_wr_cmd_r <= 1'b0;
       end
   end
end

always @(posedge  aclk) begin
   if (~aresetn)
      reg_map_wr_cmd_rr <= 1'b0;
   else
       reg_map_wr_cmd_rr <= reg_map_wr_cmd_r;
end

always @(posedge  aclk) begin
  if (~aresetn) begin
      reg_map_wr_addr_r <= 8'b0;
      reg_map_wr_data_r <= 32'b0;
      reg_map_wr_keep_r <= 32'b0;
  end else begin
      // mac speed changed
      if (reg_map_wr_ready & !reg_map_wr_cmd_r & dip_sw_chng_r[0]) begin
          reg_map_wr_addr_r <= 8'h23;
          reg_map_wr_data_r[1:0] <= {gpio_dip_sw_rr[0],~gpio_dip_sw_rr[0]};
          reg_map_wr_keep_r[1:0] <= 2'b11;
      // enable adc pkt changed
      end else if (reg_map_wr_ready & !reg_map_wr_cmd_r & dip_sw_chng_r[1]) begin
        reg_map_wr_addr_r <= 8'h20;
        reg_map_wr_data_r[0] <= gpio_dip_sw_rr[1];
        reg_map_wr_keep_r[0] <= 1'b1;
      // chirp mode changed
      end else if (reg_map_wr_ready & !reg_map_wr_cmd_r & dip_sw_chng_r[2]) begin
      // fast chirp
        reg_map_wr_addr_r <= 8'h00;
        reg_map_wr_keep_r <= 32'hffffffff;
        if (gpio_dip_sw_rr[2]) begin
          reg_map_wr_data_r <= 32'd1;     // 1 sec
      // slow chirp
        end else begin
          reg_map_wr_data_r <= 32'd10;    //10 sec
        end
      // ddc_duc_bypass cahnged
      end else if (reg_map_wr_ready & !reg_map_wr_cmd_r & dip_sw_chng_r[3]) begin
        reg_map_wr_addr_r <= 8'h10;
        reg_map_wr_data_r[0] <= gpio_dip_sw_rr[3];
        reg_map_wr_keep_r[0] <= 1'b1;
      end
  end
end

assign reg_map_wr_cmd = reg_map_wr_cmd_r;
assign reg_map_wr_addr = reg_map_wr_addr_r;
assign reg_map_wr_data = reg_map_wr_data_r;
assign reg_map_wr_keep = reg_map_wr_keep_r;


endmodule
