
typedef enum bit [3:0] {
    npu_ADD = 4'h0,
    npu_SUB = 4'h1,
    npu_MUL = 4'h2,
    npu_JEQ = 4'h3,
    npu_JNE = 4'h4,
    npu_LW  = 4'h5,
    npu_SW  = 4'h6,
    npu_LWI = 4'h7
} npu_inst_t;

// NPU-ISA architecture
// ADD, SUB, MUL 
//  opcode [17:14] | src0 [13:11] | src1 [10:8] | dest [7:5]
// JEQ, JNE
//  opcode [17:14] | src0 [13:11] | src1 [10:8] 
// LW
//  opcode [17:14] | addr [13:11] | rddata [4:2] 
// SW
//  opcode [17:14] | addr [13:11] | wrdata [4:2] 
// LWI
//  opcode [17:14] | src0 [13:11] | up/low [10] | nz/z [9] | value[7:0] 
