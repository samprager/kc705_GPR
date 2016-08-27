# Create MCS file for BPI memory device

write_cfgmem -force -format mcs -interface bpix16 -size 128 -loadbit "up 0x0 project_2/project_2.runs/impl_1/kc705_gpr_top.bit" -file project_2/project_2.runs/impl_1/kc705_gpr_top_bpix16.mcs

# Connect to the Digilent Cable on localhost:3121
disconnect_hw_server localhost

connect_hw_server -host localhost -port 60001 -url localhost:3121
current_hw_target [get_hw_targets */xilinx_tcf/Digilent/210203344634A]
set_property PARAM.FREQUENCY 15000000 [get_hw_targets */xilinx_tcf/Digilent/210203344634A]
open_hw_target

# Program and Refresh the XC7K325T Device

set_property PROGRAM.FILE {D:/UndergroundRadar/kc705_GPR/Design/Firmware/implement/project_2/project_2.runs/impl_1/kc705_gpr_top.bit} [lindex [get_hw_devices] 0]
set_property PROBES.FILE {D:/UndergroundRadar/kc705_GPR/Design/Firmware/implement/project_2/project_2.runs/impl_1/debug_nets.ltx} [lindex [get_hw_devices] 0]
current_hw_device [lindex [get_hw_devices] 0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]

# Program Flash Memory

create_hw_cfgmem -hw_device [lindex [get_hw_devices] 0] -mem_dev  [lindex [get_cfgmem_parts {28f00ap30t-bpi-x16}] 0]
set_property PROGRAM.BLANK_CHECK  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
set_property PROGRAM.ERASE  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
set_property PROGRAM.CFG_PROGRAM  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
set_property PROGRAM.VERIFY  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
refresh_hw_device [lindex [get_hw_devices] 0]
set_property PROGRAM.ADDRESS_RANGE  {use_file} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
set_property PROGRAM.FILE_1 {D:/UndergroundRadar/kc705_GPR/Design/Firmware/implement/project_2/project_2.runs/impl_1/kc705_gpr_top_bpix16.mcs} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0]]
set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
set_property PROGRAM.BPI_RS_PINS {none} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
set_property PROGRAM.BLANK_CHECK  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
set_property PROGRAM.ERASE  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
set_property PROGRAM.CFG_PROGRAM  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
set_property PROGRAM.VERIFY  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
startgroup
if {![string equal [get_property PROGRAM.HW_CFGMEM_TYPE  [lindex [get_hw_devices] 0]] [get_property MEM_TYPE [get_property CFGMEM_PART [get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]]]] }  { create_hw_bitstream -hw_device [lindex [get_hw_devices] 0] [get_property PROGRAM.HW_CFGMEM_BITFILE [ lindex [get_hw_devices] 0]]; program_hw_devices [lindex [get_hw_devices] 0]; };
program_hw_cfgmem -hw_cfgmem [get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]

# Program and Refresh the XC7K325T Device

set_property PROBES.FILE {D:/UndergroundRadar/kc705_GPR/Design/Firmware/implement/project_2/project_2.runs/impl_1/debug_nets.ltx} [lindex [get_hw_devices] 0]
set_property PROGRAM.FILE {D:/UndergroundRadar/kc705_GPR/Design/Firmware/implement/project_2/project_2.runs/impl_1/kc705_gpr_top.bit} [lindex [get_hw_devices] 0]
program_hw_devices [lindex [get_hw_devices] 0]
refresh_hw_device [lindex [get_hw_devices] 0]
