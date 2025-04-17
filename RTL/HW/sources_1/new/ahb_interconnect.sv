`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2025 09:09:13 PM
// Design Name: 
// Module Name: ahb_interconnect
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

module ahb_interconnect(
    input  wire         clk,
    input  wire         resetn,

    input  wire [31:0]  ahb_s0_haddr_i,
    input  wire         ahb_s0_hwrite_i,
    input  wire [2:0]   ahb_s0_hsize_i,
    input  wire [2:0]   ahb_s0_hburst_i,
    input  wire [3:0]   ahb_s0_hprot_i,
    input  wire [1:0]   ahb_s0_htrans_i,
    input  wire         ahb_s0_hmastlock_i,
    input  wire [31:0]  ahb_s0_hwdata_i,

    output logic        ahb_s0_hready_o,
    output logic        ahb_s0_hresp_o,
    output logic [31:0] ahb_s0_hrdata_o,
					  
    output logic [31:0] ahb_m0_haddr_o,
    output logic        ahb_m0_hwrite_o,
    output logic [2:0]  ahb_m0_hsize_o,
    output logic [2:0]  ahb_m0_hburst_o,
    output logic [3:0]  ahb_m0_hprot_o,
    output logic [1:0]  ahb_m0_htrans_o,
    output logic        ahb_m0_hmastlock_o,
    output logic [31:0] ahb_m0_hwdata_o,

    input  wire         ahb_m0_hready_i,
    input  wire         ahb_m0_hresp_i,
    input  wire  [31:0] ahb_m0_hrdata_i,

    output logic [31:0] ahb_m1_haddr_o,
    output logic        ahb_m1_hwrite_o,
    output logic [2:0]  ahb_m1_hsize_o,
    output logic [2:0]  ahb_m1_hburst_o,
    output logic [3:0]  ahb_m1_hprot_o,
    output logic [1:0]  ahb_m1_htrans_o,
    output logic        ahb_m1_hmastlock_o,
    output logic [31:0] ahb_m1_hwdata_o,

    input  wire         ahb_m1_hready_i,
    input  wire         ahb_m1_hresp_i,
    input  wire  [31:0] ahb_m1_hrdata_i,

    output logic [31:0] ahb_m2_haddr_o,
    output logic        ahb_m2_hwrite_o,
    output logic [2:0]  ahb_m2_hsize_o,
    output logic [2:0]  ahb_m2_hburst_o,
    output logic [3:0]  ahb_m2_hprot_o,
    output logic [1:0]  ahb_m2_htrans_o,
    output logic        ahb_m2_hmastlock_o,
    output logic [31:0] ahb_m2_hwdata_o,

    input  wire         ahb_m2_hready_i,
    input  wire         ahb_m2_hresp_i,
    input  wire  [31:0] ahb_m2_hrdata_i
);

`include "ahb_intf.vh"

typedef enum bit[1:0] {
   IDLE   = 2'b00,
   ISSUE  = 2'b01,
   WAIT   = 2'b10
} state_t;

state_t bus_state;
state_t bus_state_nxt;

logic [1:0] ahb_addr_p_r;

always_comb begin
    bus_state_nxt = bus_state;
    case(bus_state)
        IDLE: begin
            if(ahb_s0_htrans_i == HTRANS_NSEQ && |ahb_s0_haddr_i[31:30]) begin
                bus_state_nxt = ISSUE;
            end
        end
        ISSUE: begin
            bus_state_nxt = WAIT;
        end
        WAIT: begin
            case(ahb_addr_p_r)
                2'b01:   bus_state_nxt = ahb_m0_hready_i ? IDLE : WAIT;
                2'b10:   bus_state_nxt = ahb_m1_hready_i ? IDLE : WAIT;
                2'b11:   bus_state_nxt = ahb_m2_hready_i ? IDLE : WAIT;
                default: bus_state_nxt = IDLE;
            endcase
        end
    endcase
end

always_ff @(posedge clk, negedge resetn) begin
    if(~resetn) begin
        bus_state <= IDLE;
    end
    else begin
        bus_state <= bus_state_nxt;
    end
end

always_ff @(posedge clk, negedge resetn) begin
    if(~resetn) begin
        ahb_addr_p_r       <= 2'b00;

        ahb_m0_haddr_o     <= 32'h0;
        ahb_m0_hsize_o     <= '0;
        ahb_m0_hburst_o    <= '0;
        ahb_m0_hprot_o     <= '0;
        ahb_m0_htrans_o    <= HTRANS_IDLE;
        ahb_m0_hmastlock_o <= '0;
        ahb_m0_hwdata_o    <= 32'h0;
        ahb_m0_hwrite_o    <= 1'b0;

        ahb_m1_haddr_o     <= 32'h0;
        ahb_m1_hsize_o     <= '0;
        ahb_m1_hburst_o    <= '0;
        ahb_m1_hprot_o     <= '0;
        ahb_m1_htrans_o    <= HTRANS_IDLE;
        ahb_m1_hmastlock_o <= '0;
        ahb_m1_hwdata_o    <= 32'h0;
        ahb_m1_hwrite_o    <= 1'b0;

        ahb_m2_haddr_o     <= 32'h0;
        ahb_m2_hsize_o     <= '0;
        ahb_m2_hburst_o    <= '0;
        ahb_m2_hprot_o     <= '0;
        ahb_m2_htrans_o    <= HTRANS_IDLE;
        ahb_m2_hmastlock_o <= '0;
        ahb_m2_hwdata_o    <= 32'h0;
        ahb_m2_hwrite_o    <= 1'b0;

        ahb_s0_hready_o    <= 1'b1;
        ahb_s0_hresp_o     <= 1'b0;
        ahb_s0_hrdata_o    <= 32'h0;
    end
    else begin
        case(bus_state)
            IDLE: begin
                if(ahb_s0_htrans_i == HTRANS_NSEQ && |ahb_s0_haddr_i[31:30]) begin
                    ahb_addr_p_r    <= ahb_s0_haddr_i[31:30];
                    ahb_s0_hready_o <= 1'b0;
			    
                    case(ahb_s0_haddr_i[31:30])
                        2'b01: begin
                            ahb_m0_haddr_o      <= ahb_s0_haddr_i;
                            ahb_m0_hsize_o      <= ahb_s0_hsize_i;
                            ahb_m0_hburst_o     <= ahb_s0_hburst_i;
                            ahb_m0_hprot_o      <= ahb_s0_hprot_i;
                            ahb_m0_htrans_o     <= HTRANS_NSEQ;
                            ahb_m0_hmastlock_o  <= ahb_s0_hmastlock_i;
                            ahb_m0_hwrite_o     <= ahb_s0_hwrite_i;
                        end
                        2'b10: begin 
                            ahb_m1_haddr_o      <= ahb_s0_haddr_i;
                            ahb_m1_hsize_o      <= ahb_s0_hsize_i;
                            ahb_m1_hburst_o     <= ahb_s0_hburst_i;
                            ahb_m1_hprot_o      <= ahb_s0_hprot_i;
                            ahb_m1_htrans_o     <= HTRANS_NSEQ;
                            ahb_m1_hmastlock_o  <= ahb_s0_hmastlock_i;
                            ahb_m1_hwrite_o     <= ahb_s0_hwrite_i;
                        end
                        2'b11: begin
                            ahb_m2_haddr_o      <= ahb_s0_haddr_i;
                            ahb_m2_hsize_o      <= ahb_s0_hsize_i;
                            ahb_m2_hburst_o     <= ahb_s0_hburst_i;
                            ahb_m2_hprot_o      <= ahb_s0_hprot_i;
                            ahb_m2_htrans_o     <= HTRANS_NSEQ;
                            ahb_m2_hmastlock_o  <= ahb_s0_hmastlock_i;
                            ahb_m2_hwrite_o     <= ahb_s0_hwrite_i;
                        end
                    endcase
                end
            end
            ISSUE: begin
                ahb_m0_htrans_o <= HTRANS_IDLE;
                case(ahb_addr_p_r)
                    2'b01: begin
                        ahb_m0_hwdata_o <= ahb_s0_hwdata_i;
                    end
                    2'b10: begin
                        ahb_m1_hwdata_o <= ahb_s0_hwdata_i;
                    end
                    2'b11: begin
                        ahb_m2_hwdata_o <= ahb_s0_hwdata_i;
                    end
                endcase
            end
            WAIT: begin
                case(ahb_addr_p_r)
                    2'b01: begin
                            if(ahb_m0_hready_i) begin
                                ahb_s0_hready_o <= 1'b1;
                                ahb_s0_hresp_o  <= ahb_m0_hresp_i;
                                ahb_s0_hrdata_o <= ahb_m0_hrdata_i;
                            end
                            ahb_m0_htrans_o <= HTRANS_IDLE;
                            ahb_m0_hwdata_o <= ahb_s0_hwdata_i;
                    end
                    2'b10: begin
                            if(ahb_m1_hready_i) begin
                                ahb_s0_hready_o <= 1'b1;
                                ahb_s0_hresp_o  <= ahb_m1_hresp_i;
                                ahb_s0_hrdata_o <= ahb_m1_hrdata_i;
                            end
                            ahb_m1_htrans_o <= HTRANS_IDLE;
                            ahb_m1_hwdata_o <= ahb_s0_hwdata_i;
                    end
                    2'b11: begin
                            if(ahb_m2_hready_i) begin
                                ahb_s0_hready_o <= 1'b1;
                                ahb_s0_hresp_o  <= ahb_m2_hresp_i;
                                ahb_s0_hrdata_o <= ahb_m2_hrdata_i;
                            end
                            ahb_m2_htrans_o <= HTRANS_IDLE;
                            ahb_m2_hwdata_o <= ahb_s0_hwdata_i;
                    end
                endcase
            end
        endcase
    end
end

endmodule
