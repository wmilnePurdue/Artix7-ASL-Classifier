`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2025 08:28:21 PM
// Design Name: 
// Module Name: ahb_master
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


module ahb_master(
    input                clk,
    input                resetn,

    output logic [31:0]  ahb_haddr_o,
    output logic         ahb_hwrite_o,
    output logic [2:0]   ahb_hsize_o,
    output logic [2:0]   ahb_hburst_o,
    output logic [3:0]   ahb_hprot_o,
    output logic [1:0]   ahb_htrans_o,
    output logic         ahb_hmastlock_o,
    output logic [31:0]  ahb_hwdata_o,
    output wire [1:0]   test_img_index_o,

    input                ahb_hready_i,
    input                ahb_hresp_i,
    input  [31:0]        ahb_hrdata_i
);

// AHB-L definitions

// HTRANS
localparam [1:0] HTRANS_IDLE   = 2'b00;
localparam [1:0] HTRANS_BUSY   = 2'b01;
localparam [1:0] HTRANS_NSEQ   = 2'b10;
localparam [1:0] HTRANS_SEQ    = 2'b11;

// HSIZE
localparam [2:0] HSIZE_8       = 3'b000;
localparam [2:0] HSIZE_16      = 3'b001;
localparam [2:0] HSIZE_32      = 3'b010;

logic [31:0] rd_data;
logic [4:0] test_img_cnt;
logic [4:0] test_success_cnt;

reg [7:0] rgb_mem_test [3072-1:0];
parameter MEM_INIT_FILE_0  = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/a/hand1_a_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_1  = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/b/hand1_b_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_2  = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/c/hand1_c_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_3  = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/d/hand1_d_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_4  = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/e/hand1_e_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_5  = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/f/hand1_f_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_6  = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/g/hand1_g_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_7  = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/h/hand1_h_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_8  = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/i/hand1_i_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_9  = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/k/hand1_k_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_10 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/l/hand1_l_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_11 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/m/hand1_m_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_12 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/n/hand1_n_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_13 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/o/hand1_o_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_14 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/p/hand1_p_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_15 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/q/hand1_q_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_16 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/r/hand1_r_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_17 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/s/hand1_s_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_18 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/t/hand1_t_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_19 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/u/hand1_u_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_20 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/v/hand1_v_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_21 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/w/hand1_w_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_22 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/x/hand1_x_bot_seg_1_cropped_aug1.hex";
parameter MEM_INIT_FILE_23 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/train_img_augmented_hex/y/hand1_y_bot_seg_1_cropped_aug1.hex";
                           
// parameter MEM_INIT_FILE_0 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/a.hex";
// parameter MEM_INIT_FILE_1 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/b.hex";
// parameter MEM_INIT_FILE_2 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/c.hex";
// parameter MEM_INIT_FILE_3 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/d.hex";
// parameter MEM_INIT_FILE_4 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/e.hex";
// parameter MEM_INIT_FILE_5 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/f.hex";
// parameter MEM_INIT_FILE_6 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/g.hex";
// parameter MEM_INIT_FILE_7 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/h.hex";
// parameter MEM_INIT_FILE_8 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/i.hex";
// parameter MEM_INIT_FILE_9 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/k.hex";
// parameter MEM_INIT_FILE_10 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/l.hex";
// parameter MEM_INIT_FILE_11 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/m.hex";
// parameter MEM_INIT_FILE_12 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/n.hex";
// parameter MEM_INIT_FILE_13 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/o.hex";
// parameter MEM_INIT_FILE_14 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/p.hex";
// parameter MEM_INIT_FILE_15 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/q.hex";
// parameter MEM_INIT_FILE_16 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/r.hex";
// parameter MEM_INIT_FILE_17 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/s.hex";
// parameter MEM_INIT_FILE_18 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/t.hex";
// parameter MEM_INIT_FILE_19 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/u.hex";
// parameter MEM_INIT_FILE_20 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/v.hex";
// parameter MEM_INIT_FILE_21 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/w.hex";
// parameter MEM_INIT_FILE_22 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/x.hex";
// parameter MEM_INIT_FILE_23 = "D:/Devendra/Purdue_MS/Courses/Embedded_Systems/Project/HandDetect_SoC/Artix7-ASL-Classifier/hex_test_img2_resize_quant2/y.hex";
assign test_img_index_o = test_img_cnt[1:0];
 
initial begin

    ahb_haddr_o      <= '0;
    ahb_hwrite_o     <= '0;
    ahb_hsize_o      <= '0;
    ahb_hburst_o     <= '0;
    ahb_hprot_o      <= '0;
    ahb_htrans_o     <= HTRANS_IDLE;
    ahb_hmastlock_o  <= '0;
    ahb_hwdata_o     <= '0;
    test_img_cnt     <= 5'd0;
    test_success_cnt <= 5'd0;
   
    @(posedge resetn);
    @(posedge clk);
    // ahb_write(32'h8000_0004, 8'h1);
    // ahb_write(32'h8000_0000, 8'h1);
    // ahb_read(32'h8000_2000);
    /* perform test writes and reads here */
    ahb_write(32'h8000_0004,32'd32);
    while(test_img_cnt!=24)
    begin
       case(test_img_cnt)
       5'd0: $readmemh(MEM_INIT_FILE_0, rgb_mem_test);
       5'd1: $readmemh(MEM_INIT_FILE_1, rgb_mem_test);
       5'd2: $readmemh(MEM_INIT_FILE_2, rgb_mem_test);
       5'd3: $readmemh(MEM_INIT_FILE_3, rgb_mem_test);
       5'd4: $readmemh(MEM_INIT_FILE_4, rgb_mem_test);
       5'd5: $readmemh(MEM_INIT_FILE_5, rgb_mem_test);
       5'd6: $readmemh(MEM_INIT_FILE_6, rgb_mem_test);
       5'd7: $readmemh(MEM_INIT_FILE_7, rgb_mem_test);
       5'd8: $readmemh(MEM_INIT_FILE_8, rgb_mem_test);
       5'd9: $readmemh(MEM_INIT_FILE_9, rgb_mem_test);
       5'd10: $readmemh(MEM_INIT_FILE_10, rgb_mem_test);
       5'd11: $readmemh(MEM_INIT_FILE_11, rgb_mem_test);
       5'd12: $readmemh(MEM_INIT_FILE_12, rgb_mem_test);
       5'd13: $readmemh(MEM_INIT_FILE_13, rgb_mem_test);
       5'd14: $readmemh(MEM_INIT_FILE_14, rgb_mem_test);
       5'd15: $readmemh(MEM_INIT_FILE_15, rgb_mem_test);
       5'd16: $readmemh(MEM_INIT_FILE_16, rgb_mem_test);
       5'd17: $readmemh(MEM_INIT_FILE_17, rgb_mem_test);
       5'd18: $readmemh(MEM_INIT_FILE_18, rgb_mem_test);
       5'd19: $readmemh(MEM_INIT_FILE_19, rgb_mem_test);
       5'd20: $readmemh(MEM_INIT_FILE_20, rgb_mem_test);
       5'd21: $readmemh(MEM_INIT_FILE_21, rgb_mem_test);
       5'd22: $readmemh(MEM_INIT_FILE_22, rgb_mem_test);
       5'd23: $readmemh(MEM_INIT_FILE_23, rgb_mem_test);
       endcase
       for(integer i0 = 0; i0 < 4; i0 = i0+1) begin
          for(integer i1 = 0; i1 < 32; i1 = i1 + 1) begin
            ahb_write(32'h8000_2000 + i0*32 + i1, rgb_mem_test[(i0*32)+i1]); 
            ahb_write(32'h8000_2400 + i0*32 + i1, rgb_mem_test[((i0+32)*32)+i1]); 
            ahb_write(32'h8000_2800 + i0*32 + i1, rgb_mem_test[((i0+64)*32)+i1]); 
          end
          ahb_write(32'h8000_0000, 32'h1);
        end
       ahb_read(32'h8000_1000);
       while(rd_data[0] != 1'b1) ahb_read(32'h8000_1000);
       ahb_read(32'h8000_1004);
       $display("Expected Label =%d Predicated Label =%d\n",test_img_cnt,rd_data[4:0]);
       test_success_cnt <= (test_img_cnt == rd_data[4:0]) ? test_success_cnt + 1 : test_success_cnt;
       test_img_cnt <= test_img_cnt + 5'd1;       
    end 
    $stop;
end

task ahb_write(input [31:0] addr, input [31:0] wdata);
    begin
        ahb_haddr_o  <= addr;
        ahb_hwrite_o <= 1'b1;
        ahb_htrans_o <= HTRANS_NSEQ;
        @(posedge clk);
        #0.1;
        ahb_htrans_o <= HTRANS_IDLE;
        ahb_hwrite_o <= 1'b0;
        ahb_hwdata_o <= wdata;
        while(!ahb_hready_i) @(posedge clk);
    end
endtask

task ahb_read(input [31:0] addr);
    begin
        ahb_haddr_o  <= addr;
        ahb_hwrite_o <= 1'b0;
        ahb_htrans_o <= HTRANS_NSEQ;
        @(posedge clk);
        #0.1;
        ahb_htrans_o <= HTRANS_IDLE;
        while(!ahb_hready_i) @(posedge clk);
        rd_data <= ahb_hrdata_i;
        @(posedge clk);
    end
endtask


endmodule
