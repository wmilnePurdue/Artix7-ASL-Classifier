create_clock -period 8.000 -name clk_int -waveform {0.000 4.000} -add [get_nets -hierarchical *clk_int*]
create_clock -period 10.000 -name cam_clk -waveform {0.000 5.000} -add [get_nets cam_clk]


set_false_path -reset_path -from [get_cells RST_SYNC/rst_syn_reg] -to [get_pins {{CAMERA_UNIT/CLK_GENERATOR/reset_sync_reg[0]/CLR} {CAMERA_UNIT/CLK_GENERATOR/reset_sync_reg[1]/CLR}}]
