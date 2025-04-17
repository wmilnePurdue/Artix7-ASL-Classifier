`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2025 10:15:02 PM
// Design Name: 
// Module Name: div_core
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


module div_core (
    input  wire A_i,
    input  wire B_i,
		   
    input  wire Bo_i,
    input  wire OS_i,

    output wire Bo_o,
    output wire Q_o
);

wire D_w;

assign Q_o  = (D_w & ~OS_i) | (A_i & OS_i);
assign D_w  = (A_i ^ B_i ^ Bo_i);
assign Bo_o = (~A_i & B_i) | (Bo_i & ~(A_i ^ B_i));

endmodule

