`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2025 10:34:26 AM
// Design Name: 
// Module Name: divider_testbench
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


module divider_testbench();


logic               clk;
logic               resetn;
				        
logic [31:0]        A_i;
logic [31:0]        B_i;

logic               enable_i;
logic               div_or_rem_sel_i;
logic               sign_i;

wire [31:0]         QR;
wire                ready_o;

divider DUT (
    .clk               (clk              ),
    .resetn            (resetn           ),

    .A_i               (A_i              ),
    .B_i               (B_i              ),
    .enable_i          (enable_i         ),
    .div_or_rem_sel_i  (div_or_rem_sel_i ),
    .sign_i            (sign_i           ),

    .QR                (QR               ),
    .ready_o           (ready_o          )
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
    getQuotient_Unsigned(32'd729, 32'd7);
    getRemainder_Unsigned(32'd729, 32'd7);
    getQuotient_Signed(-729, 32'd7);
    getRemainder_Signed(-729, 32'd7);
    getQuotient_Signed(-729, -7);
    getRemainder_Signed(-729, -7);
    getQuotient_Signed(729, -7);
    getRemainder_Signed(729, -7);
    @(posedge clk);
    $stop;
end

task getQuotient_Unsigned (input [31:0] A, B);
    begin
        @(posedge clk);
        A_i = A;
        B_i = B;
        div_or_rem_sel_i = 1'b0;
        sign_i = 1'b0;
        enable_i = 1'b1;
        @(posedge clk);
        enable_i = 1'b0;
        while(!ready_o) @(posedge clk);
    end
endtask

task getRemainder_Unsigned (input [31:0] A, B);
    begin
        @(posedge clk);
        A_i = A;
        B_i = B;
        div_or_rem_sel_i = 1'b1;
        sign_i = 1'b0;
        enable_i = 1'b1;
        @(posedge clk);
        enable_i = 1'b0;
        while(!ready_o) @(posedge clk);
    end
endtask

task getQuotient_Signed (input [31:0] A, B);
    begin
        @(posedge clk);
        A_i = A;
        B_i = B;
        div_or_rem_sel_i = 1'b0;
        sign_i = 1'b1;
        enable_i = 1'b1;
        @(posedge clk);
        enable_i = 1'b0;
        while(!ready_o) @(posedge clk);
    end
endtask

task getRemainder_Signed (input [31:0] A, B);
    begin
        @(posedge clk);
        A_i = A;
        B_i = B;
        div_or_rem_sel_i = 1'b1;
        sign_i = 1'b1;
        enable_i = 1'b1;
        @(posedge clk);
        enable_i = 1'b0;
        while(!ready_o) @(posedge clk);
    end
endtask


endmodule
