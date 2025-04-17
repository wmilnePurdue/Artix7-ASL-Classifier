`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2025 02:09:28 PM
// Design Name: 
// Module Name: spi_io
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

module spi_io (
    input                  clk,
    input                  resetn,
						   
    input  wire [31:0]     ahb_s0_haddr_i,
    input  wire            ahb_s0_hwrite_i,
    input  wire [2:0]      ahb_s0_hsize_i,
    input  wire [2:0]      ahb_s0_hburst_i,
    input  wire [3:0]      ahb_s0_hprot_i,
    input  wire [1:0]      ahb_s0_htrans_i,
    input  wire            ahb_s0_hmastlock_i,
    input  wire [31:0]     ahb_s0_hwdata_i,
						   
    output logic           ahb_s0_hready_o,
    output logic           ahb_s0_hresp_o,
    output logic [31:0]    ahb_s0_hrdata_o,

    output logic           spi_sclk,
    output logic           spi_sdo,
    
    output logic           dc,
    output logic           csn
);
// address map
// 0xC000_0000 - wr_data
// 0xC000_0004 - delay
// 0xC000_0008 - num_bytes
// 0xC000_000C - D/C
// 0xC000_0010 - start_process
// 0xC000_0014 - check if ready
//             
//         IDLE       SETUP    CLK_POS    SETUP    CLK_POS     CLK_POS  IDLE
//        _________                                                     _____
//  CSN            |__________________________________________ ........|
//  
//        <-delay-> <-delay-> _________           _________
//  SCLK  ___________________|         |_________|         |   ........ _____
//                  <-delay-> <-delay->
//                  ___________________ ___________________
//  SDO   ____X____|        D0         |         D1         |  ........|  X
//
//
//  <-delay->

`include "ahb_intf.vh"

typedef enum bit[1:0] {
    SPI_IDLE    = 2'b00,
    SPI_SETUP   = 2'b01,
    SPI_CLK_POS = 2'b10,
    SPI_TIMER   = 2'b11
} spi_state_t;

spi_state_t spi_state;
spi_state_t spi_state_ret;

logic [15:0] delay_count;
logic [31:0] wr_data;
logic [4:0]  num_bits;

logic [2:0]  ahb_addr_p;
logic        wr_en;

logic [4:0]  tx_bits;
logic [15:0] delay_ctr;

assign ahb_s0_hready_o = 1'b1;
assign ahb_s0_hresp_o  = 1'b0;
assign ahb_s0_hrdata_o = {31'h0, ((spi_state == SPI_IDLE) ? 1'b1 : 1'b0 )};

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        ahb_addr_p <= 3'b000;
        wr_en      <= 1'b0;
    end
    else begin
        if(ahb_s0_htrans_i == HTRANS_NSEQ) begin
            ahb_addr_p <= ahb_s0_haddr_i[4:2];
            wr_en      <= ahb_s0_hwrite_i;
        end
        else begin
            wr_en <= 1'b0;
        end
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        wr_data     <= 32'h0;
        delay_count <= 16'h0;
        num_bits    <= 5'h0;
        dc          <= 1'b0;
    end
    else begin
        if(wr_en) begin
            case(ahb_addr_p)
               3'b000 : wr_data     <= ahb_s0_hwdata_i;
               3'b001 : delay_count <= ahb_s0_hwdata_i[15:0];
               3'b010 : num_bits    <= ahb_s0_hwdata_i[4:0];
               3'b011 : dc          <= ahb_s0_hwdata_i[0];
            endcase
        end
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        tx_bits   <= 5'h0;
        delay_ctr <= 16'h0;
        spi_state <= SPI_IDLE;

        spi_sclk  <= 1'b0;
        spi_sdo   <= 1'b0;
        csn       <= 1'b1;
    end
    else begin
        case(spi_state)
            SPI_IDLE : begin
                spi_sclk  <= 1'b0;
                if(wr_en & ahb_addr_p == 3'b100 & ahb_s0_hwdata_i[0]) begin
                    spi_state     <= SPI_TIMER;
                    spi_state_ret <= SPI_SETUP;
                    delay_ctr     <= delay_count;
                    tx_bits       <= num_bits;
                    csn           <= 1'b0;
                end
                else begin
                    csn           <= 1'b1;
                end
            end
            SPI_SETUP : begin
                spi_state     <= SPI_TIMER;
                spi_state_ret <= SPI_CLK_POS;
                delay_ctr     <= delay_count;
                spi_sdo       <= wr_data[tx_bits];
                spi_sclk      <= 1'b0;
            end
            SPI_CLK_POS : begin
                spi_state <= SPI_TIMER;
                spi_sclk  <= 1'b1;
                delay_ctr <= delay_count;
                if(tx_bits == 5'h0) begin
                    spi_state_ret <= SPI_IDLE;
                end
                else begin
                    tx_bits       <= tx_bits - 1'b1; 
                    spi_state_ret <= SPI_SETUP;
                end
            end
            SPI_TIMER : begin
                if(delay_ctr == 16'h0) begin
                    spi_state <= spi_state_ret;
                end
                else begin
                    delay_ctr <= delay_ctr - 1'b1;
                end
            end
        endcase
    end
end

endmodule