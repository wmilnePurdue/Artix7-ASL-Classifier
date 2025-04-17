`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2025 10:43:44 PM
// Design Name: 
// Module Name: softmax
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


module softmax(
    input        clk,
    input        resetn,
			    
    input [7:0]  data_in [28:0],
    input        valid_i,

    output [7:0] data_out,
    output [4:0] idx_out,
    output logic valid_o    
);

wire [7:0] data_stage_0 [7:0];
wire [4:0] idx_stage_0  [7:0];

wire [7:0] data_stage_1 [1:0];
wire [7:0] idx_stage_1  [1:0];

logic [1:0] valid_temp;

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin 
        valid_o       <= 1'b0;
        valid_temp    <= 2'b00;
    end
    else begin
        valid_temp[0] <= valid_i;
        valid_temp[1] <= valid_temp[0];
        valid_o       <= valid_temp[1];
    end
end

for(genvar i0 = 0; i0 < 29; i0 = i0 + 4) begin : STAGE_1
    localparam IDX_0     = i0;
    localparam IDX_1     = i0 + 1;
    localparam IDX_2     = i0 + 2;
    localparam IDX_3     = i0 + 3;

    localparam IDX_1_CHK = (IDX_1 < 29) ? 1 : 0;
    localparam IDX_2_CHK = (IDX_2 < 29) ? 1 : 0;
    localparam IDX_3_CHK = (IDX_3 < 29) ? 1 : 0;

    localparam NUM_INPUT   = 1 + IDX_1_CHK + IDX_2_CHK + IDX_3_CHK;
    localparam OUT_IDX     = i0 / 4;

    wire [4:0] index_0 = IDX_0;
    wire [4:0] index_1 = IDX_1;
    wire [4:0] index_2 = IDX_2;
    wire [4:0] index_3 = IDX_3;

    wire [7:0] data_0;
    wire [7:0] data_1;
    wire [7:0] data_2;
    wire [7:0] data_3;

    assign data_0 = data_in[IDX_0];
    if(IDX_1_CHK) begin
        assign data_1 = data_in[IDX_1];
    end
    else begin
        assign data_1 = 8'hFF;
    end

    if(IDX_2_CHK) begin
        assign data_2 = data_in[IDX_2];
    end
    else begin
        assign data_2 = 8'hFF;
    end

    if(IDX_3_CHK) begin
        assign data_3 = data_in[IDX_3];
    end
    else begin
        assign data_3 = 8'hFF;
    end

    softmax_core # (
        .NUM_INPUT (NUM_INPUT)
    ) CORE_N (
        .clk     (clk                    ),
        .resetn  (resetn                 ),
						                 
		.index_0 (index_0                ),
		.data_0  (data_0                 ),
						                 
		.index_1 (index_1                ),
		.data_1  (data_1                 ),
						                 
		.index_2 (index_2                ),
		.data_2  (data_2                 ),
						                 
		.index_3 (index_3                ),
		.data_3  (data_3                 ),

        .index_o (idx_stage_0  [OUT_IDX] ),
        .data_o  (data_stage_0 [OUT_IDX] )
    );
end

softmax_core # (
   .NUM_INPUT (4)
) STAGE_2_CORE_0 (
    .clk     (clk              ),
    .resetn  (resetn           ),
					                 
	.index_0 (idx_stage_0  [0] ),
	.data_0  (data_stage_0 [0] ),

	.index_1 (idx_stage_0  [1] ),
	.data_1  (data_stage_0 [1] ),
					                 
	.index_2 (idx_stage_0  [2] ),
	.data_2  (data_stage_0 [2] ),
					                 
	.index_3 (idx_stage_0  [3] ),
	.data_3  (data_stage_0 [3] ),

    .index_o (idx_stage_1  [0] ),
    .data_o  (data_stage_1 [0] )
);

softmax_core # (
   .NUM_INPUT (4)
) STAGE_2_CORE_1 (
    .clk     (clk              ),
    .resetn  (resetn           ),
					                 
	.index_0 (idx_stage_0  [4] ),
	.data_0  (data_stage_0 [4] ),

	.index_1 (idx_stage_0  [5] ),
	.data_1  (data_stage_0 [5] ),
					                 
	.index_2 (idx_stage_0  [6] ),
	.data_2  (data_stage_0 [6] ),
					                 
	.index_3 (idx_stage_0  [7] ),
	.data_3  (data_stage_0 [7] ),

    .index_o (idx_stage_1  [1] ),
    .data_o  (data_stage_1 [1] )
);

softmax_core # (
    .NUM_INPUT (2)
) FINAL_STAGE (
    .clk     (clk              ),
    .resetn  (resetn           ),
					                 
	.index_0 (idx_stage_1  [0] ),
	.data_0  (data_stage_1 [0] ),

	.index_1 (idx_stage_1  [1] ),
	.data_1  (data_stage_1 [1] ),
					                 
	.index_2 (5'h0             ),
	.data_2  (8'hFF            ),
					                             
	.index_3 (5'h0             ),
	.data_3  (8'hFF            ),
					           
    .index_o (idx_out          ),
    .data_o  (data_out         )
);

endmodule
