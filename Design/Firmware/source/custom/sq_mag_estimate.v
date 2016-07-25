`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Samuel Prager
//
// Create Date: 07/23/2016 03:43:49 AM
// Design Name:
// Module Name: c_mag_estimate
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


module sq_mag_estimate #(
    parameter DATA_LEN = 32,
    parameter DIV_OR_OVERFLOW = 0,      // (1): Divide output by 2, (0): use overflow bit
    parameter REGISTER_OUTPUT = 1
    )(
    input clk,
    input [DATA_LEN-1:0] dataI,
    input [DATA_LEN-1:0] dataQ,
    output[2*DATA_LEN-1:0] dataMagSq,
    output overflow
    );

    reg [2*DATA_LEN:0] dataMagSq_r;
    wire [2*DATA_LEN:0] dataMagSq_ext;
    wire [2*DATA_LEN-1:0] dataI_sq;
    wire [2*DATA_LEN-1:0] dataQ_sq;

  mult_gen_32b sq_i (
    .CLK(clk),  // input wire CLK
    .A(dataI),      // input wire [31 : 0] A
    .B(dataI),      // input wire [31 : 0] B
    .P(dataI_sq)      // output wire [63 : 0] P
  );
  mult_gen_32b sq_q (
    .CLK(clk),  // input wire CLK
    .A(dataQ),      // input wire [31 : 0] A
    .B(dataQ),      // input wire [31 : 0] B
    .P(dataQ_sq)      // output wire [63 : 0] P
  );

generate if(REGISTER_OUTPUT == 1) begin
  always @(posedge clk) begin
      dataMagSq_r <= dataI_sq + dataQ_sq;
  end
  assign dataMagSq_ext = dataMagSq_r;
end
else begin
  assign dataMagSq_ext = dataI_sq + dataQ_sq;
end
endgenerate

assign dataMagSq = (DIV_OR_OVERFLOW == 1) ? dataMagSq_ext[2*DATA_LEN:1] : dataMagSq_ext[2*DATA_LEN-1:0];
assign overflow = dataMagSq_ext[2*DATA_LEN];


endmodule
