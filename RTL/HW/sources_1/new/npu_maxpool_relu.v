`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.08.2023 17:57:13
// Design Name: 
// Module Name: mac
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

module npu_maxpool_relu(
    clk, rst, mac_valid, mac_out, npu_layer_in_progress, 
    hw_mem_wr, hw_mem_wr_addr, hw_mem_wr_data, hw_mem_wr_ack_p,
    ch_num, bias_rd_addr, bias_rd_data, act_overflow,
	fc2_layer_output_data, fc2_layer_output_valid_p
    );

parameter DATA_WIDTH = 8;
parameter NUM_FRAC_BITS = 5;

input clk;
input rst; 

input mac_valid;
input signed [DATA_WIDTH-1:0] mac_out;
input [2:0] npu_layer_in_progress;
input [4:0] ch_num;

output reg hw_mem_wr; // latched till ack_p is set
output reg [`LOG2_ACT_ADDR_WIDTH-1:0] hw_mem_wr_addr; 
output wire [7:0] hw_mem_wr_data; 
input  hw_mem_wr_ack_p; 

output reg [2:0] bias_rd_addr;
input signed [DATA_WIDTH-1:0] bias_rd_data;
output reg act_overflow;

output wire [DATA_WIDTH-1:0] fc2_layer_output_data;
output reg fc2_layer_output_valid_p;

reg signed [DATA_WIDTH-1:0] max_result_r;
reg signed [DATA_WIDTH-1:0] mac_plus_bias_r;
reg [1:0] mod4_cnt;
reg [2:0] npu_layer_in_progress_r1;
reg [7:0] output_pixel_cnt;
reg mac_valid_r1;
reg [11:0] layer_act_mem_start_addr_offset_r;
reg [11:0] prod_num_of_output_pixel_per_ch_r_times_ch_num; // max 256 pixels for conv1 where num_of_ch are 8
reg [12:0] start_addr_offset_per_ch_r;
/// Logic starts here

wire conv_layer_in_progress = (npu_layer_in_progress == `CONV1_LAYER_ENC) | (npu_layer_in_progress == `CONV2_LAYER_ENC) | (npu_layer_in_progress == `CONV3_LAYER_ENC);

assign hw_mem_wr_data        = max_result_r;
assign fc2_layer_output_data = max_result_r;

wire [8:0] num_of_output_pixel_per_ch_c = (conv_layer_in_progress == `CONV1_LAYER_ENC) ? `CONV1_NUM_PIXEL_OUT_PER_CH :
					  (conv_layer_in_progress == `CONV2_LAYER_ENC) ? `CONV2_NUM_PIXEL_OUT_PER_CH :
					  (conv_layer_in_progress == `CONV3_LAYER_ENC) ? `CONV3_NUM_PIXEL_OUT_PER_CH :
					  8'd1;

wire [11:0] layer_act_mem_start_addr_offset_c = 
				          (conv_layer_in_progress == `CONV1_LAYER_ENC) ? `CONV1_OUTPUT_START_ADDR:
					  (conv_layer_in_progress == `CONV2_LAYER_ENC) ? `CONV2_OUTPUT_START_ADDR:
					  (conv_layer_in_progress == `CONV3_LAYER_ENC) ? `CONV3_OUTPUT_START_ADDR:
					  (conv_layer_in_progress == `FC1_1_LAYER_ENC) ? `FC1_1_OUTPUT_START_ADDR:
					  (conv_layer_in_progress == `FC1_2_LAYER_ENC) ? `FC1_2_OUTPUT_START_ADDR:
					  (conv_layer_in_progress == `FC2_LAYER_ENC) ? `FC2_OUTPUT_START_ADDR:
					  12'hF20;

// Add bias to MAC output
wire signed [DATA_WIDTH-1:0] mac_plus_bias_c = mac_out + bias_rd_data;

always @ (posedge clk, negedge rst)
begin
   if (~rst) begin
       max_result_r     <= {DATA_WIDTH{1'b0}};
       mac_plus_bias_r  <= {(DATA_WIDTH+1){1'b0}};
       mod4_cnt         <= 2'd0;
       hw_mem_wr        <= 1'b0;
       hw_mem_wr_addr   <= {`LOG2_ACT_ADDR_WIDTH{1'b0}};
       bias_rd_addr     <= 3'd0;
       output_pixel_cnt <= 8'd0;
       mac_valid_r1     <= 1'b0;
	   act_overflow       <= 1'b0;
       layer_act_mem_start_addr_offset_r   <= 12'd0;
       prod_num_of_output_pixel_per_ch_r_times_ch_num <= 12'd0;
       start_addr_offset_per_ch_r  <= 13'd0;
	   fc2_layer_output_valid_p <= 1'b0;
       npu_layer_in_progress_r1 <= 3'h0;
   end else begin
       npu_layer_in_progress_r1 <= npu_layer_in_progress;
       mac_valid_r1     <= mac_valid;
       layer_act_mem_start_addr_offset_r              <= layer_act_mem_start_addr_offset_c;
       prod_num_of_output_pixel_per_ch_r_times_ch_num <= num_of_output_pixel_per_ch_c * ch_num;
       start_addr_offset_per_ch_r                     <= prod_num_of_output_pixel_per_ch_r_times_ch_num + layer_act_mem_start_addr_offset_r;
       fc2_layer_output_valid_p                       <= (npu_layer_in_progress == `SOFTMAX_LAYER_ENC) & mac_valid_r1;

       // Increment Bias read address when layer changes from Conv1 onwards
       if (npu_layer_in_progress == 3'd0) begin
	       bias_rd_addr  <= 3'd0;     
       end else if ((npu_layer_in_progress != npu_layer_in_progress_r1) & (|npu_layer_in_progress_r1)) begin
           bias_rd_addr  <= bias_rd_addr + 3'd1; 
       end	   
       
       // Add bias to MAC result
	   // In case of overflow, saturate result
	   if (mac_out[DATA_WIDTH-1] & bias_rd_data[DATA_WIDTH-1] & ~mac_plus_bias_c[DATA_WIDTH-1]) begin
       		mac_plus_bias_r[DATA_WIDTH-1]   <= 1'b1;
		    mac_plus_bias_r[DATA_WIDTH-2:0] <= {(DATA_WIDTH-1){1'b0}};	
			act_overflow                      <= mac_valid;
	   end else if (~mac_out[DATA_WIDTH-1] & ~bias_rd_data[DATA_WIDTH-1] & mac_plus_bias_c[DATA_WIDTH-1]) begin
       		mac_plus_bias_r[DATA_WIDTH-1]   <= 1'b0;
		    mac_plus_bias_r[DATA_WIDTH-2:0] <= {(DATA_WIDTH-1){1'b1}};	
			act_overflow                      <= mac_valid;
	   end else begin
			mac_plus_bias_r                 <= mac_plus_bias_c;
			act_overflow                      <= 1'b0;
	   end

       if (npu_layer_in_progress == 3'd0) begin
           mod4_cnt <= 2'd0;
           max_result_r     <= {DATA_WIDTH{1'b0}};
	   end else if (mac_valid_r1) begin
	       // Conv Layer- do max pool func + Relu func. Max Pool - Find max of set of 4 outputs   
           if (conv_layer_in_progress) begin
               mod4_cnt <= mod4_cnt + 2'd1;
	           if (mod4_cnt == 2'd0) begin
	           // load to 1st of 4 MAC results for Max pool; if neg load 0 - Relu 
      	           max_result_r <= mac_plus_bias_r[DATA_WIDTH-1] ? {DATA_WIDTH{1'b0}} : mac_plus_bias_r;
               // next mac output is positive
	           end else if ((~mac_plus_bias_r[DATA_WIDTH-1]) & (max_result_r[DATA_WIDTH-2:0] < mac_plus_bias_r[DATA_WIDTH-2:0])) begin
      	           max_result_r <= mac_plus_bias_r;
	           end
	       // FC2 layer - No max pool function; No Relu
           end else if (npu_layer_in_progress == `FC2_LAYER_ENC) begin
      	       max_result_r <= mac_plus_bias_r;
	       // FC1 layer - No max pool function; Only Relu
           end else begin   
      	       max_result_r <= mac_plus_bias_r[DATA_WIDTH-1] ? {DATA_WIDTH{1'b0}} : mac_plus_bias_r;
		   end
       end

	   // Write req to Act Mem
	   if (hw_mem_wr_ack_p) begin
	       hw_mem_wr        <= 1'b0;
	   end else if ((conv_layer_in_progress & (mod4_cnt == 2'd3) & mac_valid_r1) | (~conv_layer_in_progress & mac_valid_r1)) begin
		   hw_mem_wr        <= 1'b1;
           hw_mem_wr_addr   <= start_addr_offset_per_ch_r + output_pixel_cnt;
	   end
		   
       // Increment Bias read address when layer changes from Conv1 onwards
       if ((npu_layer_in_progress == 3'd0) | ((npu_layer_in_progress != npu_layer_in_progress_r1) & (|npu_layer_in_progress_r1))) begin
	       output_pixel_cnt    <= 8'd0;     
	   end else if ((conv_layer_in_progress & (mod4_cnt == 2'd3) & mac_valid_r1) | (~conv_layer_in_progress & mac_valid_r1)) begin
	       output_pixel_cnt    <= output_pixel_cnt + 8'd1;     
       end	   
   end
end

endmodule
