`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2025 08:49:08 PM
// Design Name: 
// Module Name: sccb_decoder
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


module sccb_decoder(
    input         i2c_scl,
    input         i2c_sda,

    output logic [15:0] data_o
);

wire I2C_CLK = i2c_scl === 1'b0 ? 1'b0 : 1'b1;
wire I2C_DAT = i2c_sda === 1'b0 ? 1'b0 : 1'b1;

logic [26:0] read_data; 
logic [4:0]  i2c_ctr;   

initial begin
    #1;
    read_data <= 27'h0;
    i2c_ctr   <= 5'h0;
    data_o    <= 16'h0;
    forever begin
        @(posedge I2C_CLK);
        if(i2c_ctr == 5'd27) begin
            data_o    <= {read_data[17:10], read_data[8:1]};
            i2c_ctr   <= 5'h0;
            read_data <= 27'h0;
        end
        else begin
            read_data[26-i2c_ctr] <= I2C_DAT;
            i2c_ctr <= i2c_ctr + 1'b1;
        end
    end
end

endmodule
