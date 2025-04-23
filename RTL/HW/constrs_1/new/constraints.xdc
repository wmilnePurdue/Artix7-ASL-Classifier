create_clock -period 10.000 -name clk_int -waveform {0.000 5.000} -add [get_nets -hierarchical *clk_int*]
create_clock -period 40.000 -name p_clock -waveform {0.000 20.000} -add [get_ports p_clock]
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name clk -waveform {0.000 5.000} -add [get_ports clk]

set_false_path -reset_path -from [get_cells RST_SYNC/rst_syn_reg] -to [get_pins {{CAMERA_UNIT/CLK_GENERATOR/reset_sync_reg[0]/CLR} {CAMERA_UNIT/CLK_GENERATOR/reset_sync_reg[1]/CLR}}]
set_false_path -reset_path -from [get_pins PLL_RST_SYNC/rst_syn_reg/C] -to [get_pins {PLL_INST/inst/*/CLR}]

## Switch (SW0 for display mode)
set_property PACKAGE_PIN V17 [get_ports SW0]
set_property IOSTANDARD LVCMOS33 [get_ports SW0]

## Seven Segment Display
#Cathodes
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]  # CA
set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
set_property PACKAGE_PIN W6 [get_ports {seg[1]}]  # CB
set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
set_property PACKAGE_PIN U8 [get_ports {seg[2]}]  # CC
set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]  # CD
set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
set_property PACKAGE_PIN U5 [get_ports {seg[4]}]  # CE
set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
set_property PACKAGE_PIN V5 [get_ports {seg[5]}]  # CF
set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]  # CG
set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]
## Anodes
set_property PACKAGE_PIN U2 [get_ports {an[0]}]   # AN0
set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]   # AN1
set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]   # AN2
set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]   # AN3
set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]


set_false_path -reset_path -from [get_clocks clk] -to [get_clocks clk_int]
set_false_path -reset_path -from [get_clocks clk] -to [get_clocks clk_int]
set_false_path -reset_path -from [get_clocks clk] -to [get_clocks clk_int]