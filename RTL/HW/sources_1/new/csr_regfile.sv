`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2025 10:17:50 PM
// Design Name: 
// Module Name: csr_regfile
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

module csr_regfile # (
    parameter RW_REG_CNT   = 10,
    parameter R_REG_CNT    = 10
)(
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

    output logic [31:0]    rw_reg [RW_REG_CNT-1:0],
    input  wire  [31:0]    r_reg  [R_REG_CNT-1:0]
);

`include "ahb_intf.vh"

typedef enum bit[0:0] {
   IDLE   = 1'b0,
   WAIT   = 1'b1
} state_t;

state_t csr_state;
state_t csr_state_nxt;

localparam [31:0] RW_REG_START = 32'h0000_0000;
localparam [31:0] R_REG_START  = 32'h0008_0000;
localparam        BIT_CUTOFF   = 19;
localparam        RW_CNT_CLOG  = $clog2(RW_REG_CNT);
localparam        R_CNT_CLOG   = $clog2(R_REG_CNT);
localparam        CNT_CLOG_MAX = RW_CNT_CLOG > R_CNT_CLOG ? RW_CNT_CLOG : R_CNT_CLOG;

logic                    ahb_write_en;
logic                    ahb_rw_rd_en;
logic [CNT_CLOG_MAX-1:0] ahb_addr;

assign ahb_s0_hresp_o = 1'b0;

always_comb begin
    csr_state_nxt = csr_state;
    if(csr_state == IDLE) begin
        if(ahb_s0_htrans_i == HTRANS_NSEQ) begin
            csr_state_nxt = WAIT;
        end
    end
    else begin
        csr_state_nxt = IDLE;
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        csr_state <= IDLE;
    end
    else begin
        csr_state <= csr_state_nxt;
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        for (integer i0 = 0; i0 < RW_REG_CNT; i0++ ) begin
            rw_reg[i0] <= 32'h0;
        end
        ahb_s0_hready_o <= 1'b1;
        ahb_write_en    <= 1'b0;
        ahb_rw_rd_en    <= 1'b0;
        ahb_addr        <= {CNT_CLOG_MAX{1'b0}};
        ahb_s0_hrdata_o <= 32'h0;
    end
    else begin
        if(csr_state == IDLE) begin
            if(ahb_s0_htrans_i == HTRANS_NSEQ) begin
                if(~|ahb_s0_haddr_i[29:19]) begin
                    ahb_write_en <= ahb_s0_hwrite_i;
                    ahb_rw_rd_en <= 1'b1;
                end
                ahb_addr <= ahb_s0_haddr_i[CNT_CLOG_MAX+1:2];
                ahb_s0_hready_o <= 1'b0;
            end
        end
        else begin
            if(ahb_write_en) begin
                rw_reg[ahb_addr[RW_CNT_CLOG-1:0]] <= ahb_s0_hwdata_i;
            end
            if (ahb_rw_rd_en) begin
                ahb_s0_hrdata_o <= rw_reg[ahb_addr[RW_CNT_CLOG-1:0]];
            end
            else begin
                ahb_s0_hrdata_o <= r_reg[ahb_addr[R_CNT_CLOG-1:0]];
            end
            ahb_write_en <= 1'b0;
            ahb_rw_rd_en <= 1'b0;
            ahb_s0_hready_o <= 1'b1;
        end
    end
end

endmodule
