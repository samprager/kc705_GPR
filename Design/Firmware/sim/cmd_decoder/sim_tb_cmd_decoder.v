`timescale 1ps/100fs

module sim_tb_cmd_decoder;

   localparam AXI_TCLK_PERIOD          = 8000;         // 125 MHz
  localparam RESET_PERIOD = 320000; //in pSec

    reg axi_tresetn_i;
    reg axi_tclk_i;

   wire                   axi_tclk;
   wire                   axi_tresetn;

     // data from ADC Data fifo
  reg       [31:0]                    rx_axis_tdata_reg;
  reg                                rx_axis_tvalid_reg;
  reg                                rx_axis_tlast_reg;
  reg                                rx_axis_tuser_reg;

         // data from ADC Data fifo
wire       [31:0]                   rx_axis_tdata;
wire                                rx_axis_tvalid;
wire                                rx_axis_tlast;
wire                                rx_axis_tuser;

 wire                               rx_axis_tready;


 wire  [31:0]       tdata;
 wire              tvalid;
 wire              tlast;
 wire              tready;

 // data TO the TX data path
 //        .tx_axis_tdata       (tx_axis_tdata),
 //        .tx_axis_tvalid       (tx_axis_tvalid),
 //        .tx_axis_tlast       (tx_axis_tlast),
 //        .tx_axis_tready      (tx_axis_tready)
 wire      [7:0]                    tx_axis_tdata;
 wire                               tx_axis_tvalid;
 wire                               tx_axis_tlast;
 wire                                tx_axis_tready;

 reg                                tx_axis_tready_reg;

 reg                tready_reg;
 reg                rx_axis_tvalid_select;

 reg [31:0]         data_counter = 'b0;
 reg [1:0]               test_flop = 2'b0;
 reg [31:0]       cmd_id;

 reg [6*8-1:0]     dest_mac_addr = 48'h5a0102030405;

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


   assign axi_tresetn = axi_tresetn_i;
   assign axi_tclk = axi_tclk_i;


 initial begin
      tx_axis_tready_reg = 1'b1; // initial value
      @(posedge axi_tresetn_i); // wait for reset
      tx_axis_tready_reg = 1'b0;
      repeat(32) @(posedge axi_tclk_i);
      tx_axis_tready_reg = 1'b1;
      repeat(256) @(posedge axi_tclk_i);
      tx_axis_tready_reg = 1'b0;
      repeat(32) @(posedge axi_tclk_i);
      tx_axis_tready_reg = 1'b0;
      repeat(1) @(posedge axi_tclk_i);
      tx_axis_tready_reg = 1'b1;
      repeat(3) @(posedge axi_tclk_i);
      tx_axis_tready_reg = 1'b0;
      repeat(1) @(posedge axi_tclk_i);
      tx_axis_tready_reg = 1'b1;
      repeat(2) @(posedge axi_tclk_i);
      tx_axis_tready_reg = 1'b0;
      repeat(1) @(posedge axi_tclk_i);
      tx_axis_tready_reg = 1'b1;
      repeat(1) @(posedge axi_tclk_i);
      tx_axis_tready_reg = 1'b0;
      repeat(256) @(posedge axi_tclk_i);
      tx_axis_tready_reg = 1'b1;
      repeat(2048) @(posedge axi_tclk_i);
      tx_axis_tready_reg = 1'b0;
      repeat(2048) @(posedge axi_tclk_i);
      tx_axis_tready_reg = 1'b1;
      repeat(2048) @(posedge axi_tclk_i);
      $finish;
    end

 always @(posedge  axi_tclk_i) begin
    if (~axi_tresetn_i) begin
        data_counter <= 'b0;
        rx_axis_tdata_reg <= 'b0;
        rx_axis_tvalid_reg <= 1'b0;
        rx_axis_tlast_reg <= 1'b0;
        rx_axis_tuser_reg <= 1'b0;
        cmd_id <= 32'ha;
    end else begin
        rx_axis_tvalid_reg <= 1'b1;
        if (rx_axis_tready & rx_axis_tvalid) begin
            if (data_counter == 0)
                rx_axis_tdata_reg <= 32'h57575757;
            else if (data_counter == 1)
                rx_axis_tdata_reg <= cmd_id;
            else
                rx_axis_tdata_reg <= data_counter;
        end
       // if (&rx_axis_tdata_reg[5:0]) begin
        if (data_counter == 32'h7) begin
            rx_axis_tlast_reg <= 1'b1;
            data_counter <= 0;
            test_flop <= test_flop+1'b1;
        end else if (rx_axis_tready & rx_axis_tvalid)begin
            rx_axis_tlast_reg <= 1'b0;
            data_counter <= data_counter + 1'b1;
        end

        if (&test_flop)
          cmd_id <= cmd_id + 1'b1;
    end
end


 initial begin
     rx_axis_tvalid_select = 1'b0; // initial value
     @(posedge axi_tresetn_i); // wait for reset
     rx_axis_tvalid_select = 1'b0;
     repeat(300) @(posedge axi_tclk_i);
     rx_axis_tvalid_select = 1'b1;
     repeat(150) @(posedge axi_tclk_i);
     rx_axis_tvalid_select = 1'b0;
     repeat(32) @(posedge axi_tclk_i);
     rx_axis_tvalid_select = 1'b1;
     repeat(1) @(posedge axi_tclk_i);
     rx_axis_tvalid_select = 1'b1;
     repeat(3) @(posedge axi_tclk_i);
     rx_axis_tvalid_select = 1'b0;
     repeat(1) @(posedge axi_tclk_i);
     rx_axis_tvalid_select = 1'b1;
     repeat(2) @(posedge axi_tclk_i);
     rx_axis_tvalid_select = 1'b0;
     repeat(1) @(posedge axi_tclk_i);
     rx_axis_tvalid_select = 1'b1;
     repeat(1) @(posedge axi_tclk_i);
     rx_axis_tvalid_select = 1'b0;
     repeat(20) @(posedge axi_tclk_i);
     rx_axis_tvalid_select = 1'b1;
     repeat(1000) @(posedge axi_tclk_i);
     rx_axis_tvalid_select = 1'b0;
     repeat(2000) @(posedge axi_tclk_i);
     rx_axis_tvalid_select = 1'b1;
   end

// initial begin
//     rx_axis_tdata_reg = 7'b0;
//     rx_axis_tvalid_reg = 1'b0;
//     rx_axis_tlast_reg = 1'b0;
//     rx_axis_tuser_reg = 1'b0;
// end

 axi_rx_command_gen #(
  ) u_cmd_decoder_top (
        .axi_tclk (axi_tclk),
        .axi_tresetn (axi_tresetn),

        .enable_rx_decode        (1'b1),
    // data from the RX data path
            .cmd_axis_tdata       (rx_axis_tdata),
            .cmd_axis_tvalid       (rx_axis_tvalid),
            .cmd_axis_tlast       (rx_axis_tlast),
            .cmd_axis_tready      (rx_axis_tready),

    // data TO the TX data path
            .tdata       (tx_axis_tdata),
            .tvalid       (tx_axis_tvalid),
            .tlast       (tx_axis_tlast),
            .tready      (tx_axis_tready)

);

//kc705_ethernet_rgmii_axi_packetizer u_packetizer_top
//(
//       .axi_tclk (axi_tclk),
//       .axi_tresetn (axi_tresetn),

//        .enable_adc_pkt (1'b1),
//        .speed  (2'b10),

//    // data from ADC Data fifo
//        .rx_axis_tdata               (rx_axis_tdata),
//        .rx_axis_tvalid              (rx_axis_tvalid),
//        .rx_axis_tlast              (rx_axis_tlast),
//        .rx_axis_tuser          (rx_axis_tuser),
//        .rx_axis_tready              (rx_axis_tready),

//        .tdata       (tdata),
//        .tvalid       (tvalid),
//        .tlast       (tlast),
//        .tready       (tready)
//);

assign tx_axis_tready = tx_axis_tready_reg;

assign rx_axis_tdata =  rx_axis_tdata_reg;
assign rx_axis_tvalid =  rx_axis_tvalid_reg & rx_axis_tvalid_select;
assign rx_axis_tlast =  rx_axis_tlast_reg;
assign rx_axis_tuser =  rx_axis_tuser_reg;



endmodule
