`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2025 05:06:22 PM
// Design Name: 
// Module Name: pixel_bin_checker
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


module pixel_bin_checker(
    input wire        npu_clk,
    input wire        npu_write_en,
    input wire [11:0] npu_addr,
    input wire [7:0]  npu_data
);

logic [7:0] mem_ref [3072-1:0];
logic compare_ok;

wire [7:0] ref_data = mem_ref[npu_addr];
wire comb_compare   = (npu_data == ref_data);

initial begin
    $readmemh("C:/Users/Michael/Downloads/share_0420/pxl_binned_255_x.hex", mem_ref);
end

always_ff @ (posedge npu_clk) begin
    if(compare_ok === 1'bx) begin
        compare_ok <= 1'b1;
    end
    else if(npu_write_en && (npu_addr < 3072)) begin
        compare_ok <= comb_compare;
    end
end

endmodule
