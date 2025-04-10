
;;
;; Assembly Programming User Guide
;; - This document aims to provide users information
;;   how to properly program the custom CPU in 
;;   the HandDetect SoC project

;; Miscellaneous information and sample programs 
;; are at the end of Instruction List

Instruction list
* NOTE: instructions must be LOWERCASE

ADD
    ;; adds two numbers from two registers or one register and a constant
    
    add <destination_register>,<source_register>,<register/constant>

    ;; Example:
    add r0,r1,r2
    ;; Result: r0 = r1 + r2
    
    add r0,r1,5
    ;; Result: r0 = r1 + 5
    ;; Note: Constant limited to 14-bits with a max-value of 16,383

SUB
    ;; subtracts two numbers from two registers or one register and a constant
    
    sub <destination_register>,<source_register>,<register/constant>
    ;; Example:
    sub r0,r1,r2
    ;; Result: r0 = r1 + r2
    
    sub r0,r1,5
    ;; Result: r0 = r1 + 5
    ;; Note: Constant limited to 14-bits with a max-value of 16,383

MUL/IMUL
    ;; Multiplies two 32-bit numbers from two registers
    ;;  mul - unsigned multiplication
    ;; imul - signed multiplication

    mul/imul <destination_register>,<source_register>,<register/constant>,<upper/lower>

    ;; if upper, the function returns result[63:32]
    ;; if lower, the function returns result[31:0]
    ;; - use "u" or "l" to denote reuslt 

    ;; Example:
    mul r0,r1,r2,l
    ;; Result: r0 = r1*r2 (lower 32-bits)
    ;; if:
    ;;    r1 = 131,072 
    ;;    r2 = 131,073
    ;; then:
    ;;    r1 * r2 = 17,180,000,256
    ;;    In hex this result is 0x0000_0004_0002_0000
    ;;  
    ;; Because we're asking for the lower portion, 
    ;; the return value is : 0x0002_0000
    ;; Likewise, if we have:
    mul r0,r1,r2,u
    ;; the return value is : 0x0000_0004

DIV/IDIV
    ;; Divides two 32-bit numbers from two registers
    ;;  div - unsigned division
    ;; idiv - signed division
    ;; - use "q" to return quotient
    ;;   or  "r" to return remainder

    ;; Example:
    div r0,r1,r2,q
    ;; Result: r0 = r1/r2 

    div r0,r1,r2,r
    ;; Result: r0 = r1%r2 

OR 
    ;; ORs two 32-bit numbers from two registers

    ;; Example:
    or r0,r1,r2
    ;; Result: r0 = r1 | r2 

AND 
    ;; ANDs two 32-bit numbers from two registers

    ;; Example:
    and r0,r1,r2
    ;; Result: r0 = r1 & r2 

MOV 
    ;; Copies one register to another register

    ;; Example:
    mov r0,r1
    ;; Result: r0 = r1

INVD 
    ;; inverts (bitwise) the value of one register and saves to another register

    ;; Example:
    invd r0,r1
    ;; Result: r0 = ~r1

SHR 
    ;; Shifts to the right the value of one register by the value of another register
    ;; or with a constant (max constant value is 31-bits)

    ;; Example:
    shr r0,r1,4
    ;; r0 = r1 >> 4
    shr r0,r1,r2
    ;; r0 = r1 >> r2[4:0]

SHL 
    ;; Shifts to the left the value of one register by the value of another register
    ;; or with a constant (max constant value is 31-bits)

    ;; Example:
    shl r0,r1,4
    ;; r0 = r1 << 4
    shl r0,r1,r2
    ;; r0 = r1 << r2[4:0]

JE 
    ;; Jumps to a specific location in the program if r0 == r1

    ;; Example:
    je r0,r1,START_CAMERA_SAMPLE
    ;; if r0 == r1, then the program counter = START_CAMERA_SAMPLE

JMP 
    ;; Jumps to a specific location in the program (unconditional)

    ;; Example:
    jmp START_CAMERA_SAMPLE
    ;; program counter = START_CAMERA_SAMPLE
    ;; this is a simulated instruction.
    ;;   In hardware, this is equivalent to:
    ------>  je r0,r0,START_CAMERA_SAMPLE
             ;; r0 is always equal to r0 hence it will always jump

JNE 
    ;; Jumps to a specific location in the program if r0 != r1

    ;; Example:
    jne r0,r1,START_CAMERA_SAMPLE
    ;; if r0 != r1, then the program counter = START_CAMERA_SAMPLE

JL 
    ;; Jumps to a specific location in the program if r0 < r1

    ;; Example:
    jne r0,r1,START_CAMERA_SAMPLE
    ;; if r0 < r1, then the program counter = START_CAMERA_SAMPLE

JG 
    ;; Jumps to a specific location in the program if r0 > r1

    ;; Example:
    jg r0,r1,START_CAMERA_SAMPLE
    ;; if r0 > r1, then the program counter = START_CAMERA_SAMPLE

CALL
    ;; Jumps to a specific location in the program
    ;; - and stores the program counter + 1 to the memory address pointed by the register

    ;; Example:
    call r0,START_CAMERA_SAMPLE
    ;; if r0 = 0x0000_1000,
    ;; *(0x0000_1000) = program counter + 1, 
    ;; program counter = START_CAMERA_SAMPLE

RET
    ;; Jumps to the address pointed by the register

    ;; Example:
    call r0,START_CAMERA_SAMPLE
    ;; if r0 = 0x0000_1000, 
    ;; program counter = *(0x0000_1000)

STOSB
    ;; Stores a byte from a register to an address pointed by another register +/- constant
    ;; max constant value = 16,383

    ;; Example:
    stosb r0,r1,b0,+4
    ;; If r0 = 0xABCD_1234, and r1 = 0x0000_1000
    ;; *(0x0000_1004)[7:0] = 0x34
    stosb r0,r1,b1,-4
    ;; *(0x0000_0FFC)[15:8] = 0x12

STOSD
    ;; Stores a 16-bit data from a register to an address pointed by another register +/- constant
    ;; max constant value = 16,383

    ;; Example:
    stosd r0,r1,h0,+4
    ;; If r0 = 0xABCD_1234, and r1 = 0x0000_1000
    ;; *(0x0000_1004)[15:0] = 0x1234
    stosd r0,r1,h1,-4
    ;; *(0x0000_0FFC)[31:15] = 0xABCD

WARNING: STOSB/STOSD attempts to write $byte / $double_word via AHB-L interface,
         but hardware must support byte-aligned writes. true memory typically does, but
         peripherals it's optional.

STOSW
    ;; Stores a 16-bit data from a register to an address pointed by another register +/- constant
    ;; max constant value = 16,383

    ;; Example:
    stosw r0,r1,+4
    ;; If r0 = 0xABCD_1234, and r1 = 0x0000_1000
    ;; *(0x0000_1004) = 0xABCD_1234
    stosw r0,r1,-4
    ;; *(0x0000_0FFC)[31:15] = 0xABCD_1234

LODSB
    ;; Loads a byte from an address pointed by a register (+/- constant) to another register
    ;; max constant value = 16,383

    ;; Example:
    ;; If             r0     = 0xABCD_1234, 
    ;; and            r1     = 0x0000_1000
    ;; and    *(0x0000_1004) = 0xDEAD_BEEF
    ;; and    *(0x0000_0FFC) = 0xFEED_DEAF

    lodsb r0,r1,b0,+4
    ;; r0 (old_data) = 0xABCD_1234
    ;; r0 (new_data) = 0xABCD_12EF
    lodsb r0,r1,b1,-4
    ;; r0 (old_data) = 0xABCD_1234
    ;; r0 (new_data) = 0xABCD_DE34

LODSD
    ;; Loads a 16-bit data an address pointed by a register (+/- constant) to another register
    ;; max constant value = 16,383

    ;; Example:
    ;; If             r0     = 0xABCD_1234, 
    ;; and            r1     = 0x0000_1000
    ;; and    *(0x0000_1004) = 0xDEAD_BEEF
    ;; and    *(0x0000_0FFC) = 0xFEED_DEAF

    lodsd r0,r1,h0,+4
    ;; r0 (old_data) = 0xABCD_1234
    ;; r0 (new_data) = 0xABCD_BEEF
    lodsd r0,r1,h1,-4
    ;; r0 (old_data) = 0xABCD_1234
    ;; r0 (new_data) = 0xFEED_1234

LODSW
    ;; Loads a 32-bit data an address pointed by a register (+/- constant) to another register
    ;; max constant value = 16,383

    ;; Example:
    ;; If             r0     = 0xABCD_1234, 
    ;; and            r1     = 0x0000_1000
    ;; and    *(0x0000_1004) = 0xDEAD_BEEF
    ;; and    *(0x0000_0FFC) = 0xFEED_DEAF

    lodsw r0,r1,+4
    ;; r0 (old_data) = 0xABCD_1234
    ;; r0 (new_data) = 0xDEAD_BEEF
    lodsw r0,r1,-4
    ;; r0 (old_data) = 0xABCD_1234
    ;; r0 (new_data) = 0xFEED_DEAF

LSL
    ;; Load a 16-bit constant to the lower-half register. 
    ;; The upper-half can be zeroed out, or kept as is
    ;; - use "z" for zero, and "nz" for non-zero

    ;; Example:
    ;; If r0 = 0xABCD_1234

    lsl r0,z,0xFEED
    ;; If r0 = 0x0000_FEED 

    lsl r0,nz,0xFEED
    ;; If r0 = 0xABCD_FEED

LSS
    ;; Load a 16-bit constant to the upper-half register. 
    ;; The lower-half can be zeroed out, or kept as is
    ;; - use "z" for zero, and "nz" for non-zero

    ;; Example:
    ;; If r0 = 0xABCD_1234

    lss r0,z,0xDEED
    ;; If r0 = 0xDEED_0000 

    lss r0,nz,0xDEED
    ;; If r0 = 0xFEED_1234

MISCELLANEOUS INFORMATION:

I. Comments are denoted by a prefix of ";;" to match Notepad++ formatting

;; Example:
;; This is a comment

II. Address-Map:
0x0000_0000 - 0x3FFF_FFFF (True Memory)
0x4000_0000 - 0x7FFF_FFFF (Camera/GPIO interface)
0x8000_0000 - 0xBFFF_FFFF (NPU/Accelerator)
0xC000_0000 - 0xFFFF_FFFF (Output unit)

III. Assembling Code

1. Write a code in *.asm format.
2. Enter the path it in main.py
;; look for:
    raw_program = open("prog.asm", "r") // replace prog.asm with your file

3. Enter the output file path in main.py
;; look for:
    f = open("prog.coe", "w") // replace prog.coe with your file 

NOTE: *.coe is a VIVADO initialization memory file, the python script is designed
      to format the output in *.coe

4. Open VIVADO
5. In the heirarchy, look for:
    soc_top
     |
     | --> CPU
            |
            | --> MEM

   Right-click on MEM -> "Re-customize IP"
6. Go to "Other Options" tab
7. In the Coe file file, click Browse and select the *.coe output
   ---> If you have previously selected a file and are using the same filename, 
        click on "Edit" instead, and click "Save"
8. Click "OK" -> "Generate"
9. The memory should be updated now, to check, you can run a simulation.

IV. Sample coding
- Address Markers are denoted by a ":" in the end

a.) if-else EXAMPLE:

    if(a == b) {
     <if_tasks>
    } else {
     <else_tasks>
    }
     <code continue>

    ASSEMBLY:    

    jne r0,r1,ELSE_FUNC
      <if_tasks>
    jmp END_IF_ELSE
    ELSE_FUNC:
      <else_tasks>
    END_IF_ELSE:
      <code continue>
     
b.) for-loop example

    for (a = 0; a < b; a ++ ) {
        <for tasks>
    }
        <code continue>

    ASSEMBLY:

    lsl r0,z,0
    LOOP_START:
    jl r0,r1,DO_LOOP_FUNC
    jmp END_LOOP
       <for tasks>
    add r0,r0,1
    jmp LOOP_START
    END_LOOP:
       <code continue>

c.) while-loop example

    a = *(0x0001_4000)
    while (a != 1) {
       <while_tasks>
       a = *(0x0001_4000)
    }
    <code continue>

    ASSEMBLY:

    lsl r1,nz,0x4000
    lss r1,nz,0x0001
    lss r2,z,1

    START_WHILE:
    lodsw r0,r1,+0
    je r0,r2,END_WHILE
       <while_tasks>
    jmp START_WHILE

    END_WHILE:
    <code continue>

    