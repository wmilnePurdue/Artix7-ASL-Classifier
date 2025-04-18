`define CONV1_NUM_INPUT_CH  3
`define CONV1_NUM_OUTPUT_CH 8
`define CONV2_NUM_INPUT_CH  8
`define CONV2_NUM_OUTPUT_CH 16
`define CONV3_NUM_INPUT_CH  16
`define CONV3_NUM_OUTPUT_CH 24

`define CONV1_NUM_INPUT_CH_MINUS_1  4'd2
`define CONV2_NUM_INPUT_CH_MINUS_1  4'd7
`define CONV3_NUM_INPUT_CH_MINUS_1  4'd15

`define CONV1_NUM_OUT_PIXELS_DIV2_MINUS_1 4'd15
`define CONV2_NUM_OUT_PIXELS_DIV2_MINUS_1 4'd7
`define CONV3_NUM_OUT_PIXELS_DIV2_MINUS_1 4'd3

`define LOG2_FILTER_MEM_ADDR_WIDTH  11
`define LOG2_ACT_ADDR_WIDTH 13

`define INPUT_IMAGE_START_ADDR    13'h0
`define CONV1_OUTPUT_START_ADDR   13'hC00
`define CONV2_OUTPUT_START_ADDR   13'h1400
`define CONV3_OUTPUT_START_ADDR   13'h1800
`define FC1_1_OUTPUT_START_ADDR   13'h1A00
`define FC1_2_OUTPUT_START_ADDR   13'h1A20
`define FC2_OUTPUT_START_ADDR     13'h1B00

`define CONV1_FILTER_START_ADDR   11'd0
`define CONV1_FILTER_END_ADDR     11'd26
`define CONV2_FILTER_START_ADDR   11'd27
`define CONV2_FILTER_END_ADDR     11'd98
`define CONV3_FILTER_START_ADDR   11'd99
`define CONV3_FILTER_END_ADDR     11'd242
`define FC1_1_FILTER_START_ADDR   11'd243
`define FC1_1_FILTER_END_ADDR     11'd626
`define FC1_2_FILTER_START_ADDR   11'd627
`define FC1_2_FILTER_END_ADDR     11'd1010
`define FC2_FILTER_START_ADDR     11'd1011
`define FC2_FILTER_END_ADDR       11'd1074

`define CONV1_FILTER_EN           32'hFF
`define CONV2_FILTER_EN           32'hFFFF
`define CONV3_FILTER_EN           32'hFF_FFFF
`define FC1_1_FILTER_EN           32'hFFFF_FFFF
`define FC1_2_FILTER_EN           32'hFFFF_FFFF
`define FC2_FILTER_EN             32'hFF_FFFF