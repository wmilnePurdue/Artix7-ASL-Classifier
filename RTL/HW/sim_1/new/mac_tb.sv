`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2025 07:09:02 PM
// Design Name: 
// Module Name: mac_tb
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


module mac_tb();

logic clk;
logic rst;

logic        CARRYIN;
logic [7:0] A;
logic [7:0] B;
logic [15:0] C;
logic [7:0] D;
wire  [15:0] P;

dsp_macro_0 MAC0 (
    .CLK(clk),
    .CARRYIN(CARRYIN),
    .A (A),
    .B (B),
    .C (C),
//    .D (D),
    .P (P)   
);

initial begin
    clk <= 1'b0;
    forever #10 clk <= ~clk;
end

initial begin
    rst <= 1'b1;
    #100;
    @(posedge clk);
    rst <= 1'b0;
    #10000;
    $stop;
end

always_ff @ (posedge clk, posedge rst) begin
    if(rst) begin
        A <= '0;
        B <= '0;
        C <= '0;
        D <= '0;
        CARRYIN <= '0;
    end
    else begin
        A        <= $urandom_range(8'h0, 8'hFF);
        B        <= $urandom_range(8'h0, 8'hFF);
        C[15:0]  <= $urandom_range(16'h0, 16'hFFFF);
        CARRYIN  <= $urandom_range(1'b0, 1'b1);
        //C[31:0]  <= $urandom_range(32'h0, 32'hFFFF_FFFF);
        //C[47:32] <= $urandom_range(16'h0, 16'hFFFF);
        D        <= $urandom_range(17'h0, 17'h1_FFFF);
    end
end

endmodule
