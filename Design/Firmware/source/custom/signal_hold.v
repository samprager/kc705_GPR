//////////////////////////////////////////////////////////////////////////////////
// Company: MiXIL
// Engineer: Samuel Prager
//
// Create Date: 07/11/2016 02:25:19 PM
// Design Name:
// Module Name: signal_hold
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
`timescale 1ps / 1ps

module signal_hold #
(
   parameter HOLD_CLOCKS = 2,
   parameter DATA_WIDTH = 1
)
(
   input       [DATA_WIDTH-1:0] data_in,
   input                        clk,
   output wire [DATA_WIDTH-1:0] data_out
);
localparam HOLD_COUNT = (HOLD_CLOCKS > 1) ? (HOLD_CLOCKS-1): 0; 

localparam CTR_WIDTH = (HOLD_COUNT < 2)? 1:
                       ((HOLD_COUNT < 4)? 2:
                       ((HOLD_COUNT < 256)? 8:
                       32));                     
                        
reg [DATA_WIDTH-1:0] data_r, data_rr;
reg [CTR_WIDTH-1:0] counter = 0;

// Register twice for metastability
always @(posedge clk)
begin
  data_r <= data_in;
end

always @(posedge clk)
begin
  if (|counter)
    counter <= counter -1;
  else if (data_r != data_in)
    counter <= HOLD_COUNT;
  else
    counter <= 0;
end

always @(posedge clk)
begin
  if (|counter)
    data_rr <= data_rr;
  else
    data_rr <= data_in;
end


assign data_out = data_rr;

endmodule
