`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2025 12:15:56 PM
// Design Name: 
// Module Name: npu_control_unit
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

`include "npu_defines.vh"

module npu_control_unit(
    npu_clk, npu_rst_n,
    cfg_write_row_p, cfg_thrshld_num_rows_to_start,
    softmax_result_valid_p, softmax_class_predicted,
    npu_active, npu_done, npu_layer_in_progress, img_num_rows_written, npu_class_predicted,
    mac_enable, mac_start_p, mac_last_p,
    filter_mem_rd_en, filter_mem_rd_addr,
    activation_mem_rd_en, activation_mem_rd_addr, activation_mem_rd_bypass,
    cur_state_conv1_c, cur_state_conv2_c, cur_state_conv3_c,
    cur_state_fc1_1_c, cur_state_fc1_2_c, cur_state_fc2_c       
);
// Clock, reset
input npu_clk;
input npu_rst_n;

// Config
input cfg_write_row_p; // pulse indicating that CPU has written 32x3 image pixels 
input [5:0] cfg_thrshld_num_rows_to_start; // start after programmed threshold num of rows updated by CPU

// Input from Soft Max Unit
input  softmax_result_valid_p; // pulse - qualifies class predicted vector
input [4:0] softmax_class_predicted;

// Status
output npu_active; // when 1 indicates CNN operation in progress; cleared when operation is done
output npu_done; 
output reg [2:0] npu_layer_in_progress;
output reg [5:0] img_num_rows_written;
output reg [4:0] npu_class_predicted;
// in case decoded state is needed
output cur_state_conv1_c;
output cur_state_conv2_c;
output cur_state_conv3_c;
output cur_state_fc1_1_c; // 32 neurons of FC1
output cur_state_fc1_2_c; // next 32 neurons of FC1
output cur_state_fc2_c; // FC2

// Control signals to MAC Top
output reg [31:0] mac_enable; // active high level signal. Qualifies all other inputs
output reg [1:0] mac_start_p; // pulse indicates start of dot product
output reg [1:0] mac_last_p;  // last cycle of dot product input

// Filter Mem read 
output reg [31:0] filter_mem_rd_en; // active high per 32 banks read enable
output reg [LOG2_FILTER_MEM_ADDR_WIDTH-1:0] filter_mem_rd_addr; // byte aligned address; read address common to all 32 banks

// Activation Mem read
output reg activation_mem_rd_en;
output reg [LOG2_ACT_ADDR_WIDTH-1:0] activation_mem_rd_addr; // byte aligned address 
output reg [31:0] activation_mem_rd_bypass; // when this is high, generate 0 as read data out instead of memory output with same latency

// State one-hot defines
localparam NPU_STATE_IDLE                 = 14'b00_0000_0000_0001;
localparam NPU_STATE_CONV1                = 14'b00_0000_0000_0010;
localparam NPU_STATE_WAIT_CONV1_RESULT_WR = 14'b00_0000_0000_0100;
localparam NPU_STATE_CONV2                = 14'b00_0000_0000_1000;
localparam NPU_STATE_WAIT_CONV2_RESULT_WR = 14'b00_0000_0001_0000;
localparam NPU_STATE_CONV3                = 14'b00_0000_0010_0000;
localparam NPU_STATE_WAIT_CONV3_RESULT_WR = 14'b00_0000_0100_0000;
localparam NPU_STATE_FC1_1                = 14'b00_0000_1000_0000;
localparam NPU_STATE_WAIT_FC1_1_RESULT_WR = 14'b00_0001_0000_0000;
localparam NPU_STATE_FC1_2                = 14'b00_0010_0000_0000;
localparam NPU_STATE_WAIT_FC1_2_RESULT_WR = 14'b00_0100_0000_0000;
localparam NPU_STATE_FC2                  = 14'b00_1000_0000_0000;
localparam NPU_STATE_SOFTMAX              = 14'b01_0000_0000_0000;
localparam NPU_STATE_DONE                 = 14'b10_0000_0000_0000;

reg [13:0] npu_state_r;
reg [13:0] nxt_npu_state_r;
// Filter counters
reg [1:0] filter_row_cnt_r;
reg [1:0] filter_col_cnt_r;
reg [3:0] filter_num_in_ch_cnt_r;
reg [3:0] filter_num_in_ch_cnt_max_minus_1;
// Output activation counters 
reg [3:0] quad_op_row_cnt;
reg [3:0] quad_op_col_cnt;
reg [1:0] quad_op_rel_cnt; 
reg [3:0] quad_row_col_cnt_max_minus_1;
// Cube of input image without pad - counters to track row and col cnt of image
reg [1:0] op_rel_row_cnt_without_pad;
reg [1:0] op_rel_col_cnt_without_pad;  
// row, col, ch counter for FC
reg [1:0] fc1_row_cnt;
reg [1:0] fc1_col_cnt;
reg [4:0] fc1_inp_ch_cnt;
reg [4:0] fc2_act_cnt;
reg [4:0] fc2_act_cnt_r1;
reg [4:0] fc2_act_cnt_r2;

reg [3:0] cur_state_conv1_pipeline_r;
reg [3:0] cur_state_conv2_pipeline_r;
reg [3:0] cur_state_conv3_pipeline_r;
reg [3:0] cur_state_fc1_1_pipeline_r;
reg [3:0] cur_state_fc1_2_pipeline_r;
reg [3:0] cur_state_fc2_pipeline_r;

reg pad_top_left_out_pixel_r1; 
reg pad_top_right_out_pixel_r1;
reg pad_bottom_left_out_pixel_r1;
reg pad_bottom_right_out_pixel_r1;
reg pad_top_edge_out_pixel_r1;
reg pad_bottom_edge_out_pixel_r1;
reg pad_left_edge_out_pixel_r1;
reg pad_right_edge_out_pixel_r1;

reg [1:0] filter_col_cnt_r1;
reg [5:0] input_img_row_num_without_pad_r1;
reg [5:0] input_img_col_num_without_pad_r1; 

reg [LOG2_ACT_ADDR_WIDTH-1:0] conv_act_mem_rd_addr_r2;
reg [LOG2_ACT_ADDR_WIDTH-1:0] fc1_act_mem_rd_addr_r1;
reg [LOG2_ACT_ADDR_WIDTH-1:0] fc1_act_mem_rd_addr_r2;

reg [3:0] filter_num_in_ch_cnt_r1;
reg bypass_act_mem_rd_r2;

wire npu_done = (npu_state_r == NPU_STATE_DONE);
wire npu_active = (npu_state_r != NPU_STATE_IDLE) & (npu_state_r != NPU_STATE_DONE);

wire cur_state_conv1_c = (npu_state_r == NPU_STATE_CONV1);
wire cur_state_conv2_c = (npu_state_r == NPU_STATE_CONV2);
wire cur_state_conv3_c = (npu_state_r == NPU_STATE_CONV3);
wire cur_state_fc1_1_c = (npu_state_r == NPU_STATE_FC1_1); // 32 neurons of FC1
wire cur_state_fc1_2_c = (npu_state_r == NPU_STATE_FC1_2); // next 32 neurons of FC1
wire cur_state_fc2_c   = (npu_state_r == NPU_STATE_FC2); // next 32 neurons of FC1

wire output_pixel_comp_boundary_c = (filter_row_cnt_r == 2'd2) & (filter_col_cnt_r == 2'd2) & 
                                    (((npu_state_r == NPU_STATE_CONV1) & (filter_num_in_ch_cnt_r == `CONV1_NUM_INPUT_CH_MINUS_1)) |
                                     ((npu_state_r == NPU_STATE_CONV2) & (filter_num_in_ch_cnt_r == `CONV2_NUM_INPUT_CH_MINUS_1)) |
                                     ((npu_state_r == NPU_STATE_CONV3) & (filter_num_in_ch_cnt_r == `CONV3_NUM_INPUT_CH_MINUS_1)));

// Conv: last output pixel and last computation for that
wire conv_termnical_cnt_c = (quad_op_row_cnt == quad_row_col_cnt_max_minus_1) & (quad_op_col_cnt == quad_row_col_cnt_max_minus_1) & 
		            (quad_op_rel_cnt == 2'd3) & output_pixel_comp_boundary_c;			     

// Below counters define boundary of Conv Layer operations
always @ (posedge npu_clk or negedge npu_rst_n) 
begin
if (~npu_rst_n) begin
    filter_row_cnt_r                   <= 2'd0;
    filter_col_cnt_r                   <= 2'd0;
    filter_num_in_ch_cnt_r             <= 4'd0;
    npu_state_r                        <= NPU_STATE_IDLE;
    filter_num_in_ch_cnt_max_minus_1   <= 4'd0;
    quad_op_row_cnt                    <= 4'd0;
    quad_op_col_cnt                    <= 4'd0;
    quad_op_rel_cnt                    <= 2'd0;
    quad_row_col_cnt_max_minus_1       <= 4'd0;
end else begin
    npu_state_r    <= nxt_npu_state_r;
    // roll over value for input channel filter cnt
    if (nxt_npu_state_r == NPU_STATE_CONV1) begin
        filter_num_in_ch_cnt_max_minus_1 <= `CONV1_NUM_INPUT_CH_MINUS_1;
    end else if (nxt_npu_state_r == NPU_STATE_CONV2) begin
        filter_num_in_ch_cnt_max_minus_1 <= `CONV2_NUM_INPUT_CH_MINUS_1;
    end else if (nxt_npu_state_r == NPU_STATE_CONV3) begin
        filter_num_in_ch_cnt_max_minus_1 <= `CONV3_NUM_INPUT_CH_MINUS_1;
    end
      
    // Conv filter row, col, input channel counters
    if (cur_state_conv1_c | cur_state_conv2_c | cur_state_conv3_c) begin
        if (filter_col_cnt_r == 2'd2) begin
            filter_col_cnt_r       <= 2'd0;
            if (filter_num_in_ch_cnt_r == filter_num_in_ch_cnt_max_minus_1) begin
                filter_num_in_ch_cnt_r <= 4'd0;
                if (filter_row_cnt_r == 2'd2) begin
                    filter_row_cnt_r       <= 2'd0;         
                end else begin
                    filter_row_cnt_r <= filter_row_cnt_r + 2'd1;
                end
            end else begin
                filter_num_in_ch_cnt_r <= filter_num_in_ch_cnt_r + 4'd1;
            end
        end else begin
            filter_col_cnt_r <= filter_col_cnt_r + 2'd1;
        end
    end else begin
        filter_col_cnt_r <= 2'd0;
        filter_row_cnt_r <= 2'd0;
        filter_num_in_ch_cnt_r <= 4'd0;
    end
  
      // roll over value for quad row col cnt
    if (nxt_npu_state_r == NPU_STATE_CONV1) begin
        quad_row_col_cnt_max_minus_1 <= `CONV1_NUM_OUT_PIXELS_DIV2_MINUS_1;
    end else if (nxt_npu_state_r == NPU_STATE_CONV2) begin
        quad_row_col_cnt_max_minus_1 <= `CONV2_NUM_OUT_PIXELS_DIV2_MINUS_1;
    end else if (nxt_npu_state_r == NPU_STATE_CONV3) begin
        quad_row_col_cnt_max_minus_1 <= `CONV3_NUM_OUT_PIXELS_DIV2_MINUS_1;
    end
  
    // one output pixel is done when all filter counters rollover  
    // For Max pool design, generating 4 output pixels together
    if (cur_state_conv1_c | cur_state_conv2_c | cur_state_conv3_c) begin
        if (output_pixel_comp_boundary_c) begin
            if (quad_op_rel_cnt == 2'd3) begin
               quad_op_rel_cnt <= 2'd0;
               if (quad_op_col_cnt == quad_row_col_cnt_max_minus_1) begin
                   quad_op_col_cnt <= 4'd0;
                   if (quad_op_row_cnt == quad_row_col_cnt_max_minus_1) begin
                       quad_op_row_cnt <= 4'd0;
                   end else begin
                       quad_op_row_cnt <= quad_op_row_cnt + 4'd1;                     
                   end
                end else begin
                   quad_op_col_cnt <= quad_op_col_cnt + 4'd1;
                end
             end else begin
                quad_op_rel_cnt <= quad_op_rel_cnt + 2'd1;
             end
        end            
    end else begin
         quad_op_rel_cnt <= 2'd0;
         quad_op_row_cnt <= 4'd0;
         quad_op_col_cnt <= 4'd0;
    end                 
  end
end
// finding reference wrt input image where current filter conv is in progress
// 4 output pixels are generated in a set. 2 from row n and 2 from row n+1 
// when rel_cnt value is 2 and 3, operation is happening on row n+1
wire [5:0] input_img_row_num_with_pad_c = (quad_op_row_cnt*2) + quad_op_rel_cnt[1];
wire [5:0] input_img_row_num_without_pad_c = (input_img_row_num_with_pad_c > 6'd0) ? (input_img_row_num_with_pad_c-6'd1) : 6'd0;
// when rel_cnt value is 1 and 3, operation is happening on col n+1
wire [5:0] input_img_col_num_with_pad_c = (quad_op_col_cnt*2) + quad_op_rel_cnt[0];
wire [5:0] input_img_col_num_without_pad_c = (input_img_col_num_with_pad_c > 6'd0) ? (input_img_col_num_with_pad_c-6'd1) : 6'd0;

// Input image and output of all Conv layers are padded by 1 row and 1 col zero pixels all around it
// Design generates activation input to MAC as zero when conv filter is covering padded region
// Below signal indicates pad region
// Pad : is there when quad_op_row_cnt and quad_op_col_cnt are boundary values. Padded pixels number vary based on whether it is extreme corner
// output pixel or it is on edge
wire pad_top_left_out_pixel_c     = (quad_op_row_cnt == 4'd0) & (quad_op_col_cnt == 4'd0) & 
                                    (quad_op_rel_cnt == 2'd0) & ((filter_row_cnt_r == 2'd0) | (filter_col_cnt_r == 2'd0)); 
wire pad_top_right_out_pixel_c    = (quad_op_row_cnt == 4'd0) & (quad_op_col_cnt == quad_row_col_cnt_max_minus_1) & 
                                    (quad_op_rel_cnt == 2'd1) & ((filter_row_cnt_r == 2'd0) | (filter_col_cnt_r == 2'd2));
wire pad_bottom_left_out_pixel_c  = (quad_op_row_cnt == quad_row_col_cnt_max_minus_1) & (quad_op_col_cnt == 4'd0) & 
                                    (quad_op_rel_cnt == 2'd2) & ((filter_row_cnt_r == 2'd2) | (filter_col_cnt_r == 2'd0));
wire pad_bottom_right_out_pixel_c = (quad_op_row_cnt == quad_row_col_cnt_max_minus_1) & (quad_op_col_cnt == quad_row_col_cnt_max_minus_1) & 
                                    (quad_op_rel_cnt == 2'd3) & ((filter_row_cnt_r == 2'd2) | (filter_col_cnt_r == 2'd2));
wire pad_top_edge_out_pixel_c     = (quad_op_row_cnt == 4'd0) & (~quad_op_rel_cnt[1]) & ~((quad_op_col_cnt == 4'd0) & (quad_op_rel_cnt == 2'd0)) &
                                    ~((quad_op_col_cnt == quad_row_col_cnt_max_minus_1) & (quad_op_rel_cnt == 2'd1));
wire pad_bottom_edge_out_pixel_c  = (quad_op_row_cnt == quad_row_col_cnt_max_minus_1) & (quad_op_rel_cnt[1]) & ~((quad_op_col_cnt == 4'd0) & (quad_op_rel_cnt == 2'd2)) &
                                    ~((quad_op_col_cnt == quad_row_col_cnt_max_minus_1) & (quad_op_rel_cnt == 2'd3));
wire pad_left_edge_out_pixel_c    = (quad_op_col_cnt == 4'd0) & (~quad_op_rel_cnt[0]) & ~((quad_op_row_cnt == 4'd0) & (quad_op_rel_cnt == 2'd0)) &
                                    ~((quad_op_row_cnt == quad_row_col_cnt_max_minus_1) & (quad_op_rel_cnt == 2'd1));
wire pad_right_edge_out_pixel_c   = (quad_op_col_cnt == quad_row_col_cnt_max_minus_1) & (quad_op_rel_cnt[0]) & ~((quad_op_row_cnt == 4'd0) & (quad_op_rel_cnt == 2'd1)) &
                                    ~((quad_op_row_cnt == quad_row_col_cnt_max_minus_1) & (quad_op_rel_cnt == 2'd3));    

wire bypass_act_mem_rd_r1_c = pad_top_left_out_pixel_r1 | pad_top_right_out_pixel_r1 | pad_bottom_left_out_pixel_r1 | pad_bottom_right_out_pixel_r1 |
                           pad_top_edge_out_pixel_r1 | pad_bottom_edge_out_pixel_r1 | pad_left_edge_out_pixel_r1 | pad_right_edge_out_pixel_r1;
                           
// Below counters track actual number of pixels worked on in image cuboid with pad
// These counter work in sync with filter counter
always @ (posedge npu_clk or negedge npu_rst_n) 
begin
if (~npu_rst_n) begin
    op_rel_row_cnt_without_pad   <= 2'd0;
    op_rel_col_cnt_without_pad   <= 2'd0;  
end else begin
    if (cur_state_conv1_r1 | cur_state_conv2_r1 | cur_state_conv3_r1) begin
        if (filter_col_cnt_r1 == 2'd2) begin
            op_rel_col_cnt_without_pad   <= 2'd0;
            if (op_rel_col_cnt_without_pad != 2'd0) begin
                if (op_rel_row_cnt_without_pad == 2'd2) begin
                    op_rel_row_cnt_without_pad   <= 2'd0;
                end else begin
                    op_rel_row_cnt_without_pad   <= op_rel_row_cnt_without_pad + 2'd1;
                end
            end
        end else if (~bypass_act_mem_rd_r1_c) begin
            op_rel_col_cnt_without_pad   <= op_rel_col_cnt_without_pad + 2'd1;
        end
     end else begin
        op_rel_row_cnt_without_pad   <= 2'd0;
        op_rel_col_cnt_without_pad   <= 2'd0;       
     end
  end
end

// A layer reads from previous layer's output mem section
wire [12:0] activation_mem_start_offset_r2_c = (cur_state_conv1_r2) ? `INPUT_IMAGE_START_ADDR :
                                            (cur_state_conv2_r2) ? `CONV1_OUTPUT_START_ADDR :
                                            (cur_state_conv3_r2) ? `CONV2_OUTPUT_START_ADDR :
                                            (cur_state_fc1_1_r2) ? `CONV3_OUTPUT_START_ADDR :
                                            (cur_state_fc1_2_r2) ? `CONV3_OUTPUT_START_ADDR :
                                            (cur_state_fc2_r2)   ? `FC1_1_OUTPUT_START_ADDR :
                                            `FC2_OUTPUT_START_ADDR;
                                              

// Number of Input paixels per channel for Conv 1 is 32x32 = 1KB
// Number of Input pixels per channel for Conv 2 is 16x16 = 256B
// Number of Input pixels per channel for Conv 3 is 8x8 = 64
// Input images are stored in Image Act memory in per channel granularity
// While reading across channels an offset has to be applied for channel start address

wire [11:0] ch_offset_img_act_mem_rd_r1_c = (cur_state_conv1_r1) ? (filter_num_in_ch_cnt_r1 << 10) :
                                         (cur_state_conv2_r1) ? (filter_num_in_ch_cnt_r1 << 8) :
                                         (filter_num_in_ch_cnt_r1 << 6);  
                                         
// Number of Input pixels per channel per row for Conv 1 is 32
// Number of Input pixels per channel per row for Conv 2 is 16
// Number of Input pixels per channel per row for Conv 3 is 8                                        
wire [6:0] sum_start_plus_rel_row_cnt_without_pad_r1_c = input_img_row_num_without_pad_r1 + op_rel_row_cnt_without_pad;
wire [11:0] abs_row_cnt_without_pad_r1_c =  (cur_state_conv1_r1) ? (sum_start_plus_rel_row_cnt_without_pad_r1_c << 5) : 
                                         (cur_state_conv2_r1) ? (sum_start_plus_rel_row_cnt_without_pad_r1_c << 4) : 
                                         (sum_start_plus_rel_row_cnt_without_pad_r1_c << 3);
                                         
    
                                                                                       
wire [6:0] sum_start_plus_rel_col_cnt_without_pad_r1_c = input_img_col_num_without_pad_r1 + op_rel_col_cnt_without_pad; 
wire [LOG2_ACT_ADDR_WIDTH-1:0] conv_act_mem_rd_addr_r1_c = abs_row_cnt_without_pad_r1_c + sum_start_plus_rel_col_cnt_without_pad_r1_c + ch_offset_img_act_mem_rd_r1_c;                                                         

wire [LOG2_ACT_ADDR_WIDTH-1:0] fc1_act_mem_rd_addr_c = {fc1_inp_ch_cnt,fc1_row_cnt,fc1_col_cnt};
wire fc1_terminal_cnt_c = (fc1_row_cnt == 2'd2) & (fc1_col_cnt == 2'd2) & (fc1_inp_ch_cnt == 5'd23);
wire fc2_terminal_cnt_c = (fc2_act_cnt == 5'd23);
// As per flattening order done by Matlab Flatten layer; Row (or Height first), then Col (or Width) and then input channel
always @ (posedge npu_clk or negedge npu_rst_n) 
begin
if (~npu_rst_n) begin
    fc1_row_cnt    <= 2'd0;
    fc1_col_cnt    <= 2'd0;
    fc1_inp_ch_cnt <= 5'd0;
    fc2_act_cnt    <= 5'd0;      
end else begin
    if (cur_state_fc1_1_c | cur_state_fc1_2_c) begin
        if (fc1_row_cnt == 2'd3) begin
            fc1_row_cnt  <= 2'd0;
            if (fc1_col_cnt == 2'd3) begin
                fc1_col_cnt <= 2'd0;
                if (fc1_inp_ch_cnt == 5'd23) begin
                    fc1_inp_ch_cnt <= 5'd0;
                end else begin
                    fc1_inp_ch_cnt <= fc1_inp_ch_cnt + 5'd1;
                end
            end else begin
                fc1_col_cnt <= fc1_col_cnt + 2'd1;
            end
        end else begin
            fc1_row_cnt  <= fc1_row_cnt + 2'd1;        
        end
     end else begin
        fc1_row_cnt    <= 2'd0;
        fc1_col_cnt    <= 2'd0;
        fc1_inp_ch_cnt <= 5'd0;       
     end
   end
   // FC2 - read activation linearly 
   if (cur_state_fc2_c) begin
       if (fc2_act_cnt < 5'd23) begin
           fc2_act_cnt <= fc2_act_cnt + 5'd1;
       end
   end else begin
       fc2_act_acnt <= 5'd0;
   end  
end          

// pipelining
always @ (posedge npu_clk or negedge npu_rst_n) 
begin
 if (~npu_rst_n) begin
   cur_state_conv1_pipeline_r     <= 4'd0;
   cur_state_conv2_pipeline_r     <= 4'd0;
   cur_state_conv3_pipeline_r     <= 4'd0;
   cur_state_fc1_1_pipeline_r     <= 4'd0;
   cur_state_fc1_2_pipeline_r     <= 4'd0;
   cur_state_fc2_pipeline_r       <= 4'd0;
   pad_top_left_out_pixel_r1      <= 1'b0; 
   pad_top_right_out_pixel_r1     <= 1'b0;
   pad_bottom_left_out_pixel_r1   <= 1'b0;
   pad_bottom_right_out_pixel_r1  <= 1'b0;
   pad_top_edge_out_pixel_r1      <= 1'b0;
   pad_bottom_edge_out_pixel_r1   <= 1'b0;
   pad_left_edge_out_pixel_r1     <= 1'b0;
   pad_right_edge_out_pixel_r1    <= 1'b0;
   filter_col_cnt_r1              <= 2'd0;  
   input_img_row_num_without_pad_r1 <= 6'd0;
   input_img_col_num_without_pad_r1 <= 6'd0;    
   filter_num_in_ch_cnt_r1        <= 4'd0;  
   conv_act_mem_rd_addr_r2        <= 13'd0; 
   fc1_act_mem_rd_addr_r1         <= 13'd0;
   fc1_act_mem_rd_addr_r2         <= 13'd0;
   bypass_act_mem_rd_r2           <= 1'b0;
   fc2_act_cnt_r1                 <= 5'd0;
   fc2_act_cnt_r2                 <= 5'd0;
end else begin
   cur_state_conv1_pipeline_r     <= {cur_state_conv1_pipeline_r[2:1],cur_state_conv1_pipeline_c};
   cur_state_conv2_pipeline_r     <= {cur_state_conv2_pipeline_r[2:1],cur_state_conv2_pipeline_c};
   cur_state_conv3_pipeline_r     <= {cur_state_conv3_pipeline_r[2:1],cur_state_conv3_pipeline_c};
   cur_state_fc1_1_pipeline_r     <= {cur_state_fc1_1_pipeline_r[2:1],cur_state_fc1_1_pipeline_c};
   cur_state_fc1_2_pipeline_r     <= {cur_state_fc1_2_pipeline_r[2:1],cur_state_fc1_2_pipeline_c};
   cur_state_fc2_pipeline_r       <= {cur_state_fc2_pipeline_r[2:1],cur_state_fc2_pipeline_c};
   cur_state_conv1_r1             <= cur_state_conv1_c;
   cur_state_conv2_r1             <= cur_state_conv2_c;
   cur_state_conv3_r1             <= cur_state_conv3_c;
   cur_state_fc1_1_r1             <= cur_state_fc1_1_c;
   cur_state_fc1_2_r1             <= cur_state_fc1_2_c;
   cur_state_fc2_r1               <= cur_state_fc2_c;
   cur_state_conv1_r2             <= cur_state_conv1_r1;
   cur_state_conv2_r2             <= cur_state_conv2_r1;
   cur_state_conv3_r2             <= cur_state_conv3_r1;
   cur_state_fc1_1_r2             <= cur_state_fc1_1_r1;
   cur_state_fc1_2_r2             <= cur_state_fc1_2_r1;
   cur_state_fc2_r2               <= cur_state_fc2_r1;
   pad_top_left_out_pixel_r1      <= pad_top_left_out_pixel_c; 
   pad_top_right_out_pixel_r1     <= pad_top_right_out_pixel_c;
   pad_bottom_left_out_pixel_r1   <= pad_bottom_left_out_pixel_c;
   pad_bottom_right_out_pixel_r1  <= pad_bottom_right_out_pixel_c;
   pad_top_edge_out_pixel_r1      <= pad_top_edge_out_pixel_c;
   pad_bottom_edge_out_pixel_r1   <= pad_bottom_edge_out_pixel_c;
   pad_left_edge_out_pixel_r1     <= pad_left_edge_out_pixel_c;
   pad_right_edge_out_pixel_r1    <= pad_right_edge_out_pixel_c;
   filter_col_cnt_r1              <= filter_col_cnt_r;     
   input_img_row_num_without_pad_r1 <= input_img_row_num_without_pad_c;
   input_img_col_num_without_pad_r1 <= input_img_col_num_without_pad_c; 
   filter_num_in_ch_cnt_r1        <= filter_num_in_ch_cnt_r;  
   conv_act_mem_rd_addr_r2        <= conv_act_mem_rd_addr_r1_c;
   fc1_act_mem_rd_addr_r1         <= fc1_act_mem_rd_addr_c;
   fc1_act_mem_rd_addr_r2         <= fc1_act_mem_rd_addr_r1;
   bypass_act_mem_rd_r2           <= bypass_act_mem_rd_r1_c;
   fc2_act_cnt_r1                 <= fc2_act_cnt;
   fc2_act_cnt_r2                 <= fc2_act_cnt_r1;
  end
end

// Mux filter start, end and channel enable based on state
wire [`LOG2_FILTER_MEM_ADDR_WIDTH-1:0] filter_rd_start_addr_mux_r2_c =  cur_state_conv1_pipeline_r[1]  ? `CONV1_FILTER_START_ADDR :
                                       cur_state_conv2_pipeline_r[1]  ? `CONV2_FILTER_START_ADDR :
                                       cur_state_conv3_pipeline_r[1]  ? `CONV3_FILTER_START_ADDR :
                                       cur_state_fc1_1_pipeline_r[1]  ? `FC1_1_FILTER_START_ADDR :
                                       cur_state_fc1_2_pipeline_r[1]  ? `FC1_2_FILTER_START_ADDR :
                                       cur_state_fc2_pipeline_r[1]    ? `FC2_FILTER_START_ADDR :
                                       11'd0;


wire [`LOG2_FILTER_MEM_ADDR_WIDTH-1:0] filter_rd_end_addr_mux_r2_c =  cur_state_conv1_pipeline_r[1]  ? `CONV1_FILTER_END_ADDR :
                                       cur_state_conv2_pipeline_r[1]  ? `CONV2_FILTER_END_ADDR :
                                       cur_state_conv3_pipeline_r[1]  ? `CONV3_FILTER_END_ADDR :
                                       cur_state_fc1_1_pipeline_r[1]  ? `FC1_1_FILTER_END_ADDR :
                                       cur_state_fc1_2_pipeline_r[1]  ? `FC1_2_FILTER_END_ADDR :
                                       cur_state_fc2_pipeline_r[1]    ? `FC2_FILTER_END_ADDR :
                                       11'd0;
                                       
wire [31:0] filter_rd_en_mux_r2_c =    cur_state_conv1_pipeline_r[1]  ? `CONV1_FILTER_EN :
                                       cur_state_conv2_pipeline_r[1]  ? `CONV2_FILTER_EN :
                                       cur_state_conv3_pipeline_r[1]  ? `CONV3_FILTER_EN :
                                       cur_state_fc1_1_pipeline_r[1]  ? `FC1_1_FILTER_EN :
                                       cur_state_fc1_2_pipeline_r[1]  ? `FC1_2_FILTER_EN :
                                       cur_state_fc2_pipeline_r[1]    ? `FC2_FILTER_EN :
                                       32'd0;
                                       
wire [31:0] filter_rd_en_mux_r4_c =    cur_state_conv1_pipeline_r[3]  ? `CONV1_FILTER_EN :
                                       cur_state_conv2_pipeline_r[3]  ? `CONV2_FILTER_EN :
                                       cur_state_conv3_pipeline_r[3]  ? `CONV3_FILTER_EN :
                                       cur_state_fc1_1_pipeline_r[3]  ? `FC1_1_FILTER_EN :
                                       cur_state_fc1_2_pipeline_r[3]  ? `FC1_2_FILTER_EN :
                                       cur_state_fc2_pipeline_r[3]    ? `FC2_FILTER_EN :
                                       32'd0;
                                       
wire cur_state_fc_or_conv_r1_c = (cur_state_conv1_r1 | cur_state_conv2_r1 |
                                 cur_state_conv3_r1 | cur_state_fc1_1_r1 |
                                 cur_state_fc1_2_r1 | cur_state_fc2_r1);                                       
                                       
wire cur_state_fc_or_conv_r2_c = (cur_state_conv1_pipeline_r[1] | cur_state_conv2_pipeline_r[1] |
                                 cur_state_conv3_pipeline_r[1] | cur_state_fc1_1_pipeline_r[1] |
                                 cur_state_fc1_2_pipeline_r[1] | cur_state_fc2_pipeline_r[1]);

// This is activation mem addr muxed based on state before adding ACT mem address
// start offset
wire [`LOG2_ACT_ADDR_WIDTH-1:0] activation_mem_rd_addr_rel_mux_r2_c = (cur_state_conv1_pipeline_r[1] | cur_state_conv2_pipeline_r[1] | cur_state_conv3_pipeline_r[1]) ?
                                                                       conv_act_mem_rd_addr_pipeline_r[1] : 
								       (cur_state_fc1_1_pipeline_r[1] | cur_state_fc1_2_pipeline_r[1]) ? 
								       fc1_act_mem_rd_addr_pipeline_r[1] : fc2_act_cnt_pipeline_r[1];  
                                                                   

always @ (posedge npu_clk or negedge npu_rst_n) 
begin
  if (~npu_rst_n) begin
      filter_mem_rd_en       <= 32'd0; // active high per 32 banks read enable
      filter_mem_rd_addr     <= {`LOG2_FILTER_MEM_ADDR_WIDTH{1'b0}};
      
      activation_mem_rd_en      <= 1'b0;
      activation_mem_rd_addr    <= {`LOG2_ACT_ADDR_WIDTH{1'b0}}; 
      activation_mem_rd_bypass  <= 1'b0; 
      img_num_rows_written   <=  6'd0;
      npu_class_predicted    <=  5'd0;
      mac_enable             <=  32'd0;
      mac_start_p            <=  1'b0;
      mac_last_p             <=  1'b0;
  end else begin
      // Filter read en and addr
      filter_mem_rd_en       <=  filter_rd_en_mux_r2_c;
      mac_enable             <=  filter_rd_en_mux_r4_c;
      mac_start_p            <=  conv_act_mem_rd_addr_pipeline_r[3] & ~conv_act_mem_rd_addr_pipeline_r[4];
      mac_last_p             <=  conv_act_mem_rd_addr_pipeline_r[3] & ~conv_act_mem_rd_addr_pipeline_r[2];
      if (cur_state_fc_or_conv_r2_c) begin
          if ((filter_mem_rd_addr == filter_rd_end_addr_mux_r2_c) & cur_state_fc_or_conv_r1_c) begin
              filter_mem_rd_addr <= filter_rd_start_addr_mux_r2_c;
          end else begin
              filter_mem_rd_addr <= filter_rd_start_addr_mux_r2_c + 1;
          end
      end
      
      // Act mem read en, read bypass and read address 
      activation_mem_rd_bypass  <= bypass_act_mem_rd_r2;
      activation_mem_rd_en      <= cur_state_fc_or_conv_r2_c;
      activation_mem_rd_addr    <= activation_mem_rd_addr_rel_mux_r2_c + activation_mem_start_offset_r2_c;     

      // cfg_write_row_p indicates CPU has written 1ROW for all 3 channels
      // i.e. 32x3 pixels. Increment counter when this pulse is rcvd
      // reset counter when NPU is done
      if (npu_done) begin
          img_num_rows_written   <=  6'd0;
      end else if (cfg_write_row_p) begin
	  img_num_rows_written   <= img_num_rows_written + 6'd1;
      end

      // Latch NPU classification result
      npu_class_predicted    <=  (softmax_result_valid_p) ? softmax_class_predicted : npu_class_predicted;
  end
end 

// State Machine
wire trigger_npu_c = (img_num_rows_written >= cfg_thrshld_num_rows_to_start) & (|cfg_thrshld_num_rows_to_start);


always @ (*)
begin
    case(npu_state_r)
    NPU_STATE_IDLE:
    begin
        nxt_npu_state_r = (trigger_npu_c) ? NPU_STATE_CONV1 : NPU_STATE_IDLE;
	npu_layer_in_progress = 3'd0;
    end
    NPU_STATE_CONV1:
    begin
        nxt_npu_state_r = (conv_termnical_cnt_c) ? NPU_STATE_WAIT_CONV1_RESULT_WR : NPU_STATE_CONV1;
	npu_layer_in_progress = 3'd1;
    end
    NPU_STATE_WAIT_CONV1_RESULT_WR:
    begin
        nxt_npu_state_r = (result_wr_wait_terminal_cnt_c) ? NPU_STATE_CONV2 : NPU_STATE_WAIT_CONV1_RESULT_WR;
	npu_layer_in_progress = 3'd1;
    end
    NPU_STATE_CONV2:
    begin
        nxt_npu_state_r = (conv_termnical_cnt_c) ? NPU_STATE_WAIT_CONV2_RESULT_WR : NPU_STATE_CONV2;
	npu_layer_in_progress = 3'd2;
    end
    NPU_STATE_WAIT_CONV2_RESULT_WR:
    begin
        nxt_npu_state_r = (result_wr_wait_terminal_cnt_c) ? NPU_STATE_CONV3 : NPU_STATE_WAIT_CONV2_RESULT_WR;
	npu_layer_in_progress = 3'd2;
    end
    NPU_STATE_CONV3:
    begin
        nxt_npu_state_r = (conv_termnical_cnt_c) ? NPU_STATE_WAIT_CONV3_RESULT_WR : NPU_STATE_CONV3;
	npu_layer_in_progress = 3'd3;
    end
    NPU_STATE_WAIT_CONV3_RESULT_WR:
    begin
        nxt_npu_state_r = (result_wr_wait_terminal_cnt_c) ? NPU_STATE_FC1_1 : NPU_STATE_WAIT_CONV3_RESULT_WR;
	npu_layer_in_progress = 3'd3;
    end
    NPU_STATE_FC1_1:
    begin
        nxt_npu_state_r = (fc1_terminal_cnt_c) ? NPU_STATE_WAIT_FC1_1_RESULT_WR : NPU_STATE_FC1_1;
	npu_layer_in_progress = 3'd4;
    end
    NPU_STATE_WAIT_FC1_1_RESULT_WR:
    begin
        nxt_npu_state_r = (result_wr_wait_terminal_cnt_c) ? NPU_STATE_FC1_2 : NPU_STATE_WAIT_FC1_1_RESULT_WR;
	npu_layer_in_progress = 3'd4;
    end
    NPU_STATE_FC1_2:
    begin
        nxt_npu_state_r = (fc1_terminal_cnt_c) ? NPU_STATE_WAIT_FC1_2_RESULT_WR : NPU_STATE_FC1_2;
	npu_layer_in_progress = 3'd4;
    end
    NPU_STATE_WAIT_FC1_2_RESULT_WR:
    begin
        nxt_npu_state_r = (result_wr_wait_terminal_cnt_c) ? NPU_STATE_FC2 : NPU_STATE_WAIT_FC1_2_RESULT_WR;
	npu_layer_in_progress = 3'd4;
    end
    NPU_STATE_FC2:
    begin
        nxt_npu_state_r = (fc2_terminal_cnt_c) ? NPU_STATE_WAIT_FC2_RESULT_WR : NPU_STATE_FC2;
	npu_layer_in_progress = 3'd5;
    end
    NPU_STATE_WAIT_FC2_RESULT_WR:
    begin
        nxt_npu_state_r = (result_wr_wait_terminal_cnt_c) ? NPU_STATE_SOFTMAX : NPU_STATE_WAIT_FC2_RESULT_WR;
	npu_layer_in_progress = 3'd5;
    end
    NPU_STATE_SOFTMAX:
    begin
        nxt_npu_state_r = (softmax_result_valid_p) ? NPU_STATE_DONE : NPU_STATE_SOFTMAX;
	npu_layer_in_progress = 3'd6;
    end
    NPU_STATE_DONE:
    begin
	// be in DONE state till a new image write starts
        nxt_npu_state_r = (cfg_write_row_p) ? NPU_STATE_IDLE : NPU_STATE_DONE;
	npu_layer_in_progress = 3'd7;
    end
    default:
    begin
        nxt_npu_state_r = NPU_STATE_IDLE;
	npu_layer_in_progress = 3'd0;
    end
    endcase
end

end	

endmodule
