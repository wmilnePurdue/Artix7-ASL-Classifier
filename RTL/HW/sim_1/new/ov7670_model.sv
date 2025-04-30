`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2025 04:39:35 PM
// Design Name: 
// Module Name: ov7670_model
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


module ov7670_model(
    input xclk,
    input reset,

	output logic       p_clock,
	output logic       vsync,
	output logic       href,
	output logic [7:0] p_data,

    input              i2c_scl,
    input              i2c_sda
);

localparam TP          = 2;
localparam TLINE       = 784 * TP;
localparam TDEL_V2H    = 17 * TLINE;
localparam TVSYNC      = 3 * TLINE;
localparam TDEL_H2V    = 10 * TLINE;
localparam V_LINE      = 480;
localparam H_LINE      = 640;
localparam H_DELAY     = 144*TP;
localparam CORRUPT_EN  = 0;
localparam CORRUPT_CNT = 100;

logic [3:0]  counter;
logic [23:0] mem_src [307200-1:0];
logic [18:0] addr;
logic [23:0] mem_ptr;
logic [31:0] href_ctr;

logic        trig_received = 1'b0;
wire [15:0]  i2c_out;

assign mem_ptr = mem_src[addr];

always_ff @ (posedge xclk) begin
    if(~trig_received) begin
        trig_received <= (i2c_out == 16'h13E5);
    end
end

always_ff @ (posedge href, posedge reset) begin
    if(reset) begin
        href_ctr <= 32'h0;
    end
    else begin
        href_ctr <= href_ctr + 1'b1;
    end
end

initial begin
    $readmemh("C:/Users/Michael/Documents/ECE56800/Pictures/image.hex", mem_src);
end

initial begin
    p_clock <= 1'b0;
    forever #20 p_clock <= ~p_clock;
end

initial begin
    p_clock <= 1'b0;
    vsync   <= 1'b0;
    href    <= 1'b0;
    p_data  <= 8'h0;
    counter <= 4'h0;
    addr    <= 19'h0;
    while(reset);
    @(posedge xclk);
    while(~trig_received) @(posedge xclk);
    while(counter != 4'hF) begin
        @(posedge xclk);
        counter <= counter + 1'b1;
    end

    forever begin
        clk_delay(TDEL_H2V);
        vsync <= 1'b1;
        clk_delay(TVSYNC);
        vsync <= 1'b0;
        clk_delay(TDEL_V2H);
        for(integer i0 = 0; i0 < V_LINE; i0++) begin
            for(integer i1 = 0; i1 < H_LINE; i1++) begin
                p_data <= {1'b0, mem_ptr[23:19], mem_ptr[15:14]};
                if((CORRUPT_EN == 1) && (i0 == V_LINE-1) && (i1 >= (H_LINE - (CORRUPT_CNT + 1)))) begin
				    href   <= 1'b0;
                end
                else begin
                    href   <= 1'b1;
                end
                @(posedge p_clock);
                p_data <= {mem_ptr[13:11], mem_ptr[7:3]};
                addr   <= addr + 1'b1;
                @(posedge p_clock);
            end
            href <= 1'b0;
            clk_delay(H_DELAY);
        end
        addr <= 19'h0;
        @(posedge p_clock);
    end
end

task clk_delay(input [31:0] del_cnt);
    begin
        for(integer i0 = 0; i0 < del_cnt; i0++) begin
            @(posedge p_clock);
        end
    end
endtask


sccb_decoder SCCB_DECODE (
    .i2c_scl  (i2c_scl ),
    .i2c_sda  (i2c_sda ),
					   
    .data_o   (i2c_out )
);

endmodule
