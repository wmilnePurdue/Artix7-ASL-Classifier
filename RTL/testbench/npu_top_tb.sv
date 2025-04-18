`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2025 08:24:39 PM
// Design Name: 
// Module Name: npu_top_tb
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


module npu_top_tb();

logic           clk_i;
logic           rstn_i;

wire [31:0]     ahb_s0_haddr_o;
wire            ahb_s0_hwrite_o;
wire [2:0]      ahb_s0_hsize_o;
wire [2:0]      ahb_s0_hburst_o;
wire [3:0]      ahb_s0_hprot_o;
wire [1:0]      ahb_s0_htrans_o;
wire            ahb_s0_hmastlock_o;
wire [31:0]     ahb_s0_hwdata_o;
			    
wire            ahb_s0_hready_i;
wire            ahb_s0_hresp_i;
wire [31:0]     ahb_s0_hrdata_i;

npu_top NPU (
    .clk                 (clk_i              ), 
    .resetn              (rstn_i             ),

    .ahb_s0_haddr_i      (ahb_s0_haddr_o     ),
    .ahb_s0_hwrite_i     (ahb_s0_hwrite_o    ),
    .ahb_s0_hsize_i      (ahb_s0_hsize_o     ),
    .ahb_s0_hburst_i     (ahb_s0_hburst_o    ),
    .ahb_s0_hprot_i      (ahb_s0_hprot_o     ),
    .ahb_s0_htrans_i     (ahb_s0_htrans_o    ),
    .ahb_s0_hmastlock_i  (ahb_s0_hmastlock_o ),
    .ahb_s0_hwdata_i     (ahb_s0_hwdata_o    ),

    .ahb_s0_hready_o     (ahb_s0_hready_i    ),
    .ahb_s0_hresp_o      (ahb_s0_hresp_i     ),
    .ahb_s0_hrdata_o     (ahb_s0_hrdata_i    )
);

ahb_master AHB_CTRL (                                      
    .clk                 (clk_i              ), 
    .resetn              (rstn_i             ),
												      
    .ahb_haddr_o         (ahb_s0_haddr_o     ),
    .ahb_hwrite_o        (ahb_s0_hwrite_o    ),
    .ahb_hsize_o         (ahb_s0_hsize_o     ),
    .ahb_hburst_o        (ahb_s0_hburst_o    ),
    .ahb_hprot_o         (ahb_s0_hprot_o     ),
    .ahb_htrans_o        (ahb_s0_htrans_o    ),
    .ahb_hmastlock_o     (ahb_s0_hmastlock_o ),
    .ahb_hwdata_o        (ahb_s0_hwdata_o    ),
												      
    .ahb_hready_i        (ahb_s0_hready_i    ),
    .ahb_hresp_i         (ahb_s0_hresp_i     ),
    .ahb_hrdata_i        (ahb_s0_hrdata_i    )
);         

initial begin
    clk_i <= 1'b0;
    forever #10 clk_i <= ~clk_i;
end

initial begin
    rstn_i <= 1'b0;
    #200;
    @(posedge clk_i);
    rstn_i <= 1'b1;
end

endmodule
