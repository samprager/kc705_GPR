# Connect to the Digilent Cable on localhost:3121

connect_hw_server -host localhost -port 60001 -url localhost:3121
current_hw_target [get_hw_targets */xilinx_tcf/Digilent/210203344634A]
set_property PARAM.FREQUENCY 15000000 [get_hw_targets */xilinx_tcf/Digilent/210203344634A]
open_hw_target

# Program and Refresh the XC7K325T Device
set_property PROGRAM.FILE {/home/sprager/CurrentProject/Design/Firmware/implement/project_1/project_1.runs/impl_2/kc705_gpr_top.bit} [lindex [get_hw_devices] 0]
set_property PROBES.FILE {/home/sprager/CurrentProject/Design/Firmware/implement/project_1/project_1.runs/impl_2/debug_nets.ltx} [lindex [get_hw_devices] 0]
current_hw_device [lindex [get_hw_devices] 0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]


set_property PROBES.FILE {/home/sprager/CurrentProject/Design/Firmware/implement/project_1/project_1.runs/impl_2/debug_nets.ltx} [lindex [get_hw_devices] 0]
set_property PROGRAM.FILE {/home/sprager/CurrentProject/Design/Firmware/implement/project_1/project_1.runs/impl_2/kc705_gpr_top.bit} [lindex [get_hw_devices] 0]
program_hw_devices [lindex [get_hw_devices] 0]
refresh_hw_device [lindex [get_hw_devices] 0]
