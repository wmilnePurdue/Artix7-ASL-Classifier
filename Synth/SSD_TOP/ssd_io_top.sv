`timescale 1ns / 1ps

module ssd_io_top (
    input  logic        clk,       // 100 MHz clock
    input  logic        btnC,      // Reset button (active high)
    input  logic [5:0]  sw,       // Switches: sw[4:0] for data_reg, sw[5] for display mode
    output logic [6:0]  seg,      // 7-segment cathodes
    output logic [3:0]  an        // 7-segment anodes
);

`include "ahb_intf.vh"

typedef enum logic [1:0] {
    IDLE       = 2'b00,
    WRITE_DATA = 2'b01,
    WRITE_DONE = 2'b10
} state_t;

state_t state, state_nxt;

// AHB-Lite signals
logic [31:0] ahb_s0_haddr;
logic        ahb_s0_hwrite;
logic [2:0]  ahb_s0_hsize;
logic [2:0]  ahb_s0_hburst;
logic [3:0]  ahb_s0_hprot;
logic [1:0]  ahb_s0_htrans;
logic        ahb_s0_hmastlock;
logic [31:0] ahb_s0_hwdata;
logic [31:0] ahb_s0_hrdata;
logic        ahb_s0_hready;
logic        ahb_s0_hresp;

// Switch handling
logic [5:0] sw_sync;    // Synchronized switches
logic [5:0] sw_last;    // Last switch values
logic       sw_changed; // Switch change detected
logic       resetn;     // Active-low reset
logic [31:0] hwdata_reg; // Registered hwdata for data phase
logic       sw_change_pulse; // Latched change detection

// Instantiate ssd_io
ssd_io u_ssd_io (
    .clk(clk),
    .resetn(resetn),
    .ahb_s0_haddr_i(ahb_s0_haddr),
    .ahb_s0_hwrite_i(ahb_s0_hwrite),
    .ahb_s0_hsize_i(ahb_s0_hsize),
    .ahb_s0_hburst_i(ahb_s0_hburst),
    .ahb_s0_hprot_i(ahb_s0_hprot),
    .ahb_s0_htrans_i(ahb_s0_htrans),
    .ahb_s0_hmastlock_i(ahb_s0_hmastlock),
    .ahb_s0_hwdata_i(ahb_s0_hwdata),
    .SW0(sw_sync[5]), // Display mode from synchronized sw[5]
    .ahb_s0_hrdata_o(ahb_s0_hrdata),
    .ahb_s0_hready_o(ahb_s0_hready),
    .ahb_s0_hresp_o(ahb_s0_hresp),
    .seg(seg),
    .an(an)
);

// Reset (active-low)
assign resetn = ~btnC;

// Synchronize switches and latch change detection
always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        sw_sync <= '0;
        sw_last <= '0;
        sw_change_pulse <= 1'b0;
    end else begin
        sw_sync <= sw;
        if (sw_sync != sw_last) begin
            sw_change_pulse <= 1'b1; // Latch change
        end
        if (state == WRITE_DONE && ahb_s0_hready) begin
            sw_last <= sw_sync; // Update sw_last after write completes
            sw_change_pulse <= 1'b0; // Clear pulse
        end
    end
end

assign sw_changed = sw_change_pulse;

// State machine for AHB writes
always_comb begin
    state_nxt = state;
    ahb_s0_haddr = '0;
    ahb_s0_hwrite = 1'b0;
    ahb_s0_hsize = HSIZE_32;
    ahb_s0_hburst = 3'b000;
    ahb_s0_hprot = 4'b0000;
    ahb_s0_htrans = HTRANS_IDLE;
    ahb_s0_hmastlock = 1'b0;
    ahb_s0_hwdata = hwdata_reg;

    case (state)
        IDLE: begin
            if (sw_changed) begin
                state_nxt = WRITE_DATA;
                ahb_s0_haddr = 32'hC000_0000;
                ahb_s0_hwrite = 1'b1;
                ahb_s0_htrans = HTRANS_NSEQ;
            end
        end
        WRITE_DATA: begin
            ahb_s0_haddr = 32'hC000_0000;
            ahb_s0_hwrite = 1'b1;
            ahb_s0_htrans = HTRANS_NSEQ;
            if (ahb_s0_hready) begin
                state_nxt = WRITE_DONE;
                ahb_s0_haddr = 32'hC000_0004;
                ahb_s0_hwrite = 1'b1;
                ahb_s0_htrans = HTRANS_NSEQ;
            end
        end
        WRITE_DONE: begin
            ahb_s0_haddr = 32'hC000_0004;
            ahb_s0_hwrite = 1'b1;
            ahb_s0_htrans = HTRANS_NSEQ;
            if (ahb_s0_hready) begin
                state_nxt = IDLE;
            end
        end
        default: state_nxt = IDLE;
    endcase
end

// State and hwdata updates
always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        state <= IDLE;
        hwdata_reg <= '0;
    end else begin
        state <= state_nxt;
        case (state)
            IDLE: begin
                if (sw_changed) begin
                    hwdata_reg <= {27'b0, sw_sync[4:0]}; // Set data_reg value
                end
            end
            WRITE_DATA: begin
                if (ahb_s0_hready) begin
                    hwdata_reg <= 32'h00000001; // Set done_flag
                end
            end
            WRITE_DONE: begin
                if (ahb_s0_hready) begin
                    hwdata_reg <= '0;
                end
            end
        endcase
    end
end

endmodule