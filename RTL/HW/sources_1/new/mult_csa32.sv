`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2025 08:57:08 PM
// Design Name: 
// Module Name: mult_csa32
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


module mult_csa32( 
    input  [31:0] C_i,  // Carry
    input  [31:0] SP_i, // Product

    output [31:0] P_o
);

wire [8:0] Pf_w [3:0];

assign P_o[ 7: 0] = Pf_w[0][7:0];
assign P_o[15: 8] = Pf_w[1][7:0];
assign P_o[23:16] = Pf_w[2][7:0];
assign P_o[31:24] = Pf_w[3][7:0];

mult_csa MULT_BIT_31_24 (
    .C_i   (C_i [31:24] ),
    .SP_i  ({1'b1, SP_i[30:24]}),
    .C0_i  (Pf_w[2][8]  ),
					   
    .P_o   (Pf_w [3]    )
);

mult_csa MULT_BIT_23_16 (
    .C_i   (C_i [23:16] ),
    .SP_i  (SP_i[23:16]  ),
    .C0_i  (Pf_w[1][8]  ),
					   
    .P_o   (Pf_w [2]    )
);

mult_csa MULT_BIT_15_8 (
    .C_i   (C_i [15:8] ),
    .SP_i  (SP_i[15:8] ),
    .C0_i  (Pf_w[0][8] ),
					   
    .P_o   (Pf_w [1]   )
);

mult_half_csa MULT_BIT_7_0 (
    .C_i   (C_i [7:0] ),
    .SP_i  (SP_i[7:0] ),
    .C0_i  (1'b0      ),

    .P_o   (Pf_w [0] )
);

endmodule
