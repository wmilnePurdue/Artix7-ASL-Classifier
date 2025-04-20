`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2023 13:35:15
// Design Name: 
// Module Name: dnn_layer
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
`include "npu_defines.vh"

module npu_layer(
      clk, rst, start_p, last_p, mac_en, weight_in, 
	  act_in, mac_overflow, npu_layer_in_progress, 
	  hw_mem_wr, hw_mem_wr_addr, hw_mem_wr_data, 
	  hw_mem_wr_ack_p, bias_rd_addr, bias_rd_data, 
	  act_overflow, fc2_layer_output_data, 
	  fc2_layer_output_valid_p
    );

input clk;
input rst; 

input start_p;
input last_p;
input [31:0] mac_en;
input [32*8-1:0] weight_in;
input [7:0] act_in;
output [31:0] mac_overflow;

input [2:0] npu_layer_in_progress;

output [31:0] hw_mem_wr; // latched till ack_p is set
output reg [(32*`LOG2_ACT_ADDR_WIDTH)-1:0] hw_mem_wr_addr; 
output reg [32*8-1:0] hw_mem_wr_data; 
input  [31:0] hw_mem_wr_ack_p; 

output reg [32*3-1:0] bias_rd_addr;
input  [32*8-1:0] bias_rd_data;
output [31:0] act_overflow;

output reg [24*8-1:0] fc2_layer_output_data;
output fc2_layer_output_valid_p;

integer j;
reg [7:0] bias_rd_data_arr [31:0];
wire [2:0] bias_rd_addr_arr [31:0];
reg [7:0] weight_in_arr [31:0];
wire [7:0] hw_mem_wr_data_arr [31:0];
wire [`LOG2_ACT_ADDR_WIDTH-1:0] hw_mem_wr_addr_arr [31:0];
wire [7:0] fc2_layer_output_data_arr[31:0];

reg [4:0] ch_num_arr [31:0]; 
/*
= '{5'd0,5'd1,5'd2,5'd3,5'd4,5'd5,5'd6,
                                5'd7,5'd8,5'd9,5'd10,5'd11,5'd12,5'd13,
                                5'd14,5'd15,5'd16,5'd17,5'd18,5'd19,5'd20,
                                5'd21,5'd22,5'd23,5'd24,5'd25,5'd26,5'd27,
                                5'd28,5'd29,5'd30,5'd31};                             
*/

wire [31:0] fc2_layer_output_valid_p_int;
wire fc2_layer_output_valid_p = |(fc2_layer_output_valid_p_int);

always @ (*)
begin
    for (j=0; j<32; j=j+1) begin
        bias_rd_addr[3*j +: 3] = bias_rd_addr_arr[j];
        hw_mem_wr_addr[(`LOG2_ACT_ADDR_WIDTH*j) +: `LOG2_ACT_ADDR_WIDTH] = hw_mem_wr_addr_arr[j];
        hw_mem_wr_data[8*j +: 8] = hw_mem_wr_data_arr[j];

        bias_rd_data_arr[j] = bias_rd_data[8*j +: 8];
        weight_in_arr[j]    = weight_in[8*j +: 8];
        ch_num_arr[j]       = j;
    end
    for (j=0; j<24; j=j+1) begin
        fc2_layer_output_data[8*j +: 8] = fc2_layer_output_data_arr[j];
    end
end

genvar i;
generate
for (i=0; i<32;i=i+1) begin : neuron_instantiation
    npu_neuron #(.DATA_WIDTH (8), .NUM_FRAC_BITS(5))
    u_neuron (
        .clk                  (clk), 
	.rst                  (rst),  
        .mac_en               (mac_en[i]),
        .start_p              (start_p),
        .last_p               (last_p),
        .weight_in            (weight_in_arr[i]),
        .act_in               (act_in), 
        .mac_overflow         (mac_overflow[i]), 
        .npu_layer_in_progress   (npu_layer_in_progress),
        .ch_num                  (ch_num_arr[i]),
        .hw_mem_wr               (hw_mem_wr[i]),
        .hw_mem_wr_addr          (hw_mem_wr_addr_arr[i]),
        .hw_mem_wr_data          (hw_mem_wr_data_arr[i]),
        .hw_mem_wr_ack_p         (hw_mem_wr_ack_p[i]),
        .bias_rd_addr            (bias_rd_addr_arr[i]),
        .bias_rd_data            (bias_rd_data_arr[i]),
        .act_overflow            (act_overflow[i]),
        .fc2_layer_output_data   (fc2_layer_output_data_arr[i]),
        .fc2_layer_output_valid_p (fc2_layer_output_valid_p_int[i])
    );
end
endgenerate
    
endmodule
