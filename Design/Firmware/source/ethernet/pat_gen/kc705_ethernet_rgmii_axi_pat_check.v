//------------------------------------------------------------------------------
// File       : kc705_ethernet_rgmii_axi_pat_check.v
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
// Description:  A simple pattern checker - expects the same data pattern as generated by the pat_gen
// with the same DA/SA order (it is expected that the frames will pass through 
// two address swap blocks).  the checker will first sync to the data and then
// identify any errors (this is a sticky output but the internal signal is
// per byte)
//
//------------------------------------------------------------------------------

`timescale 1 ps/1 ps

module kc705_ethernet_rgmii_axi_pat_check #(
   parameter               DEST_ADDR      = 48'hda0102030405,
   parameter               SRC_ADDR       = 48'h5a0102030405,
   parameter               MAX_SIZE       = 16'd500,
   parameter               MIN_SIZE       = 16'd64,
   parameter               ENABLE_VLAN    = 1'b0,
   parameter               VLAN_ID        = 12'd2,
   parameter               VLAN_PRIORITY  = 3'd2

)(
   input                   axi_tclk,
   input                   axi_tresetn,

   input                   enable_pat_chk,
   input       [1:0]       speed,

   input       [7:0]       tdata,
   input                   tvalid,
   input                   tlast,
   input                   tready,
   input                   tuser,
   
   output                  frame_error,
   output                  activity_flash
);

localparam  IDLE  = 2'b00,
            INFO  = 2'b01,
            LOOK  = 2'b10,
            PKT   = 2'b11;

// work out the adjustment required to get the right packet size.               
localparam     PKT_ADJUST  = (ENABLE_VLAN) ? 22 : 18;

// generate the vlan fields
localparam     VLAN_HEADER = {8'h81, 8'h00, VLAN_PRIORITY, 1'b0, VLAN_ID};

// generate the require header count compare
localparam     HEADER_LENGTH = (ENABLE_VLAN) ? 15 : 11;

reg                  errored_data;
reg                  errored_addr_data;
reg                  errored_swap_data;
wire  [7:0]          lut_data;
wire  [7:0]          lut_swap_data;
reg   [7:0]          expected_data;
reg   [15:0]         packet_size;
reg   [4:0]          packet_count;
reg   [1:0]          rx_state;
reg   [1:0]          next_rx_state;
reg                  maybe_frame_error;
reg                  frame_error_int;
reg   [15:0]         frame_activity_count;
reg                  sm_active;

assign activity_flash = speed[1] ? frame_activity_count[15] : 
                        speed[0] ? frame_activity_count[13] : frame_activity_count[11];
                        
assign frame_error    = sm_active ? frame_error_int : 0;                        

// we need a way to confirm data has been received to ensure that if no data is received it is 
// flagged as an error
always @(posedge axi_tclk)
begin
   if (!axi_tresetn) 
      sm_active <= 0;
   else if (rx_state == PKT)
      sm_active <= 1;
end

// the pattern checker is a slave in all respects so has to look for ackowledged data
// the first and 6 bytes of data are compared against the first byte of DEST_ADDR and SCR_ADDR
// to allow for address swaps being removed

// a simple state machine will keep track of the packet position
always @(rx_state or tlast or tvalid or tready or tuser or enable_pat_chk or maybe_frame_error)
begin
   next_rx_state = rx_state;
   case (rx_state)
      // cannot simply look for a rise on valid have to see a last first so
      // we know the next asserted valid is new data
      IDLE : begin
         if (tlast & tvalid & tready & enable_pat_chk)
            next_rx_state = INFO;
      end
      // since we don't know where the packet gen will be rx a frame to enable
      // packet size to be initialised
      INFO : begin
         if (tlast & tvalid & tready & !tuser)
            next_rx_state = LOOK;
      end
      // have seen a last so now look for a start
      LOOK : begin
         if (!tlast & tvalid & tready)
            next_rx_state = PKT;
      end
      // rxd first byte of packet - now stay in this state until we see a last
      PKT : begin
         if (!enable_pat_chk)
            next_rx_state = IDLE;
         else if (tlast & tvalid & tready) begin
            if (!tuser & maybe_frame_error)
               next_rx_state = IDLE;
            else
               next_rx_state = LOOK;
         end         
      end
   endcase
end

always @(posedge axi_tclk)
begin
   if (!axi_tresetn) 
      rx_state <= IDLE;
   else
      rx_state <= next_rx_state;
end

always @(posedge axi_tclk)
begin
   if (rx_state == PKT & next_rx_state == LOOK) 
      if (!tuser) begin
         if (ENABLE_VLAN)
            if (errored_addr_data)
               $display("VLAN Frame PASSED.  DA/SA swapped, Frame size = %d", (packet_size + PKT_ADJUST));
            else
               $display("VLAN Frame PASSED. Frame size = %d", (packet_size + PKT_ADJUST));
         else
            if (errored_addr_data)
               $display("Frame PASSED.  DA/SA swapped, Frame size = %d", (packet_size + PKT_ADJUST));
            else
               $display("Frame PASSED.  Frame size = %d", (packet_size + PKT_ADJUST));
      end
end

// now need a counter for packet size and packet position AND data
always @(posedge axi_tclk)
begin
   if (!axi_tresetn)
      packet_count <= 0;
   else begin
      if (tlast)
         packet_count <= 0;
      else if ((next_rx_state == PKT || rx_state == PKT || rx_state == INFO) & tvalid & tready & (packet_count[4:3] != 2'b11))
         packet_count <= packet_count + 1;
   end
end

// need to get packet size info
// this is first initialised during the info state (the assumption being that
// the generate sends incrementing packet sizes (wrapping at MAX_SIZE)
always @(posedge axi_tclk)
begin
   if (rx_state == INFO & packet_count == (HEADER_LENGTH + 1) & tvalid & tready)
      packet_size[15:8] <= tdata;
   else if (rx_state == INFO & packet_count == (HEADER_LENGTH + 2) & tvalid & tready)
      packet_size[7:0] <= tdata;
      // when in the LOOK state we want to update the packet size to the next expected
   else if (rx_state != LOOK & next_rx_state == LOOK & !tuser) begin
      if (packet_size == MAX_SIZE - PKT_ADJUST)
         packet_size <= MIN_SIZE - PKT_ADJUST;
      else
         packet_size <= packet_size + 1;
   end
end

// the expected data is updated from the packet size at the end of the LOOK state
always @(posedge axi_tclk)
begin
   if (rx_state == LOOK & next_rx_state == PKT) 
      expected_data <= packet_size;
   else if (rx_state == PKT & packet_count >= (HEADER_LENGTH + 3) & tvalid & tready) 
      expected_data <= expected_data - 1;
end

// store the parametised values in a lut (64 deep)
// this should mean the values could be adjusted in fpga_editor etc..
// we don't know if the address is swapped or not so check both
genvar i;  
generate
  for (i=0; i<=7; i=i+1) begin : lut_loop
    LUT6 #(
       .INIT      ({48'd0,
                    VLAN_HEADER[i],
                    VLAN_HEADER[i+8],
                    VLAN_HEADER[i+16],
                    VLAN_HEADER[i+24],
                    SRC_ADDR[i],
                    SRC_ADDR[i+8],
                    SRC_ADDR[i+16],
                    SRC_ADDR[i+24],
                    SRC_ADDR[i+32],
                    SRC_ADDR[i+40],
                    DEST_ADDR[i],
                    DEST_ADDR[i+8],
                    DEST_ADDR[i+16],
                    DEST_ADDR[i+24],
                    DEST_ADDR[i+32],
                    DEST_ADDR[i+40]
                   })   // Specify LUT Contents
    ) LUT6_inst (
       .O         (lut_data[i]), 
       .I0        (packet_count[0]),
       .I1        (packet_count[1]),
       .I2        (packet_count[2]),
       .I3        (packet_count[3]),
       .I4        (1'b0),
       .I5        (1'b0) 
    );
    
    LUT6 #(
       .INIT      ({48'd0,
                    VLAN_HEADER[i],
                    VLAN_HEADER[i+8],
                    VLAN_HEADER[i+16],
                    VLAN_HEADER[i+24],
                    DEST_ADDR[i],
                    DEST_ADDR[i+8],
                    DEST_ADDR[i+16],
                    DEST_ADDR[i+24],
                    DEST_ADDR[i+32],
                    DEST_ADDR[i+40],
                    SRC_ADDR[i],
                    SRC_ADDR[i+8],
                    SRC_ADDR[i+16],
                    SRC_ADDR[i+24],
                    SRC_ADDR[i+32],
                    SRC_ADDR[i+40]
                   })   // Specify LUT Contents
    ) LUT6_swap_inst (
       .O         (lut_swap_data[i]), 
       .I0        (packet_count[0]),
       .I1        (packet_count[1]),
       .I2        (packet_count[2]),
       .I3        (packet_count[3]),
       .I4        (1'b0),
       .I5        (1'b0) 
    );
   end
endgenerate
  
// we do not know if the address will be swapped or not so check for both - if either pass  
/// then this field is ok (assumption being that an address swap cannot be performed by mistake.)
// errored_data is high on the cycle after a mismatch and stays high until the end of frame
always @(posedge axi_tclk)
begin
   if (!axi_tresetn)
      errored_addr_data <= 0;
   else if (tlast & tvalid & tready)
      errored_addr_data <= 0;
   else if (packet_count <= HEADER_LENGTH & tvalid & tready & !tuser) begin
      if (lut_data != tdata)
         errored_addr_data <= 1;
   end
end

// errored_data is high on the cycle after a mismatch and stays high until the end of frame
always @(posedge axi_tclk)
begin
   if (!axi_tresetn)
      errored_swap_data <= 0;
   else if (tlast & tvalid & tready)
      errored_swap_data <= 0;
   else if (packet_count <= HEADER_LENGTH & tvalid & tready & !tuser) begin
      if (lut_swap_data != tdata)
         errored_swap_data <= 1;
   end
end

always @(posedge axi_tclk)
begin
   errored_data <= 0;
   if (packet_count == (HEADER_LENGTH + 1) & tvalid & tready & !tuser) begin
      if (packet_size[15:8] != tdata)
         errored_data <= 1;
   end
   else if (packet_count == (HEADER_LENGTH + 2) & tvalid & tready & !tuser) begin
      if (packet_size[7:0] != tdata)
         errored_data <= 1;
   end
   else if (packet_count >= (HEADER_LENGTH + 3) & tvalid & tready & !tuser & rx_state == PKT) begin
      if (expected_data != tdata)
         errored_data <= 1;
   end
end

// validate the error - can only do this once we know the packet hasn't been dropped
// this error will capture the cycle specific error signal and hold it until the end of the frame
always @(posedge axi_tclk)
begin
   if (!axi_tresetn)
      maybe_frame_error <= 0;
   else if ((tlast & tvalid & tready & tuser) | rx_state == IDLE)
      maybe_frame_error <= 0;
   else if (rx_state != IDLE & rx_state != INFO & (errored_data | (errored_addr_data & errored_swap_data)))
      maybe_frame_error <= 1;
end

// capture the error if frame is not dropped and hold until reset
always @(posedge axi_tclk)
begin
   if (!axi_tresetn)
      frame_error_int <= 0;
   else if (maybe_frame_error & tlast & tready & tvalid & !tuser)
      frame_error_int <= 1;
end

// now need a counter for frame activity to provide some feedback that frames are being received
// a 16 bit counter is used as this should give a slow flash rate at 10M and a very fast rate at 1G
always @(posedge axi_tclk)
begin
   if (!axi_tresetn)
      frame_activity_count <= 0;
   else begin
      if (tlast)
         frame_activity_count <= frame_activity_count + 1;
   end
end

endmodule
