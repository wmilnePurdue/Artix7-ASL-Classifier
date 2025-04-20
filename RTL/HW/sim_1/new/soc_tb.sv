`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2025 04:39:35 PM
// Design Name: 
// Module Name: soc_tb
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

module soc_tb();

localparam [31:0] DELAY_MS = 1000;

logic                  clk;
logic                  resetn;

logic [`IN_IO-1:0]     ext_input_io;
wire [`OUT_IO-1:0]     ext_output_io;

wire                   xclk;

wire                   p_clock;
wire                   vsync;
wire                   href;
wire   [7:0]           p_data;
					    
wire                   i2c_scl;
wire                   i2c_sda;

`ifdef SPI_OUTPUT
logic                  spi_sclk;
logic                  spi_sdo;
				       
logic                  dc;
logic                  csn;
`elsif SSD_OUTPUT
wire                   SW0;
wire   [6:0]           seg;
wire   [3:0]           an;

assign SW0 = 1'b0;
`endif

wire        npu_clk;
wire        npu_write_en;
wire [11:0] npu_addr;
wire [7:0]  npu_data;

soc_top SOC (
    .clk           (clk           ),
    .resetn        (resetn        ),
			  
    .ext_input_io  (ext_input_io  ),
    .ext_output_io (ext_output_io ),
			  
    .xclk          (xclk          ),
    .p_clock       (p_clock       ),
    .vsync         (vsync         ),
    .href          (href          ),
    .p_data        (p_data        ),
							      
    .i2c_scl       (i2c_scl       ),
    .i2c_sda       (i2c_sda       )
`ifdef SPI_OUTPUT
    ,
    .spi_sclk (spi_sclk ),
    .spi_sdo  (spi_sdo  ),
    
    .dc       (dc       ),
    .csn      (csn      )
`elsif SSD_OUTPUT
    ,
    .SW0      (SW0      ),
    .seg      (seg      ),
    .an       (an       )
`endif
);

assign npu_clk      = SOC.NPU.RGB_INPUT_MEM.clka;
assign npu_write_en = SOC.NPU.RGB_INPUT_MEM.wea;
assign npu_addr     = SOC.NPU.RGB_INPUT_MEM.addra;
assign npu_data     = SOC.NPU.RGB_INPUT_MEM.dina;

ov7670_model OV7670_CAM_MODULE (
    .xclk    (xclk     ),
    .reset   (~resetn  ),

    .p_clock (p_clock  ),
    .vsync   (vsync    ),
    .href    (href     ),
    .p_data  (p_data   ),

    .i2c_scl (i2c_scl  ),
    .i2c_sda (i2c_sda  )
);

pixel_bin_checker PXL_BIN_CHK (
    .npu_clk      (npu_clk      ),
    .npu_write_en (npu_write_en ),
    .npu_addr     (npu_addr     ),
    .npu_data     (npu_data     )
);

`ifdef SPI_OUTPUT

logic [4:0]  ptr;
logic [31:0] ctr;
logic [31:0] data;

always_ff @ (posedge spi_sclk, negedge resetn) begin
    if(~resetn) begin
        ptr  <= 5'h1F;
        data <= 32'h0;
        ctr  <= 32'h0;
    end
    else begin
        if(~csn) begin
            data[ptr] <= spi_sdo;
            ptr       <= ptr - 1'b1;
            ctr       <= ctr + 1'b1;
        end
    end
end

`endif

initial begin
    clk <= 1'b0;
    forever #5 clk <= ~clk;
end

initial begin
    ext_input_io <= '0;
    forever #500000 ext_input_io[0] <= ~ext_input_io[0];
end

initial begin
    resetn <= 1'b0;
    #100;
    @(posedge clk);
    resetn <= 1'b1;
end

initial begin
    for(integer i0 = 0; i0 < DELAY_MS; i0++) begin
        #1000000;
    end
    $stop;
end

endmodule
