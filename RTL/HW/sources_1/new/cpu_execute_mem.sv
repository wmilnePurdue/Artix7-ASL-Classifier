`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2025 08:40:13 PM
// Design Name: 
// Module Name: cpu_execute_mem
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


module cpu_execute_mem (
    input               clk,
    input               resetn,
		                
    input               issue_i,
    input        [4:0]  opcode_i,
    input        [31:0] op0_i,
    input        [31:0] op1_i,
    input        [18:0] jump_addr_i,
    input        [18:0] pc_i,
    input               div_mult_sel_i,
    input               sign_i,

    input               mult_ready_i,
    input        [31:0] mult_data_i,

    input               div_ready_i,
    input        [31:0] div_data_i,

    output logic        commit_o,
    output logic [31:0] result_o,
    output logic [3:0]  result_byte_o,
    output logic [18:0] jump_addr_o,
    output logic        wr_pc_o,

    input               mem_ready_i,
    input        [31:0] mem_rddata_i,

    output logic [31:0] mem_addr_o,
    output logic [31:0] mem_wrdata_o,
    output logic [3:0]  mem_byte_en_o,
    output logic        mem_wr_en_o,
    output logic        mem_rd_en_o,

    output logic        mult_en_o,
    output logic        div_en_o,
    output logic        div_mult_sel_o,
    output logic        sign_o,

    output logic [31:0] op0_o,
    output logic [31:0] op1_o
);

`include "isa_def.vh"

logic is_ret_address_wait;

wire [31:0] add            = op0_i + op1_i;
wire [31:0] sub            = op0_i - op1_i;
wire greater_than          = op0_i > op1_i;
wire less_than             = op1_i < op1_i;
wire equal                 = op0_i == op1_i;
wire not_equal             = op0_i != op1_i;
wire [31:0] inv            = ~op0_i;
wire [31:0] and_w          = op0_i & op1_i;
wire [31:0] or_w           = op0_i | op1_i;
wire [31:0] srr_w          = op0_i >> op1_i[4:0];
wire [31:0] sll_w          = op0_i << op1_i[4:0];
wire [31:0] add_const      = op0_i + jump_addr_i[13:0];
wire [31:0] sub_const      = op0_i - jump_addr_i[13:0];
wire [31:0] add_const_addr = op1_i + jump_addr_i[13:0];
wire [31:0] sub_const_addr = op1_i - jump_addr_i[13:0];
wire [31:0] srr_const      = op0_i >> jump_addr_i[4:0];
wire [31:0] sll_const      = op0_i << jump_addr_i[4:0];

wire LW_def = (opcode_i[4:3] == LW);
wire SW_def = (opcode_i[4:3] == SW);

typedef enum bit[1:0] {
   IDLE      = 2'b00,
   EXECUTE   = 2'b01,
   MEM_WAIT  = 2'b10,
   LONG_INST = 2'b11
} state_t; 

state_t execute_state;
state_t execute_state_nxt;

always_comb begin
    execute_state_nxt = execute_state;
    if(execute_state == IDLE) begin
        if(issue_i) begin
            if(LW_def | SW_def | opcode_i == RET | opcode_i == CALL) begin
                execute_state_nxt = MEM_WAIT;
            end
            else if(opcode_i == MULT | opcode_i == DIV) begin
                execute_state_nxt = LONG_INST;
            end 
            else begin
                execute_state_nxt = EXECUTE;
            end
        end
    end
    else if(execute_state == EXECUTE) begin
        execute_state_nxt = IDLE;
    end
    else if(execute_state == MEM_WAIT) begin
        if(mem_ready_i) begin
            execute_state_nxt = IDLE;
        end
    end
    else if(execute_state == LONG_INST) begin
        if(mult_ready_i | div_ready_i) begin
            execute_state_nxt = IDLE;
        end
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        execute_state <= IDLE;
    end
    else begin
        execute_state <= execute_state_nxt;
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        is_ret_address_wait <= 1'b0;
    end
    else begin
        if(execute_state == IDLE) begin
            is_ret_address_wait <= issue_i & (opcode_i == RET | opcode_i == CALL);
        end
        else if(execute_state == MEM_WAIT) begin
            if(mem_ready_i) begin
                is_ret_address_wait <= 1'b0;
            end
        end
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        mult_en_o      <= 1'b0;
        div_en_o       <= 1'b0;
        div_mult_sel_o <= 1'b0;
        sign_o         <= 1'b0;
        op0_o          <= {32{1'b0}};
        op1_o          <= {32{1'b0}};
    end
    else begin
        mult_en_o     <= (execute_state == IDLE & issue_i & opcode_i == MULT);
        div_en_o      <= (execute_state == IDLE & issue_i & opcode_i == DIV);
        if(execute_state == IDLE & issue_i) begin
            div_mult_sel_o <= div_mult_sel_i;
            sign_o         <= sign_i;
            op0_o          <= op0_i;
            op1_o          <= op1_i;
        end
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        result_o      <= 32'h0;
        commit_o      <= 1'b0;
        jump_addr_o   <= 19'h0;
        wr_pc_o       <= 1'b0;
        result_byte_o <= 4'b0;
    end
    else begin
        if(execute_state == MEM_WAIT) begin
            result_o <= mem_rddata_i;
            commit_o <= mem_ready_i;
            if(is_ret_address_wait) begin
                if(opcode_i == RET) begin
                    jump_addr_o <= mem_rddata_i[18:0];
                end
                wr_pc_o <= mem_ready_i;
            end
        end
        else if(execute_state == LONG_INST) begin
            if(mult_ready_i) begin
                result_o <= mult_data_i;
            end
            else if(div_ready_i) begin
                result_o <= div_data_i;
            end
            commit_o <= mult_ready_i | div_ready_i;
            result_byte_o <= 4'hF;
        end
        else begin
            jump_addr_o <= jump_addr_i;
            if(execute_state == IDLE & issue_i) begin
                commit_o <= (execute_state_nxt == EXECUTE);
                case(opcode_i)
                   JEQ :    wr_pc_o <= equal;
                   JNEQ:    wr_pc_o <= not_equal;
                   JGR:     wr_pc_o <= greater_than;
                   JLT:     wr_pc_o <= less_than;
                endcase
                case(opcode_i)
                    LW8_0  : result_byte_o <= 4'b0001;
                    LW8_1  : result_byte_o <= 4'b0010;
                    LW8_2  : result_byte_o <= 4'b0100;
                    LW8_3  : result_byte_o <= 4'b1000;
                    LW16_0 : result_byte_o <= 4'b0011;
                    LW16_1 : result_byte_o <= 4'b1100;
                    LW32   : result_byte_o <= 4'b1111;
                    ADD    : result_byte_o <= 4'b1111;
                    SUB    : result_byte_o <= 4'b1111;
                    OR     : result_byte_o <= 4'b1111;
                    INV    : result_byte_o <= 4'b1111;
                    AND    : result_byte_o <= 4'b1111;
                    SLL    : result_byte_o <= 4'b1111;
                    SRR    : result_byte_o <= 4'b1111;
                    default: result_byte_o <= 4'b0000;
                endcase
            end
            else begin
                commit_o <= 1'b0;
                wr_pc_o  <= 1'b0;
            end
            case(opcode_i)
                ADD: result_o <= jump_addr_i[14] ? add_const : add;
                SUB: result_o <= jump_addr_i[14] ? sub_const : sub;
                OR:  result_o <= or_w;
                INV: result_o <= inv;
                AND: result_o <= and_w;
                SLL: result_o <= jump_addr_i[14] ? sll_const : sll_w;
                SRR: result_o <= jump_addr_i[14] ? srr_const : srr_w;
            endcase
        end
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        mem_addr_o    <= 32'h0;
        mem_wrdata_o  <= 32'h0;
        mem_wr_en_o   <= 1'b0;
        mem_rd_en_o   <= 1'b0;
        mem_byte_en_o <= 4'b0;
    end
    else begin
        if(execute_state == IDLE & issue_i) begin
            if(opcode_i == CALL || opcode_i == RET) begin
				mem_addr_o <= op0_i;
            end
            else begin
                mem_addr_o <= jump_addr_i[14] ? add_const_addr : sub_const_addr;
            end
            if(opcode_i == CALL) begin
                mem_wrdata_o  <= {13'h0, pc_i};
                mem_byte_en_o <= 4'hF;
                mem_wr_en_o   <= 1'b1;
            end
            else if(opcode_i == RET) begin
                mem_rd_en_o <= 1'b1;
            end
            else begin
                mem_wrdata_o  <= op0_i;
                if(LW_def) begin
                    mem_wr_en_o   <= 1'b0;
                    mem_rd_en_o   <= 1'b1;
                    mem_byte_en_o <= 4'h0;
                end
                else if(SW_def) begin
                    mem_wr_en_o   <= 1'b1;
                    mem_rd_en_o   <= 1'b0;
                    case(opcode_i[2:0])
                        SW8_0 [2:0]: mem_byte_en_o <= 4'b0001;
                        SW8_1 [2:0]: mem_byte_en_o <= 4'b0010;
                        SW8_2 [2:0]: mem_byte_en_o <= 4'b0100;
                        SW8_3 [2:0]: mem_byte_en_o <= 4'b1000;
                        SW16_0[2:0]: mem_byte_en_o <= 4'b0011;
                        SW16_1[2:0]: mem_byte_en_o <= 4'b1100;
                        SW32  [2:0]: mem_byte_en_o <= 4'b1111;
                    endcase
                end
            end
        end
        else begin
            mem_wr_en_o <= 1'b0;
            mem_rd_en_o <= 1'b0;
        end
    end
end

endmodule
