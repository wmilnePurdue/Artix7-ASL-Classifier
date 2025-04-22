create_clock -period 8.600 -name clk_int -waveform {0.000 4.300} -add [get_nets -hierarchical *clk_int*]
create_clock -period 40.000 -name cam_clk -waveform {0.000 20.000} -add [get_nets cam_clk]
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name clk -waveform {0.000 5.000} -add [get_ports clk]


set_false_path -reset_path -from [get_cells RST_SYNC/rst_syn_reg] -to [get_pins {{CAMERA_UNIT/CLK_GENERATOR/reset_sync_reg[0]/CLR} {CAMERA_UNIT/CLK_GENERATOR/reset_sync_reg[1]/CLR}}]

## Switch (SW0 for display mode)
set_property PACKAGE_PIN V17 [get_ports SW0]
set_property IOSTANDARD LVCMOS33 [get_ports SW0]

## Seven Segment Display
#Cathodes
set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]
## Anodes
set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]


set_false_path -reset_path -from [get_clocks clk] -to [get_clocks clk_int]
set_false_path -reset_path -from [get_clocks clk] -to [get_clocks clk_int]
set_false_path -reset_path -from [get_clocks clk] -to [get_clocks clk_int]
