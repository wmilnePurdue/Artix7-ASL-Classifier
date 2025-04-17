`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2025 10:15:02 PM
// Design Name: 
// Module Name: divider
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

// Performs A / B or A % B
module divider(
    input               clk,
    input               resetn,
				        
    input [31:0]        A_i,
    input [31:0]        B_i,
    input               enable_i,
    input               div_or_rem_sel_i,
    input               sign_i,

    output logic [31:0] QR,
    output logic        ready_o
);

typedef enum bit[1:0] {
   IDLE    = 2'b00,
   EXECUTE = 2'b01,
   OUTPUT  = 2'b10
} state_t; 



state_t divider_state;
state_t divider_state_nxt;

logic        div_or_rem_sel_r;
logic        sign_r;
logic        sign_res_r;
logic [4:0]  ctr_r;
logic [31:0] A_r;
logic [31:0] B_r;
logic [31:0] Q_r;
logic [31:0] R_r;
logic [30:0] Rsub_r;
logic        A31_r;
// logic        B31_r;

logic [31:0] QuotientInterim;
logic [31:0] RemainderInterim;

wire  [31:0] A_w;
wire  [31:0] Bo_p_w;
wire         BO_31;
// wire  [31:0] Bo_w;
wire  [31:0] R_w;
wire  [31:0] Q_c;

wire         A_ptr_w         = A_r[31-ctr_r];

always_comb begin
    QuotientInterim  = Q_r;
    RemainderInterim = R_r;

    if(sign_r) begin
        QuotientInterim [31] = sign_res_r;
        if(sign_res_r) begin
            QuotientInterim[30:0] = ~Q_r[30:0] + 1'b1;
        end

        RemainderInterim[31] = A31_r;
        if(A31_r) begin
            RemainderInterim[30:0] = ~R_r[30:0] + 1'b1;
        end
    end
end

always_comb begin
    divider_state_nxt = divider_state;
    if(divider_state == IDLE) begin
        if(enable_i) begin
            divider_state_nxt = EXECUTE;
        end
    end
    else if(divider_state == EXECUTE) begin
        if(ctr_r == 5'b1_1111) begin
            divider_state_nxt = OUTPUT;
        end
    end
    else begin
        divider_state_nxt = IDLE;
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        divider_state <= IDLE;
    end
    else begin
        divider_state <= divider_state_nxt;
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        ctr_r <= 5'h0;
    end
    else begin
        if((divider_state == EXECUTE) & (ctr_r != 5'h1_F)) begin
            ctr_r <= ctr_r + 1'b1;
        end
        else begin
            ctr_r <= 5'h0;
        end
    end
end

always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
        A_r              <= {32{1'b0}};
        B_r              <= {32{1'b0}};
        Q_r              <= {32{1'b0}};
        R_r              <= {32{1'b0}};
        QR               <= {32{1'b0}};
        Rsub_r           <= {31{1'b0}};
        A31_r            <= 1'b0;
        sign_r           <= 1'b0;
        sign_res_r       <= 1'b0;
        ready_o          <= 1'b0;
        div_or_rem_sel_r <= 1'b0;
    end
    else begin
        Q_r     <= Q_c;
        ready_o <= (divider_state == OUTPUT);
        if(divider_state == OUTPUT) begin
            if(div_or_rem_sel_r) begin
                QR <= RemainderInterim;
            end
            else begin
                QR <= QuotientInterim;
            end
        end
        if(divider_state == IDLE & enable_i) begin
            A31_r            <= A_i[31];
            sign_r           <= sign_i;
            sign_res_r       <= A_i[31] != B_i[31];
            div_or_rem_sel_r <= div_or_rem_sel_i;
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
        if(divider_state == EXECUTE) begin
            Rsub_r <= R_w[30:0];
            R_r    <= R_w;
        end
        else begin
            Rsub_r <= {30{1'b0}};
        end
    end
end

for(genvar i0 = 0; i0 < 32; i0++) begin
   assign Q_c[i0] = ((divider_state == EXECUTE) & (ctr_r[4:0] == (31-i0))) ? ~BO_31 : Q_r[i0];
end

div_csa32 DIV_CALC (
    .A_i    ({Rsub_r[30:0], A_ptr_w} ),
    .B_i    (B_r                     ),
				                     
    .Bo31_o (BO_31                   ),
    .Q_o    (R_w                     )
);

//for(genvar i0 = 0; i0 < 32; i0++) begin : DIV_GENERATE
//    assign Q_c[i0] = ((divider_state == EXECUTE) & (ctr_r[4:0] == (31-i0))) ? ~Bo_w[31] : Q_r[i0];
//
//    if(i0 == 0) begin
//        assign A_w    [i0] = A_ptr_w;
//        assign Bo_p_w [i0] = 1'b0;
//    end
//    else begin
//        assign A_w    [i0] = Rsub_r [i0 - 1];
//        assign Bo_p_w [i0] = Bo_w   [i0 - 1];
//    end
//
//    div_core u_DIVCORE (
//        .A_i  (A_w [i0]   ),
//        .B_i  (B_r [i0]   ),
//					    
//        .Bo_i (Bo_p_w[i0] ),
//        .OS_i (Bo_w[31]   ),
//					     
//        .Bo_o (Bo_w[i0]   ),
//        .Q_o  (R_w [i0]   )
//    );
//end
//
//// synthesis translate_off
//wire [31:0] QQc;
//wire [31:0] AAc;
//wire [31:0] RRc;
//wire        BO_31;
//
//assign AAc = {Rsub_r[30:0], A_ptr_w};
//
//for(genvar i0 = 0; i0 < 32; i0++) begin
//   assign QQc[i0] = ((divider_state == EXECUTE) & (ctr_r[4:0] == (31-i0))) ? ~BO_31 : Q_r[i0];
//end
//
//
//wire Qchk  = QQc == Q_c;
//wire Rchk  = RRc == R_w;
//wire OSchk = BO_31 == Bo_w[31];
//
//div_csa32 DIV_CALC (
//    .A_i    (AAc   ),
//    .B_i    (B_r   ),
//
//    .Bo31_o (BO_31 ),
//    .Q_o    (RRc   )
//);
//
//// synthesis translate_on

endmodule
