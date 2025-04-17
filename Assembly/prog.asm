; Comment Test
bound START_PXL 0x4000_0014
bound START_PXL_LO 0x0014
bound START_PXL_HI 0x4000

bound ROW_READ 0x4008_0188
bound ROW_READ_LO 0x0188
bound ROW_READ_HI 0x4008

bound RED_START 0x4008_0008
bound PXL_RED_START_LO 0x0008
bound RED_START_HI 0x4008
bound LIMIT 0x4008_0184
bound LIMIT_LO 0x0184
bound LIMIT_HI 0x4008
bound PXL_RED_LIMIT   0x0084
bound PXL_BLUE_LIMIT  0x0104
bound PXL_GREEN_LIMIT 0x0184

;bound STORAGE_MEMORY 0xE00
bound MASK_DATA 0xFFFF

bound I2C_WR_ADDR_HI 0x4000
bound I2C_WR_ADDR_LO 0x000C

bound SPI_UPPER 0xC000
bound SPI_DELAY_VAL 0x10
bound SPI_DATA_HI 0xDEAD
bound SPI_DATA_LO 0xBEEF

bound NPU_RGB_HI  0x8000
bound NPU_RED_LO  0x2000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RGB_DIVISOR
bound RGB_DIVISOR 28

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; I2C initialization values
;; Target Clock = 400kHz
;; Input Clock = 116MHz
;; I2C delay line = (116 MHz / 400 kHz) = 290 -> 
bound I2C_DELAY_LINE    0x122
bound I2C_RESET_DELAY   0x1000

;; I2C Registers to write
bound I2C_RESET           0x1280
;; COM7 Register
;; - set color output
bound I2C_SET_RGB_OUT     0x1204
;; CLKRC Register
;; - set PCLK = 50MHz / 2 = 25 MHz
bound I2C_INTERNAL_PLL    0x1140
;; COM3 Register
;; - set default
bound I2C_SET_COM3_DEF    0x0C00
;; COM14 Register 
;; - set PCLK to 25MHz
bound I2C_SET_COM14_REG   0x3E00
;; COM1 Register
;; - disable CCIR656
bound I2C_DIS_CCIR656     0x0400
;; COM15 Register
;; - set RGB555 format
bound I2C_EN_RGB555       0x40F0
;; TSLB Register
;; - (unknown reason based on reference)
bound I2C_TSLB            0x3A04
;; COM9 Register
;; - set AGC to 4x
bound I2C_SET_AGC         0x1410

;; MATRIX coefficients
bound I2C_MATRIX_01       0x4FB3
bound I2C_MATRIX_02       0x50B3
bound I2C_MATRIX_03       0x5100
bound I2C_MATRIX_04       0x523D
bound I2C_MATRIX_05       0x53A7
bound I2C_MATRIX_06       0x54E4
bound I2C_MATRIX_07       0x589E

;; COM13 Register 
;; - sets Gamma Enable, does NOT preserve bits
bound I2C_COM13_GAMMA     0x3DC0

;; Set HREF format
bound I2C_HSTART          0x1714
bound I2C_HSTOP           0x1802
;; Set HREF EDGE offset
bound I2C_HREF            0x3280

;; Set VREF format
bound I2C_VSTART          0x1903
bound I2C_VSTOP           0x1A7B
;; Set VSYNC edge offset
bound I2C_VREF            0x030A

;; COM6 Register
;; - Reset all timings after format change
bound I2C_COM6_RESET      0x0F41

;; Disable Mirror
bound I2C_DISABLE_MIRROR  0x1E00
;; Set CHLF (unknown)
bound I2C_CHLF            0x330B

;; COM12 Register
;; - No HREF when VSYNC is low
bound I2C_COM12_NO_HREF   0x3C00

;; GFIX (set Fix gain - all channels)
bound I2C_GFIX_CTRL       0x6900

;; REG74 (digital gain control)
bound I2C_REG74_CTRL      0x7400

;; Miscellaneous values
bound I2C_MISC_01         0xB084
bound I2C_MISC_02         0xB10C
bound I2C_MISC_03         0xB20E
bound I2C_MISC_04         0xB380

;; Scaling Values
bound I2C_SCALE_01        0x703A
bound I2C_SCALE_02        0x7135
bound I2C_SCALE_03        0x7211
bound I2C_SCALE_04        0x73F0
bound I2C_SCALE_05        0xA202

;; Gamma Values
bound I2C_GAMMA_01        0x7A20
bound I2C_GAMMA_02        0x7B10
bound I2C_GAMMA_03        0x7C1E
bound I2C_GAMMA_04        0x7D35
bound I2C_GAMMA_05        0x7E5A
bound I2C_GAMMA_06        0x7F69
bound I2C_GAMMA_07        0x8076
bound I2C_GAMMA_08        0x8180
bound I2C_GAMMA_09        0x8288
bound I2C_GAMMA_10        0x838F
bound I2C_GAMMA_11        0x8496
bound I2C_GAMMA_12        0x85A3
bound I2C_GAMMA_13        0x86AF
bound I2C_GAMMA_14        0x87C4
bound I2C_GAMMA_15        0x88D7
bound I2C_GAMMA_16        0x89E8

;; Other controls
;; COM8 Register
;; - (disable) Fast AGC/AEC 
bound I2C_COM8_DIS_AEC    0x13E0
bound I2C_SET_AGC_GAIN    0x0000
;; - Set AECH register
bound I2C_SET_AECH        0x1000
;; COM4 misc
bound I2C_SET_COM4        0x0D40

;; COM 9 Register
;; - Set 4x gain
bound I2C_SET_COM_9       0x1418
bound I2C_BD50_MAX        0xA505
bound I2C_DB60_MAX        0xAB07
bound I2C_AGC_UPPER       0x2495
bound I2C_AGC_LOWER       0x2595

bound I2C_AGC_AEC_FAST    0x26E3
bound I2C_HAECC1          0x9F78
bound I2C_HAECC2          0xA068
;; Unknown but recommended 
bound I2C_XXX             0xA103
bound I2C_HAECC3          0xA6D8
bound I2C_HAECC4          0xA7D8
bound I2C_HAECC5          0xA8F0
bound I2C_HAECC6          0xA990
bound I2C_HAECC7          0xAA94

;; COM8 Register
;; - (disable) Fast AGC/AEC 
bound I2C_COM8_AGC_AEC    0x13E5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAIN FUNCTION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
START:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RESERVE r15 for call-pointer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lsl r15,z,0xFFFF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ** Initialize I2C
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lss r0,z, $I2C_WR_ADDR_HI

lsl r1,z,$I2C_DELAY_LINE
stosw r1,r0,+16

;; Reset OV7670
lsl r1,z,$I2C_RESET
call r15,WRITE_I2C_WITH_REGISTER

;; delay
lsl r1,z,$I2C_RESET_DELAY
lsl r8,z,0
I2C_RESET_LOOP:
sub r1,r1,1
jne r1,r8,I2C_RESET_LOOP

;; Set OV7670 to RGB output
lsl r1,z,$I2C_SET_RGB_OUT
call r15,WRITE_I2C_WITH_REGISTER

;; Set OV7670 to 25MHz Clock
lsl r1,z,$I2C_INTERNAL_PLL
call r15,WRITE_I2C_WITH_REGISTER

;; Set COM3 register to default
lsl r1,z,$I2C_SET_COM3_DEF
call r15,WRITE_I2C_WITH_REGISTER

;; Set PCLK to 25MHz Clock
lsl r1,z,$I2C_SET_COM14_REG
call r15,WRITE_I2C_WITH_REGISTER

;; Disable CCIR656
lsl r1,z,$I2C_DIS_CCIR656
call r15,WRITE_I2C_WITH_REGISTER

;; Set RGB555 format
lsl r1,z,$I2C_EN_RGB555
call r15,WRITE_I2C_WITH_REGISTER

;; Set TLSB Register
lsl r1,z,$I2C_TSLB
call r15,WRITE_I2C_WITH_REGISTER

;; Set AGC to 4x
lsl r1,z,$I2C_SET_AGC
call r15,WRITE_I2C_WITH_REGISTER

;; Matrix Coefficients
lsl r1,z,$I2C_MATRIX_01
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_MATRIX_02
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_MATRIX_03
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_MATRIX_04
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_MATRIX_05
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_MATRIX_06
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_MATRIX_07
call r15,WRITE_I2C_WITH_REGISTER

;; COM13 Register
lsl r1,z,$I2C_COM13_GAMMA
call r15,WRITE_I2C_WITH_REGISTER

;; Set HREF format
lsl r1,z,$I2C_HSTART
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_HSTOP
call r15,WRITE_I2C_WITH_REGISTER

;; Set HREF EDGE offset
lsl r1,z,$I2C_HREF
call r15,WRITE_I2C_WITH_REGISTER

;; Set VREF format
lsl r1,z,$I2C_VSTART
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_VSTOP
call r15,WRITE_I2C_WITH_REGISTER

;; Set HREF EDGE offset
lsl r1,z,$I2C_VREF
call r15,WRITE_I2C_WITH_REGISTER

;; Set COM6 Register
lsl r1,z,$I2C_COM6_RESET
call r15,WRITE_I2C_WITH_REGISTER

;; Disable Mirror
lsl r1,z,$I2C_DISABLE_MIRROR
call r15,WRITE_I2C_WITH_REGISTER

;; CHLF
lsl r1,z,$I2C_CHLF
call r15,WRITE_I2C_WITH_REGISTER

;; Set COM12 (No HREF when VSYNC is low)
lsl r1,z,$I2C_COM12_NO_HREF
call r15,WRITE_I2C_WITH_REGISTER

;; GFIX (set Fix gain - all channels)
lsl r1,z,$I2C_GFIX_CTRL
call r15,WRITE_I2C_WITH_REGISTER

;; REG74 (digital gain control)
lsl r1,z,$I2C_REG74_CTRL
call r15,WRITE_I2C_WITH_REGISTER

;; Miscellaneous values
lsl r1,z,$I2C_MISC_01
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_MISC_02
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_MISC_03
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_MISC_04
call r15,WRITE_I2C_WITH_REGISTER

;; Scaling values
lsl r1,z,$I2C_SCALE_01
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_SCALE_02
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_SCALE_03
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_SCALE_04
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_SCALE_05
call r15,WRITE_I2C_WITH_REGISTER

;; Gamma Values
lsl r1,z,$I2C_GAMMA_01
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_GAMMA_02
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_GAMMA_03
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_GAMMA_04
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_GAMMA_05
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_GAMMA_06
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_GAMMA_07
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_GAMMA_08
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_GAMMA_09
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_GAMMA_10
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_GAMMA_11
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_GAMMA_12
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_GAMMA_13
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_GAMMA_14
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_GAMMA_15
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_GAMMA_16
call r15,WRITE_I2C_WITH_REGISTER

;; Other controls
;; - (disable) Fast AGC/AEC 
lsl r1,z,$I2C_COM8_DIS_AEC
call r15,WRITE_I2C_WITH_REGISTER

lsl r1,z,$I2C_SET_AGC_GAIN
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_SET_AECH
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_SET_COM4
call r15,WRITE_I2C_WITH_REGISTER

;; Set 4x gain
lsl r1,z,$I2C_SET_COM_9
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_BD50_MAX
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_DB60_MAX
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_AGC_UPPER
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_AGC_LOWER
call r15,WRITE_I2C_WITH_REGISTER

;; HAECC Register
lsl r1,z,$I2C_AGC_AEC_FAST
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_HAECC1
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_HAECC2
call r15,WRITE_I2C_WITH_REGISTER
;; Unknown but recommended 
lsl r1,z,$I2C_XXX
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_HAECC3
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_HAECC4
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_HAECC5
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_HAECC6
call r15,WRITE_I2C_WITH_REGISTER
lsl r1,z,$I2C_HAECC7
call r15,WRITE_I2C_WITH_REGISTER

;; Enable AGC/AEC
lsl r1,z,$I2C_COM8_AGC_AEC
call r15,WRITE_I2C_WITH_REGISTER

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ** Start PIXEL BINNER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; r0 - Row Address
;; r1 - write value
;; r2 - row value
;; r3 - npu rgb address
;; r4 - mask value
;; r5 - divider
;; r6 - read_value of pixel binner
;; r7 - address limit of pixel binner (GREEN)
;; r8 - constant 33 (to check if row are at limit)
;; r9 - shift value

MAIN_ROUTINE_START:
lsl r0,nz,$START_PXL_LO
lss r0,nz,$START_PXL_HI
lsl r1,z,0
stosw r1,r0,+0
lsl r1,z,1
stosw r1,r0,+0

lss r3,nz,$NPU_RGB_HI
lsl r3,nz,$NPU_RED_LO
lsl r4,z,$RGB_DIVISOR
lss r5,z,$MASK_DATA
lss r7,nz,0x4008
lss r8,z,33

START_ROW_DETECT:
lss r0,z,$ROW_READ_HI
invd r5,r5
lsl r9,z,$MASK_DATA
je r9,r5,APPLY_ZERO_SHIFT
lsl r9,z,16
jmp POLL_ROW
APPLY_ZERO_SHIFT:
lsl r9,z,0

POLL_ROW:
;; 0x0188 = 392
lodsw r0,r2,+392
jne r2,r1,POLL_ROW

lsl r0,nz,$PXL_RED_START_LO
lsl r7,nz,$PXL_RED_LIMIT
call r15,STORE_RESULT

lsl r7,nz,$PXL_BLUE_LIMIT
add r3,r3,992
call r15,STORE_RESULT

lsl r7,nz,$PXL_GREEN_LIMIT
add r3,r3,992
call r15,STORE_RESULT

sub r3,r3,2048
add r1,r1,1
jne r8,r1,START_ROW_DETECT

LOOP_HERE:
jmp LOOP_HERE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FUNCTION DEFINITIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WRITE_I2C_WITH_REGISTER:
stosw r1,r0,+12
WRITE_I2C:
lsl r1,z,0
stosw r1,r0,+8
lsl r1,z,1
stosw r1,r0,+8
lss r0,nz,0x4008
POLL_I2C_LOOP:
lodsw r0,r2,+4
jne r2,r1,POLL_I2C_LOOP
lss r0,nz,0x4000
ret r15

STORE_RESULT:
lodsw r0,r6,+0
and r6,r6,r5
div r6,r6,r4,q
stosw r6,r3,+0
je r0,r7,END_STORE
add r0,r0,4
add r3,r3,1
jmp STORE_RESULT
END_STORE:
add r0,r0,4
add r3,r3,1
ret r15