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

module npu_mac(
    clk, rst, mac_en, start_p, last_p, weight_in, act_in, mac_out, mac_valid, mac_overflow,
    bias_rd_addr, npu_layer_in_progress, bias_rd_data 
    );

parameter DATA_WIDTH = 8;
parameter NUM_FRAC_BITS = 5;

input clk;
input rst; 

input start_p;
input last_p;
input mac_en;
input signed [DATA_WIDTH-1:0] weight_in;
input signed [DATA_WIDTH-1:0] act_in;
input [2:0] npu_layer_in_progress;

output mac_valid;
output signed [DATA_WIDTH-1:0] mac_out;
output reg mac_overflow;

output reg [2:0] bias_rd_addr;
input signed [DATA_WIDTH-1:0] bias_rd_data;

reg start_r1;
reg last_r1;
reg last_r2;
reg mac_valid;
reg signed [DATA_WIDTH-1:0] mac_out;

reg signed [2*DATA_WIDTH-1:0] mult_r;
reg signed [2*DATA_WIDTH-1:0] partial_sum_r;
reg [2:0] npu_layer_in_progress_r1;

wire signed [2*DATA_WIDTH-1:0] mux_sum_in0_c = (start_r1) ? {(2*DATA_WIDTH){1'b0}} : partial_sum_r;
wire signed [2*DATA_WIDTH-1:0] partial_sum_c = (mult_r + mux_sum_in0_c ); 
// quantize partial sum and generate final output
wire [2*DATA_WIDTH-1:0] final_sum_c = (partial_sum_r >>> NUM_FRAC_BITS) + bias_rd_data;

always @ (posedge clk, negedge rst)
begin
    if (~rst) begin
        mult_r        <= {2*DATA_WIDTH{1'b0}}; 
        partial_sum_r <= {(2*DATA_WIDTH+1){1'b0}};
        start_r1      <= 1'b0;
        last_r1       <= 1'b0;
        last_r2       <= 1'b0;
        mac_valid     <= 1'b0;
     	mac_overflow  <= 1'b0;
     	npu_layer_in_progress_r1 <= 3'h0;
     	bias_rd_addr     <= 3'd0;
     	mac_out       <= {DATA_WIDTH{1'b0}}; 
    end else begin
        mac_out       <= final_sum_c[DATA_WIDTH-1];
        // delayed control signals for pipeline
        start_r1      <= start_p & mac_en;
        last_r1       <= last_p & mac_en;
        last_r2       <= last_r1;
        mac_valid     <= last_r2;
        // multiply weight and act
        mult_r        <= weight_in * act_in;
        // accumulator; upon start pulse it loads mult value; else it accumulates
		// take care of mac_overflow.. saturate sum in case it overflows
     	if (mult_r[2*DATA_WIDTH-1] & mux_sum_in0_c[2*DATA_WIDTH-1] & ~partial_sum_c[2*DATA_WIDTH-1]) begin
            partial_sum_r[2*DATA_WIDTH-1]   <= 1'b1;
            partial_sum_r[2*DATA_WIDTH-2:0] <= {2*DATA_WIDTH-1{1'b0}};
	        mac_overflow                        <= 1'b1;
	    end else if (~mult_r[2*DATA_WIDTH-1] & ~mux_sum_in0_c[2*DATA_WIDTH-1] & partial_sum_c[2*DATA_WIDTH-1]) begin
            partial_sum_r[2*DATA_WIDTH-1]   <= 1'b0;
            partial_sum_r[2*DATA_WIDTH-2:0] <= {2*DATA_WIDTH-1{1'b1}};
            mac_overflow                    <= 1'b1;
	    end else begin
	        partial_sum_r 				    <= partial_sum_c;
	        mac_overflow                    <= 1'b0;
	    end 
	    
	   npu_layer_in_progress_r1 <= npu_layer_in_progress;
	   // Increment Bias read address when layer changes from Conv1 onwards
       if (npu_layer_in_progress == 3'd0) begin
	       bias_rd_addr  <= 3'd0;     
       end else if ((npu_layer_in_progress != npu_layer_in_progress_r1) & (|npu_layer_in_progress_r1)) begin
           bias_rd_addr  <= bias_rd_addr + 3'd1; 
       end	
    end
end

endmodule
