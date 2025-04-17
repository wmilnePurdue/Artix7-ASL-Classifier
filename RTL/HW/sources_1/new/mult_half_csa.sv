`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2025 08:37:11 PM
// Design Name: 
// Module Name: mult_half_csa
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


module mult_half_csa(
    input  [7:0] C_i,
    input  [7:0] SP_i,
    input        C0_i,

    output [8:0] P_o
);

wire [7:0] C_w;

assign P_o[8] = C_w[7];

for(genvar i0 = 0; i0 < 8; i0++) begin : MULT_END_GEN
    logic A_i;
    logic xSP_i;
    logic xC_i;

    if(i0 == 0) begin
        assign A_i = C0_i;
    end
    else begin
        assign A_i = C_w[i0-1];
    end

    mult_core u_MULTCORE0 (
        .A_i  (A_i      ),
        .B_i  (1'b1     ),
    				    
        .SP_i (SP_i[i0] ),
        .C_i  (C_i[i0]  ),
    					            
        .P_o  (P_o[i0]  ),
        .C_o  (C_w[i0]  )
    );
    
end

endmodule
