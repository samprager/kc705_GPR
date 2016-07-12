`timescale 1ps/100fs

module sim_tb_cmd_decoder;

   localparam AXI_TCLK_PERIOD          = 10000;         // 100 MHz
   localparam GTX_TCLK_PERIOD          = 8000;         // 125 MHz
   localparam FMC_TCLK_PERIOD          = 4069;         // 245.76 MHz
   localparam RESET_PERIOD = 320000; //in pSec
   localparam HOST_MAC_ADDR = 48'h985aebdb066f;
   localparam FPGA_MAC_ADDR = 48'h5a0102030405;

    reg axi_tresetn_i;
    reg axi_tclk_i;

    reg gtx_tresetn_i;
    reg gtx_tclk_i;

    reg fmc_tresetn_i;
    reg fmc_tclk_i;

  wire [7:0] gpio_led;

   wire                   axi_tclk;
   wire                   axi_tresetn;

   wire                   gtx_tclk;
   wire                   gtx_tresetn;

   wire                   fmc_tclk;
   wire                   fmc_tresetn;

     // data from ADC Data fifo
  reg       [7:0]                    rx_axis_tdata_reg;
  reg                                rx_axis_tvalid_reg;
  reg                                rx_axis_tlast_reg;
  reg                                rx_axis_tuser_reg;
  
  reg [7:0]                     temp_data;

         // data from ADC Data fifo
wire       [7:0]                   rx_axis_tdata;
wire                                rx_axis_tvalid;
wire                                rx_axis_tlast;
wire                                rx_axis_tuser;

 wire                               rx_axis_tready;


 wire      [7:0]                    tx_axis_tdata;
 wire                               tx_axis_tvalid;
 wire                               tx_axis_tlast;
 wire                                tx_axis_tready;

 reg                                tx_axis_tready_reg;

 reg                tready_reg;
 reg                rx_axis_tvalid_select;

 reg [7:0]         data_counter = 'b0;
 reg [1:0]               test_flop = 2'b0;

 reg [6*8-1:0]     fpga_mac = FPGA_MAC_ADDR;
 reg [7:0] cmd_id_reg = 8'h00;
 

 wire     frame_error;
 wire activity_flash;
 //**************************************************************************//
  // Reset Generation
  //**************************************************************************//
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
      tx_axis_tready_reg = 1'b1; // initial value
      @(posedge gtx_tresetn_i); // wait for reset
      tx_axis_tready_reg = 1'b0;
      repeat(32) @(posedge gtx_tclk_i);
      tx_axis_tready_reg = 1'b1;
      repeat(8192) @(posedge gtx_tclk_i);
      // tx_axis_tready_reg = 1'b0;
      // repeat(32) @(posedge gtx_tclk_i);
      // tx_axis_tready_reg = 1'b0;
      // repeat(1) @(posedge gtx_tclk_i);
      // tx_axis_tready_reg = 1'b1;
      // repeat(3) @(posedge gtx_tclk_i);
      // tx_axis_tready_reg = 1'b0;
      // repeat(1) @(posedge gtx_tclk_i);
      // tx_axis_tready_reg = 1'b1;
      // repeat(2) @(posedge gtx_tclk_i);
      // tx_axis_tready_reg = 1'b0;
      // repeat(1) @(posedge gtx_tclk_i);
      // tx_axis_tready_reg = 1'b1;
      // repeat(1) @(posedge gtx_tclk_i);
      // tx_axis_tready_reg = 1'b0;
      // repeat(256) @(posedge gtx_tclk_i);
      // tx_axis_tready_reg = 1'b1;
      // repeat(2048) @(posedge gtx_tclk_i);
      // tx_axis_tready_reg = 1'b0;
      // repeat(2048) @(posedge gtx_tclk_i);
      // tx_axis_tready_reg = 1'b1;
      // repeat(2048) @(posedge gtx_tclk_i);
      $finish;
    end

    always @(posedge  gtx_tclk_i) begin
       if (~gtx_tresetn_i) begin
           data_counter <= 'b0;
           rx_axis_tdata_reg <= 8'h02;
           rx_axis_tvalid_reg <= 1'b0;
           rx_axis_tlast_reg <= 1'b0;
           rx_axis_tuser_reg <= 1'b0;
           cmd_id_reg <= 'b0;
       end else begin
           data_counter <= data_counter + 1'b1;
           if (data_counter < 8'h40)
               rx_axis_tvalid_reg <= 1'b0;
           else
               rx_axis_tvalid_reg <= 1'b1;
           if (data_counter == 8'hff)
              rx_axis_tlast_reg <= 1'b1;
           else
               rx_axis_tlast_reg <= 1'b0;

           if (data_counter >=8'h40 & data_counter<8'h46) begin
               rx_axis_tdata_reg <= fpga_mac[48-8*(data_counter-8'h40)-1-:8];
           end else if (data_counter == 8'h4c) begin
               rx_axis_tdata_reg <= 8'h00;
               temp_data <=rx_axis_tdata_reg+1'b1;
           end else if (data_counter == 8'h4d) begin
               rx_axis_tdata_reg <= 8'h22;
               temp_data <= temp_data + 1'b1;
           end else if (data_counter == 8'h4e) begin
              // rx_axis_tdata_reg <= 8'hd1;
              rx_axis_tdata_reg <= temp_data +1'b1;
   //        end else if (data_counter==8'h50) begin
   //             rx_axis_tdata_reg <= 8'h57;
   //             temp_data <=rx_axis_tdata_reg+1'b1;
           end else if (data_counter>=8'h50 & data_counter<8'h54)
             rx_axis_tdata_reg <= 8'h57;
           else if (data_counter == 8'h54) begin
             rx_axis_tdata_reg <= cmd_id_reg;
             cmd_id_reg <= cmd_id_reg+1;
           end else if (data_counter == 8'h55) begin
             rx_axis_tdata_reg <= temp_data + 8'h08;
           end else if (rx_axis_tvalid_reg & rx_axis_tready & !rx_axis_tlast_reg)
               rx_axis_tdata_reg <= rx_axis_tdata_reg + 1'b1;
           else if (data_counter == 8'h40)
               rx_axis_tdata_reg <= rx_axis_tdata_reg + 1'b1;                          
        end
      end


 cmd_decoder_top #(
  ) u_cmd_decoder_top (
        .gtx_clk_bufg (gtx_tclk),
        .gtx_resetn (gtx_tresetn),
        .s_axi_aclk (axi_tclk),
        .s_axi_resetn (axi_tresetn),
        .clk_fmc150 (fmc_tclk),
        .resetn_fmc150 (fmc_tresetn),

        .gpio_dip_sw        (8'hff),
        .gpio_led        (gpio_led),
    // data from the RX data path
        .tx_axis_tdata       (tx_axis_tdata),
        .tx_axis_tvalid       (tx_axis_tvalid),
        .tx_axis_tlast       (tx_axis_tlast),
        .tx_axis_tready      (tx_axis_tready),

            .rx_axis_tdata       (rx_axis_tdata),
            .rx_axis_tvalid       (rx_axis_tvalid),
            .rx_axis_tlast       (rx_axis_tlast),
            .rx_axis_tready      (rx_axis_tready)

);

assign tx_axis_tready = tx_axis_tready_reg;

assign rx_axis_tdata =  rx_axis_tdata_reg;
assign rx_axis_tvalid =  rx_axis_tvalid_reg;
assign rx_axis_tlast =  rx_axis_tlast_reg;
assign rx_axis_tuser =  rx_axis_tuser_reg;





endmodule
