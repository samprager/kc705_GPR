// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.2 (win64) Build 932637 Wed Jun 11 13:33:10 MDT 2014
// Date        : Fri Jun 17 11:24:27 2016
// Host        : radar-PC running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               D:/UndergroundRadar/kc705_dds_mig/k7dsp_dds_mig.srcs/sources_1/ip/ila_axis_vfifo/ila_axis_vfifo_stub.v
// Design      : ila_axis_vfifo
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2014.2" *)
module ila_axis_vfifo(clk, probe0, probe1, probe2, probe3, probe4, probe5, probe6, probe7, probe8, probe9, probe10, probe11, probe12, probe13, probe14, probe15, probe16, probe17, probe18, probe19)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[1:0],probe1[511:0],probe2[63:0],probe3[63:0],probe4[0:0],probe5[0:0],probe6[0:0],probe7[0:0],probe8[0:0],probe9[511:0],probe10[63:0],probe11[63:0],probe12[0:0],probe13[0:0],probe14[0:0],probe15[0:0],probe16[0:0],probe17[1:0],probe18[1:0],probe19[1:0]" */;
  input clk;
  input [1:0]probe0;
  input [511:0]probe1;
  input [63:0]probe2;
  input [63:0]probe3;
  input [0:0]probe4;
  input [0:0]probe5;
  input [0:0]probe6;
  input [0:0]probe7;
  input [0:0]probe8;
  input [511:0]probe9;
  input [63:0]probe10;
  input [63:0]probe11;
  input [0:0]probe12;
  input [0:0]probe13;
  input [0:0]probe14;
  input [0:0]probe15;
  input [0:0]probe16;
  input [1:0]probe17;
  input [1:0]probe18;
  input [1:0]probe19;
endmodule
