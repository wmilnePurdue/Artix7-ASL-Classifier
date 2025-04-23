`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2025 09:40:46 PM
// Design Name: 
// Module Name: soc_top
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

`include "soc_defs.vh"

module soc_top(
    input                   clk,
    input                   resetn,

    // External-interface
    input  [`IN_IO-1:0]     ext_input_io,
    output [`OUT_IO-1:0]    ext_output_io,

    output                  xclk,

	input  wire             p_clock,
	input  wire             vsync,
	input  wire             href,
	input  wire   [7:0]     p_data,
						    
    inout                   i2c_scl,
    inout                   i2c_sda

`ifdef SPI_OUTPUT
    ,
    output logic           spi_sclk,
    output logic           spi_sdo,
    
    output logic           dc,
    output logic           csn
`elsif SSD_OUTPUT
    ,
    input  wire            SW0,
    output wire   [6:0]    seg,
    output wire   [3:0]    an
`endif
);

wire clk_int;
wire cam_clk;
wire resetn_int;
wire pll_reset;
logic pll_en;

wire [31:0]     ahb_cpu2bus_haddr_o;
wire            ahb_cpu2bus_hwrite_o;
wire [2:0]      ahb_cpu2bus_hsize_o;
wire [2:0]      ahb_cpu2bus_hburst_o;
wire [3:0]      ahb_cpu2bus_hprot_o;
wire [1:0]      ahb_cpu2bus_htrans_o;
wire            ahb_cpu2bus_hmastlock_o;
wire [31:0]     ahb_cpu2bus_hwdata_o;

wire            ahb_cpu2bus_hready_i;
wire            ahb_cpu2bus_hresp_i;
wire [31:0]     ahb_cpu2bus_hrdata_i;

wire [31:0]     ahb_ov7670_gpio_haddr_o;
wire            ahb_ov7670_gpio_hwrite_o;
wire [2:0]      ahb_ov7670_gpio_hsize_o;
wire [2:0]      ahb_ov7670_gpio_hburst_o;
wire [3:0]      ahb_ov7670_gpio_hprot_o;
wire [1:0]      ahb_ov7670_gpio_htrans_o;
wire            ahb_ov7670_gpio_hmastlock_o;
wire [31:0]     ahb_ov7670_gpio_hwdata_o;
			    
wire            ahb_ov7670_gpio_hready_i;
wire            ahb_ov7670_gpio_hresp_i;
wire [31:0]     ahb_ov7670_gpio_hrdata_i;

wire [31:0]     ahb_npu_accel_haddr_o;
wire            ahb_npu_accel_hwrite_o;
wire [2:0]      ahb_npu_accel_hsize_o;
wire [2:0]      ahb_npu_accel_hburst_o;
wire [3:0]      ahb_npu_accel_hprot_o;
wire [1:0]      ahb_npu_accel_htrans_o;
wire            ahb_npu_accel_hmastlock_o;
wire [31:0]     ahb_npu_accel_hwdata_o;
			    
wire            ahb_npu_accel_hready_i;
wire            ahb_npu_accel_hresp_i;
wire [31:0]     ahb_npu_accel_hrdata_i;

wire [31:0]     ahb_out_unit_haddr_o;
wire            ahb_out_unit_hwrite_o;
wire [2:0]      ahb_out_unit_hsize_o;
wire [2:0]      ahb_out_unit_hburst_o;
wire [3:0]      ahb_out_unit_hprot_o;
wire [1:0]      ahb_out_unit_htrans_o;
wire            ahb_out_unit_hmastlock_o;
wire [31:0]     ahb_out_unit_hwdata_o;
			    
wire            ahb_out_unit_hready_i;
wire            ahb_out_unit_hresp_i;
wire [31:0]     ahb_out_unit_hrdata_i;

cpu_core # (
    .AWID                (12                          )
) CPU (
    .clk                 (clk_int                     ), 
    .resetn              (resetn_int                  ),
												      
    .ahb_haddr_o         (ahb_cpu2bus_haddr_o         ),
    .ahb_hwrite_o        (ahb_cpu2bus_hwrite_o        ),
    .ahb_hsize_o         (ahb_cpu2bus_hsize_o         ),
    .ahb_hburst_o        (ahb_cpu2bus_hburst_o        ),
    .ahb_hprot_o         (ahb_cpu2bus_hprot_o         ),
    .ahb_htrans_o        (ahb_cpu2bus_htrans_o        ),
    .ahb_hmastlock_o     (ahb_cpu2bus_hmastlock_o     ),
    .ahb_hwdata_o        (ahb_cpu2bus_hwdata_o        ),
												      
    .ahb_hready_i        (ahb_cpu2bus_hready_i        ),
    .ahb_hresp_i         (ahb_cpu2bus_hresp_i         ),
    .ahb_hrdata_i        (ahb_cpu2bus_hrdata_i        )
);                                                    
													  
ahb_interconnect BUS (                                     
    .clk                 (clk_int                     ), 
    .resetn              (resetn_int                  ),
												      
    .ahb_s0_haddr_i      (ahb_cpu2bus_haddr_o         ),
    .ahb_s0_hwrite_i     (ahb_cpu2bus_hwrite_o        ),
    .ahb_s0_hsize_i      (ahb_cpu2bus_hsize_o         ),
    .ahb_s0_hburst_i     (ahb_cpu2bus_hburst_o        ),
    .ahb_s0_hprot_i      (ahb_cpu2bus_hprot_o         ),
    .ahb_s0_htrans_i     (ahb_cpu2bus_htrans_o        ),
    .ahb_s0_hmastlock_i  (ahb_cpu2bus_hmastlock_o     ),
    .ahb_s0_hwdata_i     (ahb_cpu2bus_hwdata_o        ),
												      
    .ahb_s0_hready_o     (ahb_cpu2bus_hready_i        ),
    .ahb_s0_hresp_o      (ahb_cpu2bus_hresp_i         ),
    .ahb_s0_hrdata_o     (ahb_cpu2bus_hrdata_i        ),
													  
    .ahb_m0_haddr_o      (ahb_ov7670_gpio_haddr_o     ),
    .ahb_m0_hwrite_o     (ahb_ov7670_gpio_hwrite_o    ),
    .ahb_m0_hsize_o      (ahb_ov7670_gpio_hsize_o     ),
    .ahb_m0_hburst_o     (ahb_ov7670_gpio_hburst_o    ),
    .ahb_m0_hprot_o      (ahb_ov7670_gpio_hprot_o     ),
    .ahb_m0_htrans_o     (ahb_ov7670_gpio_htrans_o    ),
    .ahb_m0_hmastlock_o  (ahb_ov7670_gpio_hmastlock_o ),
    .ahb_m0_hwdata_o     (ahb_ov7670_gpio_hwdata_o    ),
													  
    .ahb_m0_hready_i     (ahb_ov7670_gpio_hready_i    ),
    .ahb_m0_hresp_i      (ahb_ov7670_gpio_hresp_i     ),
    .ahb_m0_hrdata_i     (ahb_ov7670_gpio_hrdata_i    ),

    .ahb_m1_haddr_o      (ahb_npu_accel_haddr_o       ),
    .ahb_m1_hwrite_o     (ahb_npu_accel_hwrite_o      ),
    .ahb_m1_hsize_o      (ahb_npu_accel_hsize_o       ),
    .ahb_m1_hburst_o     (ahb_npu_accel_hburst_o      ),
    .ahb_m1_hprot_o      (ahb_npu_accel_hprot_o       ),
    .ahb_m1_htrans_o     (ahb_npu_accel_htrans_o      ),
    .ahb_m1_hmastlock_o  (ahb_npu_accel_hmastlock_o   ),
    .ahb_m1_hwdata_o     (ahb_npu_accel_hwdata_o      ),
													    
    .ahb_m1_hready_i     (ahb_npu_accel_hready_i      ),
    .ahb_m1_hresp_i      (ahb_npu_accel_hresp_i       ),
    .ahb_m1_hrdata_i     (ahb_npu_accel_hrdata_i      ),

    .ahb_m2_haddr_o      (ahb_out_unit_haddr_o        ),
    .ahb_m2_hwrite_o     (ahb_out_unit_hwrite_o       ),
    .ahb_m2_hsize_o      (ahb_out_unit_hsize_o        ),
    .ahb_m2_hburst_o     (ahb_out_unit_hburst_o       ),
    .ahb_m2_hprot_o      (ahb_out_unit_hprot_o        ),
    .ahb_m2_htrans_o     (ahb_out_unit_htrans_o       ),
    .ahb_m2_hmastlock_o  (ahb_out_unit_hmastlock_o    ),
    .ahb_m2_hwdata_o     (ahb_out_unit_hwdata_o       ),
													     
    .ahb_m2_hready_i     (ahb_out_unit_hready_i       ),
    .ahb_m2_hresp_i      (ahb_out_unit_hresp_i        ),
    .ahb_m2_hrdata_i     (ahb_out_unit_hrdata_i       )
);

ov7670_gpio # (
    .OUTPUT_IO           (`OUT_IO                     ),
    .INPUT_IO            (`IN_IO                      )
) CAMERA_UNIT (
    .clk                 (clk_int                     ), 
    .resetn              (resetn_int                  ),

    .ahb_s0_haddr_i      (ahb_ov7670_gpio_haddr_o     ),
    .ahb_s0_hwrite_i     (ahb_ov7670_gpio_hwrite_o    ),
    .ahb_s0_hsize_i      (ahb_ov7670_gpio_hsize_o     ),
    .ahb_s0_hburst_i     (ahb_ov7670_gpio_hburst_o    ),
    .ahb_s0_hprot_i      (ahb_ov7670_gpio_hprot_o     ),
    .ahb_s0_htrans_i     (ahb_ov7670_gpio_htrans_o    ),
    .ahb_s0_hmastlock_i  (ahb_ov7670_gpio_hmastlock_o ),
    .ahb_s0_hwdata_i     (ahb_ov7670_gpio_hwdata_o    ),
												      
    .ahb_s0_hready_o     (ahb_ov7670_gpio_hready_i    ),
    .ahb_s0_hresp_o      (ahb_ov7670_gpio_hresp_i     ),
    .ahb_s0_hrdata_o     (ahb_ov7670_gpio_hrdata_i    ),

    .cam_clk             (cam_clk                     ),
    .cam_clk_en          (pll_en                      ),

    // External-interface
    .xclk                (xclk                        ),

    .ext_input_io        (ext_input_io                ),
    .ext_output_io       (ext_output_io               ),

    .p_clock             (p_clock                     ),
    .vsync               (vsync                       ),
    .href                (href                        ),
    .p_data              (p_data                      ),
								                      
    .i2c_scl             (i2c_scl                     ),
    .i2c_sda             (i2c_sda                     )
);

`ifdef NPU_ACCELERATOR

npu_top NPU (
    .clk                 (clk_int                   ), 
    .resetn              (resetn_int                ),

    .ahb_s0_haddr_i      (ahb_npu_accel_haddr_o     ),
    .ahb_s0_hwrite_i     (ahb_npu_accel_hwrite_o    ),
    .ahb_s0_hsize_i      (ahb_npu_accel_hsize_o     ),
    .ahb_s0_hburst_i     (ahb_npu_accel_hburst_o    ),
    .ahb_s0_hprot_i      (ahb_npu_accel_hprot_o     ),
    .ahb_s0_htrans_i     (ahb_npu_accel_htrans_o    ),
    .ahb_s0_hmastlock_i  (ahb_npu_accel_hmastlock_o ),
    .ahb_s0_hwdata_i     (ahb_npu_accel_hwdata_o    ),

    .ahb_s0_hready_o     (ahb_npu_accel_hready_i    ),
    .ahb_s0_hresp_o      (ahb_npu_accel_hresp_i     ),
    .ahb_s0_hrdata_o     (ahb_npu_accel_hrdata_i    )
);

`else
    assign ahb_npu_accel_hready_i = 1'b1;
    assign ahb_npu_accel_hresp_i  = 1'b0;
    assign ahb_npu_accel_hrdata_i = 32'h0;
`endif

`ifdef SPI_OUTPUT
spi_io SPI_INTERFACE (
    .clk                 (clk_int                  ), 
    .resetn              (resetn_int               ),

    .ahb_s0_haddr_i      (ahb_out_unit_haddr_o     ),
    .ahb_s0_hwrite_i     (ahb_out_unit_hwrite_o    ),
    .ahb_s0_hsize_i      (ahb_out_unit_hsize_o     ),
    .ahb_s0_hburst_i     (ahb_out_unit_hburst_o    ),
    .ahb_s0_hprot_i      (ahb_out_unit_hprot_o     ),
    .ahb_s0_htrans_i     (ahb_out_unit_htrans_o    ),
    .ahb_s0_hmastlock_i  (ahb_out_unit_hmastlock_o ),
    .ahb_s0_hwdata_i     (ahb_out_unit_hwdata_o    ),

    .ahb_s0_hready_o     (ahb_out_unit_hready_i    ),
    .ahb_s0_hresp_o      (ahb_out_unit_hresp_i     ),
    .ahb_s0_hrdata_o     (ahb_out_unit_hrdata_i    ),

    .spi_sclk            (spi_sclk                 ),
    .spi_sdo             (spi_sdo                  ),

    .dc                  (dc                       ),
    .csn                 (csn                      )
);
`elsif SSD_OUTPUT
ssd_io SSD_INTERFACE (
    .clk                 (clk_int                  ),
    .resetn              (resetn                   ),
    .ahb_s0_haddr_i      (ahb_out_unit_haddr_o     ),
    .ahb_s0_hwrite_i     (ahb_out_unit_hwrite_o    ),
    .ahb_s0_hsize_i      (ahb_out_unit_hsize_o     ),
    .ahb_s0_hburst_i     (ahb_out_unit_hburst_o    ),
    .ahb_s0_hprot_i      (ahb_out_unit_hprot_o     ),
    .ahb_s0_htrans_i     (ahb_out_unit_htrans_o    ),
    .ahb_s0_hmastlock_i  (ahb_out_unit_hmastlock_o ),
    .ahb_s0_hwdata_i     (ahb_out_unit_hwdata_o    ),
    .SW0(SW0),
    .ahb_s0_hready_o     (ahb_out_unit_hready_i    ),
    .ahb_s0_hresp_o      (ahb_out_unit_hresp_i     ),
    .ahb_s0_hrdata_o     (ahb_out_unit_hrdata_i    ),
    .seg(seg),
    .an(an)
);
`else
    assign ahb_out_unit_hready_i = 1'b1;
    assign ahb_out_unit_hresp_i  = 1'b0;
    assign ahb_out_unit_hrdata_i = 32'h0;
`endif


// RESET Synchronizer

`ifdef USE_PLL
    wire pll_lock;
    logic pll_lock1, pll_lock2;

    assign clk_int = cam_clk;

    pll_ip_core PLL_INST (
       .clk_in1  (clk        ),
       .resetn   (pll_reset  ),
       // .clk_out1 (           ),
       .clk_out2 (cam_clk    ),
       .locked   (pll_lock   )
    );

    always_ff @ (posedge clk, negedge resetn) begin
        if(~resetn) begin
            pll_lock1 <= 1'b0;
            pll_lock2 <= 1'b0;
            pll_en    <= 1'b0;
        end
        else begin
            pll_lock1 <= pll_lock;
            pll_lock2 <= pll_lock1;
            pll_en    <= pll_lock2;
        end
    end

    reset_sync PLL_RST_SYNC (
        .clk      (clk        ),         
        .rst_asyn (resetn     ),
        .en       (1'b1       ),
        .rst_syn  (pll_reset  )
    );
`else
    assign pll_en    = 1'b1;
    assign pll_reset = resetn;
    assign clk_int   = clk;
    assign cam_clk   = clk;
`endif

reset_sync RST_SYNC (
    .clk      (clk_int    ),         
    .rst_asyn (pll_reset  ),
    .en       (pll_en     ),
    .rst_syn  (resetn_int )
);

endmodule
