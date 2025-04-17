`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2025 10:15:02 PM
// Design Name: 
// Module Name: mult_core
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


module mult_core(
    input wire  A_i,
    input wire  B_i,
			    
    input wire  SP_i,
    input wire  C_i,
			    
    output wire P_o,
    output wire C_o
);

wire A_w;
wire B_w;

assign C_o  = ( A_w & B_w ) | (C_i & (A_w ^ B_w));
assign P_o  = ( A_w ^ B_w ^ C_i);

assign A_w = SP_i;
assign B_w = A_i & B_i;

endmodule

