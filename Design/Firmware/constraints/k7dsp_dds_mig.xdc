# Set DCI_CASCADE
set_property DCI_CASCADE {32 34} [get_iobanks 33]

#Clock Constraints

create_clock -period 4.069 -name clk_ab_p [get_ports clk_ab_p]
create_clock -period 5.000 -name sysclk_p [get_ports sysclk_p]
set_input_jitter sysclk_p 0.050

#set to use clock backbone - this uses a long route to allow the MMCM to be placed in the other half of the device
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets example_clocks/clkin1]
set_input_jitter [get_clocks -of [get_pins example_clocks/clock_generator/mmcm_adv_inst/CLKOUT1]] 0.050
############################################################
# Get auto-generated clock names                           #
############################################################

set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets fmc150_dac_adc_inst/KC705_fmc150_inst/clk_in1]

set_input_jitter [get_clocks -of [get_pins fmc150_dac_adc_inst/KC705_fmc150_inst/mmcm_adac_inst/inst/mmcm_adv_inst/CLKIN1]] 0.041
set_input_jitter [get_clocks -of [get_pins fmc150_dac_adc_inst/KC705_fmc150_inst/mmcm_inst/inst/mmcm_adv_inst/CLKIN1]] 0.050

# Exception paths
set_clock_groups -physically_exclusive -group [get_clocks -include_generated_clocks -of [get_pins fmc150_dac_adc_inst/KC705_fmc150_inst/mmcm_adac_inst/inst/mmcm_adv_inst/CLKIN1]] -group [get_clocks -include_generated_clocks -of [get_pins fmc150_dac_adc_inst/KC705_fmc150_inst/mmcm_inst/inst/mmcm_adv_inst/CLKIN1]]



#IO Constraints

#FMC_LPC_LA16_P
set_property IOSTANDARD LVCMOS25 [get_ports adc_n_en]
#FMC_LPC_LA15_N
set_property IOSTANDARD LVCMOS25 [get_ports adc_reset]
#FMC_LPC_LA15_P
set_property IOSTANDARD LVCMOS25 [get_ports adc_sdo]
#FMC_LPC_LA30_P
set_property IOSTANDARD LVCMOS25 [get_ports cdce_n_en]
#FMC_LPC_LA31_n
set_property IOSTANDARD LVCMOS25 [get_ports cdce_n_pd]
#FMC_LPC_LA31_P
set_property IOSTANDARD LVCMOS25 [get_ports cdce_n_reset]
#FMC_LPC_LA30_N
set_property IOSTANDARD LVCMOS25 [get_ports cdce_sdo]
#FMC_LPC_LA28_P
set_property IOSTANDARD LVCMOS25 [get_ports dac_n_en]
#FMC_LPC_LA28_N
set_property IOSTANDARD LVCMOS25 [get_ports dac_sdo]
#FMC_LPC_CLK1_M2C_N
#set_property IOSTANDARD LVCMOS25 [get_ports ext_trigger_n]
#FMC_LPC_CLK1_M2C_P
#set_property IOSTANDARD LVCMOS25 [get_ports ext_trigger_p]
#FMC_LPC_LA27_P
set_property IOSTANDARD LVCMOS25 [get_ports mon_n_en]
#FMC_LPC_LA32_N
set_property IOSTANDARD LVCMOS25 [get_ports mon_n_int]
#FMC_LPC_LA27_N
set_property IOSTANDARD LVCMOS25 [get_ports mon_n_reset]
#FMC_LPC_LA32_P
set_property IOSTANDARD LVCMOS25 [get_ports mon_sdo]
#FMC_LPC_LA33_N
set_property IOSTANDARD LVCMOS25 [get_ports pll_status]
#FMC_LPC_PRSNT_M2C
set_property IOSTANDARD LVCMOS25 [get_ports prsnt_m2c_l]
#FMC_LPC_LA33_P
set_property IOSTANDARD LVCMOS25 [get_ports ref_en]
#FMC_LPC_LA29_P
set_property IOSTANDARD LVCMOS25 [get_ports spi_sclk]
#FMC_LPC_LA29_N
set_property IOSTANDARD LVCMOS25 [get_ports spi_sdata]
#FMC_LPC_LA16_N
set_property IOSTANDARD LVCMOS25 [get_ports txenable]
#
set_property IOSTANDARD LVCMOS15 [get_ports cpu_reset]
set_property SLEW SLOW [get_ports cpu_reset]
set_false_path -from [get_ports cpu_reset]

#
set_property PACKAGE_PIN AD12 [get_ports sysclk_p]
set_property PACKAGE_PIN AD11 [get_ports sysclk_n]

set_property IOSTANDARD DIFF_SSTL15 [get_ports sysclk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sysclk_n]
#set_property IOSTANDARD LVDS [get_ports sysclk_p]
#set_property IOSTANDARD LVDS [get_ports sysclk_n]


#
## 1 on SW1 DIP switch (active-high)
set_property IOSTANDARD LVCMOS25 [get_ports {gpio_dip_sw[0]}]
## 2 on SW1 DIP switch (active-high)
set_property IOSTANDARD LVCMOS25 [get_ports {gpio_dip_sw[1]}]
## 3 on SW1 DIP switch (active-high)
set_property IOSTANDARD LVCMOS25 [get_ports {gpio_dip_sw[2]}]
## 4 on SW1 DIP switch (active-high)
set_property IOSTANDARD LVCMOS25 [get_ports {gpio_dip_sw[3]}]
#
set_property IOSTANDARD LVCMOS15 [get_ports {gpio_led[0]}]
set_property IOSTANDARD LVCMOS15 [get_ports {gpio_led[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports {gpio_led[2]}]
set_property IOSTANDARD LVCMOS15 [get_ports {gpio_led[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpio_led[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpio_led[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpio_led[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {gpio_led[7]}]
#
## LCD_DB4
set_property IOSTANDARD LVCMOS15 [get_ports gpio_led_c]
## LCD_DB5
set_property IOSTANDARD LVCMOS15 [get_ports gpio_led_e]
## LCD_DB6
set_property IOSTANDARD LVCMOS15 [get_ports gpio_led_n]
## LCD_DB7
set_property IOSTANDARD LVCMOS15 [get_ports gpio_led_s]
## LCD_RW
set_property IOSTANDARD LVCMOS15 [get_ports gpio_led_w]
#
## 2 on SW9 pushbutton (active-high)
set_property IOSTANDARD LVCMOS25 [get_ports gpio_sw_c]
## 2 on SW7 pushbutton (active-high)
set_property IOSTANDARD LVCMOS15 [get_ports gpio_sw_e]
## 2 on SW5 pushbutton (active-high)
set_property IOSTANDARD LVCMOS15 [get_ports gpio_sw_n]
## 2 on SW6 pushbutton (active-high)
set_property IOSTANDARD LVCMOS15 [get_ports gpio_sw_s]
## 2 on SW8 pushbutton (active-high)
set_property IOSTANDARD LVCMOS15 [get_ports gpio_sw_w]

set_property LOC ILOGIC_X0Y10 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_a[4].ISERDESE2_adc_cha}]
set_property LOC IDELAY_X0Y10 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_a[4].IDELAYE2_inst_ADC_ch_A}]
set_property PACKAGE_PIN AG22 [get_ports {cha_p[4]}]
set_property PACKAGE_PIN AH22 [get_ports {cha_n[4]}]
set_property LOC ILOGIC_X0Y12 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_a[1].ISERDESE2_adc_cha}]
set_property LOC IDELAY_X0Y12 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_a[1].IDELAYE2_inst_ADC_ch_A}]
set_property PACKAGE_PIN AF20 [get_ports {cha_p[1]}]
set_property PACKAGE_PIN AF21 [get_ports {cha_n[1]}]
set_property LOC ILOGIC_X0Y14 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_a[6].ISERDESE2_adc_cha}]
set_property LOC IDELAY_X0Y14 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_a[6].IDELAYE2_inst_ADC_ch_A}]
set_property PACKAGE_PIN AG25 [get_ports {cha_p[6]}]
set_property PACKAGE_PIN AH25 [get_ports {cha_n[6]}]
set_property LOC ILOGIC_X0Y16 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_b[1].ISERDESE2_adc_chb}]
set_property LOC IDELAY_X0Y16 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_b[1].IDELAYE2_inst_ADC_ch_B}]
set_property PACKAGE_PIN AK23 [get_ports {chb_p[1]}]
set_property PACKAGE_PIN AK24 [get_ports {chb_n[1]}]
set_property LOC ILOGIC_X0Y18 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_b[3].ISERDESE2_adc_chb}]
set_property LOC IDELAY_X0Y18 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_b[3].IDELAYE2_inst_ADC_ch_B}]
set_property PACKAGE_PIN AE25 [get_ports {chb_p[3]}]
set_property PACKAGE_PIN AF25 [get_ports {chb_n[3]}]
set_property LOC ILOGIC_X0Y2 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_a[5].ISERDESE2_adc_cha}]
set_property LOC IDELAY_X0Y2 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_a[5].IDELAYE2_inst_ADC_ch_A}]
set_property PACKAGE_PIN AK20 [get_ports {cha_p[5]}]
set_property PACKAGE_PIN AK21 [get_ports {cha_n[5]}]
set_property LOC ILOGIC_X0Y20 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_b[2].ISERDESE2_adc_chb}]
set_property LOC IDELAY_X0Y20 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_b[2].IDELAYE2_inst_ADC_ch_B}]
set_property PACKAGE_PIN AJ24 [get_ports {chb_p[2]}]
set_property PACKAGE_PIN AK25 [get_ports {chb_n[2]}]
set_property LOC IDELAY_X0Y26 [get_cells fmc150_dac_adc_inst/KC705_fmc150_inst/IDELAYE2_inst_ADC_CLK]
set_property PACKAGE_PIN AD23 [get_ports clk_ab_p]
set_property PACKAGE_PIN AE24 [get_ports clk_ab_n]
set_property LOC ILOGIC_X0Y28 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_a[0].ISERDESE2_adc_cha}]
set_property LOC IDELAY_X0Y28 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_a[0].IDELAYE2_inst_ADC_ch_A}]
set_property PACKAGE_PIN AE23 [get_ports {cha_p[0]}]
set_property PACKAGE_PIN AF23 [get_ports {cha_n[0]}]
set_property LOC ILOGIC_X0Y30 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_b[6].ISERDESE2_adc_chb}]
set_property LOC IDELAY_X0Y30 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_b[6].IDELAYE2_inst_ADC_ch_B}]
set_property PACKAGE_PIN AD21 [get_ports {chb_p[6]}]
set_property PACKAGE_PIN AE21 [get_ports {chb_n[6]}]
set_property LOC ILOGIC_X0Y36 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_b[5].ISERDESE2_adc_chb}]
set_property LOC IDELAY_X0Y36 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_b[5].IDELAYE2_inst_ADC_ch_B}]
set_property PACKAGE_PIN AB24 [get_ports {chb_p[5]}]
set_property PACKAGE_PIN AC25 [get_ports {chb_n[5]}]
set_property LOC ILOGIC_X0Y38 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_b[4].ISERDESE2_adc_chb}]
set_property LOC IDELAY_X0Y38 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_b[4].IDELAYE2_inst_ADC_ch_B}]
set_property PACKAGE_PIN AA20 [get_ports {chb_p[4]}]
set_property PACKAGE_PIN AB20 [get_ports {chb_n[4]}]
set_property LOC ILOGIC_X0Y4 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_a[3].ISERDESE2_adc_cha}]
set_property LOC IDELAY_X0Y4 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_a[3].IDELAYE2_inst_ADC_ch_A}]
set_property PACKAGE_PIN AH21 [get_ports {cha_p[3]}]
set_property PACKAGE_PIN AJ21 [get_ports {cha_n[3]}]
set_property LOC ILOGIC_X0Y6 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_a[2].ISERDESE2_adc_cha}]
set_property LOC IDELAY_X0Y6 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_a[2].IDELAYE2_inst_ADC_ch_A}]
set_property PACKAGE_PIN AG20 [get_ports {cha_p[2]}]
set_property PACKAGE_PIN AH20 [get_ports {cha_n[2]}]
set_property LOC ILOGIC_X0Y8 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_b[0].ISERDESE2_adc_chb}]
set_property LOC IDELAY_X0Y8 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/adc_data_b[0].IDELAYE2_inst_ADC_ch_B}]
set_property PACKAGE_PIN AJ22 [get_ports {chb_p[0]}]
set_property PACKAGE_PIN AJ23 [get_ports {chb_n[0]}]
set_property PACKAGE_PIN AC22 [get_ports adc_n_en]
set_property PACKAGE_PIN AD24 [get_ports adc_reset]
set_property PACKAGE_PIN AC24 [get_ports adc_sdo]
set_property PACKAGE_PIN AB29 [get_ports cdce_n_en]
set_property PACKAGE_PIN AE29 [get_ports cdce_n_pd]
set_property PACKAGE_PIN AD29 [get_ports cdce_n_reset]
set_property PACKAGE_PIN AB30 [get_ports cdce_sdo]
set_property PACKAGE_PIN AB7 [get_ports cpu_reset]
set_property LOC OLOGIC_X0Y70 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/dac_data[0].oserdes_data}]
set_property PACKAGE_PIN AK29 [get_ports {dac_data_p[0]}]
set_property PACKAGE_PIN AK30 [get_ports {dac_data_n[0]}]
set_property LOC OLOGIC_X0Y62 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/dac_data[1].oserdes_data}]
set_property PACKAGE_PIN AC26 [get_ports {dac_data_p[1]}]
set_property PACKAGE_PIN AD26 [get_ports {dac_data_n[1]}]
set_property LOC OLOGIC_X0Y64 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/dac_data[2].oserdes_data}]
set_property PACKAGE_PIN AG30 [get_ports {dac_data_p[2]}]
set_property PACKAGE_PIN AH30 [get_ports {dac_data_n[2]}]
set_property LOC OLOGIC_X0Y56 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/dac_data[3].oserdes_data}]
set_property PACKAGE_PIN AH26 [get_ports {dac_data_p[3]}]
set_property PACKAGE_PIN AH27 [get_ports {dac_data_n[3]}]
set_property LOC OLOGIC_X0Y54 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/dac_data[4].oserdes_data}]
set_property PACKAGE_PIN AF26 [get_ports {dac_data_p[4]}]
set_property PACKAGE_PIN AF27 [get_ports {dac_data_n[4]}]
set_property LOC OLOGIC_X0Y52 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/dac_data[5].oserdes_data}]
set_property PACKAGE_PIN AJ26 [get_ports {dac_data_p[5]}]
set_property PACKAGE_PIN AK26 [get_ports {dac_data_n[5]}]
set_property LOC OLOGIC_X0Y78 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/dac_data[6].oserdes_data}]
set_property PACKAGE_PIN AD27 [get_ports {dac_data_p[6]}]
set_property PACKAGE_PIN AD28 [get_ports {dac_data_n[6]}]
set_property LOC OLOGIC_X0Y76 [get_cells {fmc150_dac_adc_inst/KC705_fmc150_inst/dac_data[7].oserdes_data}]
set_property PACKAGE_PIN AB27 [get_ports {dac_data_p[7]}]
set_property PACKAGE_PIN AC27 [get_ports {dac_data_n[7]}]
set_property LOC OLOGIC_X0Y58 [get_cells fmc150_dac_adc_inst/KC705_fmc150_inst/oserdes_clock]
set_property PACKAGE_PIN AG27 [get_ports dac_dclk_p]
set_property PACKAGE_PIN AG28 [get_ports dac_dclk_n]
set_property LOC OLOGIC_X0Y60 [get_cells fmc150_dac_adc_inst/KC705_fmc150_inst/oserdes_frame]
set_property PACKAGE_PIN AJ27 [get_ports dac_frame_p]


set_property PACKAGE_PIN AK28 [get_ports dac_frame_n]
set_property PACKAGE_PIN AE30 [get_ports dac_n_en]
set_property PACKAGE_PIN AF30 [get_ports dac_sdo]
#set_property PACKAGE_PIN AH29 [get_ports ext_trigger_n]
#set_property PACKAGE_PIN AG29 [get_ports ext_trigger_p]
set_property PACKAGE_PIN Y29 [get_ports {gpio_dip_sw[0]}]
set_property PACKAGE_PIN W29 [get_ports {gpio_dip_sw[1]}]
set_property PACKAGE_PIN AA28 [get_ports {gpio_dip_sw[2]}]
set_property PACKAGE_PIN Y28 [get_ports {gpio_dip_sw[3]}]
set_property PACKAGE_PIN AB8 [get_ports {gpio_led[0]}]
set_property PACKAGE_PIN AA8 [get_ports {gpio_led[1]}]
set_property PACKAGE_PIN AC9 [get_ports {gpio_led[2]}]
set_property PACKAGE_PIN AB9 [get_ports {gpio_led[3]}]
set_property PACKAGE_PIN AE26 [get_ports {gpio_led[4]}]
set_property PACKAGE_PIN G19 [get_ports {gpio_led[5]}]
set_property PACKAGE_PIN E18 [get_ports {gpio_led[6]}]
set_property PACKAGE_PIN F16 [get_ports {gpio_led[7]}]
set_property PACKAGE_PIN AA13 [get_ports gpio_led_c]
set_property PACKAGE_PIN AA10 [get_ports gpio_led_e]
set_property PACKAGE_PIN AA11 [get_ports gpio_led_n]
set_property PACKAGE_PIN Y10 [get_ports gpio_led_s]
set_property PACKAGE_PIN AB13 [get_ports gpio_led_w]
set_property PACKAGE_PIN G12 [get_ports gpio_sw_c]
set_property PACKAGE_PIN AG5 [get_ports gpio_sw_e]
set_property PACKAGE_PIN AA12 [get_ports gpio_sw_n]
set_property PACKAGE_PIN AB12 [get_ports gpio_sw_s]
set_property PACKAGE_PIN AC6 [get_ports gpio_sw_w]
set_property PACKAGE_PIN AJ28 [get_ports mon_n_en]
set_property PACKAGE_PIN AA30 [get_ports mon_n_int]
set_property PACKAGE_PIN AJ29 [get_ports mon_n_reset]
set_property PACKAGE_PIN Y30 [get_ports mon_sdo]
set_property PACKAGE_PIN AC30 [get_ports pll_status]
set_property PACKAGE_PIN J22 [get_ports prsnt_m2c_l]
set_property PACKAGE_PIN AC29 [get_ports ref_en]
set_property PACKAGE_PIN AE28 [get_ports spi_sclk]
set_property PACKAGE_PIN AF28 [get_ports spi_sdata]
set_property PACKAGE_PIN AD22 [get_ports txenable]


############################################################
######### Ethernet Constraints #############
############################################################
set_property PACKAGE_PIN L20 [get_ports phy_resetn]
set_property IOSTANDARD LVCMOS25 [get_ports phy_resetn]

# lock to unused header - ensure this is unused
set_property PACKAGE_PIN D29 [get_ports serial_response]
set_property PACKAGE_PIN C30 [get_ports tx_statistics_s]
set_property PACKAGE_PIN G27 [get_ports rx_statistics_s]
set_property IOSTANDARD LVCMOS25 [get_ports serial_response]
set_property IOSTANDARD LVCMOS25 [get_ports tx_statistics_s]
set_property IOSTANDARD LVCMOS25 [get_ports rx_statistics_s]

# Map the TB clock pin gtx_clk_bufg_out to and un-used pin so that its not trimmed off
set_property PACKAGE_PIN AC17 [get_ports gtx_clk_bufg_out]
set_property IOSTANDARD SSTL15 [get_ports gtx_clk_bufg_out]

############################################################
# Associate the IDELAYCTRL in the support level to the I/Os
# in the core using IODELAYs
############################################################
#set_property IODELAY_GROUP tri_mode_ethernet_mac_iodelay_grp [get_cells  {ethernet_rgmii_wrapper/trimac_fifo_block/trimac_sup_block/tri_mode_ethernet_mac_idelayctrl_common_i}]

set_property IODELAY_GROUP tri_mode_ethernet_mac_iodelay_grp [get_cells ethernet_rgmii_wrapper/trimac_fifo_block/trimac_sup_block/tri_mode_ethernet_mac_idelayctrl_common_i]


############################################################
# Input Delay constraints
############################################################
# these inputs are alll from either dip switchs or push buttons
# and therefore have no timing associated with them
set_false_path -from [get_ports {gpio_dip_sw[0]}]
set_false_path -from [get_ports {gpio_dip_sw[1]}]
set_false_path -from [get_ports {gpio_dip_sw[2]}]
set_false_path -from [get_ports {gpio_dip_sw[3]}]
# set_false_path -from [get_ports gpio_sw_c]
set_false_path -from [get_ports gpio_sw_e]
set_false_path -from [get_ports gpio_sw_n]
set_false_path -from [get_ports gpio_sw_s]
set_false_path -from [get_ports gpio_sw_w]

# no timing requirements but want the capture flops close to the IO
set_max_delay -datapath_only -from [get_ports gpio_sw_c] 4.000
# mdio has timing implications but slow interface so relaxed
set_input_delay -clock [get_clocks -of [get_pins example_clocks/clock_generator/mmcm_adv_inst/CLKOUT1]] 5.000 [get_ports mdio]

## Ignore pause deserialiser as only present to prevent logic stripping
#set_false_path -from [get_ports ethernet_rgmii_wrapper/pause_req*]
#set_false_path -from [get_cells ethernet_rgmii_wrapper/pause_req* -filter {IS_SEQUENTIAL}]
#set_false_path -from [get_cells ethernet_rgmii_wrapper/pause_val* -filter {IS_SEQUENTIAL}]

############################################################
# Output Delay constraints
############################################################
set_output_delay -clock [get_clocks -of [get_pins example_clocks/clock_generator/mmcm_adv_inst/CLKOUT1]] 1.000 [get_ports mdc]

# no timing associated with output
set_false_path -from [get_cells -hier -filter {name =~ *phy_resetn_int_reg}] -to [get_ports phy_resetn]

############################################################
# Example design Clock Crossing Constraints                          #
############################################################
set_false_path -from [get_cells -hier -filter {name =~ *phy_resetn_int_reg}] -to [get_cells -hier -filter {name =~ *axi_lite_reset_gen/reset_sync*}]


## control signal is synched over clock boundary separately
set_false_path -from [get_cells -hier -filter {name =~ tx_stats_reg[*]}] -to [get_cells -hier -filter {name =~ tx_stats_shift_reg[*]}]
set_false_path -from [get_cells -hier -filter {name =~ rx_stats_reg[*]}] -to [get_cells -hier -filter {name =~ rx_stats_shift_reg[*]}]


#############################################################
## Ignore paths to resync flops
#############################################################
set_false_path -to [get_pins -hier -filter {NAME =~ */reset_sync*/PRE}]
set_max_delay -datapath_only -from [get_cells ethernet_rgmii_wrapper/tx_stats_toggle_reg] -to [get_cells ethernet_rgmii_wrapper/tx_stats_sync/data_sync_reg0] 6.000
set_max_delay -datapath_only -from [get_cells ethernet_rgmii_wrapper/rx_stats_toggle_reg] -to [get_cells ethernet_rgmii_wrapper/rx_stats_sync/data_sync_reg0] 6.000



set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]



#set_property LOC BSCAN_X0Y0 [get_cells dbg_hub/inst/bscan_inst/SERIES7_BSCAN.bscan_inst]
set_property LOC XADC_X0Y0 [get_cells u_mig_7series_1/u_mig_7series_1_mig/temp_mon_enabled.u_tempmon/xadc_supplied_temperature.XADC_inst]

set_property FIXED_ROUTE { { IOB_IBUF0 RIOI_I0 RIOI_ILOGIC0_D IOI_ILOGIC0_O RIOI_I2GCLK_TOP0  { HCLK_CMT_CK_IN0 CLK_HROW_BOT_R_CK_BUFG_CASCO22 CLK_HROW_BOT_R_CK_BUFG_CASCO22 CLK_HROW_BOT_R_CK_BUFG_CASCO22 CLK_BUFG_BUFGCTRL11_I0 }  HCLK_CMT_MUX_OUT_FREQ_REF0 HCLK_CMT_FREQ_REF_NS0 PLL_CLK_FREQ_BB_BUFOUT_NS0 MMCM_CLK_FREQ_BB_NS0 CMT_L_LOWER_B_CLK_FREQ_BB3 CMT_LR_LOWER_B_MMCM_CLKIN1 }  } [get_nets example_clocks/clkin1]
set_property FIXED_ROUTE { { LIOI_IDELAY0_DATAOUT LIOI_ILOGIC0_DDLY IOI_ILOGIC0_O IOI_LOGIC_OUTS18_1 INT_INTERFACE_LOGIC_OUTS_L18 SE6BEG0 SE6BEG0 SE6BEG0 SE6BEG0 SE6BEG0 SE6BEG0 SE6BEG0 LH12 LH12 LH12 LH12 LH12 EE4BEG3 EE4BEG3 SE6BEG3 NE6BEG0 NE6BEG0 NE6BEG0 NE2BEG0 EE2BEG0 ER1BEG1 CLK_L0 CMT_L_LOWER_B_CLK_IN1_INT CMT_LR_LOWER_B_MMCM_CLKIN1 }  } [get_nets fmc150_dac_adc_inst/KC705_fmc150_inst/clk_in1]
set_property LOC BSCAN_X0Y0 [get_cells dbg_hub/inst/bscan_inst/SERIES7_BSCAN.bscan_inst]
