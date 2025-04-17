`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2025 09:41:47 PM
// Design Name: 
// Module Name: cpu_fetch
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


module cpu_fetch # (
    parameter AWID = 10
)(
    input                   clk,
    input                   resetn,
						    
    input                   wr_pc_i,
    input        [18:0]     pc_i,
						    
    input                   read_inst_i,
						    
    output logic            inst_valid_o,
    output       [31:0]     inst_o,    
						    
    input        [31:0]     mem_data_i,
    output       [AWID-1:0] mem_addr_o,
    output                  mem_rden_o,    

    output       [18:0]     nxt_pc
);

localparam [1:0] DELAY = 2'b11;

typedef enum bit[1:0] {
   COLD_RESET     = 2'b00,
   START_PIPELINE = 2'b01,
   IN_PIPELINE    = 2'b10
} state_t; 

state_t fetch_state;
state_t fetch_state_nxt;

logic [1:0]  counter;
logic [18:0] pc;

assign inst_o     = mem_data_i;
assign mem_addr_o = pc[AWID-1:0];
assign nxt_pc     = pc;// + 1'b1;
assign mem_rden_o = (fetch_state == START_PIPELINE) | (fetch_state == IN_PIPELINE & read_inst_i);

always_comb begin
    fetch_state_nxt = fetch_state;
    if(fetch_state == COLD_RESET) begin
        if(counter == 2'b00) begin
            fetch_state_nxt = START_PIPELINE;
        end
    end
    else if(fetch_state == START_PIPELINE) begin
        fetch_state_nxt = IN_PIPELINE;
    end
    else begin
        if(wr_pc_i) begin
            fetch_state_nxt = START_PIPELINE;
        end
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        fetch_state  <= START_PIPELINE;
        inst_valid_o <= 1'b0;
        counter      <= DELAY;
    end
    else begin
        fetch_state  <= fetch_state_nxt;
        inst_valid_o <= (fetch_state_nxt == IN_PIPELINE);
        if(counter != 2'b00) begin 
            counter <= counter - 1'b1;
        end
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        pc <= {19{1'b0}};
    end
    else begin
        if(fetch_state == COLD_RESET) begin
            pc <= {AWID{1'b0}};
        end
        else if(fetch_state == START_PIPELINE) begin
            pc <= pc + 1'b1;
        end
        else begin
            if(wr_pc_i) begin
                pc <= pc_i;
            end
            else if(read_inst_i) begin
                pc <= pc + 1'b1;
            end
        end
    end
end

endmodule
