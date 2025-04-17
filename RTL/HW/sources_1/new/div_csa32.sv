`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2025 10:23:15 PM
// Design Name: 
// Module Name: div_csa32
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


module div_csa32(
    input  [31:0] A_i,
    input  [31:0] B_i,

    output        Bo31_o,
    output [31:0] Q_o
);

wire [3:0] BO_w;
assign Bo31_o = BO_w[3];

div_csa DIV_BIT_31_24 (
    .A_i  (A_i[31:24] ),
    .B_i  (B_i[31:24] ),
    .Bo_i (BO_w[2]    ),
			        
    .OS_i (BO_w[3]    ),
    .BO_o (BO_w[3]    ),
    .Q_o  (Q_o[31:24] )
);

div_csa DIV_BIT_23_16 (
    .A_i  (A_i[23:16] ),
    .B_i  (B_i[23:16] ),
    .Bo_i (BO_w[1]    ),
			        
    .OS_i (BO_w[3]    ),
    .BO_o (BO_w[2]    ),
    .Q_o  (Q_o[23:16] )
);

div_csa DIV_BIT_15_8 (
    .A_i  (A_i[15:8] ),
    .B_i  (B_i[15:8] ),
    .Bo_i (BO_w[0]   ),
			        
    .OS_i (BO_w[3]   ),
    .BO_o (BO_w[1]   ),
    .Q_o  (Q_o[15:8] )
);

div_half_csa DIV_BIT_7_0 (
    .A_i  (A_i[7:0]  ),
    .B_i  (B_i[7:0]  ),
    .Bo_i (1'b0      ),
			         
    .OS_i (BO_w[3]   ),
    .BO_o (BO_w[0]   ),
    .Q_o  (Q_o[7:0]  )
);

endmodule
