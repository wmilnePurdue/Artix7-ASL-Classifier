; Comment Test
bound START_PXL 0x4000_0014
bound START_PXL_LO 0x0014
bound START_PXL_HI 0x4000

bound ROW_READ 0x4008_0188
bound ROW_READ_LO 0x0188
bound ROW_READ_HI 0x4008

bound RED_START 0x4008_0008
bound RED_START_LO 0x0008
bound RED_START_HI 0x0008
bound LIMIT 0x4008_0184
bound LIMIT_LO 0x0184
bound LIMIT_HI 0x4008

;bound STORAGE_MEMORY 0xE00
bound MASK_DATA 0xFFFF

bound I2C_ADDR_DATA 0x1280
bound I2C_WR_ADDR_HI 0x4000
bound I2C_WR_ADDR_LO 0x000C

bound I2C_DELAY_LINE 0x177
bound I2C_DELAY_ADDR_LO 0x0010

bound SPI_UPPER 0xC000
bound SPI_DELAY_VAL 0x10
bound SPI_DATA_HI 0xDEAD
bound SPI_DATA_LO 0xBEEF

START:

lsl r1,nz,SPI_DATA_LO
lss r1,nz,SPI_DATA_HI
lsl r0,nz,0
lss r0,nz,SPI_UPPER
stosw r1,r0,+0

lsl r1,z,SPI_DELAY_VAL
stosw r1,r0,+4

lsl r1,z,31
stosw r1,r0,+8
stosw r1,r0,+12
stosw r1,r0,+16

lsl r1,z, $I2C_ADDR_DATA
lsl r0,nz,0
lss r0,nz, $I2C_WR_ADDR_HI
stosw r1,r0,+12

lsl r1,z, $I2C_DELAY_LINE
stosw r1,r0,+16

lsl r1,z,1
stosw r1,r0,+8
lss r0,nz,0x4008
POLL_I2C:
lodsw r0,r2,+4
jne r2,r1,POLL_I2C

lsl r0,nz,START_PXL_LO
lss r0,nz,START_PXL_HI
lsl r1,z,1
stosw r1,r0,+0

lsl r8,nz,LIMIT_LO
lss r8,nz,LIMIT_HI

START_ROW_DETECT:
lsl r7,z,0x00
lsl r9,z,MASK_DATA
lsl r0,nz,ROW_READ_LO
lss r0,nz,ROW_READ_HI

POLL_ROW:
lodsw r0,r2,+0
jne r2,r1,POLL_ROW

lsl r0,nz,RED_START_LO
lsl r0,nz,RED_START_HI
lsl r5,z,7

STORE_RESULT:
lodsw r0,r4,+0
and r4,r4,r9
div r6,r4,r5,q
stosw r6,r7,+0
je r0,r8,MOVE_NEXT_ROW

add r0,r0,4
add r7,r7,1
jmp STORE_RESULT

MOVE_NEXT_ROW:
add r1,r1,1
lsl r10,z,33
jne r1,r10,START_ROW_DETECT

LOOP_HERE:
jmp LOOP_HERE