`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2025 09:47:15 PM
// Design Name: 
// Module Name: cpu_regfile
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


module cpu_regfile(
    input               clk,

    input         [3:0] wr_addr_i,
    input         [3:0] byte_en_i,
    input        [31:0] wr_data_i,
		 	      	    
    input         [3:0] rd0_addr_i,
    input         [3:0] rd1_addr_i,

    output logic [31:0] rd0_data_o,
    output logic [31:0] rd1_data_o
);

bit [7:0] mem0 [15:0];
bit [7:0] mem1 [15:0];
bit [7:0] mem2 [15:0];
bit [7:0] mem3 [15:0];

// synthesis translate_off
wire [31:0] mem_full [15:0];
for(genvar i0 = 0; i0 < 16; i0++) begin
    assign mem_full[i0] = {mem3[i0], mem2[i0], mem1[i0], mem0[i0]};
end
// synthesis translate_on

always_ff @ (posedge clk) begin
    if(byte_en_i[0]) begin
        mem0[wr_addr_i] <= wr_data_i[7:0];
    end
end
always_ff @ (posedge clk) begin
    if(byte_en_i[1]) begin
        mem1[wr_addr_i] <= wr_data_i[15:8];
    end
end
always_ff @ (posedge clk) begin
    if(byte_en_i[2]) begin
        mem2[wr_addr_i] <= wr_data_i[23:16];
    end
end
always_ff @ (posedge clk) begin
    if(byte_en_i[3]) begin
        mem3[wr_addr_i] <= wr_data_i[31:24];
    end
end

assign rd0_data_o = {mem3[rd0_addr_i], mem2[rd0_addr_i], mem1[rd0_addr_i], mem0[rd0_addr_i]};
assign rd1_data_o = {mem3[rd1_addr_i], mem2[rd1_addr_i], mem1[rd1_addr_i], mem0[rd1_addr_i]};

endmodule
