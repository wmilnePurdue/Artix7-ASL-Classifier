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


module npu_ahb_decoder(
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
    output                 ahb_s0_hresp_o,
    output logic [31:0]    ahb_s0_hrdata_o,

    output logic           write_row,
    output logic [5:0]     npu_thrshld_num_rows_to_start,

    input  wire            npu_done,
    input  wire  [4:0]     npu_class_predicted,
    input  wire            npu_active,
    input  wire  [2:0]     npu_layer_in_progress,
    input  wire  [5:0]     img_num_rows_written,
    input  wire            mac_overflow_lat_r,
    input  wire            act_overflow_lat_r,

    output logic [11:0]    mem0_addr_o,
    output logic           mem0_wr_o,
    output logic [7:0]     mem0_wrdata_o,
    input  wire  [7:0]     mem0_rddata_i,

    output logic [11:0]    mem1_addr_o,
    output logic           mem1_wr_o,
    output logic [7:0]     mem1_wrdata_o,
    input  wire  [7:0]     mem1_rddata_i,

    output logic [7:0]     r_mean_o,
    output logic [7:0]     g_mean_o,
    output logic [7:0]     b_mean_o
);

`include "ahb_intf.vh"

typedef enum bit[0:0] {
   IDLE   = 1'b0,
   WAIT   = 1'b1
} state_t;

state_t csr_state;
state_t csr_state_nxt;

logic [11:0] mem_prev_o;
logic [1:0]  mem_prev_sel;
logic [5:0]  rd_only_o;
logic        rw_reg_wr;

wire [5:0]  rd_only_csr [7:0];

assign mem0_addr_o    = mem0_wr_o ? mem_prev_o : ahb_s0_haddr_i[11:0];
assign mem0_wrdata_o  = ahb_s0_hwdata_i[7:0];

assign mem1_addr_o    = mem1_wr_o ? mem_prev_o : ahb_s0_haddr_i[11:0];
assign mem1_wrdata_o  = ahb_s0_hwdata_i[7:0];

assign ahb_s0_hresp_o = 1'b0;

assign rd_only_csr[0] = {5'h0, npu_done};                // 0x8000_1000
assign rd_only_csr[1] = {1'b0, npu_class_predicted};     // 0x8000_1004
assign rd_only_csr[2] = {5'h0, npu_active};              // 0x8000_1008
assign rd_only_csr[3] = npu_thrshld_num_rows_to_start;   // 0x8000_100C
assign rd_only_csr[4] = {3'h0, npu_layer_in_progress};   // 0x8000_1010
assign rd_only_csr[5] = img_num_rows_written;            // 0x8000_1014
assign rd_only_csr[6] = {5'h0, mac_overflow_lat_r};      // 0x8000_1018
assign rd_only_csr[7] = {5'h0, act_overflow_lat_r};      // 0x8000_1020

always_comb begin
    ahb_s0_hrdata_o = 32'h0;
    case(mem_prev_sel)
        2'b00: case(mem_prev_o[4:2])
                   3'b001: ahb_s0_hrdata_o[5:0] = npu_thrshld_num_rows_to_start;
                   3'b010: ahb_s0_hrdata_o[7:0] = r_mean_o;
                   3'b011: ahb_s0_hrdata_o[7:0] = g_mean_o;
                   3'b100: ahb_s0_hrdata_o[7:0] = b_mean_o;
               endcase
        2'b01: ahb_s0_hrdata_o[5:0] = rd_only_o;
        2'b10: ahb_s0_hrdata_o[7:0] = mem0_rddata_i;
        2'b11: ahb_s0_hrdata_o[7:0] = mem1_rddata_i;
    endcase
end

always_comb begin
    csr_state_nxt = csr_state;
    if(csr_state == IDLE) begin
        if(ahb_s0_htrans_i == HTRANS_NSEQ && ahb_s0_hwrite_i) begin
            csr_state_nxt = WAIT;
        end
    end
    else begin
        csr_state_nxt = IDLE;
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        ahb_s0_hready_o                <= 1'b1;
        csr_state                      <= IDLE;
        mem_prev_o                     <= 12'h0;
        mem_prev_sel                   <= 2'b00;
        write_row                      <= 1'b0;
        npu_thrshld_num_rows_to_start  <= 6'd0;
        rd_only_o                      <= 6'h0;
        mem0_wr_o                      <= 1'b0;
        mem1_wr_o                      <= 1'b0;
        rw_reg_wr                      <= 1'b0;
        r_mean_o                       <= '0;
        g_mean_o                       <= '0;
        b_mean_o                       <= '0;
    end
    else begin
        csr_state <= csr_state_nxt;
        if(csr_state == IDLE) begin
            write_row <= 1'b0;
            rd_only_o       <= rd_only_csr[ahb_s0_haddr_i[4:2]];
            mem_prev_sel    <= ahb_s0_haddr_i[13:12];
            mem_prev_o      <= ahb_s0_haddr_i[11:0];
            if(ahb_s0_htrans_i == HTRANS_NSEQ && ahb_s0_hwrite_i) begin
                case(ahb_s0_haddr_i[13:12])
                    2'b00: rw_reg_wr <= 1'b1;
                    2'b10: mem0_wr_o <= 1'b1;
                    2'b11: mem1_wr_o <= 1'b1;
                endcase

                ahb_s0_hready_o <= 1'b0;
            end
        end
        else begin
            if (rw_reg_wr) begin
                case(mem_prev_o[4:2])
                    3'b000: write_row                     <= ahb_s0_hwdata_i[0];
                    3'b001: npu_thrshld_num_rows_to_start <= ahb_s0_hwdata_i[5:0];
                    3'b010: r_mean_o                      <= ahb_s0_hwdata_i[7:0];
                    3'b011: g_mean_o                      <= ahb_s0_hwdata_i[7:0];
                    3'b100: b_mean_o                      <= ahb_s0_hwdata_i[7:0];
                endcase
            end
            rw_reg_wr       <= 1'b0;
            mem0_wr_o       <= 1'b0;
            mem1_wr_o       <= 1'b0;
            ahb_s0_hready_o <= 1'b1;
        end
    end
end

endmodule