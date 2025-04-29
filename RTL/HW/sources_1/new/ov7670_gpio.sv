`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2025 10:02:45 PM
// Design Name: 
// Module Name: ov7670_gpio
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


module ov7670_gpio # (
    parameter OUTPUT_IO = 8,
    parameter INPUT_IO  = 8
)(
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
    output logic           ahb_s0_hresp_o,
    output logic [31:0]    ahb_s0_hrdata_o,

    input  wire            cam_clk,
    input  wire            cam_clk_en,

    // External-interface
    output logic           xclk,

    input  [INPUT_IO-1:0]  ext_input_io,
    output [OUTPUT_IO-1:0] ext_output_io,

	input  wire            p_clock,
	input  wire            vsync,
	input  wire            href,
	input  wire   [7:0]    p_data,
						   
    inout                  i2c_scl,
    inout                  i2c_sda,

    // External-interface
    output logic  [5:0]    row_reg_o
);

localparam RW_REG_CNT = 7;
localparam R_REG_CNT  = 100;

wire [31:0]    rw_reg [RW_REG_CNT-1:0];
wire [31:0]    r_reg  [R_REG_CNT-1:0];

// GPIO
wire [OUTPUT_IO-1:0] gpio_write;
wire [INPUT_IO-1:0] gpio_clear;
wire [INPUT_IO-1:0] gpio_read;

// OV7670
// I2C
wire                i2c_start_en;
wire [7:0]          i2c_addr_i;
wire [7:0]          i2c_data_i;
wire [31:0]         delay_i;

wire                i2c_ready_o;

// graphics
wire                pxl_start_en;
wire [15:0]         r_data [1:0][31:0];
wire [15:0]         g_data [1:0][31:0];
wire [15:0]         b_data [1:0][31:0];

wire  [5:0]         row_o;
wire                cont_read;

// Memory Map assignment
// R/W registers
assign gpio_write   = rw_reg[0][OUTPUT_IO-1:0]; // 0x4000_0000
assign gpio_clear   = rw_reg[1][INPUT_IO-1:0];  // 0x4000_0004
assign i2c_start_en = rw_reg[2][0];             // 0x4000_0008
assign i2c_addr_i   = rw_reg[3][15:8];          // 0x4000_000C (upper)
assign i2c_data_i   = rw_reg[3][7:0];           // 0x4000_000C (lower)
assign delay_i      = rw_reg[4];                // 0x4000_0010
assign pxl_start_en = rw_reg[5][0];             // 0x4000_0014
assign cont_read    = rw_reg[6][0];             // 0x4000_0018

if(INPUT_IO < 32) begin
    assign r_reg[0][31:INPUT_IO] = {(32-INPUT_IO){1'b0}};
end
assign r_reg[0][INPUT_IO-1:0] = gpio_read;             // 0x4008_0000
assign r_reg[1]               = {31'h0, i2c_ready_o};  // 0x4008_0004

for (genvar i0 = 0; i0 < 32; i0++) begin
    assign r_reg[2 +      i0] =  {r_data[1][i0], r_data[0][i0]}; // 0x4008_0008 to 0x0008_0084
    assign r_reg[2 + 32 + i0] =  {g_data[1][i0], g_data[0][i0]}; // 0x4008_0088 to 0x0008_0104
    assign r_reg[2 + 64 + i0] =  {b_data[1][i0], b_data[0][i0]}; // 0x4008_0108 to 0x0008_0184
end

assign r_reg[98] = {26'h0, row_o};      // 0x4008_0188
assign r_reg[99] = {31'h0, pxl_idle_o}; // 0x4008_018C

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        row_reg_o <= '0;
    end
    else begin
        row_reg_o <= row_o;
    end
end

csr_regfile # (
    .RW_REG_CNT          (RW_REG_CNT          ),
    .R_REG_CNT           (R_REG_CNT           )
) CSR_FILE (                       
    .clk                 (clk                 ),
    .resetn              (resetn              ),
                          
    .ahb_s0_haddr_i      (ahb_s0_haddr_i      ),
    .ahb_s0_hwrite_i     (ahb_s0_hwrite_i     ),
    .ahb_s0_hsize_i      (ahb_s0_hsize_i      ),
    .ahb_s0_hburst_i     (ahb_s0_hburst_i     ),
    .ahb_s0_hprot_i      (ahb_s0_hprot_i      ),
    .ahb_s0_htrans_i     (ahb_s0_htrans_i     ),
    .ahb_s0_hmastlock_i  (ahb_s0_hmastlock_i  ),
    .ahb_s0_hwdata_i     (ahb_s0_hwdata_i     ),
                          
    .ahb_s0_hready_o     (ahb_s0_hready_o     ),
    .ahb_s0_hresp_o      (ahb_s0_hresp_o      ),
    .ahb_s0_hrdata_o     (ahb_s0_hrdata_o     ),
                          
    .rw_reg              (rw_reg              ),
    .r_reg               (r_reg               )
);

gpio # (
    .OUTPUT_IO  (OUTPUT_IO  ),
    .INPUT_IO   (INPUT_IO   )
) GPIO_INST (
    .clk                 (clk           ),
    .resetn              (resetn        ),
									    
    .ahbl_input_io       (gpio_read     ),
    .ahbl_clear_input_io (gpio_clear    ),
    .ahbl_output_io      (gpio_write    ),
									    
    .ext_input_io        (ext_input_io  ),
    .ext_output_io       (ext_output_io )
);

ov7670 CAMERA_UNIT (
    .clk                 (clk          ),
    .resetn              (resetn       ),
									   
    .i2c_start_en        (i2c_start_en ),
									   
    .i2c_addr_i          (i2c_addr_i   ),
    .i2c_data_i          (i2c_data_i   ),
    .delay_i             (delay_i      ),
									   
    .i2c_ready_o         (i2c_ready_o  ),
									   
    .pxl_start_en        (pxl_start_en ),
									   
    .r_data              (r_data       ),
    .g_data              (g_data       ),
    .b_data              (b_data       ),
    .row_o               (row_o        ),

    .pxl_idle_o          (pxl_idle_o   ),

// must be set false path (clk synchronized)
    .cont_read           (cont_read    ),

// External Interface    
    .p_clock             (p_clock      ),
    .vsync               (vsync        ),
    .href                (href         ),
    .p_data              (p_data       ),
								       
    .i2c_scl             (i2c_scl      ),
    .i2c_sda             (i2c_sda      )
);

ov7670clk_gen CLK_GENERATOR (
    .cam_clk             (cam_clk      ),
    .resetn              (resetn       ),
    .cam_clk_en          (cam_clk_en   ),
    .xclk                (xclk         )
);

endmodule
