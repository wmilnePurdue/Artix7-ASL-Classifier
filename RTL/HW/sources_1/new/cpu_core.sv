`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2025 04:16:53 PM
// Design Name: 
// Module Name: cpu_core
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


module cpu_core # (
    parameter AWID = 12
)(
    input             clk,
    input             resetn,

    output [31:0]     ahb_haddr_o,
    output            ahb_hwrite_o,
    output [2:0]      ahb_hsize_o,
    output [2:0]      ahb_hburst_o,
    output [3:0]      ahb_hprot_o,
    output [1:0]      ahb_htrans_o,
    output            ahb_hmastlock_o,
    output [31:0]     ahb_hwdata_o,

    input             ahb_hready_i,
    input             ahb_hresp_i,
    input  [31:0]     ahb_hrdata_i
);

wire [31:0]     imem_rddata;
wire [AWID-1:0] imem_addr;
wire            imem_rden;

wire [31:0]     dmem_rddata;
wire [AWID-1:0] dmem_addr;
wire            dmem_wren;
wire [3:0]      dmem_byteen;
wire [31:0]     dmem_wrdata;

// SIGNAL source: FETCH module
wire        inst_valid;
wire [31:0] inst;
wire [18:0] nxt_pc;

// SIGNAL source: DECODE/ISSUE module
wire        read_inst; 
wire        div_mult_func; 
wire        exe_math_sign; 
wire        issue_inst;
wire [4:0]  opcode;
wire [31:0] operand_0;
wire [31:0] operand_1;
wire [18:0] jump_addr;
wire [18:0] nxt_pc_passthrough;

// SIGNAL source: EXECUTE module
wire        wr_pc;  
wire [18:0] new_pc; 
wire        commit_inst;
wire [31:0] alu_data;
wire [3:0]  alu_byteen;

wire [31:0] arb_addr;
wire [31:0] arb_wrdata;
wire [3:0]  arb_byte_en;
wire        arb_wr_en;
wire        arb_rd_en;

wire        mult_en;
wire        div_en;
wire        div_mult_passthrough;
wire        sign_passthrough;
wire [31:0] op0_passthrough;
wire [31:0] op1_passthrough;

// SIGNAL source: MULTIPLIER module
wire        mult_ready;
wire [31:0] mult_data;

// SIGNAL source: DIVIDER module
wire        div_ready;
wire [31:0] div_data;

// SIGNAL source: ARBITER module
wire        arb_ready;
wire [31:0] arb_rddata;



cpu_fetch # (
    .AWID          (AWID               )
) FETCH_UNIT (                                     
    .clk           (clk                ),
    .resetn        (resetn             ),
								       
    .wr_pc_i       (wr_pc              ),
    .pc_i          (new_pc             ),
    .read_inst_i   (read_inst          ),
								       
    .inst_valid_o  (inst_valid         ),
    .inst_o        (inst               ),
								       
    .mem_data_i    (imem_rddata        ),
    .mem_addr_o    (imem_addr          ),
    .mem_rden_o    (imem_rden          ),
    .nxt_pc        (nxt_pc             )
);

cpu_decode_issue DECODE_ISSUE (
    .clk           (clk                ),
    .resetn        (resetn             ),
				 			           
    .inst_valid_i  (inst_valid         ),
    .inst_i        (inst               ),
    .pc_i          (nxt_pc             ),
				 			           
    .commit_i      (commit_inst        ), 
    .return_data   (alu_data           ),
    .byte_i        (alu_byteen         ),
				 				       
    .div_mult_o    (div_mult_func      ),
    .sign_o        (exe_math_sign      ),
    .read_inst_o   (read_inst          ),
    .issue_o       (issue_inst         ),
    .opcode_o      (opcode             ),
    .op0_o         (operand_0          ),
    .op1_o         (operand_1          ),
    .jump_addr_o   (jump_addr          ),
    .pc_o          (nxt_pc_passthrough )
);

cpu_execute_mem ALUMEM (
    .clk            (clk                  ),
    .resetn         (resetn               ),
										  
    .issue_i        (issue_inst           ),
    .opcode_i       (opcode               ),
    .op0_i          (operand_0            ),
    .op1_i          (operand_1            ),
    .jump_addr_i    (jump_addr            ),
    .pc_i           (nxt_pc_passthrough   ),
										  
    .div_mult_sel_i (div_mult_func        ),
    .sign_i         (exe_math_sign        ),
    .mult_ready_i   (mult_ready           ),
    .mult_data_i    (mult_data            ),
    .div_ready_i    (div_ready            ),
    .div_data_i     (div_data             ),
										  
    .commit_o       (commit_inst          ),
    .result_o       (alu_data             ),
    .result_byte_o  (alu_byteen           ),
										  
    .jump_addr_o    (new_pc               ),
    .wr_pc_o        (wr_pc                ),
										  
    .mem_ready_i    (arb_ready            ),
    .mem_rddata_i   (arb_rddata           ),
										  
    .mem_addr_o     (arb_addr             ),
    .mem_wrdata_o   (arb_wrdata           ),
    .mem_byte_en_o  (arb_byte_en          ),
    .mem_wr_en_o    (arb_wr_en            ),
    .mem_rd_en_o    (arb_rd_en            ),
										  
    .mult_en_o      (mult_en              ),
    .div_en_o       (div_en               ),
    .div_mult_sel_o (div_mult_passthrough ),
    .sign_o         (sign_passthrough     ),

    .op0_o          (op0_passthrough      ),
    .op1_o          (op1_passthrough      )
);

multiplier MULT_UNIT (
    .clk            (clk                  ),
    .resetn         (resetn               ),
		                
    .A_i            (op0_passthrough      ),
    .B_i            (op1_passthrough      ),

    .enable_i       (mult_en              ),
    .up_or_low_i    (div_mult_passthrough ),
    .sign_i         (sign_passthrough     ),

    .Product        (mult_data            ),
    .ready_o        (mult_ready           )
);

divider DIV_UNIT(
    .clk              (clk                  ),
    .resetn           (resetn               ),
				          
    .A_i              (op0_passthrough      ),
    .B_i              (op1_passthrough      ),
    .enable_i         (div_en               ),
    .div_or_rem_sel_i (div_mult_passthrough ),
    .sign_i           (sign_passthrough     ),

    .QR               (div_data             ),
    .ready_o          (div_ready            )
);

dmem_ahb_arbiter #(
    .AWID ( AWID )
) MEM_AHB_ARBITER (
    .clk               (clk                  ),
    .resetn            (resetn               ),
					   
    .cpu_mem_ready_o   (arb_ready            ),
    .cpu_mem_rddata_o  (arb_rddata           ),
					   
    .cpu_mem_addr_i    (arb_addr             ),
    .cpu_mem_wrdata_i  (arb_wrdata           ),
    .cpu_mem_byte_en_i (arb_byte_en          ),
    .cpu_mem_wr_en_i   (arb_wr_en            ),
    .cpu_mem_rd_en_i   (arb_rd_en            ),

    .dmem_rddata       (dmem_rddata          ),
    .dmem_addr         (dmem_addr            ),
    .dmem_wren         (dmem_wren            ),
    .dmem_byteen       (dmem_byteen          ),
    .dmem_wrdata       (dmem_wrdata          ),

    .ahb_haddr_o       (ahb_haddr_o          ),
    .ahb_hwrite_o      (ahb_hwrite_o         ),
    .ahb_hsize_o       (ahb_hsize_o          ),
    .ahb_hburst_o      (ahb_hburst_o         ),
    .ahb_hprot_o       (ahb_hprot_o          ),
    .ahb_htrans_o      (ahb_htrans_o         ),
    .ahb_hmastlock_o   (ahb_hmastlock_o      ),
    .ahb_hwdata_o      (ahb_hwdata_o         ),

    .ahb_hready_i      (ahb_hready_i         ),
    .ahb_hresp_i       (ahb_hresp_i          ),
    .ahb_hrdata_i      (ahb_hrdata_i         )
);

sys_mem MEM (
    .clka  (clk         ),
    .ena   (imem_rden   ),
    .wea   (4'h0        ),
    .addra (imem_addr   ),
    .dina  (32'h0       ),
	.douta (imem_rddata ),

    .clkb  (clk         ),
    .web   ({dmem_byteen[3] & dmem_wren,
             dmem_byteen[2] & dmem_wren,
             dmem_byteen[1] & dmem_wren,
             dmem_byteen[0] & dmem_wren}),
// Truncate to 512 x 32 access
    .addrb ({3'b111,  dmem_addr[8:0]}),
    .dinb  (dmem_wrdata ),
    .doutb (dmem_rddata )
    
);

endmodule
