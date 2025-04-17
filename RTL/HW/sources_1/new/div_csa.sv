`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2025 10:23:15 PM
// Design Name: 
// Module Name: div_csa
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


module div_csa(
    input [7:0]  A_i,
    input [7:0]  B_i,
    input        Bo_i,
				 
    input        OS_i,

    output       BO_o,
    output [7:0] Q_o
);

wire       BO_upper;
wire       BO_lower;
wire [7:0] Q_upper;
wire [7:0] Q_lower;

assign BO_o = Bo_i ? BO_upper : BO_lower;
assign Q_o  = Bo_i ? Q_upper  : Q_lower;

div_half_csa DIV_CSA_UPPER (
    .A_i  (A_i      ),
    .B_i  (B_i      ),
    .Bo_i (1'b1     ),
			        
    .OS_i (OS_i     ),
    .BO_o (BO_upper ),
    .Q_o  (Q_upper  )
);

div_half_csa DIV_CSA_LOWER (
    .A_i  (A_i      ),
    .B_i  (B_i      ),
    .Bo_i (1'b0     ),
			        
    .OS_i (OS_i     ),
    .BO_o (BO_lower ),
    .Q_o  (Q_lower  )
);

endmodule
