`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2025 04:29:13 PM
// Design Name: 
// Module Name: dmem_ahb_arbiter
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


module dmem_ahb_arbiter #(
    parameter AWID = 10
)(
    input                   clk,
    input                   resetn,

    output                  cpu_mem_ready_o,
    output       [31:0]     cpu_mem_rddata_o,

    input        [31:0]     cpu_mem_addr_i,
    input        [31:0]     cpu_mem_wrdata_i,
    input        [3:0]      cpu_mem_byte_en_i,
    input                   cpu_mem_wr_en_i,
    input                   cpu_mem_rd_en_i,

    input        [31:0]     dmem_rddata,

    output       [AWID-1:0] dmem_addr,
    output                  dmem_wren,
    output       [3:0]      dmem_byteen,
    output       [31:0]     dmem_wrdata,

    output logic [31:0]     ahb_haddr_o,
    output logic            ahb_hwrite_o,
    output logic [2:0]      ahb_hsize_o,
    output       [2:0]      ahb_hburst_o,
    output       [3:0]      ahb_hprot_o,
    output logic [1:0]      ahb_htrans_o,
    output                  ahb_hmastlock_o,
    output logic [31:0]     ahb_hwdata_o,

    input                   ahb_hready_i,
    input                   ahb_hresp_i,
    input        [31:0]     ahb_hrdata_i
);

`include "ahb_intf.vh"

typedef enum bit[1:0] {
   IDLE       = 2'b00,
   MEM_ACCESS = 2'b01,
   AHB_ISSUE  = 2'b10,
   AHB_ACCESS = 2'b11
} state_t; 

state_t arbiter_state;
state_t arbiter_state_nxt;

wire isDMEM_WrAccess = (cpu_mem_wr_en_i) & ~(|cpu_mem_addr_i[31:18]);
wire isDMEM_RdAccess = (cpu_mem_rd_en_i) & ~(|cpu_mem_addr_i[31:18]);
wire isAHB_Access  = (cpu_mem_wr_en_i | cpu_mem_rd_en_i) & (|cpu_mem_addr_i[31:18]);

assign cpu_mem_rddata_o = (arbiter_state == MEM_ACCESS) ? dmem_rddata : ahb_hrdata_i;
assign cpu_mem_ready_o  = (arbiter_state == IDLE)       ? isDMEM_WrAccess :
                          (arbiter_state == MEM_ACCESS) ? 1'b1 : 
                          (arbiter_state == AHB_ACCESS) ? ahb_hready_i : 1'b0;

assign dmem_addr   = cpu_mem_addr_i[AWID-1:0];
assign dmem_wren   = isDMEM_WrAccess;
assign dmem_byteen = cpu_mem_byte_en_i;
assign dmem_wrdata = cpu_mem_wrdata_i;

// Unused AHB signals
assign ahb_hprot_o     = 4'h0;
assign ahb_hmastlock_o = 1'b0;
assign ahb_hburst_o    = 3'b000;

always_comb begin
    arbiter_state_nxt = arbiter_state;
    case (arbiter_state)
        IDLE: begin
            if(isDMEM_RdAccess) begin
                arbiter_state_nxt = MEM_ACCESS;
            end
            else if(isAHB_Access) begin
                arbiter_state_nxt = AHB_ISSUE;
            end
        end
        MEM_ACCESS: arbiter_state_nxt = IDLE;
        AHB_ISSUE: arbiter_state_nxt = AHB_ACCESS;
        AHB_ACCESS: begin
            if(ahb_hready_i) begin
                arbiter_state_nxt = IDLE;
            end
        end
    endcase
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        arbiter_state <= IDLE;
    end
    else begin
        arbiter_state <= arbiter_state_nxt;
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        ahb_haddr_o  <= 32'h0;
        ahb_hwrite_o <= 1'b0;
        ahb_hsize_o  <= HSIZE_32;
        ahb_htrans_o <= HTRANS_IDLE;
        ahb_hwdata_o <= 32'h0;
    end
    else begin
        case(arbiter_state)
            IDLE: begin
                if(isAHB_Access) begin
                    ahb_haddr_o  <= cpu_mem_addr_i;
                    ahb_hwrite_o <= cpu_mem_wr_en_i;
                    case(cpu_mem_byte_en_i)
                        4'b1111: ahb_hsize_o <= HSIZE_32;
                        4'b1100: ahb_hsize_o <= HSIZE_16;
                        4'b0011: ahb_hsize_o <= HSIZE_16;
                        default: ahb_hsize_o <= HSIZE_8;
                    endcase
                    ahb_htrans_o <= HTRANS_NSEQ;
                    ahb_hwdata_o <= cpu_mem_wrdata_i;
                end
            end
            default : begin
                ahb_htrans_o <= HTRANS_IDLE;
            end
        endcase
    end
end

endmodule
