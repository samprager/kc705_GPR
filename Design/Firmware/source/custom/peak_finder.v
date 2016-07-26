`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Samuel Prager
//
// Create Date: 07/23/2016 03:43:49 AM
// Design Name:
// Module Name: peak_finder
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


module peak_finder #(
    parameter DATA_LEN = 64,
    parameter FCLOCK = 245.76,
    parameter FFT_LEN = 8192,
    parameter CHIRP_BW = 61,     // Mhz
    parameter INIT_THRESHOLD = 64'h0000ffffffffffff
    )(
    input clk,
    input aresetn,
    input [DATA_LEN-1:0] tdata,
    input tvalid,
    input tlast,
    input [31:0] index,
    input [DATA_LEN-1:0] threshold,
    output [31:0] peak_index,
    output [DATA_LEN-1:0] peak_tdata,
    output peak_tvalid
    );

    reg [DATA_LEN-1:0] tdata_left;
    reg [DATA_LEN-1:0] tdata_mid;
    reg [31:0]  index_mid;
    reg [DATA_LEN-1:0] peak_tdata_r;
    reg                peak_tvalid_r;
    reg [DATA_LEN-1:0]  min_threshold;
    reg [31:0] peak_index_r;


always @(posedge clk) begin
if (tvalid) begin
  tdata_mid<=tdata;
  tdata_left<=tdata_mid;
  index_mid <= index;
  end
end

always @(posedge clk) begin
if(!aresetn)
  min_threshold <=INIT_THRESHOLD;
else if(tvalid & !(|index))
  min_threshold <= threshold;
end

always @(posedge clk) begin
if((tdata_mid >= tdata_left)&(tdata_mid >= tdata)&(tdata_mid> min_threshold)) begin
  peak_tdata_r <= tdata_mid;
  peak_tvalid_r <= 1'b1;
  peak_index_r <= index_mid;
end else begin
  peak_tdata_r <= 'b0;
  peak_tvalid_r <= 1'b0;
  peak_index_r <= 'b0;
end
end

always @(posedge clk) begin
  if(!(|index))
    min_threshold <= threshold;
end

assign peak_tdata = peak_tdata_r;
assign peak_tvalid = peak_tvalid_r;
assign peak_index = peak_index_r;


endmodule
