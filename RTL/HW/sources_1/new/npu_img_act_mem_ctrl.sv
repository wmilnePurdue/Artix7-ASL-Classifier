`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2025 09:18:06 PM
// Design Name: 
// Module Name: npu_ahb_decoder
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

module npu_img_act_mem_ctrl(
    input                  clk,
    input                  resetn,

    input wire             hw_rgb_mem_rd,
    input wire             hw_act_mem_rd,
    input wire      	   hw_act_mem_rd_bypass,
    input wire [7:0]       npu_rgb_rddata,
    input wire [`NPU_ACT_DATA_WIDTH-1:0]       npu_act_mem_rd_data,
    output reg [`NPU_ACT_DATA_WIDTH-1:0]       npu_muxed_rgb_act_mem_rd_data,

    output reg             npu_act_mem_wr_en,
    output reg [`LOG2_ACT_ADDR_WIDTH-1:0] npu_act_mem_wr_addr,
    output reg [`NPU_ACT_DATA_WIDTH-1:0]       npu_act_mem_wr_data,

    input  wire [31:0]     hw_mem_wr, // latched till ack_p is set
    input  wire [32*`LOG2_ACT_ADDR_WIDTH-1:0] hw_mem_wr_addr, 
    input  wire [32*`NPU_ACT_DATA_WIDTH-1:0] hw_mem_wr_data, 
    output wire [31:0]     hw_mem_wr_ack_p,
    
    input  wire            test_mode_i,
    input  wire [15:0]     test_img_rdata

);

integer j;
reg [`NPU_ACT_DATA_WIDTH-1:0] hw_mem_wr_data_arr [31:0];
reg [`LOG2_ACT_ADDR_WIDTH-1:0] hw_mem_wr_addr_arr [31:0];

always @ (*)
begin
    for (j=0; j<32; j=j+1) begin
        hw_mem_wr_addr_arr[j] = hw_mem_wr_addr[(`LOG2_ACT_ADDR_WIDTH*j) +: `LOG2_ACT_ADDR_WIDTH];
        hw_mem_wr_data_arr[j] = hw_mem_wr_data[`NPU_ACT_DATA_WIDTH*j +: `NPU_ACT_DATA_WIDTH];
    end
end

reg [4:0] wr_service_cnt_r;
reg   hw_rgb_mem_rd_r1;
reg   hw_act_mem_rd_r1;
reg   hw_act_mem_rd_bypass_r1;

wire [31:0]  wr_req_vec_c = hw_mem_wr;

wire atleast_one_wr_set_c = |wr_req_vec_c;
wire hw_mem_wr_ack_p_0  = (wr_service_cnt_r == 5'd0) & hw_mem_wr[0];
wire hw_mem_wr_ack_p_1  = (wr_service_cnt_r == 5'd1) & hw_mem_wr[1];
wire hw_mem_wr_ack_p_2  = (wr_service_cnt_r == 5'd2) & hw_mem_wr[2];
wire hw_mem_wr_ack_p_3  = (wr_service_cnt_r == 5'd3) & hw_mem_wr[3];
wire hw_mem_wr_ack_p_4  = (wr_service_cnt_r == 5'd4) & hw_mem_wr[4];
wire hw_mem_wr_ack_p_5  = (wr_service_cnt_r == 5'd5) & hw_mem_wr[5];
wire hw_mem_wr_ack_p_6  = (wr_service_cnt_r == 5'd6) & hw_mem_wr[6];
wire hw_mem_wr_ack_p_7  = (wr_service_cnt_r == 5'd7) & hw_mem_wr[7];
wire hw_mem_wr_ack_p_8  = (wr_service_cnt_r == 5'd8) & hw_mem_wr[8];
wire hw_mem_wr_ack_p_9  = (wr_service_cnt_r == 5'd9) & hw_mem_wr[9];
wire hw_mem_wr_ack_p_10  = (wr_service_cnt_r == 5'd10) & hw_mem_wr[10];
wire hw_mem_wr_ack_p_11  = (wr_service_cnt_r == 5'd11) & hw_mem_wr[11];
wire hw_mem_wr_ack_p_12  = (wr_service_cnt_r == 5'd12) & hw_mem_wr[12];
wire hw_mem_wr_ack_p_13  = (wr_service_cnt_r == 5'd13) & hw_mem_wr[13];
wire hw_mem_wr_ack_p_14  = (wr_service_cnt_r == 5'd14) & hw_mem_wr[14];
wire hw_mem_wr_ack_p_15  = (wr_service_cnt_r == 5'd15) & hw_mem_wr[15];
wire hw_mem_wr_ack_p_16  = (wr_service_cnt_r == 5'd16) & hw_mem_wr[16];
wire hw_mem_wr_ack_p_17  = (wr_service_cnt_r == 5'd17) & hw_mem_wr[17];
wire hw_mem_wr_ack_p_18  = (wr_service_cnt_r == 5'd18) & hw_mem_wr[18];
wire hw_mem_wr_ack_p_19  = (wr_service_cnt_r == 5'd19) & hw_mem_wr[19];
wire hw_mem_wr_ack_p_20  = (wr_service_cnt_r == 5'd20) & hw_mem_wr[20];
wire hw_mem_wr_ack_p_21  = (wr_service_cnt_r == 5'd21) & hw_mem_wr[21];
wire hw_mem_wr_ack_p_22  = (wr_service_cnt_r == 5'd22) & hw_mem_wr[22];
wire hw_mem_wr_ack_p_23  = (wr_service_cnt_r == 5'd23) & hw_mem_wr[23];
wire hw_mem_wr_ack_p_24  = (wr_service_cnt_r == 5'd24) & hw_mem_wr[24];
wire hw_mem_wr_ack_p_25  = (wr_service_cnt_r == 5'd25) & hw_mem_wr[25];
wire hw_mem_wr_ack_p_26  = (wr_service_cnt_r == 5'd26) & hw_mem_wr[26];
wire hw_mem_wr_ack_p_27  = (wr_service_cnt_r == 5'd27) & hw_mem_wr[27];
wire hw_mem_wr_ack_p_28  = (wr_service_cnt_r == 5'd28) & hw_mem_wr[28];
wire hw_mem_wr_ack_p_29  = (wr_service_cnt_r == 5'd29) & hw_mem_wr[29];
wire hw_mem_wr_ack_p_30  = (wr_service_cnt_r == 5'd30) & hw_mem_wr[30];
wire hw_mem_wr_ack_p_31  = (wr_service_cnt_r == 5'd31) & hw_mem_wr[31];

assign hw_mem_wr_ack_p = {hw_mem_wr_ack_p_31,hw_mem_wr_ack_p_30,hw_mem_wr_ack_p_29,hw_mem_wr_ack_p_28,
	hw_mem_wr_ack_p_27,hw_mem_wr_ack_p_26,hw_mem_wr_ack_p_25,hw_mem_wr_ack_p_24,hw_mem_wr_ack_p_23,
	hw_mem_wr_ack_p_22,hw_mem_wr_ack_p_21,hw_mem_wr_ack_p_20,hw_mem_wr_ack_p_19,hw_mem_wr_ack_p_18,
	hw_mem_wr_ack_p_17,hw_mem_wr_ack_p_16,hw_mem_wr_ack_p_15,hw_mem_wr_ack_p_14,hw_mem_wr_ack_p_13,
	hw_mem_wr_ack_p_12,hw_mem_wr_ack_p_11,hw_mem_wr_ack_p_10,hw_mem_wr_ack_p_9,hw_mem_wr_ack_p_8,
	hw_mem_wr_ack_p_7,hw_mem_wr_ack_p_6,hw_mem_wr_ack_p_5,hw_mem_wr_ack_p_4,hw_mem_wr_ack_p_3,
	hw_mem_wr_ack_p_2,hw_mem_wr_ack_p_1,hw_mem_wr_ack_p_0};

always @ (posedge clk or negedge resetn)
begin
    if (~resetn) begin
        wr_service_cnt_r        <= 5'd0;	    
        npu_act_mem_wr_en       <= 1'b0;
        npu_act_mem_wr_addr     <= {`LOG2_ACT_ADDR_WIDTH{1'b0}};
        npu_act_mem_wr_data     <= {`NPU_ACT_DATA_WIDTH{1'b0}};
	hw_rgb_mem_rd_r1        <= 1'b0;
	hw_act_mem_rd_r1        <= 1'b0;
        hw_act_mem_rd_bypass_r1 <= 1'b0;
	npu_muxed_rgb_act_mem_rd_data <= {`NPU_ACT_DATA_WIDTH{1'b0}};
    end else begin
	hw_rgb_mem_rd_r1        <= hw_rgb_mem_rd;
	hw_act_mem_rd_r1        <= hw_act_mem_rd;
        hw_act_mem_rd_bypass_r1 <= hw_act_mem_rd_bypass;
	// Bypass is set for Pad in Conv layer
	npu_muxed_rgb_act_mem_rd_data <= (hw_act_mem_rd_bypass_r1) ? {`NPU_ACT_DATA_WIDTH{1'b0}} : 
				         (hw_rgb_mem_rd_r1) ? (test_mode_i ? test_img_rdata : {3'd0,npu_rgb_rddata,5'd0})
				          : npu_act_mem_rd_data;
	
	if (atleast_one_wr_set_c) begin
	    wr_service_cnt_r <= wr_service_cnt_r + 5'd1;
        end else begin
	    wr_service_cnt_r <= 5'd0;
        end    

        npu_act_mem_wr_en       <= atleast_one_wr_set_c;
	if (atleast_one_wr_set_c) begin
            case(wr_service_cnt_r) 
            5'd0: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[0];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[0];
                end
            5'd1: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[1];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[1];
                end
            5'd2: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[2];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[2];
                end
            5'd3: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[3];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[3];
                end
            5'd4: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[4];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[4];
                end
            5'd5: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[5];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[5];
                end
            5'd6: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[6];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[6];
                end
            5'd7: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[7];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[7];
                end
            5'd8: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[8];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[8];
                end
            5'd9: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[9];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[9];
                end
            5'd10: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[10];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[10];
                end
            5'd11: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[11];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[11];
                end
            5'd12: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[12];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[12];
                end
            5'd13: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[13];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[13];
                end
            5'd14: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[14];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[14];
                end
            5'd15: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[15];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[15];
                end
            5'd16: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[16];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[16];
                end
            5'd17: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[17];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[17];
                end
            5'd18: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[18];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[18];
                end
            5'd19: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[19];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[19];
                end
            5'd20: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[20];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[20];
                end
            5'd21: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[21];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[21];
                end
            5'd22: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[22];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[22];
                end
            5'd23: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[23];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[23];
                end
            5'd24: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[24];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[24];
                end
            5'd25: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[25];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[25];
                end
            5'd26: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[26];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[26];
                end
            5'd27: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[27];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[27];
                end
            5'd28: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[28];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[28];
                end
            5'd29: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[29];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[29];
                end
            5'd30: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[30];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[30];
                end
            5'd31: begin
                npu_act_mem_wr_addr    <= hw_mem_wr_addr_arr[31];
                npu_act_mem_wr_data <= hw_mem_wr_data_arr[31];
                end
            default: begin
                npu_act_mem_wr_addr    <= {`LOG2_ACT_ADDR_WIDTH{1'b0}};
                npu_act_mem_wr_data <= {`NPU_ACT_DATA_WIDTH{1'b0}};
                end
	    endcase
        end
    end
end    

endmodule
