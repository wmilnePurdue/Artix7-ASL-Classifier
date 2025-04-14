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
						   
    output logic           ahb_s0_hready_o,
    output                 ahb_s0_hresp_o,
    output logic [31:0]    ahb_s0_hrdata_o

);

wire        write_row;
wire [3:0]  halt_layer_num;
		    
wire        npu_done;
wire [4:0]  npu_class_predicted;
wire        npu_active;
wire        npu_halt;
wire        npu_layer_in_progress;
wire [4:0]  img_num_rows_written;
wire        err_invalid_cpu_rd_wr;
wire        err_invalid_hw_rd_wr;

wire [11:0] mem0_addr_o;
wire        mem0_wr_o;
wire [7:0]  mem0_wrdata_o;
		    
wire [7:0]  mem0_rddata_i;
		    
wire [11:0] mem1_addr_o;
wire        mem1_wr_o;
wire [7:0]  mem1_wrdata_o;
		    
wire [7:0]  mem1_rddata_i;

// npu rgb mem interface
wire        npu_rgb_wr_o;
wire [11:0] npu_rgb_wr_addr_o;
wire [7:0]  npu_rgb_wrdata_o;
wire [7:0]  npu_rgb_rddata_i;

// npu rgb mem interface
wire        npu_act_wr_o;
wire [11:0] npu_act_wr_addr_o;
wire [7:0]  npu_act_wrdata_o;
wire [7:0]  npu_act_rddata_i;
 

//temporary assignments to enable synthesis
assign npu_done               = 'h0;
assign npu_class_predicted    = 'h0;
assign npu_active             = 'h0;
assign npu_halt               = 'h0;
assign npu_layer_in_progress  = 'h0;
assign img_num_rows_written   = 'h0;
assign err_invalid_cpu_rd_wr  = 'h0;
assign err_invalid_hw_rd_wr   = 'h0;

assign npu_rgb_wr_o           = 'h0;
assign npu_rgb_wr_addr_o      = 'h0;
assign npu_rgb_wrdata_o       = 'h0;
assign npu_rgb_rddata_i       = 'h0;

assign npu_act_wr_o           = 'h0;
assign npu_act_wr_addr_o      = 'h0;
assign npu_act_wrdata_o       = 'h0;
assign npu_act_rddata_i       = 'h0;

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
    .halt_layer_num        (halt_layer_num         ),

    .npu_done              (npu_done               ),
    .npu_class_predicted   (npu_class_predicted    ),
    .npu_active            (npu_active             ),
    .npu_halt              (npu_halt               ),
    .npu_layer_in_progress (npu_layer_in_progress  ),
    .img_num_rows_written  (img_num_rows_written   ),
    .err_invalid_cpu_rd_wr (err_invalid_cpu_rd_wr  ),
    .err_invalid_hw_rd_wr  (err_invalid_hw_rd_wr   ),

    .mem0_addr_o           (mem0_addr_o            ),
    .mem0_wr_o             (mem0_wr_o              ),
    .mem0_wrdata_o         (mem0_wrdata_o          ),

    .mem0_rddata_i         (mem0_rddata_i          ),

    .mem1_addr_o           (mem1_addr_o            ),
    .mem1_wr_o             (mem1_wr_o              ),
    .mem1_wrdata_o         (mem1_wrdata_o          ),

    .mem1_rddata_i         (mem1_rddata_i          )
);

npu_rgb_input_mem RGB_INPUT_MEM (
    .clka  (clk               ),
    .wea   (mem0_wr_o         ),
    .addra (mem0_addr_o       ),
    .dina  (mem0_wrdata_o     ),
    .douta (mem0_rddata_i     ),
						      
    .clkb  (clk               ),
    .web   (npu_rgb_wr_o      ),
    .addrb (npu_rgb_wr_addr_o ),
    .dinb  (npu_rgb_wrdata_o  ),
    .doutb (npu_rgb_rddata_i  )
);

npu_act_mem ACTIVATION_MEM (
    .clka  (clk               ),
    .wea   (mem1_wr_o         ),
    .addra (mem1_addr_o       ),
    .dina  (mem1_wrdata_o     ),
    .douta (mem1_rddata_i     ),
						      
    .clkb  (clk               ),
    .web   (npu_act_wr_o      ),
    .addrb (npu_act_wr_addr_o ),
    .dinb  (npu_act_wrdata_o  ),
    .doutb (npu_act_rddata_i  )
);


endmodule
