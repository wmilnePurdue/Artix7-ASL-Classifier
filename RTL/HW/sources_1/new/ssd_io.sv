`timescale 1ns / 1ps

module ssd_io (
    input  logic        clk,              // AHB-L clock (synchronized with Basys 3 100 MHz)
    input  logic        resetn,           // AHB-L reset (active low)
    input  logic [31:0] ahb_s0_haddr_i,   // AHB-L address (0xD000_0000, 0xD000_0004)
    input  logic        ahb_s0_hwrite_i,  // AHB-L write enable
    input  logic [2:0]  ahb_s0_hsize_i,   // AHB-L size (unused)
    input  logic [2:0]  ahb_s0_hburst_i,  // AHB-L burst (unused)
    input  logic [3:0]  ahb_s0_hprot_i,   // AHB-L protection (unused)
    input  logic [1:0]  ahb_s0_htrans_i,  // AHB-L transfer type (NONSEQ or SEQ)
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

typedef enum bit[0:0] {
    IDLE = 1'b0,
    WAIT = 1'b1
} state_t;

state_t csr_state, csr_state_nxt;

logic [4:0] data_reg;         // Latched 5-bit vector
logic done_flag;              // Done signal
logic [17:0] refresh_counter; // SSD refresh counter (~3.8 kHz)
logic [1:0] digit_select;     // Selects which SSD to display
logic [4:0] display_value;    // Display value register

// AHB-L response (always OKAY)
assign ahb_s0_hresp_o = 1'b0;

// AHB-L read data
always_comb begin
    ahb_s0_hrdata_o = 32'h0;
    ahb_s0_hrdata_o[4:0] = data_reg;
end

// State machine transition
always_comb begin
    csr_state_nxt = csr_state;
    if (csr_state == IDLE) begin
        if (ahb_s0_htrans_i == HTRANS_NSEQ && ahb_s0_hwrite_i) begin
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
        display_value <= '0;
        refresh_counter <= '0;
        digit_select <= '0;
    end else begin
        csr_state <= csr_state_nxt;
        if (csr_state == IDLE) begin
            if (ahb_s0_htrans_i == HTRANS_NSEQ && ahb_s0_hwrite_i) begin
                case (ahb_s0_haddr_i[2])
                    1'b0: data_reg <= ahb_s0_hwdata_i[4:0]; // 0xD000_0000
                    1'b1: done_flag <= ahb_s0_hwdata_i[0];  // 0xD000_0004
                endcase
                ahb_s0_hready_o <= 1'b0;
            end
        end else begin
            if (done_flag) begin
                display_value <= (data_reg > 5'd23) ? 5'd31 : data_reg; // Map >23 to 31 (for 99)
            end
            done_flag <= 1'b0; // Deassert done_flag
            ahb_s0_hready_o <= 1'b1;
        end
        // SSD refresh counter
        refresh_counter <= refresh_counter + 1;
        digit_select <= refresh_counter[17:16]; // Switch every ~2.6 ms
    end
end

// SSD control: Display on two rightmost digits (AN2, AN3)
always_comb begin
    logic invalid_letter;
    logic [3:0] bcd_tens, bcd_ones;

    // Check for invalid letters (k=9, m=11, v=20, w=21, x=22)
    invalid_letter = (display_value == 5'd9 || display_value == 5'd11 || 
                      display_value == 5'd20 || display_value == 5'd21 || display_value == 5'd22);

    // Compute BCD for numeric mode or invalid cases
    if (display_value == 5'd31) begin // Special case for >23 (99)
        bcd_tens = 4'd9;
        bcd_ones = 4'd9;
    end else begin
        bcd_tens = display_value / 10;
        bcd_ones = display_value % 10;
    end

    case (digit_select)
        2'b10: begin // Rightmost SSD (AN3)
            if (SW0 && display_value <= 5'd23 && !invalid_letter) begin
                // Alphabetic mode: valid letters (a, b, c, d, e, f, g, h, i, l, n, o, p, q, r, s, t, u, y)
                an = 4'b1110; // Activate AN3 only
                case (display_value)
                    5'd0:  seg = 7'b0001000; // A (CA,CB,CC,CE,CF,CG on)
                    5'd1:  seg = 7'b0000011; // b (CC,CD,CE,CF,CG on)
                    5'd2:  seg = 7'b1000110; // C (CA,CD,CE,CF on)
                    5'd3:  seg = 7'b0100001; // d (CB,CC,CD,CE,CG on)
                    5'd4:  seg = 7'b0000110; // E (CA,CD,CE,CF,CG on)
                    5'd5:  seg = 7'b0001110; // F (CA,CE,CF,CG on)
                    5'd6:  seg = 7'b1000010; // G (CA,CC,CD,CE,CF on)
                    5'd7:  seg = 7'b0001001; // H (CB,CC,CE,CF,CG on)
                    5'd8:  seg = 7'b1111001; // i (CB,CC on)
                    5'd10: seg = 7'b1000111; // L (CD,CE,CF on)
                    5'd12: seg = 7'b0101011; // n (CC,CE,CG on)
                    5'd13: seg = 7'b0100011; // o (CC,CD,CE,CG on)
                    5'd14: seg = 7'b0001100; // P (CA,CB,CE,CF,CG on)
                    5'd15: seg = 7'b0011000; // q (CA,CB,CC,CF,CG on)
                    5'd16: seg = 7'b0101111; // r (CE,CG on)
                    5'd17: seg = 7'b0010010; // S (CA,CC,CD,CF,CG on)
                    5'd18: seg = 7'b1111000; // t (CD,CE,CF,CG on)
                    5'd19: seg = 7'b1000001; // U (CB,CC,CD,CE,CF on)
                    5'd23: seg = 7'b0010001; // y (CB,CC,CD,CF,CG on)
                    default: seg = 7'b1111111; // Off (all segments off)
                endcase
            end else begin
                // Numeric mode or invalid letters (k, m, v, w, x) or >23
                an = 4'b1110; // Activate AN3
                case (bcd_ones)
                    4'd0: seg = 7'b1000000; // 0 (CA,CB,CC,CD,CE,CF on)
                    4'd1: seg = 7'b1111001; // 1 (CB,CC on)
                    4'd2: seg = 7'b0100100; // 2 (CA,CB,CD,CE,CG on)
                    4'd3: seg = 7'b0110000; // 3 (CA,CB,CC,CD,CG on)
                    4'd4: seg = 7'b0011001; // 4 (CB,CC,CF,CG on)
                    4'd5: seg = 7'b0010010; // 5 (CA,CC,CD,CE,CG on)
                    4'd6: seg = 7'b0000010; // 6 (CA,CC,CD,CE,CF,CG on)
                    4'd7: seg = 7'b1111000; // 7 (CA,CB,CC on)
                    4'd8: seg = 7'b0000000; // 8 (CA,CB,CC,CD,CE,CF,CG on)
                    4'd9: seg = 7'b0010000; // 9 (CA,CB,CC,CF,CG on)
                    default: seg = 7'b1111111; // Off (all segments off)
                endcase
            end
        end
        2'b11: begin // Second-right SSD (AN2)
            if (SW0 && display_value <= 5'd23 && !invalid_letter) begin
                an = 4'b1111; // AN2 off in alphabetic mode for valid letters
                seg = 7'b1111111; // Off (all segments off)
            end else begin
                an = 4'b1101; // Activate AN2
                case (bcd_tens)
                    4'd0: seg = 7'b1000000; // 0 (CA,CB,CC,CD,CE,CF on)
                    4'd1: seg = 7'b1111001; // 1 (CB,CC on)
                    4'd2: seg = 7'b0100100; // 2 (CA,CB,CD,CE,CG on)
                    4'd3: seg = 7'b0110000; // 3 (CA,CB,CC,CD,CG on)
                    4'd4: seg = 7'b0011001; // 4 (CB,CC,CF,CG on)
                    4'd5: seg = 7'b0010010; // 5 (CA,CC,CD,CE,CG on)
                    4'd6: seg = 7'b0000010; // 6 (CA,CC,CD,CE,CF,CG on)
                    4'd7: seg = 7'b1111000; // 7 (CA,CB,CC on)
                    4'd8: seg = 7'b0000000; // 8 (CA,CB,CC,CD,CE,CF,CG on)
                    4'd9: seg = 7'b0010000; // 9 (CA,CB,CC,CF,CG on)
                    default: seg = 7'b1111111; // Off (all segments off)
                endcase
            end
        end
        default: begin
            an = 4'b1111; // All SSDs off
            seg = 7'b1111111; // Off (all segments off)
        end
    endcase
end

endmodule