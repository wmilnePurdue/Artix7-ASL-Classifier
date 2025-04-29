`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.08.2023 09:57:01
// Design Name: 
// Module Name: neuron
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

module npu_neuron(
    clk, rst, mac_en, start_p, last_p, weight_in, act_in, 
	mac_overflow, npu_layer_in_progress, 
	ch_num, hw_mem_wr, hw_mem_wr_addr, hw_mem_wr_data, 
	hw_mem_wr_ack_p, bias_rd_addr, bias_rd_data, act_overflow,
	fc2_layer_output_data, fc2_layer_output_valid_p
    );

parameter DATA_WIDTH  = 8;
parameter NUM_FRAC_BITS = 5;

input clk;
input rst; 

input mac_en;
input start_p;
input last_p;
input signed [DATA_WIDTH-1:0] weight_in;
input signed [DATA_WIDTH-1:0] act_in;
output mac_overflow;

input [2:0] npu_layer_in_progress;
input [4:0] ch_num;

output hw_mem_wr; // latched till ack_p is set
output [`LOG2_ACT_ADDR_WIDTH-1:0] hw_mem_wr_addr; 
output [DATA_WIDTH-1:0] hw_mem_wr_data; 
input  hw_mem_wr_ack_p; 

output [2:0] bias_rd_addr;
input signed [DATA_WIDTH-1:0] bias_rd_data;
output act_overflow;

output wire [DATA_WIDTH-1:0] fc2_layer_output_data;
output wire fc2_layer_output_valid_p;


// Adding wire connections
wire [DATA_WIDTH-1:0] mac_out;


npu_mac #(.DATA_WIDTH (DATA_WIDTH), .NUM_FRAC_BITS(NUM_FRAC_BITS))
u_npu_mac(
   .clk                      (clk), 
   .rst                      (rst), 
   .mac_en                   (mac_en),
   .start_p                  (start_p), 
   .last_p                   (last_p), 
   .weight_in                (weight_in), 
   .act_in                   (act_in), 
   .mac_out                  (mac_out), 
   .mac_valid                (mac_valid), 
   .mac_overflow             (mac_overflow),
   .npu_layer_in_progress    (npu_layer_in_progress),
   .bias_rd_addr	     (bias_rd_addr), 
   .bias_rd_data	     (bias_rd_data)
);

npu_maxpool_relu #(.DATA_WIDTH (DATA_WIDTH), .NUM_FRAC_BITS(NUM_FRAC_BITS))
u_npu_maxpool_relu(
   .clk			     (clk), 
   .rst			     (rst), 
   .mac_valid		     (mac_valid), 
   .mac_out		     (mac_out), 
   .npu_layer_in_progress    (npu_layer_in_progress), 
   .hw_mem_wr		     (hw_mem_wr), 
   .hw_mem_wr_addr	     (hw_mem_wr_addr), 
   .hw_mem_wr_data	     (hw_mem_wr_data), 
   .hw_mem_wr_ack_p	     (hw_mem_wr_ack_p),
   .ch_num		     (ch_num), 
   .bias_rd_addr	     (), 
   .bias_rd_data	     ({DATA_WIDTH{1'b0}}), 
   .act_overflow             (act_overflow),
   .fc2_layer_output_data    (fc2_layer_output_data),
   .fc2_layer_output_valid_p (fc2_layer_output_valid_p)
    );

endmodule
