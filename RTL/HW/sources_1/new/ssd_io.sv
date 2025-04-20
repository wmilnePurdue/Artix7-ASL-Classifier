`timescale 1ns / 1ps

module ssd_io (
    input  logic        clk,              // AHB-L clock (synchronized with Basys 3 100 MHz)
    input  logic        resetn,           // AHB-L reset (active low)
    input  logic [31:0] ahb_s0_haddr_i,   // AHB-L address (0xC000_0000, 0xC000_0004)
    input  logic        ahb_s0_hwrite_i,  // AHB-L write enable
    input  logic [2:0]  ahb_s0_hsize_i,   // AHB-L size (unused)
    input  logic [2:0]  ahb_s0_hburst_i,  // AHB-L burst (unused)
    input  logic [3:0]  ahb_s0_hprot_i,   // AHB-L protection (unused)
    input  logic [1:0]  ahb_s0_htrans_i,  // AHB-L transfer type (NONSEQ only)
    input  logic        ahb_s0_hmastlock_i, // AHB-L master lock (unused)
    input  logic [31:0] ahb_s0_hwdata_i,  // AHB-L write data
    input  logic        SW0,              // Switch to select display mode (0: numeric, 1: alphabetic)
    output logic [31:0] ahb_s0_hrdata_o,  // AHB-L read data
    output logic        ahb_s0_hready_o,  // AHB-L ready signal
    output logic        ahb_s0_hresp_o,   // AHB-L response (always 0)
    output logic [6:0]  seg,              // SSD cathode segments (CA, CB, CC, CD, CE, CF, CG)
    output logic [3:0]  an                // SSD anode control
);

`include "ahb_intf.vh"

typedef enum logic {
    IDLE = 1'b0,
    WAIT = 1'b1
} state_t;

state_t csr_state, csr_state_nxt;

logic [4:0] data_reg;         // Latched 5-bit vector
logic done_flag;              // Done signal
logic [16:0] refresh_counter; // SSD refresh counter (~327.68 us per digit)
logic [1:0] digit_select;     // Selects which SSD to display
logic [4:0] display_value;    // Display value register
logic [2:0] addr_latched;     // Latch lower address bits for data phase

// AHB-L response (always OKAY)
assign ahb_s0_hresp_o = 1'b0;

// AHB-L read data
always_comb begin
    ahb_s0_hrdata_o = '0;
    if (!ahb_s0_hwrite_i && ahb_s0_haddr_i[2] == 1'b0 && ahb_s0_htrans_i == HTRANS_NSEQ) begin
        ahb_s0_hrdata_o[4:0] = data_reg; // Read data_reg at 0xC000_0000
    end
end

// State machine transition
always_comb begin
    csr_state_nxt = csr_state;
    if (csr_state == IDLE) begin
        if (ahb_s0_htrans_i == HTRANS_NSEQ) begin
            csr_state_nxt = WAIT;
        end
    end else begin
        csr_state_nxt = IDLE;
    end
end

// AHB-L slave and display logic
always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        ahb_s0_hready_o <= 1'b1;
        csr_state <= IDLE;
        data_reg <= '0;
        done_flag <= '0;
        display_value <= 5'd31; // Initialize to display "99"
        refresh_counter <= '0;
        digit_select <= '0;
        addr_latched <= '0;
    end else begin
        csr_state <= csr_state_nxt;

        if (done_flag) begin
            display_value <= (data_reg > 5'd23) ? 5'd31 : data_reg; // Map >23 to 99
            done_flag <= 1'b0;
        end

        if (csr_state == IDLE) begin
            if (ahb_s0_htrans_i == HTRANS_NSEQ) begin
                addr_latched <= ahb_s0_haddr_i[2:0]; // Latch lower address bits
                ahb_s0_hready_o <= 1'b0;
            end
        end else begin // WAIT state
            if (ahb_s0_hwrite_i) begin
                case (addr_latched[2])
                    1'b0: data_reg <= ahb_s0_hwdata_i[4:0]; // 0xC000_0000
                    1'b1: done_flag <= ahb_s0_hwdata_i[0];  // 0xC000_0004
                endcase
            end
            ahb_s0_hready_o <= 1'b1;
        end
        refresh_counter <= refresh_counter + 1;
        digit_select <= refresh_counter[16:15];
    end
end

// SSD control: Display on two rightmost digits (AN1, AN0)
always_comb begin
    logic invalid_letter;
    logic [3:0] bcd_tens, bcd_ones;

    // Check for invalid letters (k=9, m=11, v=20, w=21, x=22)
    invalid_letter = (display_value == 5'd9 || display_value == 5'd11 || 
                      display_value == 5'd20 || display_value == 5'd21 || display_value == 5'd22);

    // Compute BCD for numeric mode or invalid cases
    if (display_value == 5'd31) begin
        bcd_tens = 4'd9;
        bcd_ones = 4'd9;
    end else begin
        bcd_tens = display_value / 10;
        bcd_ones = display_value % 10;
    end

    case (digit_select)
        2'b00: begin // Rightmost SSD (AN0)
            if (SW0 && display_value <= 5'd23 && !invalid_letter) begin
                an = 4'b1110;
                case (display_value)
                    5'd0:  seg = 7'b0001000; // A
                    5'd1:  seg = 7'b0000011; // b
                    5'd2:  seg = 7'b1000110; // C
                    5'd3:  seg = 7'b0100001; // d
                    5'd4:  seg = 7'b0000110; // E
                    5'd5:  seg = 7'b0001110; // F
                    5'd6:  seg = 7'b1000010; // G
                    5'd7:  seg = 7'b0001001; // H
                    5'd8:  seg = 7'b1111001; // i
                    5'd10: seg = 7'b1000111; // L
                    5'd12: seg = 7'b0101011; // n
                    5'd13: seg = 7'b0100011; // o
                    5'd14: seg = 7'b0001100; // P
                    5'd15: seg = 7'b0011000; // q
                    5'd16: seg = 7'b0101111; // r
                    5'd17: seg = 7'b0010010; // S
                    5'd18: seg = 7'b1111000; // t
                    5'd19: seg = 7'b1000001; // U
                    5'd23: seg = 7'b0010001; // y
                    default: seg = 7'b1111111;
                endcase
            end else begin
                an = 4'b1110;
                case (bcd_ones)
                    4'd0: seg = 7'b1000000; // 0
                    4'd1: seg = 7'b1111001; // 1
                    4'd2: seg = 7'b0100100; // 2
                    4'd3: seg = 7'b0110000; // 3
                    4'd4: seg = 7'b0011001; // 4
                    4'd5: seg = 7'b0010010; // 5
                    4'd6: seg = 7'b0000010; // 6
                    4'd7: seg = 7'b1111000; // 7
                    4'd8: seg = 7'b0000000; // 8
                    4'd9: seg = 7'b0010000; // 9
                    default: seg = 7'b1111111;
                endcase
            end
        end
        2'b01: begin // Second-right SSD (AN1)
            if (SW0 && display_value <= 5'd23 && !invalid_letter) begin
                an = 4'b1111;
                seg = 7'b1111111;
            end else begin
                an = 4'b1101;
                case (bcd_tens)
                    4'd0: seg = 7'b1000000; // 0
                    4'd1: seg = 7'b1111001; // 1
                    4'd2: seg = 7'b0100100; // 2
                    4'd3: seg = 7'b0110000; // 3
                    4'd4: seg = 7'b0011001; // 4
                    4'd5: seg = 7'b0010010; // 5
                    4'd6: seg = 7'b0000010; // 6
                    4'd7: seg = 7'b1111000; // 7
                    4'd8: seg = 7'b0000000; // 8
                    4'd9: seg = 7'b0010000; // 9
                    default: seg = 7'b1111111;
                endcase
            end
        end
        default: begin
            an = 4'b1111;
            seg = 7'b1111111;
        end
    endcase
end

endmodule