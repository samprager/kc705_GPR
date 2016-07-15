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
    
    localparam NUM_WRITE = 'h80;            // 32 bit words to write
    localparam NUM_BTT = 4*NUM_WRITE;       // bytes to transfer
    
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
    
    reg [31:0] rd_addr = 32'hC0000000;
    reg [31:0] wr_addr = 32'hC0000000;
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
         S_AXIS_S2MM_CMD_tdata_reg[30] <= 1'b1;    // eof
        S_AXIS_S2MM_CMD_tdata_reg[23] <= INCR;
        S_AXIS_S2MM_CMD_tdata_reg[22:0] <= NUM_BTT;
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
        S_AXIS_MM2S_CMD_tdata_reg[30] <= 1'b1;      // eof
        S_AXIS_MM2S_CMD_tdata_reg[23] <= INCR;
        S_AXIS_MM2S_CMD_tdata_reg[22:0] <= NUM_BTT;
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


endmodule
