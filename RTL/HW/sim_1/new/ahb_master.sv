`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2025 08:28:21 PM
// Design Name: 
// Module Name: ahb_master
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


module ahb_master(
    input                clk,
    input                resetn,

    output logic [31:0]  ahb_haddr_o,
    output logic         ahb_hwrite_o,
    output logic [2:0]   ahb_hsize_o,
    output logic [2:0]   ahb_hburst_o,
    output logic [3:0]   ahb_hprot_o,
    output logic [1:0]   ahb_htrans_o,
    output logic         ahb_hmastlock_o,
    output logic [31:0]  ahb_hwdata_o,

    input                ahb_hready_i,
    input                ahb_hresp_i,
    input  [31:0]        ahb_hrdata_i
);

// AHB-L definitions

// HTRANS
localparam [1:0] HTRANS_IDLE   = 2'b00;
localparam [1:0] HTRANS_BUSY   = 2'b01;
localparam [1:0] HTRANS_NSEQ   = 2'b10;
localparam [1:0] HTRANS_SEQ    = 2'b11;

// HSIZE
localparam [2:0] HSIZE_8       = 3'b000;
localparam [2:0] HSIZE_16      = 3'b001;
localparam [2:0] HSIZE_32      = 3'b010;

logic [31:0] rd_data;

initial begin
    ahb_haddr_o      <= '0;
    ahb_hwrite_o     <= '0;
    ahb_hsize_o      <= '0;
    ahb_hburst_o     <= '0;
    ahb_hprot_o      <= '0;
    ahb_htrans_o     <= HTRANS_IDLE;
    ahb_hmastlock_o  <= '0;
    ahb_hwdata_o     <= '0;
    @(posedge resetn);
    @(posedge clk);
    //ahb_write(32'h8000_2000, $urandom_range(8'h00, 8'hFF));
    //ahb_read(32'h8000_2000);
    /* perform test writes and reads here */

    //$finish;
end

task ahb_write(input [31:0] addr, input [31:0] wdata);
    begin
        ahb_haddr_o  <= addr;
        ahb_hwrite_o <= 1'b1;
        ahb_htrans_o <= HTRANS_NSEQ;
        @(posedge clk);
        #0.1;
        ahb_htrans_o <= HTRANS_IDLE;
        ahb_hwrite_o <= 1'b0;
        ahb_hwdata_o <= wdata;
        while(!ahb_hready_i) @(posedge clk);
    end
endtask

task ahb_read(input [31:0] addr);
    begin
        ahb_haddr_o  <= addr;
        ahb_hwrite_o <= 1'b0;
        ahb_htrans_o <= HTRANS_NSEQ;
        @(posedge clk);
        #0.1;
        ahb_htrans_o <= HTRANS_IDLE;
        while(!ahb_hready_i) @(posedge clk);
        rd_data <= ahb_hrdata_i;
        @(posedge clk);
    end
endtask


endmodule
