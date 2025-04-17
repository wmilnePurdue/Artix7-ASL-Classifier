`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2025 11:11:38 PM
// Design Name: 
// Module Name: i2c_io
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


module i2c_io(
    input         clk,
    input         resetn,
		          
    input         start_en,
    input [7:0]   i2c_addr_i,
    input [7:0]   i2c_data_i,
    input [31:0]  delay_i,
				  
    output logic  ready_o,
				  
    inout         i2c_scl,
    inout         i2c_sda
);

localparam [7:0] CAMERA_ADDR = 8'h42;

typedef enum bit[3:0] {
   I2C_IDLE         = 4'h0,
   I2C_START_SIGNAL = 4'h1,
   I2C_LOAD_BYTE    = 4'h2,
   I2C_TX_BYTE_1    = 4'h3,
   I2C_TX_BYTE_2    = 4'h4,
   I2C_TX_BYTE_3    = 4'h5,
   I2C_TX_BYTE_4    = 4'h6,
   I2C_END_SIGNAL_1 = 4'h7,
   I2C_END_SIGNAL_2 = 4'h8,
   I2C_END_SIGNAL_3 = 4'h9,
   I2C_END_SIGNAL_4 = 4'hA,
   I2C_DONE         = 4'hB,
   I2C_TIMER        = 4'hC
} i2c_state_t;

i2c_state_t i2c_state;
i2c_state_t i2c_state_ret;

logic [31:0] timer;
logic [1:0]  byte_counter;
logic [7:0]  tx_byte;
logic [3:0]  byte_index;

logic        SIOC_oe;
logic        SIOD_oe;

IOBUF SCL_IO (
    .T  (~SIOC_oe ),
    .I  (1'b0     ),
    .O  (         ),
    .IO (i2c_scl  )
); 

IOBUF SDA_IO (
    .T  (~SIOD_oe ),
    .I  (1'b0     ),
    .O  (         ),
    .IO (i2c_sda  )
); 

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        timer         <= 32'h0;
		byte_counter  <= 2'b00;
        tx_byte       <= 8'h0;
        byte_index    <= 4'h0;
					  
        SIOC_oe       <= 1'b0;
        SIOD_oe       <= 1'b0;

        i2c_state     <= I2C_IDLE;
        i2c_state_ret <= I2C_IDLE;

        ready_o       <= 1'b1;
    end
    else begin
        case(i2c_state)
            I2C_IDLE : begin
                if(start_en) begin
                    i2c_state    <= I2C_START_SIGNAL;
                    byte_index   <= 1'b0;
                    byte_counter <= 1'b0;
                    ready_o      <= 1'b0;
                end
            end

            I2C_START_SIGNAL : begin
                i2c_state     <= I2C_TIMER;
                i2c_state_ret <= I2C_LOAD_BYTE;
                timer         <= delay_i;
                SIOC_oe       <= 0;
                SIOD_oe       <= 1;
            end

            I2C_LOAD_BYTE: begin //load next byte to be transmitted
                i2c_state    <= (byte_counter == 3) ? I2C_END_SIGNAL_1 : I2C_TX_BYTE_1;
                byte_counter <= byte_counter + 1;
                byte_index   <= 0; //clear byte index
                case(byte_counter)
                    0: tx_byte <= CAMERA_ADDR;
                    1: tx_byte <= i2c_addr_i;
                    2: tx_byte <= i2c_data_i;
                    default: tx_byte <= i2c_data_i;
                endcase
            end

            I2C_TX_BYTE_1: begin //bring SIOC low and and delay for next state 
                i2c_state     <= I2C_TIMER;
                i2c_state_ret <= I2C_TX_BYTE_2;
                timer         <= delay_i;
                SIOC_oe       <= 1; 
            end

            I2C_TX_BYTE_2: begin //assign output data, 
                i2c_state     <= I2C_TIMER;
                i2c_state_ret <= I2C_TX_BYTE_3;
                timer         <= delay_i; //delay for SIOD to stabilize
                SIOD_oe       <= (byte_index == 8) ? 0 : ~tx_byte[7]; //allow for 9 cycle ack, output enable signal is inverting
            end

            I2C_TX_BYTE_3: begin // bring SIOC high 
                i2c_state     <= I2C_TIMER;
                i2c_state_ret <= I2C_TX_BYTE_4;
//                timer <= (CLK_FREQ/(2*SCCB_FREQ));
                timer         <= {delay_i[31:1], 1'b0};
                SIOC_oe       <= 0; //output enable is an inverting pulldown
            end

            I2C_TX_BYTE_4: begin //check for end of byte, incriment counter
                i2c_state    <= (byte_index == 8) ? I2C_LOAD_BYTE : I2C_TX_BYTE_1;
                tx_byte      <= tx_byte<<1; //shift in next data bit
                byte_index   <= byte_index + 1;
            end

            I2C_END_SIGNAL_1: begin //state is entered with SIOC high, SIOD high. Start by bringing SIOC low
                i2c_state     <= I2C_TIMER;
                i2c_state_ret <= I2C_END_SIGNAL_2;
                timer         <= delay_i;
                SIOC_oe       <= 1;
            end

            I2C_END_SIGNAL_2: begin // while SIOC is low, bring SIOD low 
                i2c_state     <= I2C_TIMER;
                i2c_state_ret <= I2C_END_SIGNAL_3;
                timer         <= delay_i;
                SIOD_oe       <= 1;
            end
            
            I2C_END_SIGNAL_3: begin // bring SIOC high
                i2c_state     <= I2C_TIMER;
                i2c_state_ret <= I2C_END_SIGNAL_4;
                timer         <= delay_i;
                SIOC_oe       <= 0;
            end
            
            I2C_END_SIGNAL_4: begin // bring SIOD high when SIOC is high
                i2c_state     <= I2C_TIMER;
                i2c_state_ret <= I2C_DONE;
                timer         <= delay_i;
                SIOD_oe       <= 0;
            end
            
            I2C_DONE: begin //add delay between transactions
                ready_o       <= 1'b1;
                if(~start_en) begin
                    i2c_state <= I2C_IDLE;
                end
            end

            I2C_TIMER: begin
                if(timer == 32'h0) begin
                    i2c_state <= i2c_state_ret;
                end
                else begin
                    timer <= timer - 1'b1;
                end
            end
        endcase
    end
end

endmodule
