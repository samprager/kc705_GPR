//------------------------------------------------------------------------------
// File       : kc705_ethernet_rgmii_basic_pat_gen.v
// Author     : Xilinx Inc.
// -----------------------------------------------------------------------------
// (c) Copyright 2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// -----------------------------------------------------------------------------
// Description:  This module allows either a user side loopback, with address swapping,
// OR the generation of simple packets.  The selection being controlled by a top level input
// which can be sourced fdrom a DIP switch in hardware.
// The packet generation is controlled by simple parameters giving the ability to set the DA,
// SA amd max/min size packets.  The data portion of each packet is always a simple
// incrementing pattern.
// When configured to loopback the first 12 bytes of the packet are accepted and then the
// packet is output with/without address swapping.  Currently, this is hard wired in the address
// swap logic.
//
//
//------------------------------------------------------------------------------

`timescale 1 ps/1 ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module kc705_ethernet_rgmii_basic_pat_gen #(
 //   parameter                            DEST_ADDR       = 48'hda0102030405,
    parameter                            DEST_ADDR       = 48'h985aebdb066f,
    parameter                            SRC_ADDR        = 48'h5a0102030405,
    parameter                            MAX_SIZE        = 16'd500,
 //   parameter                            MIN_SIZE        = 16'd64,
    parameter                            MIN_SIZE        = 16'd500,
    parameter                            ENABLE_VLAN     = 1'b0,
    parameter                            VLAN_ID         = 12'd2,
    parameter                            VLAN_PRIORITY   = 3'd2
)(
    input                                axi_tclk,
    input                                axi_tresetn,
    input                                check_resetn,

    input                                enable_pat_gen,
    input                                enable_pat_chk,
    input                                enable_address_swap,
    input       [1:0]                    speed,

    // data from the RX data path
    input       [7:0]                    rx_axis_tdata,
    input                                rx_axis_tvalid,
    input                                rx_axis_tlast,
    input                                rx_axis_tuser,
    output                               rx_axis_tready,
    // data TO the TX data path
    output      [7:0]                    tx_axis_tdata,
    output                               tx_axis_tvalid,
    output                               tx_axis_tlast,
    input                                tx_axis_tready,

    // data from ADC Data fifo
    input                                enable_adc_pkt,
    input       [7:0]                    adc_axis_tdata,
    input                                adc_axis_tvalid,
    input                                adc_axis_tlast,
    input                                adc_axis_tuser,
    output                               adc_axis_tready,

    output                               frame_error,
    output                               activity_flash
);

wire     [7:0]       rx_axis_tdata_int;
wire                 rx_axis_tvalid_int;
wire                 rx_axis_tlast_int;
wire                 rx_axis_tready_int;

wire     [7:0]       tx_axis_tdata_int;
wire                 tx_axis_tvalid_int;
wire                 tx_axis_tlast_int;
wire                 tx_axis_tready_int;

wire     [7:0]       pat_gen_tdata;
wire                 pat_gen_tvalid;
wire                 pat_gen_tlast;
wire                 pat_gen_tready;
wire                 pat_gen_tready_int;

wire     [7:0]       adc_pkt_tdata;
wire                 adc_pkt_tvalid;
wire                 adc_pkt_tlast;
wire                 adc_pkt_tready;
wire                 adc_pkt_tready_int;

wire     [7:0]       mux1_tdata;
wire                 mux1_tvalid;
wire                 mux1_tlast;
wire                 mux1_tready;

//wire     [7:0]       mux2_tdata;
//wire                 mux2_tvalid;
//wire                 mux2_tlast;
//wire                 mux2_tready;

wire     [7:0]       tx_axis_as_tdata;
wire                 tx_axis_as_tvalid;
wire                 tx_axis_as_tlast;
wire                 tx_axis_as_tready;

wire       [7:0]                    adc_axis_tdata_ila;
wire                                adc_axis_tvalid_ila;
wire                                adc_axis_tlast_ila;
wire                                adc_axis_tuser_ila;
wire                               adc_axis_tready_ila;

wire     [7:0]       adc_pkt_tdata_ila;
wire                 adc_pkt_tvalid_ila;
wire                 adc_pkt_tlast_ila;
wire                 adc_pkt_tready_ila;

//   assign tx_axis_tdata = tx_axis_as_tdata;
//   assign tx_axis_tvalid = tx_axis_as_tvalid;
//   assign tx_axis_tlast = tx_axis_as_tlast;
//   assign tx_axis_as_tready = tx_axis_tready;
   assign tx_axis_tdata = tx_axis_tdata_int;
   assign tx_axis_tvalid = tx_axis_tvalid_int;
   assign tx_axis_tlast = tx_axis_tlast_int;
   assign tx_axis_tready_int = tx_axis_tready;

   assign pat_gen_tready = pat_gen_tready_int;

   assign adc_pkt_tready = adc_pkt_tready_int;

kc705_ethernet_rgmii_axi_packetizer #(
   .DEST_ADDR                 (DEST_ADDR),
   .SRC_ADDR                  (SRC_ADDR),
   .MAX_SIZE                  (MAX_SIZE),
   .MIN_SIZE                  (MIN_SIZE),
   .ENABLE_VLAN               (ENABLE_VLAN),
   .VLAN_ID                   (VLAN_ID),
   .VLAN_PRIORITY             (VLAN_PRIORITY)
) axi_packetizer_inst (
   .axi_tclk                  (axi_tclk),
   .axi_tresetn               (axi_tresetn),

   .enable_adc_pkt            (enable_adc_pkt),
   .speed                     (speed),

    // data from ADC Data fifo
    .adc_axis_tdata           (adc_axis_tdata),
    .adc_axis_tvalid          (adc_axis_tvalid),
    .adc_axis_tlast           (adc_axis_tlast),
    .adc_axis_tuser           (adc_axis_tuser),
    .adc_axis_tready          (adc_axis_tready),

   .tdata                     (adc_pkt_tdata),
   .tvalid                    (adc_pkt_tvalid),
   .tlast                     (adc_pkt_tlast),
   .tready                    (adc_pkt_tready)
);

packetizer_ila packetizer_ila_inst (
    .clk  (axi_tclk),
    .probe0         (adc_axis_tdata_ila),
    .probe1          (adc_axis_tvalid_ila),
    .probe2           (adc_axis_tlast_ila),
    .probe3           (adc_axis_tuser_ila),
    .probe4          (adc_axis_tready_ila),

   .probe5                     (adc_pkt_tdata_ila),
   .probe6                    (adc_pkt_tvalid_ila),
   .probe7                     (adc_pkt_tlast_ila),
   .probe8                    (adc_pkt_tready_ila),
   
    .probe9         (tx_axis_tdata_int),
     .probe10       (tx_axis_tvalid_int),
     .probe11        (tx_axis_tlast_int),
     .probe12       (tx_axis_tready_int),
     
       .probe13         (mux1_tdata),
      .probe14       (mux1_tvalid),
      .probe15        (mux1_tlast),
      .probe16       (mux1_tready),
      
     .probe17         (rx_axis_tdata),
     .probe18       (rx_axis_tvalid),
     .probe19        (rx_axis_tlast),
     .probe20       (rx_axis_tready)
);

assign  adc_axis_tdata_ila = adc_axis_tdata;
assign  adc_axis_tvalid_ila = adc_axis_tvalid;
assign  adc_axis_tlast_ila = adc_axis_tlast;
assign  adc_axis_tuser_ila =adc_axis_tuser;
assign  adc_axis_tready_ila = adc_axis_tready;

assign  adc_pkt_tdata_ila = adc_pkt_tdata;
assign  adc_pkt_tvalid_ila = adc_pkt_tvalid;
assign  adc_pkt_tlast_ila = adc_pkt_tlast;
assign  adc_pkt_tready_ila = adc_pkt_tready;

// basic packet generator - this has parametisable
// DA and SA fields but the LT and data will be auto-generated
// based on the min/max size parameters - these can be set
// to the same value to obtain a specific packet size or will
// increment from the lower packet size to the upper
kc705_ethernet_rgmii_axi_pat_gen #(
   .DEST_ADDR                 (DEST_ADDR),
   .SRC_ADDR                  (SRC_ADDR),
   .MAX_SIZE                  (MAX_SIZE),
   .MIN_SIZE                  (MIN_SIZE),
   .ENABLE_VLAN               (ENABLE_VLAN),
   .VLAN_ID                   (VLAN_ID),
   .VLAN_PRIORITY             (VLAN_PRIORITY)
) axi_pat_gen_inst (
   .axi_tclk                  (axi_tclk),
   .axi_tresetn               (axi_tresetn),

   .enable_pat_gen            (enable_pat_gen),
   .speed                     (speed),

   .tdata                     (pat_gen_tdata),
   .tvalid                    (pat_gen_tvalid),
   .tlast                     (pat_gen_tlast),
   .tready                    (pat_gen_tready)
);

kc705_ethernet_rgmii_axi_pat_check #(
   .DEST_ADDR                 (DEST_ADDR),
   .SRC_ADDR                  (SRC_ADDR),
   .MAX_SIZE                  (MAX_SIZE),
   .MIN_SIZE                  (MIN_SIZE),
   .ENABLE_VLAN               (ENABLE_VLAN),
   .VLAN_ID                   (VLAN_ID),
   .VLAN_PRIORITY             (VLAN_PRIORITY)
) axi_pat_check_inst (
   .axi_tclk                  (axi_tclk),
   .axi_tresetn               (check_resetn),

   .enable_pat_chk            (enable_pat_chk),
   .speed                     (speed),

   .tdata                     (rx_axis_tdata),
   .tvalid                    (rx_axis_tvalid),
   .tlast                     (rx_axis_tlast),
   .tready                    (rx_axis_tready),
   .tuser                     (rx_axis_tuser),

   .frame_error               (frame_error),
   .activity_flash            (activity_flash)
);

// simple mux between the rx_fifo AXI interface and the pat gen output
// this is not registered as it is passed through a pipeline stage to limit the impact
kc705_ethernet_rgmii_axi_mux axi_mux_inst1(
   //.mux_select                (enable_pat_gen),
    .mux_select                (enable_adc_pkt),


//   .tdata0                    (rx_axis_tdata),
//   .tvalid0                   (rx_axis_tvalid),
//   .tlast0                    (rx_axis_tlast),
//   .tready0                   (rx_axis_tready),
    .tdata0                    (tx_axis_as_tdata),
    .tvalid0                   (tx_axis_as_tvalid),
    .tlast0                    (tx_axis_as_tlast),
    .tready0                   (tx_axis_as_tready),

//   .tdata1                    (pat_gen_tdata),
//   .tvalid1                   (pat_gen_tvalid),
//   .tlast1                    (pat_gen_tlast),
//   .tready1                   (pat_gen_tready_int),\
   .tdata1                     (adc_pkt_tdata),
    .tvalid1                   (adc_pkt_tvalid),
    .tlast1                    (adc_pkt_tlast),
    .tready1                   (adc_pkt_tready_int),    

   .tdata                     (mux1_tdata),
   .tvalid                    (mux1_tvalid),
   .tlast                     (mux1_tlast),
   .tready                    (mux1_tready)
);

// simple mux between the adc data output and loopback/generated output
// this is not registered as it is passed through a pipeline stage to limit the impact
//kc705_ethernet_rgmii_axi_mux axi_mux_inst2(
//   .mux_select                (enable_adc_pkt),

//   .tdata0                    (mux1_tdata),
//   .tvalid0                   (mux1_tvalid),
//   .tlast0                    (mux1_tlast),
//   .tready0                   (mux1_tready),

//   .tdata1                    (adc_pkt_tdata),
//   .tvalid1                   (adc_pkt_tvalid),
//   .tlast1                    (adc_pkt_tlast),
//   .tready1                   (adc_pkt_tready_int),

//   .tdata                     (mux2_tdata),
//   .tvalid                    (mux2_tvalid),
//   .tlast                     (mux2_tlast),
//   .tready                    (mux2_tready)
//);

// a pipeline stage has been added to reduce timing issues and allow
// a pattern generator to be muxed into the path
kc705_ethernet_rgmii_axi_pipe axi_pipe_inst (
   .axi_tclk                  (axi_tclk),
   .axi_tresetn               (axi_tresetn),

   .rx_axis_fifo_tdata_in     (mux1_tdata),
   .rx_axis_fifo_tvalid_in    (mux1_tvalid),
   .rx_axis_fifo_tlast_in     (mux1_tlast),
   .rx_axis_fifo_tready_in    (mux1_tready),

//   .rx_axis_fifo_tdata_out    (rx_axis_tdata_int),
//   .rx_axis_fifo_tvalid_out   (rx_axis_tvalid_int),
//   .rx_axis_fifo_tlast_out    (rx_axis_tlast_int),
//   .rx_axis_fifo_tready_out   (rx_axis_tready_int)
   .rx_axis_fifo_tdata_out    (tx_axis_tdata_int),
   .rx_axis_fifo_tvalid_out   (tx_axis_tvalid_int),
   .rx_axis_fifo_tlast_out    (tx_axis_tlast_int),
   .rx_axis_fifo_tready_out   (tx_axis_tready_int)

);

// address swap module: based around a Dual port distributed ram
// data is written in and the read only starts once the da/sa have been
// stored.  Can cope with a gap of one cycle between packets.
kc705_ethernet_rgmii_address_swap address_swap_inst (
   .axi_tclk                  (axi_tclk),
   .axi_tresetn               (axi_tresetn),

   .enable_address_swap       (enable_address_swap),

//   .rx_axis_fifo_tdata        (rx_axis_tdata_int),
//   .rx_axis_fifo_tvalid       (rx_axis_tvalid_int),
//   .rx_axis_fifo_tlast        (rx_axis_tlast_int),
//   .rx_axis_fifo_tready       (rx_axis_tready_int),
   .rx_axis_fifo_tdata        (rx_axis_tdata),
   .rx_axis_fifo_tvalid       (rx_axis_tvalid),
   .rx_axis_fifo_tlast        (rx_axis_tlast),
   .rx_axis_fifo_tready       (rx_axis_tready),

   .tx_axis_fifo_tdata        (tx_axis_as_tdata),
   .tx_axis_fifo_tvalid       (tx_axis_as_tvalid),
   .tx_axis_fifo_tlast        (tx_axis_as_tlast),
   .tx_axis_fifo_tready       (tx_axis_as_tready)
);


endmodule
