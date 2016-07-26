`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 07/25/2016 10:31:34 PM
// Design Name:
// Module Name: peakfinder_sim
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


module peakfinder_sim(

    );
       localparam AXI_TCLK_PERIOD          = 10000;         // 100 MHz
    localparam GTX_TCLK_PERIOD          = 8000;         // 125 MHz
    localparam FMC_TCLK_PERIOD          = 4069;         // 245.76 MHz
    localparam RESET_PERIOD = 320000; //in pSec

        reg axi_tresetn_i;
        reg axi_tclk_i;

        reg gtx_tresetn_i;
        reg gtx_tclk_i;

        reg fmc_tresetn_i;
        reg fmc_tclk_i;

        reg [7:0] counter;

           wire                   axi_tclk;
        wire                   axi_tresetn;

        wire                   gtx_tclk;
        wire                   gtx_tresetn;

        wire                   fmc_tclk;
        wire                   fmc_tresetn;

        wire [63:0] m_fft_i_axis_tdata;
        wire m_fft_i_axis_tvalid;
        wire m_fft_i_axis_tlast;
        wire m_fft_i_axis_tready;

        reg m_fft_i_axis_tvalid_r;
        reg m_fft_i_axis_tlast_r;

        wire [63:0] m_fft_q_axis_tdata;
        wire m_fft_q_axis_tvalid;
        wire m_fft_q_axis_tlast;
        wire m_fft_q_axis_tready;

        reg m_fft_q_axis_tvalid_r;
        reg m_fft_q_axis_tlast_r;

             wire [63:0] sq_mag_i_axis_tdata;
        wire        sq_mag_i_axis_tvalid;
        wire        sq_mag_i_axis_tlast;
        wire [31:0] sq_mag_i_axis_tuser;
        wire [63:0] sq_mag_q_axis_tdata;
        wire        sq_mag_q_axis_tvalid;
        wire        sq_mag_q_axis_tlast;
        wire [31:0] sq_mag_q_axis_tuser;
        wire       sq_mag_i_axis_tdata_overflow;
        wire       sq_mag_q_axis_tdata_overflow;

        wire [31:0] peak_index_i;
        wire [63:0] peak_tdata_i;
        wire peak_tvalid_i;

        wire [31:0] peak_index_q;
        wire [63:0] peak_tdata_q;
        wire peak_tvalid_q;

     initial begin
          axi_tresetn_i = 1'b0;
          #RESET_PERIOD
            axi_tresetn_i = 1'b1;
         end

         initial begin
           gtx_tresetn_i = 1'b0;
           #RESET_PERIOD
             gtx_tresetn_i = 1'b1;
          end

          initial begin
            fmc_tresetn_i = 1'b0;
            #RESET_PERIOD
              fmc_tresetn_i = 1'b1;
           end

        //**************************************************************************//
        // Clock Generation
        //**************************************************************************//

        initial
          begin
              axi_tclk_i = 1'b0;
          end
        always
          begin
              axi_tclk_i = #(AXI_TCLK_PERIOD/2.0) ~axi_tclk_i;
          end

        initial
          begin
              gtx_tclk_i = 1'b0;
          end
        always
          begin
              gtx_tclk_i = #(GTX_TCLK_PERIOD/2.0) ~gtx_tclk_i;
          end

        initial
          begin
              fmc_tclk_i = 1'b0;
          end
        always
          begin
              fmc_tclk_i = #(FMC_TCLK_PERIOD/2.0) ~fmc_tclk_i;
          end

         assign axi_tresetn = axi_tresetn_i;
         assign axi_tclk = axi_tclk_i;

         assign gtx_tresetn = gtx_tresetn_i;
         assign gtx_tclk = gtx_tclk_i;

         assign fmc_tresetn = fmc_tresetn_i;
         assign fmc_tclk = fmc_tclk_i;

         initial begin
              repeat(4096) @(posedge fmc_tclk_i);
              $finish;
            end

            always @(posedge  fmc_tclk_i) begin
              if (~fmc_tresetn_i) begin
                   counter <= 'b0;
                  m_fft_i_axis_tvalid_r <= 1'b0;
                  m_fft_q_axis_tvalid_r<= 1'b0;
                  m_fft_i_axis_tlast_r <= 1'b0;
                  m_fft_q_axis_tlast_r <= 1'b0;
              end else begin
                  counter <= counter + 1'b1;
                  if (counter <= 8'hfa) begin
                    m_fft_i_axis_tvalid_r <= 1'b1;
                    m_fft_q_axis_tvalid_r<= 1'b1;
                    if (counter == 8'hfa) begin
                      m_fft_i_axis_tlast_r <= 1'b1;
                      m_fft_q_axis_tlast_r <= 1'b1;
                    end else begin
                        m_fft_i_axis_tlast_r <= 1'b0;
                        m_fft_q_axis_tlast_r <= 1'b0;
                    end
                  end else begin
                     m_fft_i_axis_tvalid_r <= 1'b0;
                    m_fft_q_axis_tvalid_r <= 1'b0;
                    m_fft_i_axis_tlast_r <= 1'b0;
                    m_fft_q_axis_tlast_r <= 1'b0;
                  end
              end
            end

assign m_fft_i_axis_tdata = {28'b0,counter[7:4],28'b0,counter[3:0]};
assign m_fft_q_axis_tdata = {28'b0,counter[3:0],24'b0,counter};

 assign m_fft_i_axis_tready = 1'b1;
 assign m_fft_q_axis_tready = 1'b1;

 assign m_fft_i_axis_tvalid = m_fft_i_axis_tvalid_r;
assign m_fft_q_axis_tvalid = m_fft_q_axis_tvalid_r;
assign m_fft_i_axis_tlast = m_fft_i_axis_tlast_r;
assign m_fft_q_axis_tlast = m_fft_q_axis_tlast_r;

    sq_mag_estimate#(
        .DATA_LEN(32),
        .DIV_OR_OVERFLOW(0),  // (1): Divide output by 2, (0): use overflow bit
        .REGISTER_OUTPUT(1)
    )
     sq_mag_i (
        .clk(fmc_tclk),
        .dataI(m_fft_i_axis_tdata[31:0]),
        .dataI_tvalid(m_fft_i_axis_tvalid),
        .dataI_tlast(m_fft_i_axis_tlast),
        .dataQ(m_fft_i_axis_tdata[63:32]),
        .dataQ_tvalid(m_fft_i_axis_tvalid),
        .dataQ_tlast(m_fft_i_axis_tlast),
        .data_tuser({24'b0,counter}),
        .dataMagSq(sq_mag_i_axis_tdata),
        .dataMag_tvalid(sq_mag_i_axis_tvalid),
        .dataMag_tlast(sq_mag_i_axis_tlast),
        .dataMag_tuser(sq_mag_i_axis_tuser),
        .overflow(sq_mag_i_axis_tdata_overflow)
    );

    sq_mag_estimate#(
        .DATA_LEN(32),
        .DIV_OR_OVERFLOW(0),     // (1): Divide output by 2, (0): use overflow bit
        .REGISTER_OUTPUT(1)
    )
     sq_mag_q (
       .clk(fmc_tclk),
       .dataI(m_fft_q_axis_tdata[31:0]),
       .dataI_tvalid(m_fft_q_axis_tvalid),
       .dataI_tlast(m_fft_q_axis_tlast),
       .dataQ(m_fft_q_axis_tdata[63:32]),
       .dataQ_tvalid(m_fft_q_axis_tvalid),
       .dataQ_tlast(m_fft_q_axis_tlast),
       .data_tuser({24'b0,counter}),
       .dataMagSq(sq_mag_q_axis_tdata),
       .dataMag_tvalid(sq_mag_q_axis_tvalid),
       .dataMag_tlast(sq_mag_q_axis_tlast),
       .dataMag_tuser(sq_mag_q_axis_tuser),
       .overflow(sq_mag_q_axis_tdata_overflow)
    );

    peak_finder #(
      .DATA_LEN(64)
    ) peak_finder_i(
      .clk(fmc_tclk),
      .aresetn(fmc_tresetn_i),
      .tdata(sq_mag_i_axis_tdata),
      .tvalid(sq_mag_i_axis_tvalid),
      .tlast(sq_mag_i_axis_tlast),
      .index(sq_mag_i_axis_tuser),
      .threshold({64'hff}),
      .peak_index(peak_index_i),
      .peak_tdata(peak_tdata_i),
      .peak_tvalid(peak_tvalid_i)
    );
    peak_finder #(
      .DATA_LEN(64)
    ) peak_finder_q(
      .clk(fmc_tclk),
      .aresetn(fmc_tresetn_i),
      .tdata(sq_mag_q_axis_tdata),
      .tvalid(sq_mag_q_axis_tvalid),
      .tlast(sq_mag_q_axis_tlast),
      .index(sq_mag_q_axis_tuser),
      .threshold({64'hff}),
      .peak_index(peak_index_q),
      .peak_tdata(peak_tdata_q),
      .peak_tvalid(peak_tvalid_q)
    );

endmodule
