`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2025 11:49:52 PM
// Design Name: 
// Module Name: camera_io
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


module camera_io(
//  ------------
//  clk domain
//  ------------
    input                clk,
    input                resetn,

    input                get_data,
    output [7:0]         p_data_sync,
    output               data_ready,
// must be synchronized to clk
    output logic         cam_read_busy,
    output logic         cam_vsync_trig,

//  ---------------
//  p_clock domain
//  ---------------
// must be synchronized to p_clock
    input  wire          start_en,
// must be set false path (clk synchronized)
    input  wire          cont_read,

	input  wire          p_clock,
	input  wire          vsync,
	input  wire          href,
	input  wire   [7:0]  p_data
);

//  ---------------
//  p_clock domain
//  ---------------

typedef enum bit[2:0] {
   CAM_IDLE        = 3'b000,
   CAM_WAIT_FRAME  = 3'b001,
   CAM_FRAME_START = 3'b010,
   CAM_ROW_CAPTURE = 3'b011,
   CAM_CAPTURE_END = 3'b100
} cam_state_t;

cam_state_t  cam_state;
logic [1:0]  start_en_sync;
logic        cam_busy_reg;
logic        cam_vsync_trig_pclk;

logic        fifo_wr_en;

//  ------------
//  clk domain
//  ------------
logic  cam_vsync_sync;
logic  cam_busy_sync;
wire   empty_flag;
assign data_ready = ~empty_flag;


//  ----------------------
//  p_clock domain (logic)
//  ----------------------

always_ff @ (posedge p_clock, negedge resetn) begin
    if(~resetn) begin
        start_en_sync       <= 2'b00;
        cam_vsync_trig_pclk <= 1'b0;
    end
    else begin
        start_en_sync[0]    <= start_en;
        start_en_sync[1]    <= start_en_sync[0];
        cam_vsync_trig_pclk <= (cam_state == CAM_CAPTURE_END);
    end
end

always_ff @ (posedge p_clock, negedge resetn) begin
    if(~resetn) begin
        cam_state    <= CAM_IDLE;
        fifo_wr_en   <= 1'b0;
        cam_busy_reg <= 1'b0;
    end
    else begin
        case(cam_state)
            CAM_IDLE : begin
                if(start_en_sync[1]) begin
                    cam_state    <= CAM_WAIT_FRAME;
                    cam_busy_reg <= 1'b1;
                end
            end
            CAM_WAIT_FRAME : begin
                if(vsync) begin
                    cam_state <= CAM_FRAME_START;
                end
            end
            CAM_FRAME_START : begin
                if(~vsync) begin
                    cam_state    <= CAM_ROW_CAPTURE;
                    fifo_wr_en   <= 1'b1;
                end
            end
            CAM_ROW_CAPTURE : begin
                if(vsync) begin
                    fifo_wr_en <= 1'b0;
                    if(cont_read & start_en_sync[1]) begin
                        cam_state <= CAM_FRAME_START;
                    end
                    else begin
                        cam_state <= CAM_CAPTURE_END;
                    end
                end
            end
            CAM_CAPTURE_END : begin
                if(~start_en_sync[1]) begin
                    cam_state    <= CAM_IDLE;
                    cam_busy_reg <= 1'b0;
                end
            end
        endcase
    end
end

//  ------------------
//  clk domain (logic)
//  ------------------
always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        cam_read_busy  <= 1'b0;
        cam_busy_sync  <= 1'b0;
        cam_vsync_trig <= 1'b0;
        cam_vsync_sync <= 1'b0;
    end
    else begin
        cam_read_busy  <= cam_busy_sync;
        cam_busy_sync  <= cam_busy_reg;
        cam_vsync_sync <= cam_vsync_trig_pclk;
        cam_vsync_trig <= cam_vsync_sync;
    end
end

//  -------------------
//   FIFO synchronizer
//  -------------------

sync_fifo_ip SYNC_FIFO (
    .rst    (~resetn           ),
    .wr_clk (p_clock           ),
    .rd_clk (clk               ),
    .din    (p_data            ),
    .wr_en  (href & fifo_wr_en ),
    .rd_en  (get_data          ),
    .dout   (p_data_sync       ),
    .full   (                  ),
    .empty  (empty_flag        )
);

endmodule
