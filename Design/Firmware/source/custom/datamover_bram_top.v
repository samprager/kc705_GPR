`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2016 03:15:50 PM
// Design Name: 
// Module Name: datamover_bram_top
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


module datamover_bram_top(
        input aresetn,
        input clk_in1
    );
    localparam     IDLE        = 3'b000,
                   WR_CMD        = 3'b001,
                   WR_DATA    = 3'b010,
                   RD_CMD        = 3'b011,
                   RD_DATA    = 3'b100;
                   
    localparam FIXED = 1'b0;
    localparam INCR = 1'b1;
    
    localparam NUM_WRITE = 'h80;
    
    wire [7:0]M_AXIS_MM2S_STS_tdata;
    wire [0:0]M_AXIS_MM2S_STS_tkeep;
    wire M_AXIS_MM2S_STS_tlast;
    wire M_AXIS_MM2S_STS_tready;
    wire M_AXIS_MM2S_STS_tvalid;
    wire [31:0]M_AXIS_MM2S_tdata;
    wire [3:0]M_AXIS_MM2S_tkeep;
    wire M_AXIS_MM2S_tlast;
    wire M_AXIS_MM2S_tready;
    wire M_AXIS_MM2S_tvalid;
    wire [7:0]M_AXIS_S2MM_STS_tdata;
    wire [0:0]M_AXIS_S2MM_STS_tkeep;
    wire M_AXIS_S2MM_STS_tlast;
    wire M_AXIS_S2MM_STS_tready;
    wire M_AXIS_S2MM_STS_tvalid;
    wire [71:0]S_AXIS_MM2S_CMD_tdata;
    wire S_AXIS_MM2S_CMD_tready;
    wire S_AXIS_MM2S_CMD_tvalid;
    wire [71:0]S_AXIS_S2MM_CMD_tdata;
    wire S_AXIS_S2MM_CMD_tready;
    wire S_AXIS_S2MM_CMD_tvalid;
    wire [31:0]S_AXIS_S2MM_tdata;
    wire [3:0]S_AXIS_S2MM_tkeep;
    wire S_AXIS_S2MM_tlast;
    wire S_AXIS_S2MM_tready;
    wire S_AXIS_S2MM_tvalid;
    wire mm2s_err;
    wire s2mm_err;
    
    reg M_AXIS_MM2S_STS_tready_reg;
    reg M_AXIS_MM2S_tready_reg;
    reg M_AXIS_S2MM_STS_tready_reg;
    
    reg [71:0]S_AXIS_MM2S_CMD_tdata_reg;
    reg S_AXIS_MM2S_CMD_tvalid_reg;
    reg [71:0]S_AXIS_S2MM_CMD_tdata_reg; //{RSVD(4b),TAG(4b),SADDR(32b),DRR(1b),EOF(1b),DSA(6b),Type(1b),BTT(23b)}
    reg S_AXIS_S2MM_CMD_tvalid_reg;
    
    reg [31:0]S_AXIS_S2MM_tdata_reg;
    reg [3:0]S_AXIS_S2MM_tkeep_reg;
    reg S_AXIS_S2MM_tlast_reg;
    reg S_AXIS_S2MM_tvalid_reg;
    
    reg         [2:0]          next_gen_state;
    reg         [2:0]          gen_state;
    
    reg [31:0] rd_addr = 32'h0;
    reg [31:0] wr_addr = 32'h0;
    reg [31:0] wr_counter;
    reg [31:0] rd_counter;
    
always @(posedge clk_in1)begin
    if(!aresetn) begin
        M_AXIS_MM2S_STS_tready_reg <= 0;
        M_AXIS_S2MM_STS_tready_reg <= 0;
    end
    else begin 
        M_AXIS_MM2S_STS_tready_reg <= 1;
        M_AXIS_S2MM_STS_tready_reg <= 1;  
    end
end

always @(posedge clk_in1)begin
    if(!aresetn) begin
        S_AXIS_S2MM_CMD_tvalid_reg <= 0;
    end
    else if (gen_state == WR_CMD) begin
        S_AXIS_S2MM_CMD_tvalid_reg <= 1; 
    end
    else begin
        S_AXIS_S2MM_CMD_tvalid_reg <= 0;
    end
end

always @(posedge clk_in1)begin
    if(!aresetn) begin
        S_AXIS_S2MM_CMD_tdata_reg <= 0;
    end
    else if (gen_state == WR_CMD) begin
        S_AXIS_S2MM_CMD_tdata_reg[67:64] <= 4'hE;   //test tag
        S_AXIS_S2MM_CMD_tdata_reg[63:32] <= wr_addr;
        S_AXIS_S2MM_CMD_tdata_reg[23] <= INCR;
        S_AXIS_S2MM_CMD_tdata_reg[22:0] <= 22'h80;
    end
end
always @(posedge clk_in1)begin
    if(!aresetn) begin
        S_AXIS_MM2S_CMD_tvalid_reg <= 0;
    end
    else if (gen_state == RD_CMD)begin
        S_AXIS_MM2S_CMD_tvalid_reg <= 1;  
    end
    else begin
        S_AXIS_MM2S_CMD_tvalid_reg <= 0;
    end    
end
always @(posedge clk_in1)begin
    if(!aresetn) begin
        S_AXIS_MM2S_CMD_tdata_reg <= 0;
    end
    else if (gen_state == RD_CMD) begin
        S_AXIS_MM2S_CMD_tdata_reg[67:64] <= 4'hE;   //test tag
        S_AXIS_MM2S_CMD_tdata_reg[63:32] <= rd_addr;
        S_AXIS_MM2S_CMD_tdata_reg[23] <= INCR;
        S_AXIS_MM2S_CMD_tdata_reg[22:0] <= 22'h80;
    end
end

always @(posedge clk_in1)begin
    if(!aresetn) begin
        S_AXIS_S2MM_tvalid_reg <= 0;
    end
    else if (gen_state == WR_DATA) begin
        S_AXIS_S2MM_tvalid_reg <= 1;
    end
    else if(S_AXIS_S2MM_tready) begin
       S_AXIS_S2MM_tvalid_reg <= 0;
    end
end

always @(posedge clk_in1)begin
    if(!aresetn) begin
        S_AXIS_S2MM_tdata_reg <= 0;
        S_AXIS_S2MM_tkeep_reg <= 0;
        wr_counter <= 0;
    end
    else if(gen_state == WR_DATA & S_AXIS_S2MM_tready & S_AXIS_S2MM_tvalid_reg) begin
        S_AXIS_S2MM_tdata_reg <= wr_counter+32'h8; 
        S_AXIS_S2MM_tkeep_reg <= 4'hf;
        wr_counter <= wr_counter + 1'b1;
    end
    else if(gen_state != WR_DATA) begin
        wr_counter <= 0;
    end    
end
always @(posedge clk_in1)begin
    if(!aresetn) begin
        S_AXIS_S2MM_tlast_reg <= 0;
    end
    else if(gen_state == WR_DATA & wr_counter == NUM_WRITE & S_AXIS_S2MM_tready) begin
        S_AXIS_S2MM_tlast_reg <= 1;
    end
    else if(S_AXIS_S2MM_tready) begin
        S_AXIS_S2MM_tlast_reg <= 0;
    end    
end
always @(posedge clk_in1)begin
    if(!aresetn) begin
        S_AXIS_S2MM_tdata_reg <= 0;
        wr_counter <= 0;
    end
    else if(gen_state == WR_DATA & S_AXIS_S2MM_tready & S_AXIS_S2MM_tvalid_reg) begin
        S_AXIS_S2MM_tdata_reg <= wr_counter+32'h8; 
        wr_counter <= wr_counter + 1'b1;
    end
    else if(gen_state != WR_DATA) begin
        wr_counter <= 0;
    end    
end

always @(posedge clk_in1)begin
    if(!aresetn) begin
        rd_counter <= 0;
    end
    else if(gen_state == RD_DATA & M_AXIS_MM2S_tready_reg & M_AXIS_MM2S_tvalid) begin 
        rd_counter <= rd_counter + 1'b1;
    end
    else if(gen_state != RD_DATA) begin
        rd_counter <= 0;
    end    
end    
always @(posedge clk_in1)begin
    if(!aresetn) begin
        M_AXIS_MM2S_tready_reg <= 0;
    end
    else if ((gen_state == RD_DATA)| (gen_state == RD_CMD & S_AXIS_MM2S_CMD_tvalid_reg & S_AXIS_MM2S_CMD_tready)) begin
        M_AXIS_MM2S_tready_reg <= 1;
    end
    else begin 
        M_AXIS_MM2S_tready_reg <= 0;
    end
end     
always @(gen_state or wr_counter or rd_counter  or S_AXIS_MM2S_CMD_tvalid_reg or S_AXIS_MM2S_CMD_tready or S_AXIS_S2MM_CMD_tvalid_reg or S_AXIS_S2MM_CMD_tready or 
    S_AXIS_S2MM_tlast_reg or S_AXIS_S2MM_tready or S_AXIS_S2MM_tvalid_reg or M_AXIS_MM2S_tlast or M_AXIS_MM2S_tready_reg or M_AXIS_MM2S_tvalid)
begin
   next_gen_state = gen_state;
   case (gen_state)
      IDLE : begin
         if (S_AXIS_S2MM_CMD_tready) begin
            next_gen_state = WR_CMD;
         end
      end
      WR_CMD : begin
        if (S_AXIS_S2MM_CMD_tready & S_AXIS_S2MM_CMD_tvalid_reg)
            next_gen_state = WR_DATA;
      end
      WR_DATA : begin
         if (wr_counter == NUM_WRITE & S_AXIS_S2MM_tready)
            next_gen_state = RD_CMD;
      end
      RD_CMD : begin
         if (S_AXIS_MM2S_CMD_tready & S_AXIS_MM2S_CMD_tvalid_reg)
            next_gen_state = RD_DATA;
      end
      RD_DATA : begin
        if (M_AXIS_MM2S_tready_reg & M_AXIS_MM2S_tlast)
         next_gen_state = IDLE;
      end
      
      default : begin
         next_gen_state = IDLE;
      end
   endcase
end

always @(posedge clk_in1)
begin
   if (!aresetn) begin
      gen_state <= IDLE;
   end
   else begin
      gen_state <= next_gen_state;
   end
end

assign M_AXIS_MM2S_STS_tready =  M_AXIS_MM2S_STS_tready_reg;
assign M_AXIS_MM2S_tready = M_AXIS_MM2S_tready_reg;
assign M_AXIS_S2MM_STS_tready = M_AXIS_S2MM_STS_tready_reg;

assign S_AXIS_MM2S_CMD_tdata = S_AXIS_MM2S_CMD_tdata_reg;
assign S_AXIS_MM2S_CMD_tvalid = S_AXIS_MM2S_CMD_tvalid_reg;
assign S_AXIS_S2MM_CMD_tdata = S_AXIS_S2MM_CMD_tdata_reg; //{RSVD(4b),TAG(4b),SADDR(32b),DRR(1b),EOF(1b),DSA(6b),Type(1b),BTT(23b)}
assign S_AXIS_S2MM_CMD_tvalid = S_AXIS_S2MM_CMD_tvalid_reg;

assign S_AXIS_S2MM_tdata = S_AXIS_S2MM_tdata_reg;
assign S_AXIS_S2MM_tkeep = S_AXIS_S2MM_tkeep_reg;
assign S_AXIS_S2MM_tlast = S_AXIS_S2MM_tlast_reg;
assign S_AXIS_S2MM_tvalid = S_AXIS_S2MM_tvalid_reg;   
            
    design_1 design_1_i (
        .M_AXIS_MM2S_STS_tdata(M_AXIS_MM2S_STS_tdata),
         .M_AXIS_MM2S_STS_tkeep(M_AXIS_MM2S_STS_tkeep),
         .M_AXIS_MM2S_STS_tlast(M_AXIS_MM2S_STS_tlast),
         .M_AXIS_MM2S_STS_tready(M_AXIS_MM2S_STS_tready),
         .M_AXIS_MM2S_STS_tvalid(M_AXIS_MM2S_STS_tvalid),
         .M_AXIS_MM2S_tdata(M_AXIS_MM2S_tdata),
         .M_AXIS_MM2S_tkeep(M_AXIS_MM2S_tkeep),
         .M_AXIS_MM2S_tlast(M_AXIS_MM2S_tlast),
         .M_AXIS_MM2S_tready(M_AXIS_MM2S_tready),
         .M_AXIS_MM2S_tvalid(M_AXIS_MM2S_tvalid),
         .M_AXIS_S2MM_STS_tdata(M_AXIS_S2MM_STS_tdata),
         .M_AXIS_S2MM_STS_tkeep(M_AXIS_S2MM_STS_tkeep),
         .M_AXIS_S2MM_STS_tlast(M_AXIS_S2MM_STS_tlast),
         .M_AXIS_S2MM_STS_tready(M_AXIS_S2MM_STS_tready),
         .M_AXIS_S2MM_STS_tvalid(M_AXIS_S2MM_STS_tvalid),
         .S_AXIS_MM2S_CMD_tdata(S_AXIS_MM2S_CMD_tdata),
         .S_AXIS_MM2S_CMD_tready(S_AXIS_MM2S_CMD_tready),
         .S_AXIS_MM2S_CMD_tvalid(S_AXIS_MM2S_CMD_tvalid),
         .S_AXIS_S2MM_CMD_tdata(S_AXIS_S2MM_CMD_tdata),
         .S_AXIS_S2MM_CMD_tready(S_AXIS_S2MM_CMD_tready),
         .S_AXIS_S2MM_CMD_tvalid(S_AXIS_S2MM_CMD_tvalid),
         .S_AXIS_S2MM_tdata(S_AXIS_S2MM_tdata),
         .S_AXIS_S2MM_tkeep(S_AXIS_S2MM_tkeep),
         .S_AXIS_S2MM_tlast(S_AXIS_S2MM_tlast),
         .S_AXIS_S2MM_tready(S_AXIS_S2MM_tready),
         .S_AXIS_S2MM_tvalid(S_AXIS_S2MM_tvalid),
         .aresetn(aresetn),
         .clk_in1(clk_in1),
         .mm2s_err(mm2s_err),
         .s2mm_err(s2mm_err)
     );
//axi_waveform_bram_ctrl axi_waveform_bram_ctrl_inst (
//  .s_axi_aclk(s_axi_aclk),        // input wire s_axi_aclk
//  .s_axi_aresetn(s_axi_aresetn),  // input wire s_axi_aresetn
//  .s_axi_awid(s_axi_awid),        // input wire [3 : 0] s_axi_awid
//  .s_axi_awaddr(s_axi_awaddr),    // input wire [17 : 0] s_axi_awaddr
//  .s_axi_awlen(s_axi_awlen),      // input wire [7 : 0] s_axi_awlen
//  .s_axi_awsize(s_axi_awsize),    // input wire [2 : 0] s_axi_awsize
//  .s_axi_awburst(s_axi_awburst),  // input wire [1 : 0] s_axi_awburst
//  .s_axi_awlock(s_axi_awlock),    // input wire s_axi_awlock
//  .s_axi_awcache(s_axi_awcache),  // input wire [3 : 0] s_axi_awcache
//  .s_axi_awprot(s_axi_awprot),    // input wire [2 : 0] s_axi_awprot
//  .s_axi_awvalid(s_axi_awvalid),  // input wire s_axi_awvalid
//  .s_axi_awready(s_axi_awready),  // output wire s_axi_awready
//  .s_axi_wdata(s_axi_wdata),      // input wire [31 : 0] s_axi_wdata
//  .s_axi_wstrb(s_axi_wstrb),      // input wire [3 : 0] s_axi_wstrb
//  .s_axi_wlast(s_axi_wlast),      // input wire s_axi_wlast
//  .s_axi_wvalid(s_axi_wvalid),    // input wire s_axi_wvalid
//  .s_axi_wready(s_axi_wready),    // output wire s_axi_wready
//  .s_axi_bid(s_axi_bid),          // output wire [3 : 0] s_axi_bid
//  .s_axi_bresp(s_axi_bresp),      // output wire [1 : 0] s_axi_bresp
//  .s_axi_bvalid(s_axi_bvalid),    // output wire s_axi_bvalid
//  .s_axi_bready(s_axi_bready),    // input wire s_axi_bready
//  .s_axi_arid(s_axi_arid),        // input wire [3 : 0] s_axi_arid
//  .s_axi_araddr(s_axi_araddr),    // input wire [17 : 0] s_axi_araddr
//  .s_axi_arlen(s_axi_arlen),      // input wire [7 : 0] s_axi_arlen
//  .s_axi_arsize(s_axi_arsize),    // input wire [2 : 0] s_axi_arsize
//  .s_axi_arburst(s_axi_arburst),  // input wire [1 : 0] s_axi_arburst
//  .s_axi_arlock(s_axi_arlock),    // input wire s_axi_arlock
//  .s_axi_arcache(s_axi_arcache),  // input wire [3 : 0] s_axi_arcache
//  .s_axi_arprot(s_axi_arprot),    // input wire [2 : 0] s_axi_arprot
//  .s_axi_arvalid(s_axi_arvalid),  // input wire s_axi_arvalid
//  .s_axi_arready(s_axi_arready),  // output wire s_axi_arready
//  .s_axi_rid(s_axi_rid),          // output wire [3 : 0] s_axi_rid
//  .s_axi_rdata(s_axi_rdata),      // output wire [31 : 0] s_axi_rdata
//  .s_axi_rresp(s_axi_rresp),      // output wire [1 : 0] s_axi_rresp
//  .s_axi_rlast(s_axi_rlast),      // output wire s_axi_rlast
//  .s_axi_rvalid(s_axi_rvalid),    // output wire s_axi_rvalid
//  .s_axi_rready(s_axi_rready),    // input wire s_axi_rready
//  .bram_rst_a(bram_rst_a),        // output wire bram_rst_a
//  .bram_clk_a(bram_clk_a),        // output wire bram_clk_a
//  .bram_en_a(bram_en_a),          // output wire bram_en_a
//  .bram_we_a(bram_we_a),          // output wire [3 : 0] bram_we_a
//  .bram_addr_a(bram_addr_a),      // output wire [17 : 0] bram_addr_a
//  .bram_wrdata_a(bram_wrdata_a),  // output wire [31 : 0] bram_wrdata_a
//  .bram_rddata_a(bram_rddata_a),  // input wire [31 : 0] bram_rddata_a
//  .bram_rst_b(bram_rst_b),        // output wire bram_rst_b
//  .bram_clk_b(bram_clk_b),        // output wire bram_clk_b
//  .bram_en_b(bram_en_b),          // output wire bram_en_b
//  .bram_we_b(bram_we_b),          // output wire [3 : 0] bram_we_b
//  .bram_addr_b(bram_addr_b),      // output wire [17 : 0] bram_addr_b
//  .bram_wrdata_b(bram_wrdata_b),  // output wire [31 : 0] bram_wrdata_b
//  .bram_rddata_b(bram_rddata_b)  // input wire [31 : 0] bram_rddata_b
//);
    
//axi_waveform_datamover axi_waveform_datamover_inst (
//  .m_axi_mm2s_aclk(m_axi_mm2s_aclk),                        // input wire m_axi_mm2s_aclk
//  .m_axi_mm2s_aresetn(m_axi_mm2s_aresetn),                  // input wire m_axi_mm2s_aresetn
//  .mm2s_err(mm2s_err),                                      // output wire mm2s_err
//  .m_axis_mm2s_cmdsts_aclk(m_axis_mm2s_cmdsts_aclk),        // input wire m_axis_mm2s_cmdsts_aclk
//  .m_axis_mm2s_cmdsts_aresetn(m_axis_mm2s_cmdsts_aresetn),  // input wire m_axis_mm2s_cmdsts_aresetn
//  .s_axis_mm2s_cmd_tvalid(s_axis_mm2s_cmd_tvalid),          // input wire s_axis_mm2s_cmd_tvalid
//  .s_axis_mm2s_cmd_tready(s_axis_mm2s_cmd_tready),          // output wire s_axis_mm2s_cmd_tready
//  .s_axis_mm2s_cmd_tdata(s_axis_mm2s_cmd_tdata),            // input wire [71 : 0] s_axis_mm2s_cmd_tdata
//  .m_axis_mm2s_sts_tvalid(m_axis_mm2s_sts_tvalid),          // output wire m_axis_mm2s_sts_tvalid
//  .m_axis_mm2s_sts_tready(m_axis_mm2s_sts_tready),          // input wire m_axis_mm2s_sts_tready
//  .m_axis_mm2s_sts_tdata(m_axis_mm2s_sts_tdata),            // output wire [7 : 0] m_axis_mm2s_sts_tdata
//  .m_axis_mm2s_sts_tkeep(m_axis_mm2s_sts_tkeep),            // output wire [0 : 0] m_axis_mm2s_sts_tkeep
//  .m_axis_mm2s_sts_tlast(m_axis_mm2s_sts_tlast),            // output wire m_axis_mm2s_sts_tlast
//  .m_axi_mm2s_arid(m_axi_mm2s_arid),                        // output wire [3 : 0] m_axi_mm2s_arid
//  .m_axi_mm2s_araddr(m_axi_mm2s_araddr),                    // output wire [31 : 0] m_axi_mm2s_araddr
//  .m_axi_mm2s_arlen(m_axi_mm2s_arlen),                      // output wire [7 : 0] m_axi_mm2s_arlen
//  .m_axi_mm2s_arsize(m_axi_mm2s_arsize),                    // output wire [2 : 0] m_axi_mm2s_arsize
//  .m_axi_mm2s_arburst(m_axi_mm2s_arburst),                  // output wire [1 : 0] m_axi_mm2s_arburst
//  .m_axi_mm2s_arprot(m_axi_mm2s_arprot),                    // output wire [2 : 0] m_axi_mm2s_arprot
//  .m_axi_mm2s_arcache(m_axi_mm2s_arcache),                  // output wire [3 : 0] m_axi_mm2s_arcache
//  .m_axi_mm2s_aruser(m_axi_mm2s_aruser),                    // output wire [3 : 0] m_axi_mm2s_aruser
//  .m_axi_mm2s_arvalid(m_axi_mm2s_arvalid),                  // output wire m_axi_mm2s_arvalid
//  .m_axi_mm2s_arready(m_axi_mm2s_arready),                  // input wire m_axi_mm2s_arready
//  .m_axi_mm2s_rdata(m_axi_mm2s_rdata),                      // input wire [31 : 0] m_axi_mm2s_rdata
//  .m_axi_mm2s_rresp(m_axi_mm2s_rresp),                      // input wire [1 : 0] m_axi_mm2s_rresp
//  .m_axi_mm2s_rlast(m_axi_mm2s_rlast),                      // input wire m_axi_mm2s_rlast
//  .m_axi_mm2s_rvalid(m_axi_mm2s_rvalid),                    // input wire m_axi_mm2s_rvalid
//  .m_axi_mm2s_rready(m_axi_mm2s_rready),                    // output wire m_axi_mm2s_rready
//  .m_axis_mm2s_tdata(m_axis_mm2s_tdata),                    // output wire [31 : 0] m_axis_mm2s_tdata
//  .m_axis_mm2s_tkeep(m_axis_mm2s_tkeep),                    // output wire [3 : 0] m_axis_mm2s_tkeep
//  .m_axis_mm2s_tlast(m_axis_mm2s_tlast),                    // output wire m_axis_mm2s_tlast
//  .m_axis_mm2s_tvalid(m_axis_mm2s_tvalid),                  // output wire m_axis_mm2s_tvalid
//  .m_axis_mm2s_tready(m_axis_mm2s_tready),                  // input wire m_axis_mm2s_tready
//  .m_axi_s2mm_aclk(m_axi_s2mm_aclk),                        // input wire m_axi_s2mm_aclk
//  .m_axi_s2mm_aresetn(m_axi_s2mm_aresetn),                  // input wire m_axi_s2mm_aresetn
//  .s2mm_err(s2mm_err),                                      // output wire s2mm_err
//  .m_axis_s2mm_cmdsts_awclk(m_axis_s2mm_cmdsts_awclk),      // input wire m_axis_s2mm_cmdsts_awclk
//  .m_axis_s2mm_cmdsts_aresetn(m_axis_s2mm_cmdsts_aresetn),  // input wire m_axis_s2mm_cmdsts_aresetn
//  .s_axis_s2mm_cmd_tvalid(s_axis_s2mm_cmd_tvalid),          // input wire s_axis_s2mm_cmd_tvalid
//  .s_axis_s2mm_cmd_tready(s_axis_s2mm_cmd_tready),          // output wire s_axis_s2mm_cmd_tready
//  .s_axis_s2mm_cmd_tdata(s_axis_s2mm_cmd_tdata),            // input wire [71 : 0] s_axis_s2mm_cmd_tdata
//  .m_axis_s2mm_sts_tvalid(m_axis_s2mm_sts_tvalid),          // output wire m_axis_s2mm_sts_tvalid
//  .m_axis_s2mm_sts_tready(m_axis_s2mm_sts_tready),          // input wire m_axis_s2mm_sts_tready
//  .m_axis_s2mm_sts_tdata(m_axis_s2mm_sts_tdata),            // output wire [7 : 0] m_axis_s2mm_sts_tdata
//  .m_axis_s2mm_sts_tkeep(m_axis_s2mm_sts_tkeep),            // output wire [0 : 0] m_axis_s2mm_sts_tkeep
//  .m_axis_s2mm_sts_tlast(m_axis_s2mm_sts_tlast),            // output wire m_axis_s2mm_sts_tlast
//  .m_axi_s2mm_awid(m_axi_s2mm_awid),                        // output wire [3 : 0] m_axi_s2mm_awid
//  .m_axi_s2mm_awaddr(m_axi_s2mm_awaddr),                    // output wire [31 : 0] m_axi_s2mm_awaddr
//  .m_axi_s2mm_awlen(m_axi_s2mm_awlen),                      // output wire [7 : 0] m_axi_s2mm_awlen
//  .m_axi_s2mm_awsize(m_axi_s2mm_awsize),                    // output wire [2 : 0] m_axi_s2mm_awsize
//  .m_axi_s2mm_awburst(m_axi_s2mm_awburst),                  // output wire [1 : 0] m_axi_s2mm_awburst
//  .m_axi_s2mm_awprot(m_axi_s2mm_awprot),                    // output wire [2 : 0] m_axi_s2mm_awprot
//  .m_axi_s2mm_awcache(m_axi_s2mm_awcache),                  // output wire [3 : 0] m_axi_s2mm_awcache
//  .m_axi_s2mm_awuser(m_axi_s2mm_awuser),                    // output wire [3 : 0] m_axi_s2mm_awuser
//  .m_axi_s2mm_awvalid(m_axi_s2mm_awvalid),                  // output wire m_axi_s2mm_awvalid
//  .m_axi_s2mm_awready(m_axi_s2mm_awready),                  // input wire m_axi_s2mm_awready
//  .m_axi_s2mm_wdata(m_axi_s2mm_wdata),                      // output wire [31 : 0] m_axi_s2mm_wdata
//  .m_axi_s2mm_wstrb(m_axi_s2mm_wstrb),                      // output wire [3 : 0] m_axi_s2mm_wstrb
//  .m_axi_s2mm_wlast(m_axi_s2mm_wlast),                      // output wire m_axi_s2mm_wlast
//  .m_axi_s2mm_wvalid(m_axi_s2mm_wvalid),                    // output wire m_axi_s2mm_wvalid
//  .m_axi_s2mm_wready(m_axi_s2mm_wready),                    // input wire m_axi_s2mm_wready
//  .m_axi_s2mm_bresp(m_axi_s2mm_bresp),                      // input wire [1 : 0] m_axi_s2mm_bresp
//  .m_axi_s2mm_bvalid(m_axi_s2mm_bvalid),                    // input wire m_axi_s2mm_bvalid
//  .m_axi_s2mm_bready(m_axi_s2mm_bready),                    // output wire m_axi_s2mm_bready
//  .s_axis_s2mm_tdata(s_axis_s2mm_tdata),                    // input wire [31 : 0] s_axis_s2mm_tdata
//  .s_axis_s2mm_tkeep(s_axis_s2mm_tkeep),                    // input wire [3 : 0] s_axis_s2mm_tkeep
//  .s_axis_s2mm_tlast(s_axis_s2mm_tlast),                    // input wire s_axis_s2mm_tlast
//  .s_axis_s2mm_tvalid(s_axis_s2mm_tvalid),                  // input wire s_axis_s2mm_tvalid
//  .s_axis_s2mm_tready(s_axis_s2mm_tready)                  // output wire s_axis_s2mm_tready
//);

//axi_waveform_interconnect your_instance_name (
//  .INTERCONNECT_ACLK(INTERCONNECT_ACLK),        // input wire INTERCONNECT_ACLK
//  .INTERCONNECT_ARESETN(INTERCONNECT_ARESETN),  // input wire INTERCONNECT_ARESETN
//  .S00_AXI_ARESET_OUT_N(S00_AXI_ARESET_OUT_N),  // output wire S00_AXI_ARESET_OUT_N
//  .S00_AXI_ACLK(S00_AXI_ACLK),                  // input wire S00_AXI_ACLK
//  .S00_AXI_AWID(S00_AXI_AWID),                  // input wire [0 : 0] S00_AXI_AWID
//  .S00_AXI_AWADDR(S00_AXI_AWADDR),              // input wire [31 : 0] S00_AXI_AWADDR
//  .S00_AXI_AWLEN(S00_AXI_AWLEN),                // input wire [7 : 0] S00_AXI_AWLEN
//  .S00_AXI_AWSIZE(S00_AXI_AWSIZE),              // input wire [2 : 0] S00_AXI_AWSIZE
//  .S00_AXI_AWBURST(S00_AXI_AWBURST),            // input wire [1 : 0] S00_AXI_AWBURST
//  .S00_AXI_AWLOCK(S00_AXI_AWLOCK),              // input wire S00_AXI_AWLOCK
//  .S00_AXI_AWCACHE(S00_AXI_AWCACHE),            // input wire [3 : 0] S00_AXI_AWCACHE
//  .S00_AXI_AWPROT(S00_AXI_AWPROT),              // input wire [2 : 0] S00_AXI_AWPROT
//  .S00_AXI_AWQOS(S00_AXI_AWQOS),                // input wire [3 : 0] S00_AXI_AWQOS
//  .S00_AXI_AWVALID(S00_AXI_AWVALID),            // input wire S00_AXI_AWVALID
//  .S00_AXI_AWREADY(S00_AXI_AWREADY),            // output wire S00_AXI_AWREADY
//  .S00_AXI_WDATA(S00_AXI_WDATA),                // input wire [31 : 0] S00_AXI_WDATA
//  .S00_AXI_WSTRB(S00_AXI_WSTRB),                // input wire [3 : 0] S00_AXI_WSTRB
//  .S00_AXI_WLAST(S00_AXI_WLAST),                // input wire S00_AXI_WLAST
//  .S00_AXI_WVALID(S00_AXI_WVALID),              // input wire S00_AXI_WVALID
//  .S00_AXI_WREADY(S00_AXI_WREADY),              // output wire S00_AXI_WREADY
//  .S00_AXI_BID(S00_AXI_BID),                    // output wire [0 : 0] S00_AXI_BID
//  .S00_AXI_BRESP(S00_AXI_BRESP),                // output wire [1 : 0] S00_AXI_BRESP
//  .S00_AXI_BVALID(S00_AXI_BVALID),              // output wire S00_AXI_BVALID
//  .S00_AXI_BREADY(S00_AXI_BREADY),              // input wire S00_AXI_BREADY
//  .S00_AXI_ARID(S00_AXI_ARID),                  // input wire [0 : 0] S00_AXI_ARID
//  .S00_AXI_ARADDR(S00_AXI_ARADDR),              // input wire [31 : 0] S00_AXI_ARADDR
//  .S00_AXI_ARLEN(S00_AXI_ARLEN),                // input wire [7 : 0] S00_AXI_ARLEN
//  .S00_AXI_ARSIZE(S00_AXI_ARSIZE),              // input wire [2 : 0] S00_AXI_ARSIZE
//  .S00_AXI_ARBURST(S00_AXI_ARBURST),            // input wire [1 : 0] S00_AXI_ARBURST
//  .S00_AXI_ARLOCK(S00_AXI_ARLOCK),              // input wire S00_AXI_ARLOCK
//  .S00_AXI_ARCACHE(S00_AXI_ARCACHE),            // input wire [3 : 0] S00_AXI_ARCACHE
//  .S00_AXI_ARPROT(S00_AXI_ARPROT),              // input wire [2 : 0] S00_AXI_ARPROT
//  .S00_AXI_ARQOS(S00_AXI_ARQOS),                // input wire [3 : 0] S00_AXI_ARQOS
//  .S00_AXI_ARVALID(S00_AXI_ARVALID),            // input wire S00_AXI_ARVALID
//  .S00_AXI_ARREADY(S00_AXI_ARREADY),            // output wire S00_AXI_ARREADY
//  .S00_AXI_RID(S00_AXI_RID),                    // output wire [0 : 0] S00_AXI_RID
//  .S00_AXI_RDATA(S00_AXI_RDATA),                // output wire [31 : 0] S00_AXI_RDATA
//  .S00_AXI_RRESP(S00_AXI_RRESP),                // output wire [1 : 0] S00_AXI_RRESP
//  .S00_AXI_RLAST(S00_AXI_RLAST),                // output wire S00_AXI_RLAST
//  .S00_AXI_RVALID(S00_AXI_RVALID),              // output wire S00_AXI_RVALID
//  .S00_AXI_RREADY(S00_AXI_RREADY),              // input wire S00_AXI_RREADY
//  .S01_AXI_ARESET_OUT_N(S01_AXI_ARESET_OUT_N),  // output wire S01_AXI_ARESET_OUT_N
//  .S01_AXI_ACLK(S01_AXI_ACLK),                  // input wire S01_AXI_ACLK
//  .S01_AXI_AWID(S01_AXI_AWID),                  // input wire [0 : 0] S01_AXI_AWID
//  .S01_AXI_AWADDR(S01_AXI_AWADDR),              // input wire [31 : 0] S01_AXI_AWADDR
//  .S01_AXI_AWLEN(S01_AXI_AWLEN),                // input wire [7 : 0] S01_AXI_AWLEN
//  .S01_AXI_AWSIZE(S01_AXI_AWSIZE),              // input wire [2 : 0] S01_AXI_AWSIZE
//  .S01_AXI_AWBURST(S01_AXI_AWBURST),            // input wire [1 : 0] S01_AXI_AWBURST
//  .S01_AXI_AWLOCK(S01_AXI_AWLOCK),              // input wire S01_AXI_AWLOCK
//  .S01_AXI_AWCACHE(S01_AXI_AWCACHE),            // input wire [3 : 0] S01_AXI_AWCACHE
//  .S01_AXI_AWPROT(S01_AXI_AWPROT),              // input wire [2 : 0] S01_AXI_AWPROT
//  .S01_AXI_AWQOS(S01_AXI_AWQOS),                // input wire [3 : 0] S01_AXI_AWQOS
//  .S01_AXI_AWVALID(S01_AXI_AWVALID),            // input wire S01_AXI_AWVALID
//  .S01_AXI_AWREADY(S01_AXI_AWREADY),            // output wire S01_AXI_AWREADY
//  .S01_AXI_WDATA(S01_AXI_WDATA),                // input wire [31 : 0] S01_AXI_WDATA
//  .S01_AXI_WSTRB(S01_AXI_WSTRB),                // input wire [3 : 0] S01_AXI_WSTRB
//  .S01_AXI_WLAST(S01_AXI_WLAST),                // input wire S01_AXI_WLAST
//  .S01_AXI_WVALID(S01_AXI_WVALID),              // input wire S01_AXI_WVALID
//  .S01_AXI_WREADY(S01_AXI_WREADY),              // output wire S01_AXI_WREADY
//  .S01_AXI_BID(S01_AXI_BID),                    // output wire [0 : 0] S01_AXI_BID
//  .S01_AXI_BRESP(S01_AXI_BRESP),                // output wire [1 : 0] S01_AXI_BRESP
//  .S01_AXI_BVALID(S01_AXI_BVALID),              // output wire S01_AXI_BVALID
//  .S01_AXI_BREADY(S01_AXI_BREADY),              // input wire S01_AXI_BREADY
//  .S01_AXI_ARID(S01_AXI_ARID),                  // input wire [0 : 0] S01_AXI_ARID
//  .S01_AXI_ARADDR(S01_AXI_ARADDR),              // input wire [31 : 0] S01_AXI_ARADDR
//  .S01_AXI_ARLEN(S01_AXI_ARLEN),                // input wire [7 : 0] S01_AXI_ARLEN
//  .S01_AXI_ARSIZE(S01_AXI_ARSIZE),              // input wire [2 : 0] S01_AXI_ARSIZE
//  .S01_AXI_ARBURST(S01_AXI_ARBURST),            // input wire [1 : 0] S01_AXI_ARBURST
//  .S01_AXI_ARLOCK(S01_AXI_ARLOCK),              // input wire S01_AXI_ARLOCK
//  .S01_AXI_ARCACHE(S01_AXI_ARCACHE),            // input wire [3 : 0] S01_AXI_ARCACHE
//  .S01_AXI_ARPROT(S01_AXI_ARPROT),              // input wire [2 : 0] S01_AXI_ARPROT
//  .S01_AXI_ARQOS(S01_AXI_ARQOS),                // input wire [3 : 0] S01_AXI_ARQOS
//  .S01_AXI_ARVALID(S01_AXI_ARVALID),            // input wire S01_AXI_ARVALID
//  .S01_AXI_ARREADY(S01_AXI_ARREADY),            // output wire S01_AXI_ARREADY
//  .S01_AXI_RID(S01_AXI_RID),                    // output wire [0 : 0] S01_AXI_RID
//  .S01_AXI_RDATA(S01_AXI_RDATA),                // output wire [31 : 0] S01_AXI_RDATA
//  .S01_AXI_RRESP(S01_AXI_RRESP),                // output wire [1 : 0] S01_AXI_RRESP
//  .S01_AXI_RLAST(S01_AXI_RLAST),                // output wire S01_AXI_RLAST
//  .S01_AXI_RVALID(S01_AXI_RVALID),              // output wire S01_AXI_RVALID
//  .S01_AXI_RREADY(S01_AXI_RREADY),              // input wire S01_AXI_RREADY
//  .M00_AXI_ARESET_OUT_N(M00_AXI_ARESET_OUT_N),  // output wire M00_AXI_ARESET_OUT_N
//  .M00_AXI_ACLK(M00_AXI_ACLK),                  // input wire M00_AXI_ACLK
//  .M00_AXI_AWID(M00_AXI_AWID),                  // output wire [3 : 0] M00_AXI_AWID
//  .M00_AXI_AWADDR(M00_AXI_AWADDR),              // output wire [31 : 0] M00_AXI_AWADDR
//  .M00_AXI_AWLEN(M00_AXI_AWLEN),                // output wire [7 : 0] M00_AXI_AWLEN
//  .M00_AXI_AWSIZE(M00_AXI_AWSIZE),              // output wire [2 : 0] M00_AXI_AWSIZE
//  .M00_AXI_AWBURST(M00_AXI_AWBURST),            // output wire [1 : 0] M00_AXI_AWBURST
//  .M00_AXI_AWLOCK(M00_AXI_AWLOCK),              // output wire M00_AXI_AWLOCK
//  .M00_AXI_AWCACHE(M00_AXI_AWCACHE),            // output wire [3 : 0] M00_AXI_AWCACHE
//  .M00_AXI_AWPROT(M00_AXI_AWPROT),              // output wire [2 : 0] M00_AXI_AWPROT
//  .M00_AXI_AWQOS(M00_AXI_AWQOS),                // output wire [3 : 0] M00_AXI_AWQOS
//  .M00_AXI_AWVALID(M00_AXI_AWVALID),            // output wire M00_AXI_AWVALID
//  .M00_AXI_AWREADY(M00_AXI_AWREADY),            // input wire M00_AXI_AWREADY
//  .M00_AXI_WDATA(M00_AXI_WDATA),                // output wire [31 : 0] M00_AXI_WDATA
//  .M00_AXI_WSTRB(M00_AXI_WSTRB),                // output wire [3 : 0] M00_AXI_WSTRB
//  .M00_AXI_WLAST(M00_AXI_WLAST),                // output wire M00_AXI_WLAST
//  .M00_AXI_WVALID(M00_AXI_WVALID),              // output wire M00_AXI_WVALID
//  .M00_AXI_WREADY(M00_AXI_WREADY),              // input wire M00_AXI_WREADY
//  .M00_AXI_BID(M00_AXI_BID),                    // input wire [3 : 0] M00_AXI_BID
//  .M00_AXI_BRESP(M00_AXI_BRESP),                // input wire [1 : 0] M00_AXI_BRESP
//  .M00_AXI_BVALID(M00_AXI_BVALID),              // input wire M00_AXI_BVALID
//  .M00_AXI_BREADY(M00_AXI_BREADY),              // output wire M00_AXI_BREADY
//  .M00_AXI_ARID(M00_AXI_ARID),                  // output wire [3 : 0] M00_AXI_ARID
//  .M00_AXI_ARADDR(M00_AXI_ARADDR),              // output wire [31 : 0] M00_AXI_ARADDR
//  .M00_AXI_ARLEN(M00_AXI_ARLEN),                // output wire [7 : 0] M00_AXI_ARLEN
//  .M00_AXI_ARSIZE(M00_AXI_ARSIZE),              // output wire [2 : 0] M00_AXI_ARSIZE
//  .M00_AXI_ARBURST(M00_AXI_ARBURST),            // output wire [1 : 0] M00_AXI_ARBURST
//  .M00_AXI_ARLOCK(M00_AXI_ARLOCK),              // output wire M00_AXI_ARLOCK
//  .M00_AXI_ARCACHE(M00_AXI_ARCACHE),            // output wire [3 : 0] M00_AXI_ARCACHE
//  .M00_AXI_ARPROT(M00_AXI_ARPROT),              // output wire [2 : 0] M00_AXI_ARPROT
//  .M00_AXI_ARQOS(M00_AXI_ARQOS),                // output wire [3 : 0] M00_AXI_ARQOS
//  .M00_AXI_ARVALID(M00_AXI_ARVALID),            // output wire M00_AXI_ARVALID
//  .M00_AXI_ARREADY(M00_AXI_ARREADY),            // input wire M00_AXI_ARREADY
//  .M00_AXI_RID(M00_AXI_RID),                    // input wire [3 : 0] M00_AXI_RID
//  .M00_AXI_RDATA(M00_AXI_RDATA),                // input wire [31 : 0] M00_AXI_RDATA
//  .M00_AXI_RRESP(M00_AXI_RRESP),                // input wire [1 : 0] M00_AXI_RRESP
//  .M00_AXI_RLAST(M00_AXI_RLAST),                // input wire M00_AXI_RLAST
//  .M00_AXI_RVALID(M00_AXI_RVALID),              // input wire M00_AXI_RVALID
//  .M00_AXI_RREADY(M00_AXI_RREADY)              // output wire M00_AXI_RREADY
//);

//blk_mem_gen_0 blk_mem_gen_0_inst (
//  .s_aclk(s_aclk),                // input wire s_aclk
//  .s_aresetn(s_aresetn),          // input wire s_aresetn
//  .s_axi_awid(s_axi_awid),        // input wire [3 : 0] s_axi_awid
//  .s_axi_awaddr(s_axi_awaddr),    // input wire [31 : 0] s_axi_awaddr
//  .s_axi_awlen(s_axi_awlen),      // input wire [7 : 0] s_axi_awlen
//  .s_axi_awsize(s_axi_awsize),    // input wire [2 : 0] s_axi_awsize
//  .s_axi_awburst(s_axi_awburst),  // input wire [1 : 0] s_axi_awburst
//  .s_axi_awvalid(s_axi_awvalid),  // input wire s_axi_awvalid
//  .s_axi_awready(s_axi_awready),  // output wire s_axi_awready
//  .s_axi_wdata(s_axi_wdata),      // input wire [31 : 0] s_axi_wdata
//  .s_axi_wstrb(s_axi_wstrb),      // input wire [3 : 0] s_axi_wstrb
//  .s_axi_wlast(s_axi_wlast),      // input wire s_axi_wlast
//  .s_axi_wvalid(s_axi_wvalid),    // input wire s_axi_wvalid
//  .s_axi_wready(s_axi_wready),    // output wire s_axi_wready
//  .s_axi_bid(s_axi_bid),          // output wire [3 : 0] s_axi_bid
//  .s_axi_bresp(s_axi_bresp),      // output wire [1 : 0] s_axi_bresp
//  .s_axi_bvalid(s_axi_bvalid),    // output wire s_axi_bvalid
//  .s_axi_bready(s_axi_bready),    // input wire s_axi_bready
//  .s_axi_arid(s_axi_arid),        // input wire [3 : 0] s_axi_arid
//  .s_axi_araddr(s_axi_araddr),    // input wire [31 : 0] s_axi_araddr
//  .s_axi_arlen(s_axi_arlen),      // input wire [7 : 0] s_axi_arlen
//  .s_axi_arsize(s_axi_arsize),    // input wire [2 : 0] s_axi_arsize
//  .s_axi_arburst(s_axi_arburst),  // input wire [1 : 0] s_axi_arburst
//  .s_axi_arvalid(s_axi_arvalid),  // input wire s_axi_arvalid
//  .s_axi_arready(s_axi_arready),  // output wire s_axi_arready
//  .s_axi_rid(s_axi_rid),          // output wire [3 : 0] s_axi_rid
//  .s_axi_rdata(s_axi_rdata),      // output wire [31 : 0] s_axi_rdata
//  .s_axi_rresp(s_axi_rresp),      // output wire [1 : 0] s_axi_rresp
//  .s_axi_rlast(s_axi_rlast),      // output wire s_axi_rlast
//  .s_axi_rvalid(s_axi_rvalid),    // output wire s_axi_rvalid
//  .s_axi_rready(s_axi_rready)    // input wire s_axi_rready
//);

endmodule
