
// AHB-L definitions

// HTRANS
localparam [1:0] HTRANS_IDLE   = 2'b00;
localparam [1:0] HTRANS_BUSY   = 2'b01;
localparam [1:0] HTRANS_NSEQ   = 2'b10;
localparam [1:0] HTRANS_SEQ    = 2'b11;

// HSIZE
localparam [2:0] HSIZE_8       = 3'b000;
localparam [2:0] HSIZE_16      = 3'b001;
localparam [2:0] HSIZE_32      = 3'b010;

