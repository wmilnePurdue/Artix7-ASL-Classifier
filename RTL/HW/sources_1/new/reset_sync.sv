`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2025 09:43:18 PM
// Design Name: 
// Module Name: reset_sync
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


module reset_sync(
    input        clk,
    input        rst_asyn,
    input        en,

    output logic rst_syn    
);

logic rst_syn0;
logic rst_syn1;

always_ff @ (posedge clk, negedge rst_asyn) begin
    if(~rst_asyn) begin
        rst_syn  <= 1'b0;
        rst_syn0 <= 1'b0;
        rst_syn1 <= 1'b0;
    end
    else begin
        if(en) begin
            rst_syn  <= rst_syn0;
            rst_syn0 <= rst_syn1;
            rst_syn1 <= 1'b1;
        end
    end
end

endmodule
