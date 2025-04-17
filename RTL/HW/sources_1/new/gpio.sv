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