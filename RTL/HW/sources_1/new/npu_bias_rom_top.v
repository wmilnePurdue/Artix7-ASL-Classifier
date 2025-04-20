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


module npu_bias_rom_top(
      clk, bias_rom_rd_addr, bias_rom_rd_data
    );

input clk;

input [2:0] bias_rom_rd_addr; 
output reg [32*8-1:0] bias_rom_rd_data;

integer j;
wire [7:0] bias_rom_rd_data_arr [31:0];

always @ (*)
begin
    for (j=0; j<32; j=j+1) begin
        bias_rom_rd_data[8*j +: 8] = bias_rom_rd_data_arr[j];
    end
end

bias_rom_0 u_bias_rom_0 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[0])
  );

bias_rom_1 u_bias_rom_1 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[1])
  );

bias_rom_2 u_bias_rom_2 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[2])
  );

bias_rom_3 u_bias_rom_3 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[3])
  );

bias_rom_4 u_bias_rom_4 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[4])
  );

bias_rom_5 u_bias_rom_5 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[5])
  );

bias_rom_6 u_bias_rom_6 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[6])
  );

bias_rom_7 u_bias_rom_7 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[7])
  );

bias_rom_8 u_bias_rom_8 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[8])
  );

bias_rom_9 u_bias_rom_9 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[9])
  );

bias_rom_10 u_bias_rom_10 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[10])
  );

bias_rom_11 u_bias_rom_11 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[11])
  );

bias_rom_12 u_bias_rom_12 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[12])
  );

bias_rom_13 u_bias_rom_13 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[13])
  );

bias_rom_14 u_bias_rom_14 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[14])
  );

bias_rom_15 u_bias_rom_15 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[15])
  );

bias_rom_16 u_bias_rom_16 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[16])
  );

bias_rom_17 u_bias_rom_17 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[17])
  );

bias_rom_18 u_bias_rom_18 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[18])
  );

bias_rom_19 u_bias_rom_19 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[19])
  );

bias_rom_20 u_bias_rom_20 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[20])
  );

bias_rom_21 u_bias_rom_21 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[21])
  );

bias_rom_22 u_bias_rom_22 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[22])
  );

bias_rom_23 u_bias_rom_23 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[23])
  );

bias_rom_24 u_bias_rom_24 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[24])
  );

bias_rom_25 u_bias_rom_25 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[25])
  );

bias_rom_26 u_bias_rom_26 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[26])
  );

bias_rom_27 u_bias_rom_27 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[27])
  );

bias_rom_28 u_bias_rom_28 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[28])
  );

bias_rom_29 u_bias_rom_29 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[29])
  );

bias_rom_30 u_bias_rom_30 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[30])
  );

bias_rom_31 u_bias_rom_31 (
    .a      ({1'b0,bias_rom_rd_addr}),
    .clk    (clk), 
    .qspo   (bias_rom_rd_data_arr[31])
  );

endmodule
