`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2025 11:43:28 PM
// Design Name: 
// Module Name: pixel_binner
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


module pixel_binner(
    input               clk,
    input               resetn,
				        
    input               start_en,
				  
    output logic [15:0] r_data [1:0][31:0],
    output logic [15:0] g_data [1:0][31:0],
    output logic [15:0] b_data [1:0][31:0],
    output logic  [5:0] row_o,

    output logic        pxl_idle_o,

// FIFO Interface

    output              get_data,
    input  [7:0]        p_data_sync,
    input               data_ready
);

// Assumes 555 output data

// p_clk
typedef enum bit[2:0] {
   PXL_IDLE         = 3'b000,
   PXL_TRIM_START   = 3'b001,
   PXL_AGGREGATE    = 3'b010,
   PXL_TRIM_END     = 3'b011,
   PXL_DONE         = 3'b100
} pxl_state_t;

logic [8:0]  row_ptr;
logic [8:0]  row_limit;
logic [10:0] col_ptr;
logic [10:0] col_limit;
logic [4:0]  col_data_ptr;
logic [4:0]  col_data_ptr2;

logic        data_set_in_use;
logic        rg_b;
			 
logic [7:0]  data_prev;
logic        clear_data;
			 
pxl_state_t  pixel_state;

assign get_data = (pixel_state != PXL_IDLE);

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        row_ptr         <= 9'h0;
        row_limit       <= 9'h0;
        col_ptr         <= 11'h0;
        col_limit       <= 11'h0;
        data_set_in_use <= 1'b0;
        col_data_ptr    <= 5'h0;
        col_data_ptr2   <= 5'h0;

        pixel_state     <= PXL_IDLE;
        row_o           <= 6'h0;
        rg_b            <= 1'b0;

        pxl_idle_o      <= 1'b1;
        data_prev       <= 8'h0;
        clear_data      <= 1'b0;

        for(integer i0 = 0; i0 < 32; i0++) begin
            r_data[0][i0] <= 16'h0;
            g_data[0][i0] <= 16'h0;
            b_data[0][i0] <= 16'h0;

            r_data[1][i0] <= 16'h0;
            g_data[1][i0] <= 16'h0;
            b_data[1][i0] <= 16'h0;
        end
    end
    else begin
        case(pixel_state)
            PXL_IDLE : begin
                if(start_en) begin
                    pixel_state     <= PXL_TRIM_START;
                    row_ptr         <= 10'h0;
                    row_limit       <= 9'd14;
                    col_ptr         <= 11'h0;
                    col_limit       <= 11'd159;
                    data_set_in_use <= 1'b0;
                    row_o           <= 6'h0;
                    pxl_idle_o      <= 1'b0;
                    clear_data      <= 1'b1;
                end
            end
            PXL_TRIM_START : begin
                if(~start_en) begin
                    pixel_state <= PXL_IDLE;
                    pxl_idle_o  <= 1'b1;
                end
                else if(data_ready) begin
                    col_ptr <= col_ptr + 1'b1;
                    if(col_ptr == col_limit) begin
                        pixel_state   <= PXL_AGGREGATE;
                        col_data_ptr  <= 5'h0;
                        col_data_ptr2 <= 5'h0;
                        col_limit     <= col_limit + 10'd30;
                        if(clear_data) begin
                            for(integer i0 = 0; i0 < 32; i0++) begin
                                r_data[data_set_in_use][i0] <= 16'h0;
                                g_data[data_set_in_use][i0] <= 16'h0;
                                b_data[data_set_in_use][i0] <= 16'h0;
                            end
                            clear_data <= 1'b0;
                        end
                        rg_b <= 1'b0;
                    end
                end
            end
            PXL_AGGREGATE : begin
                if(~start_en) begin
                    pixel_state <= PXL_IDLE;
                    pxl_idle_o  <= 1'b1;
                end
                else if(data_ready) begin
                    col_ptr <= col_ptr + 1'b1;
                    rg_b <= ~rg_b;
                    if(~rg_b) begin
                        data_prev <= p_data_sync;
                    end
                    else begin
                        r_data[data_set_in_use][col_data_ptr]  <= r_data[data_set_in_use][col_data_ptr2] + data_prev[6:2];
                        g_data[data_set_in_use][col_data_ptr2] <= g_data[data_set_in_use][col_data_ptr]  + {data_prev[1:0], p_data_sync[7:5]};
                        b_data[data_set_in_use][col_data_ptr]  <= b_data[data_set_in_use][col_data_ptr2] + p_data_sync[4:0];
                    end
                    if(col_ptr == 11'd1119) begin
                        row_ptr <= row_ptr + 1'b1;
                        if(row_ptr == 9'd479) begin
                            pixel_state     <= PXL_DONE;
                            row_o           <= 6'd32;
                            data_set_in_use <= ~data_set_in_use;
                        end
                        else begin
                            pixel_state <= PXL_TRIM_END;
                            if(row_ptr == row_limit) begin
                                row_limit       <= row_limit + 15'd15;
                                row_o           <= row_o + 1'b1;
                                data_set_in_use <= ~data_set_in_use;
                                clear_data      <= 1'b1;
                            end
                        end
                    end
                    else if(col_ptr == col_limit) begin
                        col_data_ptr  <= col_data_ptr + 1'b1;
                        col_data_ptr2 <= col_data_ptr + 1'b1;
                        col_limit     <= col_limit + 10'd30;
                    end
                end
            end
            PXL_TRIM_END : begin
                if(~start_en) begin
                    pixel_state <= PXL_IDLE;
                    pxl_idle_o  <= 1'b1;
                end
                else if(data_ready) begin
                    col_ptr <= col_ptr + 1'b1;
                    if(col_ptr == 11'd1279) begin
                        col_ptr     <= 11'h0;
                        col_limit   <= 11'd159;
                        pixel_state <= PXL_TRIM_START;
                    end
                end
            end
            PXL_DONE : begin
                if(~start_en) begin
                    pixel_state <= PXL_IDLE;
                    pxl_idle_o  <= 1'b1;
                end
                else if(col_ptr == 11'd1279) begin
                    if(~start_en) begin
                        pixel_state <= PXL_IDLE;
                        pxl_idle_o  <= 1'b1;
                    end
                end
                else begin
                    if(data_ready) begin
                        col_ptr <= col_ptr + 1'b1;
                    end
                end
            end
        endcase
    end
end


endmodule
