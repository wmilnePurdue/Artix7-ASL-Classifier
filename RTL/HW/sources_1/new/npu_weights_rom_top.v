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


module npu_weights_rom_top(
      clk, weights_rom_rd_addr, weights_rom_rd_data
    );

input clk;

input [`LOG2_FILTER_MEM_ADDR_WIDTH-1:0] weights_rom_rd_addr; 
output reg [32*8-1:0] weights_rom_rd_data;
wire [7:0] weights_rom_rd_data_arr [31:0];

integer j;

always @ (*)
begin
    for (j=0; j<32; j=j+1) begin
        weights_rom_rd_data[8*j +: 8] = weights_rom_rd_data_arr[j];
    end
end

weights_rom_0 u_weight_rom_0 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[0])
  );

weights_rom_1 u_weight_rom_1 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[1])
  );

weights_rom_2 u_weight_rom_2 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[2])
  );

weights_rom_3 u_weight_rom_3 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[3])
  );

weights_rom_4 u_weight_rom_4 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[4])
  );

weights_rom_5 u_weight_rom_5 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[5])
  );

weights_rom_6 u_weight_rom_6 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[6])
  );

weights_rom_7 u_weight_rom_7 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[7])
  );

weights_rom_8 u_weight_rom_8 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[8])
  );

weights_rom_9 u_weight_rom_9 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[9])
  );

weights_rom_10 u_weight_rom_10 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[10])
  );

weights_rom_11 u_weight_rom_11 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[11])
  );

weights_rom_12 u_weight_rom_12 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[12])
  );

weights_rom_13 u_weight_rom_13 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[13])
  );

weights_rom_14 u_weight_rom_14 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[14])
  );

weights_rom_15 u_weight_rom_15 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[15])
  );

weights_rom_16 u_weight_rom_16 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[16])
  );

weights_rom_17 u_weight_rom_17 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[17])
  );

weights_rom_18 u_weight_rom_18 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[18])
  );

weights_rom_19 u_weight_rom_19 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[19])
  );

weights_rom_20 u_weight_rom_20 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[20])
  );

weights_rom_21 u_weight_rom_21 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[21])
  );

weights_rom_22 u_weight_rom_22 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[22])
  );

weights_rom_23 u_weight_rom_23 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[23])
  );

weights_rom_24 u_weight_rom_24 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[24])
  );

weights_rom_25 u_weight_rom_25 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[25])
  );

weights_rom_26 u_weight_rom_26 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[26])
  );

weights_rom_27 u_weight_rom_27 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[27])
  );

weights_rom_28 u_weight_rom_28 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[28])
  );

weights_rom_29 u_weight_rom_29 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[29])
  );

weights_rom_30 u_weight_rom_30 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[30])
  );

weights_rom_31 u_weight_rom_31 (
   .clka   (clk),
   .addra  (weights_rom_rd_addr),
   .douta  (weights_rom_rd_data_arr[31])
  );

endmodule
