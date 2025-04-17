
localparam [4:0] ADD      = 5'b0_0000;
localparam [4:0] SUB      = 5'b0_0001;
localparam [4:0] MULT     = 5'b0_0010; // optional op-code
localparam [4:0] DIV      = 5'b0_0011; // optional op-code

// FORMAT
// 31 30 29 28 27 | 26 25 24 23 | 22 21 20 19 | 18 17 16 15 |     14      |       13        |  12 - 0
//    <OP_CODE>   | <SRC_REG_0> | <SRC_REG_1> | <DEST_REG>  |   Div/Rem   | Signed/Unsigned | (unused)
//                                                          | Upper/Lower |                   (unused)
//                                                          | Use constant|     13 - 0 (Immidiate)

localparam [4:0] MOV      = 5'b0_0100;
localparam [4:0] OR       = 5'b0_0101;
localparam [4:0] AND      = 5'b0_0110;
localparam [4:0] INV      = 5'b0_0111;

// FORMAT
// 31 30 29 28 27 | 26 25 24 23 | 22 21 20 19 | 18 17 16 15 |  14 - 0
// <OP_CODE>      | <SRC_REG_0> | <SRC_REG_1> | <DEST_REG>  | (unused)
// 
// FORMAT (INV / MOV)
// 31 30 29 28 27 | 26 25 24 23 | 22 21 20 19 | 18 17 16 15 |  14 - 0
// <OP_CODE>      | <SRC_REG_0> |  (unused)   | <DEST_REG>  | (unused)

localparam [4:0] SLL      = 5'b0_1000;
localparam [4:0] SRR      = 5'b0_1001;						  

// FORMAT
// 31 30 29 28 27 | 26 25 24 23 | 22 21 20 19 | 18 17 16 15 |     14     | 4 - 0
// <OP_CODE>      | <SRC_REG_0> | <SRC_REG_1> | <DEST_REG>  | (use const)| const

localparam [4:0] JEQ      = 5'b0_1010;
localparam [4:0] JNEQ     = 5'b0_1011; 
localparam [4:0] JGR      = 5'b0_1100; // same as J_NLT
localparam [4:0] JLT      = 5'b0_1101; // same as J_NGR
// FORMAT
// 31 30 29 28 27 | 26 25 24 23 | 22 21 20 19 |   18 - 0
// <OP_CODE>      | <SRC_REG_0> | <SRC_REG_1> | (jump addr)

localparam [4:0] CALL     = 5'b0_1110; 
localparam [4:0] RET      = 5'b0_1111;

// FORMAT - CALL uses jump addr, RET uses SRC_REG_0
// 31 30 29 28 27 | 26 25 24 23 | 22 21 20 19 |   18 - 0
// <OP_CODE>      | <SRC_REG_0> |  (unused)   | (jump addr)

localparam [4:0] SW8_0    = 5'b1_0000;
localparam [4:0] SW8_1    = 5'b1_0001;
localparam [4:0] SW8_2    = 5'b1_0010;
localparam [4:0] SW8_3    = 5'b1_0011;
localparam [4:0] SW16_0   = 5'b1_0100;
localparam [4:0] SW16_1   = 5'b1_0101;
localparam [4:0] SW32     = 5'b1_0110;
localparam [4:0] IMMI_L   = 5'b1_0111;
localparam [1:0] SW       = 3'b1_0;

localparam [4:0] LW8_0    = 5'b1_1000;
localparam [4:0] LW8_1    = 5'b1_1001;
localparam [4:0] LW8_2    = 5'b1_1010;
localparam [4:0] LW8_3    = 5'b1_1011;
localparam [4:0] LW16_0   = 5'b1_1100;
localparam [4:0] LW16_1   = 5'b1_1101;
localparam [4:0] LW32     = 5'b1_1110;
localparam [4:0] IMMI_H   = 5'b1_1111;
localparam [1:0] LW       = 3'b1_1;

// FORMAT - SW
// 31 30 29 28 27 | 26 25 24 23 | 22 21 20 19 |  18 - 15    | 14  |    13  - 0
// <OP_CODE>      | <WR_DATA>   |  <WR_ADDR>  |  (unused)   | +/- | (offset value)
//

// FORMAT - LW
// 31 30 29 28 27 | 26 25 24 23 | 22 21 20 19 | 18 17 16 15 | 14  |    13  - 0
// <OP_CODE>      |  (unused)   |  <RD_ADDR>  | <DEST_REG>  | +/- | (offset value)
//                                                              

// FORMAT - IMMI
// 31 30 29 28 27 | 26 25 24 23 | 22 - 17 | 16 |     15 - 0
// <OP_CODE>      | <DEST_REG>  | (unused)| ZR | (immidiate data)
// ZR - if 1, sets the other 16-bits to 0
