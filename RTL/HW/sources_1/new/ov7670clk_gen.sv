`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2025 04:20:27 PM
// Design Name: 
// Module Name: ov7670clk_gen
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


module ov7670clk_gen(
    input cam_clk,
    input resetn,
    input cam_clk_en,
    
    output logic xclk
);

logic [1:0] reset_sync;
logic [3:0] cam_clk_en_sync;

always_ff @ (posedge cam_clk, negedge resetn) begin
    if(~resetn) begin
        reset_sync <= 2'b00;
    end
    else begin
        reset_sync[0] <= 1'b1;
        reset_sync[1] <= reset_sync[0];
    end
end

always_ff @ (posedge cam_clk, negedge reset_sync[1]) begin
    if(~reset_sync[1]) begin
        cam_clk_en_sync <= 4'h0;
    end
    else begin
        cam_clk_en_sync[0] <= cam_clk_en;
        cam_clk_en_sync[1] <= cam_clk_en_sync[0];
        cam_clk_en_sync[2] <= cam_clk_en_sync[1];
        cam_clk_en_sync[3] <= cam_clk_en_sync[2];
    end
end

always_ff @ (posedge cam_clk, negedge reset_sync[1]) begin
    if(~reset_sync[1]) begin
        xclk <= 1'b0;
    end
    else begin
        if(cam_clk_en_sync[3]) begin
            xclk <= ~xclk;
        end
    end
end

endmodule
