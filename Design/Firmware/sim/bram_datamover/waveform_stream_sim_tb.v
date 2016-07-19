`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2016 04:32:51 PM
// Design Name: 
// Module Name: datamover_bram_sim_tb
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


module waveform_stream_sim_tb;

localparam FMC_TCLK_PERIOD          = 4069;         // 245.76 MHz
localparam RESET_PERIOD = 16276; //in pSec 
reg fmc_tresetn_i;
reg fmc_tclk_i;   
wire                   fmc_tclk;
wire                   fmc_tresetn;

wire [127:0] waveform_parameters;
wire init_wf_write;
wire wf_write_ready;
wire wf_read_ready;
// data from ADC Data fifo
wire       [31:0]                    wfin_axis_tdata;
wire                                 wfin_axis_tvalid;
wire                                 wfin_axis_tlast;
wire       [3:0]                    wfin_axis_tkeep;
wire                                wfin_axis_tready;

// data from ADC Data fifo
wire       [31:0]                    wfout_axis_tdata;
wire                                 wfout_axis_tvalid;
wire                                 wfout_axis_tlast;
wire       [3:0]                     wfout_axis_tkeep;
wire                                wfout_axis_tready;

reg                                 init_wf_write_reg = 0;
reg      [127:0]                    waveform_parameters_reg = 'b0;

reg       [31:0]                    wfin_axis_tdata_reg;
reg                                 wfin_axis_tvalid_reg;
reg                                 wfin_axis_tlast_reg;
reg       [3:0]                    wfin_axis_tkeep_reg;
reg                                wfout_axis_tready_reg = 0;

reg [7:0]               counter = 'b0;
reg [7:0]               wr_counter = 'b0;
reg [7:0]               rd_counter = 'b0;
reg                     wf_written = 0;
        
initial
begin
      fmc_tclk_i = 1'b0;
end

initial begin
  fmc_tresetn_i = 1'b0;
  #RESET_PERIOD
    fmc_tresetn_i = 1'b1;
 end
 
always
  begin
      fmc_tclk_i = #(FMC_TCLK_PERIOD/2.0) ~fmc_tclk_i;
end    

assign fmc_tresetn = fmc_tresetn_i;
assign fmc_tclk = fmc_tclk_i;

initial begin
      repeat(4096)@(posedge fmc_tclk_i); // wait for reset
      $finish;
end

always @(posedge fmc_tclk) begin
    if (!fmc_tresetn) begin
        init_wf_write_reg <= 0;
        wfin_axis_tdata_reg <= 'b0;
        wfin_axis_tvalid_reg <= 0;
        wfin_axis_tlast_reg <= 0;
        wfin_axis_tkeep_reg <= 'b0;
        wfout_axis_tready_reg <= 0;
        counter <= 0;
        wr_counter <= 0;
        rd_counter <= 0;
        wf_written <= 0;
    end
    else begin
        counter <= counter + 1'b1;
        wfout_axis_tready_reg <= 1'b1;
        //wfout_axis_tready_reg <= wf_written;
        if (counter == 0) begin
            init_wf_write_reg <= 1'b1;
            waveform_parameters_reg[31:0] <= 32'h00000080; 
            wr_counter <= 'b0;
            rd_counter <= 'b0;
        end    
        else begin
            if (wf_write_ready) begin
                init_wf_write_reg <= 1'b0;
            end    
            if (wr_counter <( waveform_parameters_reg[7:0]-1)) begin
                 wfin_axis_tvalid_reg <= 1'b1;
                 wfin_axis_tkeep_reg <= 4'hf;
                 if (wr_counter == ( waveform_parameters_reg[7:0]-2)) begin
                    wfin_axis_tlast_reg <= 1'b1;
                    wf_written <= 1'b1;
                 end
                 else if (wfin_axis_tready) begin
                    wfin_axis_tlast_reg <= 1'b0;
                 end
            end
            else if (wfin_axis_tready) begin
                wfin_axis_tvalid_reg <= 0;
                wfin_axis_tlast_reg <= 1'b0;
            end        
            if  (wfin_axis_tvalid_reg & wfin_axis_tready) begin
               wfin_axis_tdata_reg <= counter;   
               wr_counter <= wr_counter + 1'b1;
            end              
        end
        if (wfout_axis_tready_reg & wfout_axis_tvalid) begin
            rd_counter <= rd_counter + 1'b1;
        end
    end        
end

waveform_stream #(
   .WRITE_BEFORE_READ(1'b1)
) u_waveform_stream(
    .clk_in1(fmc_tclk),
    .aresetn(fmc_tresetn),
    .waveform_parameters(waveform_parameters),
    .init_wf_write (init_wf_write),
    .wf_write_ready (wf_write_ready),
    .wf_read_ready (wf_read_ready),
    // data from ADC Data fifo
    .wfin_axis_tdata (wfin_axis_tdata),
    .wfin_axis_tvalid(wfin_axis_tvalid),
    .wfin_axis_tlast(wfin_axis_tlast),
    .wfin_axis_tkeep(wfin_axis_tkeep),
    .wfin_axis_tready(wfin_axis_tready),

    // data from ADC Data fifo
    .wfout_axis_tdata(wfout_axis_tdata),
    .wfout_axis_tvalid(wfout_axis_tvalid),
    .wfout_axis_tlast(wfout_axis_tlast),
    .wfout_axis_tkeep(wfout_axis_tkeep),
    .wfout_axis_tready(wfout_axis_tready)
);

assign init_wf_write = init_wf_write_reg;
assign wfin_axis_tdata = wfin_axis_tdata_reg;
assign wfin_axis_tvalid = wfin_axis_tvalid_reg;
assign wfin_axis_tlast = wfin_axis_tlast_reg;
assign wfin_axis_tkeep = wfin_axis_tkeep_reg;
assign wfout_axis_tready = wfout_axis_tready_reg;

assign waveform_parameters = waveform_parameters_reg;
   
endmodule