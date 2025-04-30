`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2025 09:21:07 PM
// Design Name: 
// Module Name: npu_top
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
`include "npu_defines.vh"

module npu_top(
    input                  clk,
    input                  resetn,

    input  wire [31:0]     ahb_s0_haddr_i,
    input  wire            ahb_s0_hwrite_i,
    input  wire [2:0]      ahb_s0_hsize_i,
    input  wire [2:0]      ahb_s0_hburst_i,
    input  wire [3:0]      ahb_s0_hprot_i,
    input  wire [1:0]      ahb_s0_htrans_i,
    input  wire            ahb_s0_hmastlock_i,
    input  wire [31:0]     ahb_s0_hwdata_i,
    
    input  wire            test_mode_i,
    input  wire [1:0]      test_img_index_i,
						   
    output logic           ahb_s0_hready_o,
    output                 ahb_s0_hresp_o,
    output logic [31:0]    ahb_s0_hrdata_o

);

wire        write_row;
wire [5:0]  npu_thrshld_num_rows_to_start;
		    
wire        npu_done;
wire [4:0]  npu_class_predicted;
wire        npu_active;
wire [2:0]  npu_layer_in_progress;
wire [5:0]  img_num_rows_written;
wire        mac_overflow_lat_r;
wire        act_overflow_lat_r;

wire        softmax_result_valid_p;
wire [4:0]  softmax_class_predicted;
wire [31:0] mac_enable;
wire [10:0] filter_mem_rd_addr;
wire [11:0] activation_mem_rd_addr;
wire [31:0] mac_overflow;
wire [31:0] act_overflow;
wire [11:0] cpu_rgb_mem_addr_o;
wire [7:0]  cpu_rgb_mem_wrdata_o;
wire [7:0]  cpu_rgb_mem_rddata_i;
wire [11:0] npu_act_mem_wr_addr;
wire [`NPU_ACT_DATA_WIDTH-1:0]  npu_act_mem_wr_data;
wire [7:0]  npu_rgb_rddata;
wire [`NPU_ACT_DATA_WIDTH-1:0]  npu_act_mem_rd_data;
wire [`NPU_ACT_DATA_WIDTH-1:0]  npu_muxed_rgb_act_mem_rd_data;
wire [12*32-1:0] hw_mem_wr_addr;
wire [`NPU_ACT_DATA_WIDTH*32-1:0]  hw_mem_wr_data;
wire [31:0] hw_mem_wr_ack_p;
wire [31:0] hw_mem_wr;

wire [32*`NPU_ACT_DATA_WIDTH-1:0] weights_rom_rd_data;
wire [32*`NPU_ACT_DATA_WIDTH-1:0] bias_rom_rd_data;
wire [2:0]      bias_rom_rd_addr; 
wire [24*`NPU_ACT_DATA_WIDTH-1:0] fc2_layer_output_data;
wire            fc2_layer_output_valid_p;
wire [`NPU_ACT_DATA_WIDTH-1:0] test_img_rdata;     

//temporary assignments to enable synthesis

npu_control_unit NPU_CTRL(
   .npu_clk			              (clk), 
   .npu_rst_n			          (resetn),
   .cfg_write_row_p		          (write_row), 
   .cfg_thrshld_num_rows_to_start (npu_thrshld_num_rows_to_start),
   .softmax_result_valid_p	      (softmax_result_valid_p), 
   .softmax_class_predicted		  (softmax_class_predicted),
   .npu_active				      (npu_active), 
   .npu_done				      (npu_done), 
   .npu_layer_in_progress	      (npu_layer_in_progress), 
   .img_num_rows_written	      (img_num_rows_written), 
   .npu_class_predicted		      (npu_class_predicted),
   .mac_enable			          (mac_enable), 
   .mac_start_p			          (mac_start_p), 
   .mac_last_p			          (mac_last_p),
   .filter_mem_rd_en		      (), 
   .filter_mem_rd_addr		      (filter_mem_rd_addr),
   .rgb_mem_rd_en                 (rgb_mem_rd_en),
   .activation_mem_rd_en	      (activation_mem_rd_en), 
   .activation_mem_rd_addr	      (activation_mem_rd_addr), 
   .activation_mem_rd_bypass      (activation_mem_rd_bypass),
   .cur_state_conv1_c		      (), 
   .cur_state_conv2_c		      (), 
   .cur_state_conv3_c		      (),
   .cur_state_fc1_1_c		      (), 
   .cur_state_fc1_2_c		      (), 
   .cur_state_fc2_c       	      (),
   .mac_overflow                  (mac_overflow),
   .mac_overflow_lat_r            (mac_overflow_lat_r),
   .act_overflow                  (act_overflow),
   .act_overflow_lat_r            (act_overflow_lat_r)
   );

npu_ahb_decoder DECODER (
    .clk                   (clk                    ), 
    .resetn                (resetn                 ),
											       
    .ahb_s0_haddr_i        (ahb_s0_haddr_i         ),
    .ahb_s0_hwrite_i       (ahb_s0_hwrite_i        ),
    .ahb_s0_hsize_i        (ahb_s0_hsize_i         ),
    .ahb_s0_hburst_i       (ahb_s0_hburst_i        ),
    .ahb_s0_hprot_i        (ahb_s0_hprot_i         ),
    .ahb_s0_htrans_i       (ahb_s0_htrans_i        ),
    .ahb_s0_hmastlock_i    (ahb_s0_hmastlock_i     ),
    .ahb_s0_hwdata_i       (ahb_s0_hwdata_i        ),
						    				 	    
    .ahb_s0_hready_o       (ahb_s0_hready_o        ),
    .ahb_s0_hresp_o        (ahb_s0_hresp_o         ),
    .ahb_s0_hrdata_o       (ahb_s0_hrdata_o        ),

    .write_row             (write_row              ),
    .npu_thrshld_num_rows_to_start	(npu_thrshld_num_rows_to_start),

    .npu_done              (npu_done               ),
    .npu_class_predicted   (npu_class_predicted    ),
    .npu_active            (npu_active             ),
    .npu_layer_in_progress (npu_layer_in_progress  ),
    .img_num_rows_written  (img_num_rows_written   ),
    .mac_overflow_lat_r    (mac_overflow_lat_r     ),
    .act_overflow_lat_r    (act_overflow_lat_r     ),

    .mem0_addr_o           (cpu_rgb_mem_addr_o     ),
    .mem0_wr_o             (cpu_rgb_mem_wr_o       ),
    .mem0_wrdata_o         (cpu_rgb_mem_wrdata_o   ),
    .mem0_rddata_i         (cpu_rgb_mem_rddata_i   ),

    .mem1_addr_o           (),
    .mem1_wr_o             (),
    .mem1_wrdata_o         (),
    .mem1_rddata_i         (8'd0                   )
    );

npu_rgb_input_mem RGB_INPUT_MEM (
    .clka  (clk               ),
    .wea   (cpu_rgb_mem_wr_o  ), // CPU RGB mem wr port
    .addra (cpu_rgb_mem_addr_o),
    .dina  (cpu_rgb_mem_wrdata_o),
    .douta (cpu_rgb_mem_rddata_i),
						      
    .clkb  (clk               ),
    .web   (1'b0              ), // NPU only reads
    .addrb (activation_mem_rd_addr[11:0]),
    .dinb  (8'd0              ),
    .doutb (npu_rgb_rddata    )
   );

npu_act_mem ACTIVATION_MEM (
    .clka  (clk               ),
    .wea   (npu_act_mem_wr_en ), // NPU Act Mem Wr Port
    .addra (npu_act_mem_wr_addr[11:0]),
    .dina  (npu_act_mem_wr_data),
    .douta (),
						      
    .clkb  (clk               ),
    .enb   (activation_mem_rd_en),
    .web   (1'b0              ), // NPU read port
    .addrb (activation_mem_rd_addr[11:0]),
    .dinb  ({`NPU_ACT_DATA_WIDTH{1'b0}}),
    .doutb (npu_act_mem_rd_data)
    );

npu_img_act_mem_ctrl NPU_IMG_ACT_CTRL(
    .clk                            (clk),
    .resetn                         (resetn),
    .hw_rgb_mem_rd                  (rgb_mem_rd_en),
    .hw_act_mem_rd                  (activation_mem_rd_en),
    .hw_act_mem_rd_bypass           (activation_mem_rd_bypass),
    .npu_rgb_rddata                 (npu_rgb_rddata),
    .npu_act_mem_rd_data            (npu_act_mem_rd_data),
    .npu_muxed_rgb_act_mem_rd_data  (npu_muxed_rgb_act_mem_rd_data),
    .npu_act_mem_wr_en              (npu_act_mem_wr_en),
    .npu_act_mem_wr_addr            (npu_act_mem_wr_addr),
    .npu_act_mem_wr_data            (npu_act_mem_wr_data),
    .hw_mem_wr                      (hw_mem_wr),
    .hw_mem_wr_addr                 (hw_mem_wr_addr), 
    .hw_mem_wr_data                 (hw_mem_wr_data), 
    .hw_mem_wr_ack_p                (hw_mem_wr_ack_p),
    .test_img_rdata                 (test_img_rdata),
    .test_mode_i                    (test_mode_i) 
    );

npu_layer #(.DATA_WIDTH (`NPU_ACT_DATA_WIDTH), .NUM_FRAC_BITS(`NPU_NUM_FRAC_BITS)) NPU_LAYER_UNIT (
   .clk			     (clk),    
   .rst                      (resetn), 
   .start_p 	             (mac_start_p),
   .last_p                   (mac_last_p),
   .mac_en		     (mac_enable), 
   .weight_in                (weights_rom_rd_data), 
   .act_in                   (npu_muxed_rgb_act_mem_rd_data), 
   .mac_overflow             (mac_overflow), 
   .npu_layer_in_progress    (npu_layer_in_progress), 
   .hw_mem_wr                (hw_mem_wr), 
   .hw_mem_wr_addr           (hw_mem_wr_addr), 
   .hw_mem_wr_data           (hw_mem_wr_data), 
   .hw_mem_wr_ack_p          (hw_mem_wr_ack_p), 
   .bias_rd_addr	     (bias_rom_rd_addr), 
   .bias_rd_data             (bias_rom_rd_data), 
   .act_overflow	     (act_overflow),
   .fc2_layer_output_data    (fc2_layer_output_data),
   .fc2_layer_output_valid_p (fc2_layer_output_valid_p)
    );

npu_weights_rom_top #(.DATA_WIDTH (`NPU_ACT_DATA_WIDTH)) NPU_WEIGHTS_ROM(
    .clk		    (clk), 
    .weights_rom_rd_addr    (filter_mem_rd_addr), 
    .weights_rom_rd_data    (weights_rom_rd_data)
    );

npu_bias_rom_top #(.DATA_WIDTH (`NPU_ACT_DATA_WIDTH)) NPU_BIAS_ROM(
    .clk		    (clk), 
    .bias_rom_rd_addr       (bias_rom_rd_addr), 
    .bias_rom_rd_data       (bias_rom_rd_data)
    );

softmax #(.DATA_WIDTH (`NPU_ACT_DATA_WIDTH)) SFTMAX(
    .clk		   (clk),
    .resetn                (resetn),
    .data_in               (fc2_layer_output_data), 
    .valid_i               (fc2_layer_output_valid_p),
    .data_out              (),
    .idx_out	           (softmax_class_predicted),
    .valid_o               (softmax_result_valid_p)    
    );

test_image_rom TEST_IMG_ROM
   (
    .clka (clk),
    .addra({test_img_index_i,activation_mem_rd_addr[11:0]}),
    .douta (test_img_rdata)
  );

endmodule
