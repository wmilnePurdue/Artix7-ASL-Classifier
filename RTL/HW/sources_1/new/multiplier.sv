`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2025 10:15:02 PM
// Design Name: 
// Module Name: multiplier
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


module multiplier(
    input               clk,
    input               resetn,
		                
    input [31:0]        A_i,
    input [31:0]        B_i,

    input               enable_i,
    input               up_or_low_i,
    input               sign_i,

    output logic [31:0] Product,
    output logic        ready_o
);

typedef enum bit[1:0] {
   IDLE        = 2'b00,
   EXECUTE     = 2'b01,
   PRODUCT_RES = 2'b10,
   OUTPUT      = 2'b11
} state_t; 

state_t mult_state;
state_t mult_state_nxt;

logic [31:0] A_r;
logic [31:0] B_r;
logic        sign_r;
logic        sign_res_r;
logic        up_or_low_r;

logic [4:0]  ctr_c;
logic [4:0]  ctr_r;
logic [4:0]  ctr_dup_r;
logic [31:0] CarryInterim;
logic [63:0] ProductInterim;

wire  [31:0] C_w;
wire  [31:0] P_w;
wire  [62:0] ProductInterim_Neg;
wire  [31:0] Pf_w;

assign ProductInterim_Neg = ~ProductInterim[62:0] + 1'b1;

always_comb begin
    mult_state_nxt = mult_state;
    case(mult_state)
        IDLE: begin
            if(enable_i) begin
                mult_state_nxt = EXECUTE;
            end
        end
        EXECUTE: begin
            if(ctr_r == 5'h1_F) begin
                mult_state_nxt = PRODUCT_RES;
            end
        end
        PRODUCT_RES: begin
            mult_state_nxt = OUTPUT;
        end
        OUTPUT: begin
            mult_state_nxt = IDLE;
        end
    endcase
end

always_ff @(posedge clk, negedge resetn) begin
    if(~resetn) begin
        mult_state <= IDLE;
    end
    else begin
        mult_state <= mult_state_nxt;
    end
end

always_comb begin
    ctr_c = ctr_r;
    if(mult_state == IDLE) begin
        ctr_c = 5'h0;
    end
    else if (mult_state == EXECUTE && (ctr_r != 5'h1F))begin
		ctr_c = ctr_r + 1'b1;
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        ctr_r     <= 5'h0;
        ctr_dup_r <= 5'h0;
    end
    else begin
        // if(mult_state == IDLE) begin
        //     ctr_r <= 5'h0;
        // end
        // else if(mult_state == EXECUTE && (ctr_r != 5'h1_F)) begin
        //     ctr_r <= ctr_r + 1'b1;
        // end
        ctr_r     <= ctr_c;
        ctr_dup_r <= ctr_c;
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        A_r         <= {32{1'b0}};
        B_r         <= {32{1'b0}};
        sign_r      <= 1'b0;
        sign_res_r  <= 1'b0;
        up_or_low_r <= 1'b0;
        Product     <= {32{1'b0}};
        ready_o     <= 1'b0;
    end
    else begin
        if(mult_state == IDLE) begin
            if(enable_i) begin
                sign_r      <= sign_i;
                sign_res_r  <= A_i[31] != B_i[31];
                up_or_low_r <= up_or_low_i;

                if(A_i[31] & sign_i) begin
                    A_r[30:0] <= ~A_i[30:0] + 1'b1;
                    A_r[31]   <= 1'b0;
                end
                else begin
                    A_r       <= A_i;
                end
			    
                if(B_i[31] & sign_i) begin
                    B_r[30:0] <= ~B_i[30:0] + 1'b1;
                    B_r[31]   <= 1'b0;
                end
                else begin
                    B_r       <= B_i;
                end
            end
        end

        if(mult_state == OUTPUT) begin
            ready_o <= 1'b1;
            case({(sign_r & sign_res_r), up_or_low_r, ProductInterim[63]})
                3'b000: Product <= ProductInterim[31:0];
                3'b001: Product <= ProductInterim[31:0];
                3'b010: Product <= ProductInterim[63:0];
                3'b011: Product <= ProductInterim[63:0];
                3'b100: Product <= ProductInterim[31:0];
                3'b101: Product <= ProductInterim_Neg[31:0];
                3'b111: Product <= {1'b1, ProductInterim_Neg[62:32]};
            endcase
        end
        else begin
            ready_o = 1'b0;
        end
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        ProductInterim <= {64{1'b0}};
        CarryInterim   <= {32{1'b0}};
    end
    else begin
        case(mult_state)
            IDLE: begin 
                  ProductInterim <= 64'h0;
                  CarryInterim   <= 32'h0;
            end
            EXECUTE: begin
                CarryInterim <= C_w;
                case(ctr_dup_r)
                    5'b0_0000: ProductInterim[31: 0] <= P_w;
                    5'b0_0001: ProductInterim[32: 1] <= P_w;
                    5'b0_0010: ProductInterim[33: 2] <= P_w;
                    5'b0_0011: ProductInterim[34: 3] <= P_w;
                    5'b0_0100: ProductInterim[35: 4] <= P_w;
                    5'b0_0101: ProductInterim[36: 5] <= P_w;
                    5'b0_0110: ProductInterim[37: 6] <= P_w;
                    5'b0_0111: ProductInterim[38: 7] <= P_w;
                    5'b0_1000: ProductInterim[39: 8] <= P_w;
                    5'b0_1001: ProductInterim[40: 9] <= P_w;
                    5'b0_1010: ProductInterim[41:10] <= P_w;
                    5'b0_1011: ProductInterim[42:11] <= P_w;
                    5'b0_1100: ProductInterim[43:12] <= P_w;
                    5'b0_1101: ProductInterim[44:13] <= P_w;
                    5'b0_1110: ProductInterim[45:14] <= P_w;
                    5'b0_1111: ProductInterim[46:15] <= P_w;
                    5'b1_0000: ProductInterim[47:16] <= P_w;
                    5'b1_0001: ProductInterim[48:17] <= P_w;
                    5'b1_0010: ProductInterim[49:18] <= P_w;
                    5'b1_0011: ProductInterim[50:19] <= P_w;
                    5'b1_0100: ProductInterim[51:20] <= P_w;
                    5'b1_0101: ProductInterim[52:21] <= P_w;
                    5'b1_0110: ProductInterim[53:22] <= P_w;
                    5'b1_0111: ProductInterim[54:23] <= P_w;
                    5'b1_1000: ProductInterim[55:24] <= P_w;
                    5'b1_1001: ProductInterim[56:25] <= P_w;
                    5'b1_1010: ProductInterim[57:26] <= P_w;
                    5'b1_1011: ProductInterim[58:27] <= P_w;
                    5'b1_1100: ProductInterim[59:28] <= P_w;
                    5'b1_1101: ProductInterim[60:29] <= P_w;
                    5'b1_1110: ProductInterim[61:30] <= P_w;
                    5'b1_1111: ProductInterim[62:31] <= P_w;
                endcase
            end
            PRODUCT_RES: begin
                // ProductInterim[63:32] <= P_w;
                ProductInterim[63:32] <= Pf_w;
            end
        endcase
    end
end

for(genvar i0 = 0; i0 < 32; i0++) begin : MULT_GENERATE

    logic m_A;
    logic m_B;
    logic m_Si;
    logic m_Ci;

    always_comb begin
        m_A  = 1'b0;
        m_B  = 1'b0;
        m_Si = 1'b0;
        m_Ci = 1'b0;
        if(mult_state == EXECUTE) begin
            m_A = A_r[i0];
            m_B = B_r[ctr_r];
            if(ctr_r != 5'h0) begin
                m_Si = ProductInterim[{1'b0, ctr_dup_r} + i0];
                m_Ci = CarryInterim[i0];
            end
        end
    end
 
    mult_core u_MULTCORE0 (
        .A_i  (m_A     ),
        .B_i  (m_B     ),
    				   
        .SP_i (m_Si    ),
        .C_i  (m_Ci    ),
						           
        .P_o  (P_w[i0] ),
        .C_o  (C_w[i0] )
    ); 
end

// synthesis translate_off
wire [31:0] Pp_w = P_w;
wire AreEqual = (Pf_w == Pp_w) & (mult_state == PRODUCT_RES);
// synthesis translate_on

mult_csa32 MULT_FINAL (
    .C_i    (CarryInterim          ),  // Carry
    .SP_i   (ProductInterim[63:32] ), // Product

    .P_o    (Pf_w                  )
);


endmodule
