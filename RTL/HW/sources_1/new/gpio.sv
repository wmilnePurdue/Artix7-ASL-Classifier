`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2025 10:03:42 PM
// Design Name: 
// Module Name: gpio
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

module gpio # (
    parameter OUTPUT_IO = 8,
    parameter INPUT_IO  = 8
)(                              
    input                       clk,
    input                       resetn,

    // AHB-interface
    output logic [INPUT_IO-1:0] ahbl_input_io,
    input  [INPUT_IO-1:0]       ahbl_clear_input_io,
    input  [OUTPUT_IO-1:0]      ahbl_output_io,
						        
    // External-interface       
    input  [INPUT_IO-1:0]       ext_input_io,
    output [OUTPUT_IO-1:0]      ext_output_io
);

assign ext_output_io = ahbl_output_io;

for(genvar i0 = 0; i0 < INPUT_IO; i0++) begin : IO_GEN
    logic [1:0] cdc_sync;

    always_ff @ (posedge clk, negedge resetn) begin
        if(~resetn) begin
            ahbl_input_io[i0] <= 1'b0;
            cdc_sync          <= 2'b00;
        end
        else begin
            cdc_sync[0]       <= ext_input_io[i0];
            cdc_sync[1]       <= cdc_sync[0];
            ahbl_input_io[i0] <= cdc_sync[1];
            // if(ahbl_clear_input_io[i0]) begin
            //     ahbl_input_io[i0] <= 1'b0;
            //     cdc_sync          <= 2'b00;
            // end
            // else if(~ahbl_input_io[i0]) begin
            //     cdc_sync[0]       <= ext_input_io[i0];
            //     cdc_sync[1]       <= cdc_sync[0];
            //     ahbl_input_io[i0] <= cdc_sync[1];
            // end
        end
    end
end

endmodule

/*
module gpio # (
    parameter GPIO_WIDTH = 16
)(
    input  wire [GPIO_WIDTH-1:0] gpio_write,
    input  wire [GPIO_WIDTH-1:0] gpio_status,
    output      [GPIO_WIDTH-1:0] gpio_read,
			     			     
    inout       [GPIO_WIDTH-1:0] gpio_io
);

for (genvar i0 = 0; i0 < GPIO_WIDTH; i0++) begin
    IOBUF GPIO_PIN_INST (
        .T  (gpio_status[i0] ),
        .I  (gpio_write[i0]  ),
        .O  (gpio_read[i0]   ),
        .IO (gpio_io[i0]     )
    ); 
end

endmodule
*/