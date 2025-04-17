`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2025 09:47:15 PM
// Design Name: 
// Module Name: cpu_decode_issue
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

module cpu_decode_issue(
    input               clk,
    input               resetn,
					    
    input               inst_valid_i,
    input        [31:0] inst_i,
    input        [18:0] pc_i,
					    
    input               commit_i,
    input        [31:0] return_data,
    input         [3:0] byte_i,

    output logic        div_mult_o,
    output logic        sign_o,
    output logic        read_inst_o,
    output logic        issue_o,
    output logic [4:0]  opcode_o,
    output logic [31:0] op0_o,
    output logic [31:0] op1_o,
    output logic [18:0] jump_addr_o,
    output logic [18:0] pc_o
);

`include "isa_def.vh"

typedef enum bit[0:0] {
   IDLE   = 1'b0,
   DECODE = 1'b1
} state_t; 

state_t decode_state;
state_t decode_state_nxt;

logic [3:0] dest_reg;
logic       is_waiting_return;
// logic [3:0] byte_reg;

logic       self_commit_r;

wire [31:0]  rd0_data;
wire [31:0]  rd1_data;

logic [31:0] regfile_data;
logic [3:0]  regfile_addr;
logic [3:0]  regfile_byte_en;

wire [4:0] inst_op =  inst_i[31:27];
wire       LW_def  = (inst_op[4:3] == LW) & (inst_op[2:0] != 3'b111);
wire       SW_def  = (inst_op[4:3] == SW) & (inst_op[2:0] != 3'b111);    

wire need_issue = ( inst_op == ADD    | inst_op == SUB  | inst_op == OR   | inst_op == AND  | 
                    inst_op == INV    | LW_def | SW_def | inst_op == MULT | inst_op == DIV  |
                    inst_op == SLL    | inst_op == SRR  | inst_op == JEQ  | inst_op == JNEQ |
                    inst_op == JGR    | inst_op == JLT  | inst_op == CALL | inst_op == RET );
wire no_wait    = ( inst_op == IMMI_H | inst_op == IMMI_L | inst_op == MOV );

// synthesis translate_off
typedef enum bit [4:0] {
    i_ADD     = 0 ,
    i_SUB     = 1 ,
    i_MULT    = 2 ,
    i_DIV     = 3 ,
    i_MOV     = 4 ,
    i_OR      = 5 ,
    i_AND     = 6 ,
    i_INV     = 7 ,
    i_SLL     = 8 ,
    i_SRR     = 9 ,
    i_JEQ     = 10,
    i_JNEQ    = 11,
    i_JGR     = 12,
    i_JLT     = 13,
    i_CALL    = 14,
    i_RET     = 15,
    i_SW8_0   = 16,
    i_SW8_1   = 17,
    i_SW8_2   = 18,
    i_SW8_3   = 19,
    i_SW16_0  = 20,
    i_SW16_1  = 21,
    i_SW32    = 22,
    i_IMMI_L  = 23,
    i_LW8_0   = 24,
    i_LW8_1   = 25,
    i_LW8_2   = 26,
    i_LW8_3   = 27,
    i_LW16_0  = 28,
    i_LW16_1  = 29,
    i_LW32    = 30,
    i_IMMI_H  = 31
} InstType_t;

InstType_t Inst;

assign Inst = opcode_o;

// synthesis translate_on

always_comb begin
    regfile_byte_en = 4'h0;
    regfile_addr    = 4'h0;
    regfile_data    = 32'h0;
    if(commit_i & is_waiting_return) begin
        regfile_byte_en = byte_i;
        regfile_addr    = dest_reg;
        regfile_data    = return_data;
    end
    else if(inst_valid_i && decode_state == IDLE) begin
        if(inst_op == IMMI_H) begin
            regfile_addr        = inst_i[26:23];
            regfile_byte_en     = {2'b11, {2{inst_i[16]}}};
            regfile_data[31:16] = inst_i[15:0];
        end
        else if(inst_op == IMMI_L) begin
            regfile_addr        = inst_i[26:23];
            regfile_byte_en     = {{2{inst_i[16]}}, 2'b11};
            regfile_data[15:0]  = inst_i[15:0];
        end
        else if(inst_op == MOV) begin
            regfile_addr    = inst_i[18:15];
            regfile_byte_en = 4'hF;
            regfile_data    = rd0_data;
        end
    end
end

always_comb begin
    decode_state_nxt = decode_state;
    if(decode_state == IDLE) begin
        if(inst_valid_i) begin
            decode_state_nxt = DECODE;
        end
    end
    else begin
        if(self_commit_r | commit_i) begin
            decode_state_nxt = IDLE;
        end
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        decode_state <= IDLE;
    end
    else begin
        decode_state <= decode_state_nxt;
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        is_waiting_return <= 1'b0;
        dest_reg          <= 4'h0;
//        byte_reg          <= 4'h0;
        issue_o           <= 1'b0;
        op0_o             <= 32'h0;
        op1_o             <= 32'h0;
        opcode_o          <= 5'h0;
        jump_addr_o       <= 19'h0;
        pc_o              <= 19'h0;
        div_mult_o        <= 1'b0;
        sign_o            <= 1'b0;
        read_inst_o       <= 1'b0;
        self_commit_r     <= 1'b0;
    end
    else begin
        read_inst_o <= (decode_state == IDLE & inst_valid_i);
        if(decode_state == IDLE) begin
            if(inst_valid_i) begin
                is_waiting_return <= ~no_wait;                
                issue_o           <= need_issue;
                self_commit_r     <= no_wait;
                dest_reg          <= inst_i[18:15];
                op0_o             <= rd0_data;
                op1_o             <= rd1_data;
                opcode_o          <= inst_op;
                jump_addr_o       <= inst_i[18:0];
                pc_o              <= pc_i;
                div_mult_o        <= inst_i[14];
                sign_o            <= inst_i[13];
            end
        end
        else begin
            issue_o <= 1'b0;
            if(self_commit_r | commit_i) begin
                is_waiting_return <= 1'b0;
                self_commit_r     <= 1'b0;
            end
        end
    end
end

cpu_regfile REGFILE (
    .clk         (clk             ),
							      
    .wr_addr_i   (regfile_addr    ),
    .byte_en_i   (regfile_byte_en ),            
    .wr_data_i   (regfile_data    ),            
							    
    .rd0_addr_i  (inst_i[26:23]   ),
    .rd1_addr_i  (inst_i[22:19]   ),
							      
    .rd0_data_o  (rd0_data        ),
    .rd1_data_o  (rd1_data        )
);
endmodule