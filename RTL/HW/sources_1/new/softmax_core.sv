`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2025 10:06:27 PM
// Design Name: 
// Module Name: softmax_core
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


module softmax_core #  (
    parameter NUM_INPUT = 4,
    parameter DATA_WIDTH = 16
)(
    input              clk,
    input              resetn,
		         
    input        [4:0] index_0, 
    input        [DATA_WIDTH-1:0] data_0,
		         
    input        [4:0] index_1, 
    input        [DATA_WIDTH-1:0] data_1,
		         
    input        [4:0] index_2, 
    input        [DATA_WIDTH-1:0] data_2,
		         
    input        [4:0] index_3, 
    input        [DATA_WIDTH-1:0] data_3,

    output logic [4:0] index_o,
    output logic [DATA_WIDTH-1:0] data_o
);

wire [4:0] first_stage_idx;
wire [DATA_WIDTH-1:0] first_stage_data;

wire [4:0] second_stage_idx;
wire [DATA_WIDTH-1:0] second_stage_data;

if(NUM_INPUT >= 2) begin
    wire [DATA_WIDTH-1:0] data_0_expand  = {~data_0[DATA_WIDTH-1], data_0[DATA_WIDTH-2:0]};
    wire [DATA_WIDTH-1:0] data_1_expand  = {~data_1[DATA_WIDTH-1], data_1[DATA_WIDTH-2:0]};

    assign first_stage_idx    = (data_1_expand > data_0_expand) ? index_1 : index_0;
    assign first_stage_data   = (data_1_expand > data_0_expand) ? data_1  : data_0;
end

if(NUM_INPUT == 3) begin
    wire [DATA_WIDTH-1:0] first_stage_data_expand = {~first_stage_data[DATA_WIDTH-1], first_stage_data[DATA_WIDTH-2:0]};
    wire [DATA_WIDTH-1:0] data_2_expand           = {~data_2[DATA_WIDTH-1], data_2[DATA_WIDTH-2:0]}; 

    assign second_stage_idx            = (first_stage_data_expand > data_2_expand) ? first_stage_idx  : index_2;
    assign second_stage_data           = (first_stage_data_expand > data_2_expand) ? first_stage_data : data_2;
end
else begin
    wire [DATA_WIDTH-1:0] data_2_expand           = {~data_2[DATA_WIDTH-1], data_2[DATA_WIDTH-2:0]}; 
    wire [DATA_WIDTH-1:0] data_3_expand           = {~data_3[DATA_WIDTH-1], data_3[DATA_WIDTH-2:0]}; 
    wire [DATA_WIDTH-1:0] first_stage_data_expand = {~first_stage_data[DATA_WIDTH-1], first_stage_data[DATA_WIDTH-2:0]};

    wire [4:0] interim_idx             = (data_3_expand > data_2_expand) ? index_3  : index_2;
    wire [DATA_WIDTH-1:0] interim_data            = (data_3_expand > data_2_expand) ? data_3   : data_2;

    wire [DATA_WIDTH-1:0] interim_data_expand     =  {~interim_data[DATA_WIDTH-1], interim_data[DATA_WIDTH-2:0]}; 

    assign second_stage_idx  = (interim_data_expand > first_stage_data_expand) ? interim_idx  : first_stage_idx;
    assign second_stage_data = (interim_data_expand > first_stage_data_expand) ? interim_data : first_stage_data;
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        index_o <= 5'h0;
        data_o  <= {DATA_WIDTH{1'b0}};
    end
    else begin
        if (NUM_INPUT == 1) begin
            index_o <= index_0;
            data_o  <= data_0;
        end
        else if (NUM_INPUT == 2) begin
            index_o <= first_stage_idx;
            data_o  <= first_stage_data;
        end
        else begin
            index_o <= second_stage_idx;
            data_o  <= second_stage_data;
        end
    end
end


endmodule
