`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2025 11:11:38 PM
// Design Name: 
// Module Name: ov7670
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


module ov7670(
    input                clk,
    input                resetn,
		                 
    input                i2c_start_en,

    input [7:0]          i2c_addr_i,
    input [7:0]          i2c_data_i,
    input [31:0]         delay_i,
				         
    output logic         i2c_ready_o,

    input                pxl_start_en,

    output logic [15:0]  r_data [1:0][31:0],
    output logic [15:0]  g_data [1:0][31:0],
    output logic [15:0]  b_data [1:0][31:0],
    output logic  [5:0]  row_o,

    output logic         pxl_idle_o,

// must be set false path (clk synchronized)
    input  wire          cont_read,

// External Interface
	input  wire          p_clock,
	input  wire          vsync,
	input  wire          href,
	input  wire   [7:0]  p_data,

    inout                i2c_scl,
    inout                i2c_sda
);

wire       get_data;
wire [7:0] p_data_sync;
wire       data_ready;

wire       cam_read_busy;

i2c_io I2C_IO (
    .clk        (clk          ),
    .resetn     (resetn       ),
		        
    .start_en   (i2c_start_en ),
    .i2c_addr_i (i2c_addr_i   ),
    .i2c_data_i (i2c_data_i   ),
    .delay_i    (delay_i      ),
							  
    .ready_o    (i2c_ready_o  ),
				 		       
    .i2c_scl    (i2c_scl      ),
    .i2c_sda    (i2c_sda      )
);

camera_io CAMERA (
//  ------------
//  clk domain
//  ------------
    .clk           (clk             ),
    .resetn        (resetn          ),
								    
    .get_data      (get_data        ),
    .p_data_sync   (p_data_sync     ),
    .data_ready    (data_ready      ),
// must be synchronized to clk      
    .cam_read_busy (cam_read_busy   ),
// must be synchronized to p_clock  
    .start_en      (pxl_start_en    ),

//  ---------------
//  p_clock domain
//  ---------------

// must be set false path (clk synchronized)
   .cont_read      (cont_read     ),
							      
   .p_clock        (p_clock       ),
   .vsync          (vsync         ),
   .href           (href          ),
   .p_data         (p_data        )
);

pixel_binner PIXEL_BIN (
    .clk           (clk             ),
    .resetn        (resetn          ),
				        
    .start_en      (pxl_start_en    ),
				  
    .r_data        (r_data          ),
    .g_data        (g_data          ),
    .b_data        (b_data          ),
    .row_o         (row_o           ),

    .pxl_idle_o    (pxl_idle_o      ),

// FIFO Interface
    .get_data      (get_data        ),
    .p_data_sync   (p_data_sync     ),
    .data_ready    (data_ready      )
);

endmodule
