`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2025 10:23:15 PM
// Design Name: 
// Module Name: div_half_csa
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


module div_half_csa(
    input [7:0]  A_i,
    input [7:0]  B_i,
    input        Bo_i,
				 
    input        OS_i,

    output       BO_o,
    output [7:0] Q_o
);

wire [7:0] Bo_w;
assign BO_o = Bo_w[7];

for(genvar i0 = 0; i0 < 8; i0++) begin : DIV_GEN

    wire xBo_i;

    if(i0 == 0) begin
        assign xBo_i = Bo_i;
    end
    else begin
        assign xBo_i = Bo_w[i0-1];
    end

    div_core u_DIVCORE (
        .A_i  (A_i [i0]   ),
        .B_i  (B_i [i0]   ),
					    
        .Bo_i (xBo_i      ),
        .OS_i (OS_i       ),
					     
        .Bo_o (Bo_w[i0]   ),
        .Q_o  (Q_o [i0]   )
    );
end

endmodule
