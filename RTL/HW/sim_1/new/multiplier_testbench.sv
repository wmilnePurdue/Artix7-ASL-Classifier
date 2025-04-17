`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2025 03:31:27 PM
// Design Name: 
// Module Name: multiplier_testbench
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


module multiplier_testbench();

logic               clk;
logic               resetn;
				        
logic [31:0]        A_i;
logic [31:0]        B_i;

logic               enable_i;
logic               up_or_low_i;
logic               sign_i;

wire [31:0]         Product;
wire                ready_o;

multiplier DUT (
    .clk         (clk         ),
    .resetn      (resetn      ),
				  
    .A_i         (A_i         ),
    .B_i         (B_i         ),
    .enable_i    (enable_i    ),
    .up_or_low_i (up_or_low_i ),
    .sign_i      (sign_i      ),
				 
    .Product     (Product     ),
    .ready_o     (ready_o     )
);

initial begin
    clk             <= 1'b0;
    forever #10 clk <= ~clk;
end

initial begin
    enable_i <= 1'b0;
    resetn   <= 1'b1;
    #50;
    resetn <= 1'b0;
    #50;
    @(posedge clk);
    resetn <= 1'b1;
    @(posedge clk);
    getProductLower_Unsigned(117, 23);
    getProductLower_Signed(117, -23);
    getProductLower_Signed(-117, -23);
    getProductLower_Unsigned(65536, 65536);
    @(posedge clk);
    $stop;
end

task getProductLower_Unsigned (input [31:0] A, B);
    begin
        @(posedge clk);
        A_i = A;
        B_i = B;
        up_or_low_i = 1'b0;
        sign_i = 1'b0;
        enable_i = 1'b1;
        @(posedge clk);
        enable_i = 1'b0;
        while(!ready_o) @(posedge clk);
    end
endtask

task getProductLower_Signed (input [31:0] A, B);
    begin
        @(posedge clk);
        A_i = A;
        B_i = B;
        up_or_low_i = 1'b0;
        sign_i = 1'b1;
        enable_i = 1'b1;
        @(posedge clk);
        enable_i = 1'b0;
        while(!ready_o) @(posedge clk);
    end
endtask

endmodule
