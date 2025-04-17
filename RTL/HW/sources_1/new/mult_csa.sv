`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2025 11:18:51 PM
// Design Name: 
// Module Name: mult_csa
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


module mult_csa(
    input  [7:0] C_i,
    input  [7:0] SP_i,
    input        C0_i,

    output [8:0] P_o
);

wire [8:0] Po_lower;
wire [8:0] Po_upper;

assign P_o = C0_i ? Po_upper : Po_lower;

mult_half_csa MULT_CSA_LOWER (
    .C_i    (C_i      ),
    .SP_i   (SP_i     ),
    .C0_i   (1'b0     ),
					  
    .P_o    (Po_lower )
);

mult_half_csa MULT_CSA_UPPER (
    .C_i    (C_i      ),
    .SP_i   (SP_i     ),
    .C0_i   (1'b1     ),
					  
    .P_o    (Po_upper )
);

endmodule
