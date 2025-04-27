create_clock -period 10.000 -name clk_int -waveform {0.000 5.000} -add [get_nets -hierarchical *clk_int*]
create_clock -period 40.000 -name p_clock -waveform {0.000 20.000} -add [get_ports p_clock]
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name clk -waveform {0.000 5.000} -add [get_ports clk]

## Reset mapped to onboard push button; active high
set_property PACKAGE_PIN T17 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

## PLL Locked LED status
set_property PACKAGE_PIN L1 [get_ports {pll_locked}]
set_property IOSTANDARD LVCMOS33 [get_ports {pll_locked}]

## Push button to trigger a camera image capture
set_property PACKAGE_PIN U18 [get_ports {ext_input_io[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ext_input_io[0]}]

## Ext output pins-- mapped to onboard LEDs
set_property PACKAGE_PIN U16 [get_ports {ext_output_io[2]}]
set_property PACKAGE_PIN E19 [get_ports {ext_output_io[3]}]
set_property PACKAGE_PIN U19 [get_ports {ext_output_io[4]}]
set_property PACKAGE_PIN V19 [get_ports {ext_output_io[5]}]
set_property PACKAGE_PIN W18 [get_ports {ext_output_io[6]}]
set_property PACKAGE_PIN U15 [get_ports {ext_output_io[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {ext_output_io[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ext_output_io[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ext_output_io[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ext_output_io[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ext_output_io[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ext_output_io[7]}]

## Ext input pins - mapped to onboard toggle switches
set_property PACKAGE_PIN V2 [get_ports {ext_input_io[7]}]
set_property PACKAGE_PIN T3 [get_ports {ext_input_io[6]}]
set_property PACKAGE_PIN T2 [get_ports {ext_input_io[5]}]
set_property PACKAGE_PIN R3 [get_ports {ext_input_io[4]}]
set_property PACKAGE_PIN W2 [get_ports {ext_input_io[3]}]
set_property PACKAGE_PIN U1 [get_ports {ext_input_io[2]}]
set_property PACKAGE_PIN T1 [get_ports {ext_input_io[1]}]

set_property IOSTANDARD LVCMOS33 [get_ports {ext_input_io[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ext_input_io[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ext_input_io[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ext_input_io[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ext_input_io[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ext_input_io[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ext_input_io[1]}]

set_false_path -reset_path -from [get_cells RST_SYNC/rst_syn_reg] -to [get_pins {{CAMERA_UNIT/CLK_GENERATOR/reset_sync_reg[0]/CLR} {CAMERA_UNIT/CLK_GENERATOR/reset_sync_reg[1]/CLR}}]
set_false_path -reset_path -from [get_pins PLL_RST_SYNC/rst_syn_reg/C] -to [get_pins {PLL_INST/inst/*/CLR}]

## Switch (SW0 for display mode)
set_property PACKAGE_PIN V17 [get_ports SW0]
set_property IOSTANDARD LVCMOS33 [get_ports SW0]

## Seven Segment Display
#Cathodes
## CA
set_property PACKAGE_PIN W7 [get_ports {seg[0]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
 ## CB
set_property PACKAGE_PIN W6 [get_ports {seg[1]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
 ## CC
set_property PACKAGE_PIN U8 [get_ports {seg[2]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
 ## CD
set_property PACKAGE_PIN V8 [get_ports {seg[3]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
 ## CE
set_property PACKAGE_PIN U5 [get_ports {seg[4]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
 ## CF
set_property PACKAGE_PIN V5 [get_ports {seg[5]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
 ## CG
set_property PACKAGE_PIN U7 [get_ports {seg[6]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]
## Anodes
  ## AN0
set_property PACKAGE_PIN U2 [get_ports {an[0]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
  ## AN1
set_property PACKAGE_PIN U4 [get_ports {an[1]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
  ## AN2
set_property PACKAGE_PIN V4 [get_ports {an[2]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
  ## AN3
set_property PACKAGE_PIN W4 [get_ports {an[3]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]

## OV7670 Camera pins
##Pmod Header JB
## p_data 8 bits
## JB1
set_property PACKAGE_PIN A14 [get_ports {p_data[0]}]     
 set_property IOSTANDARD LVCMOS33 [get_ports {p_data[0]}]
## JB2
set_property PACKAGE_PIN A16 [get_ports {p_data[1]}]     
 set_property IOSTANDARD LVCMOS33 [get_ports {p_data[1]}]
## JB3
set_property PACKAGE_PIN B15 [get_ports {p_data[2]}]     
 set_property IOSTANDARD LVCMOS33 [get_ports {p_data[2]}]
## JB4
set_property PACKAGE_PIN B16 [get_ports {p_data[3]}]     
 set_property IOSTANDARD LVCMOS33 [get_ports {p_data[3]}]
## JB7
set_property PACKAGE_PIN A15 [get_ports {p_data[4]}]     
 set_property IOSTANDARD LVCMOS33 [get_ports {p_data[4]}]
## JB8
set_property PACKAGE_PIN A17 [get_ports {p_data[5]}]     
 set_property IOSTANDARD LVCMOS33 [get_ports {p_data[5]}]
## JB9
set_property PACKAGE_PIN C15 [get_ports {p_data[6]}]     
 set_property IOSTANDARD LVCMOS33 [get_ports {p_data[6]}]
## JB10 
set_property PACKAGE_PIN C16 [get_ports {p_data[7]}]     
 set_property IOSTANDARD LVCMOS33 [get_ports {p_data[7]}]

##Pmod Header JC
## JC1 -- reset
set_property PACKAGE_PIN K17 [get_ports {ext_output_io[0]}]     
 set_property IOSTANDARD LVCMOS33 [get_ports {ext_output_io[0]}]
## JC2 -- xclk
set_property PACKAGE_PIN M18 [get_ports xclk]     
 set_property IOSTANDARD LVCMOS33 [get_ports xclk]
## JC3 -- p_clock
set_property PACKAGE_PIN N17 [get_ports p_clock]     
 set_property IOSTANDARD LVCMOS33 [get_ports p_clock]
 ##set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {pclk_IBUF}]
## JC4 -- sda
set_property PACKAGE_PIN P18 [get_ports i2c_sda]     
 set_property IOSTANDARD LVCMOS33 [get_ports i2c_sda]
 ## set_property PULLUP TRUE [get_ports i2c_sda]
## JC7 -- PWDN
set_property PACKAGE_PIN L17 [get_ports {ext_output_io[1]}]     
 set_property IOSTANDARD LVCMOS33 [get_ports {ext_output_io[1]}]
## JC8 -- href
set_property PACKAGE_PIN M19 [get_ports href]     
 set_property IOSTANDARD LVCMOS33 [get_ports href]
## JC9 - vsync
set_property PACKAGE_PIN P17 [get_ports vsync]     
 set_property IOSTANDARD LVCMOS33 [get_ports vsync]
## JC10 - i2c_scl
set_property PACKAGE_PIN R18 [get_ports i2c_scl]     
 set_property IOSTANDARD LVCMOS33 [get_ports i2c_scl]

set_false_path -reset_path -from [get_clocks clk] -to [get_clocks clk_int]
set_false_path -reset_path -from [get_clocks clk] -to [get_clocks clk_int]
set_false_path -reset_path -from [get_clocks clk] -to [get_clocks clk_int]