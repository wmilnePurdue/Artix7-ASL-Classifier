`timescale 1ns / 1ps

`include "ahb_intf.vh"

module ssd_io_tb;

    // Testbench signals
    logic        clk;
    logic        resetn;
    logic [31:0] ahb_s0_haddr_i;
    logic        ahb_s0_hwrite_i;
    logic [2:0]  ahb_s0_hsize_i;
    logic [2:0]  ahb_s0_hburst_i;
    logic [3:0]  ahb_s0_hprot_i;
    logic [1:0]  ahb_s0_htrans_i;
    logic        ahb_s0_hmastlock_i;
    logic [31:0] ahb_s0_hwdata_i;
    logic        SW0;
    logic [31:0] ahb_s0_hrdata_o;
    logic        ahb_s0_hready_o;
    logic        ahb_s0_hresp_o;
    logic [6:0]  seg;
    logic [3:0]  an;
    logic [31:0] rdata;

    // Instantiate SSD IO slave
    ssd_io u_ssd_io (
        .clk(clk),
        .resetn(resetn),
        .ahb_s0_haddr_i(ahb_s0_haddr_i),
        .ahb_s0_hwrite_i(ahb_s0_hwrite_i),
        .ahb_s0_hsize_i(ahb_s0_hsize_i),
        .ahb_s0_hburst_i(ahb_s0_hburst_i),
        .ahb_s0_hprot_i(ahb_s0_hprot_i),
        .ahb_s0_htrans_i(ahb_s0_htrans_i),
        .ahb_s0_hmastlock_i(ahb_s0_hmastlock_i),
        .ahb_s0_hwdata_i(ahb_s0_hwdata_i),
        .SW0(SW0),
        .ahb_s0_hrdata_o(ahb_s0_hrdata_o),
        .ahb_s0_hready_o(ahb_s0_hready_o),
        .ahb_s0_hresp_o(ahb_s0_hresp_o),
        .seg(seg),
        .an(an)
    );

    // Clock generation (100 MHz, 10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // AHB write task
    task automatic ahb_write(input logic [31:0] addr, input logic [31:0] wdata);
        @(posedge clk);
        ahb_s0_haddr_i = addr;
        ahb_s0_hwrite_i = 1'b1;
        ahb_s0_htrans_i = HTRANS_NSEQ;
        ahb_s0_hsize_i = HSIZE_32;
        ahb_s0_hburst_i = 3'b000;
        ahb_s0_hprot_i = 4'b0000;
        ahb_s0_hmastlock_i = 1'b0;
        @(posedge clk);
        ahb_s0_hwdata_i = wdata;
        while (!ahb_s0_hready_o) @(posedge clk);
        ahb_s0_htrans_i = HTRANS_IDLE;
        ahb_s0_hwrite_i = 1'b0;
        @(posedge clk);
    endtask

    // AHB read task
    task automatic ahb_read(input logic [31:0] addr, output logic [31:0] rdata);
        @(posedge clk);
        ahb_s0_haddr_i = addr;
        ahb_s0_hwrite_i = 1'b0;
        ahb_s0_htrans_i = HTRANS_NSEQ;
        ahb_s0_hsize_i = HSIZE_32;
        ahb_s0_hburst_i = 3'b000;
        ahb_s0_hprot_i = 4'b0000;
        ahb_s0_hmastlock_i = 1'b0;
        @(posedge clk);
        while (!ahb_s0_hready_o) @(posedge clk);
        rdata = ahb_s0_hrdata_o;
        ahb_s0_htrans_i = HTRANS_IDLE;
        @(posedge clk);
    endtask

    // Task to test display
    task automatic test_display(input logic [4:0] value, input logic SW0, input logic [4:0] expected_value);
        logic [6:0] expected_seg_an0, expected_seg_an1;
        logic [3:0] expected_an_an0, expected_an_an1;
        logic invalid_letter;

        // Write value to data_reg
        ahb_write(32'hC000_0000, {27'b0, value});
        // Write done_flag
        ahb_write(32'hC000_0004, 32'h00000001);

        // Wait for refresh cycle (2^15 cycles per digit)
        repeat (2*(2**15)) @(posedge clk);

        // Debug: Read data_reg
        ahb_read(32'hC000_0000, rdata);
        $display("Debug: value=%0d, data_reg=%0d, display_value=%0d", value, rdata[4:0], u_ssd_io.display_value);

        // Determine expected display
        invalid_letter = (expected_value == 5'd9 || expected_value == 5'd11 || 
                          expected_value == 5'd20 || expected_value == 5'd21 || expected_value == 5'd22);
        if (SW0 && expected_value <= 5'd23 && !invalid_letter) begin
            expected_an_an0 = 4'b1110;
            expected_an_an1 = 4'b1111;
            case (expected_value)
                5'd0:  expected_seg_an0 = 7'b0001000; // A
                5'd1:  expected_seg_an0 = 7'b0000011; // b
                5'd2:  expected_seg_an0 = 7'b1000110; // C
                5'd3:  expected_seg_an0 = 7'b0100001; // d
                5'd4:  expected_seg_an0 = 7'b0000110; // E
                5'd5:  expected_seg_an0 = 7'b0001110; // F
                5'd6:  expected_seg_an0 = 7'b1000010; // G
                5'd7:  expected_seg_an0 = 7'b0001001; // H
                5'd8:  expected_seg_an0 = 7'b1111001; // i
                5'd10: expected_seg_an0 = 7'b1000111; // L
                5'd12: expected_seg_an0 = 7'b0101011; // n
                5'd13: expected_seg_an0 = 7'b0100011; // o
                5'd14: expected_seg_an0 = 7'b0001100; // P
                5'd15: expected_seg_an0 = 7'b0011000; // q
                5'd16: expected_seg_an0 = 7'b0101111; // r
                5'd17: expected_seg_an0 = 7'b0010010; // S
                5'd18: expected_seg_an0 = 7'b1111000; // t
                5'd19: expected_seg_an0 = 7'b1000001; // U
                5'd23: expected_seg_an0 = 7'b0010001; // y
                default: expected_seg_an0 = 7'b1111111;
            endcase
            expected_seg_an1 = 7'b1111111;
        end else begin
            expected_an_an0 = 4'b1110;
            expected_an_an1 = 4'b1101;
            if (expected_value == 5'd31) begin
                expected_seg_an1 = 7'b0010000; // 9
                expected_seg_an0 = 7'b0010000; // 9
            end else begin
                case (expected_value / 10)
                    4'd0: expected_seg_an1 = 7'b1000000; // 0
                    4'd1: expected_seg_an1 = 7'b1111001; // 1
                    4'd2: expected_seg_an1 = 7'b0100100; // 2
                    default: expected_seg_an1 = 7'b1111111;
                endcase
                case (expected_value % 10)
                    4'd0: expected_seg_an0 = 7'b1000000; // 0
                    4'd1: expected_seg_an0 = 7'b1111001; // 1
                    4'd2: expected_seg_an0 = 7'b0100100; // 2
                    4'd3: expected_seg_an0 = 7'b0110000; // 3
                    4'd4: expected_seg_an0 = 7'b0011001; // 4
                    4'd5: expected_seg_an0 = 7'b0010010; // 5
                    4'd6: expected_seg_an0 = 7'b0000010; // 6
                    4'd7: expected_seg_an0 = 7'b1111000; // 7
                    4'd8: expected_seg_an0 = 7'b0000000; // 8
                    4'd9: expected_seg_an0 = 7'b0010000; // 9
                    default: expected_seg_an0 = 7'b1111111;
                endcase
            end
        end

        // Check AN0
        while (an !== expected_an_an0) @(posedge clk);
        if (seg !== expected_seg_an0)
            $error("AN0 incorrect: value=%0d, SW0=%b, expected_seg=%b, got=%b", value, SW0, expected_seg_an0, seg);
        // Check AN1
        while (an !== expected_an_an1) @(posedge clk);
        if (seg !== expected_seg_an1)
            $error("AN1 incorrect: value=%0d, SW0=%b, expected_seg=%b, got=%b", value, SW0, expected_seg_an1, seg);
    endtask

    // Main test sequence
    initial begin
        // Initialize signals
        resetn = 0;
        SW0 = 0;
        ahb_s0_haddr_i = '0;
        ahb_s0_hwrite_i = 0;
        ahb_s0_hsize_i = '0;
        ahb_s0_hburst_i = '0;
        ahb_s0_hprot_i = '0;
        ahb_s0_htrans_i = HTRANS_IDLE;
        ahb_s0_hmastlock_i = 0;
        ahb_s0_hwdata_i = '0;
        #20;
        resetn = 1;
        @(posedge clk);

        // Test 1: Reset state (should display "99")
        $display("Test 1: Checking reset state (expect '99')");
        repeat (2*(2**15)) @(posedge clk);
        while (an !== 4'b1110) @(posedge clk);
        if (seg !== 7'b0010000 || an !== 4'b1110 || !ahb_s0_hready_o || ahb_s0_hresp_o)
            $error("Reset AN0 incorrect: expected_seg=0010000, expected_an=1110, expected_hready=1, expected_hresp=0, got seg=%b, an=%b, hready=%b, hresp=%b", seg, an, ahb_s0_hready_o, ahb_s0_hresp_o);
        while (an !== 4'b1101) @(posedge clk);
        if (seg !== 7'b0010000 || an !== 4'b1101)
            $error("Reset AN1 incorrect: expected_seg=0010000, expected_an=1101, got seg=%b, an=%b", seg, an);

        // Test 2: Numeric mode (SW0=0)
        $display("Test 2: Numeric mode (SW0=0)");
        SW0 = 0;
        for (int i = 0; i <= 6; i++) begin
            $display("Testing value=%0d, SW0=0, expected_value=%0d", i, i);
            test_display(i[4:0], SW0, i[4:0]);
        end
        test_display(5'd23, SW0, 5'd23); // Display "23"
        test_display(5'd24, SW0, 5'd31); // Display "99"

        // Test 3: Alphabetic mode (SW0=1)
        $display("Test 3: Alphabetic mode (SW0=1)");
        SW0 = 1;
        test_display(5'd0, SW0, 5'd0);   // Display "A"
        test_display(5'd15, SW0, 5'd15); // Display "q"
        test_display(5'd9, SW0, 5'd9);   // Invalid letter "k", display "09"
        test_display(5'd24, SW0, 5'd31); // Display "99"

        // Test 4: Read data_reg
        $display("Test 4: Read data_reg");
        ahb_write(32'hC000_0000, 32'h0000001F); // Write 31
        ahb_read(32'hC000_0000, rdata);
        if (rdata[4:0] !== 5'd31)
            $error("Read data_reg incorrect: expected=31, got=%0d", rdata[4:0]);

        // Test 5: Invalid address
        $display("Test 5: Invalid address write");
        ahb_write(32'hC000_0008, 32'hDEADBEEF);
        @(posedge clk);
        if (!ahb_s0_hready_o)
            $error("Invalid address write should not affect hready");

        // Test 6: Non-supported transfer (BUSY)
        $display("Test 6: Non-supported transfer (BUSY)");
        @(posedge clk);
        ahb_s0_haddr_i = 32'hC000_0000;
        ahb_s0_hwrite_i = 1;
        ahb_s0_htrans_i = HTRANS_BUSY;
        @(posedge clk);
        ahb_s0_htrans_i = HTRANS_IDLE;
        ahb_s0_hwrite_i = 0;
        @(posedge clk);
        if (!ahb_s0_hready_o)
            $error("BUSY transfer should not affect hready");

        // Test 7: Non-supported transfer (SEQ)
        $display("Test 7: Non-supported transfer (SEQ)");
        @(posedge clk);
        ahb_s0_haddr_i = 32'hC000_0000;
        ahb_s0_hwrite_i = 1;
        ahb_s0_htrans_i = HTRANS_SEQ;
        @(posedge clk);
        ahb_s0_hwdata_i = 32'h0000000A;
        ahb_s0_htrans_i = HTRANS_IDLE;
        ahb_s0_hwrite_i = 0;
        while (!ahb_s0_hready_o) @(posedge clk);
        ahb_read(32'hC000_0000, rdata);
        if (rdata[4:0] == 5'd10)
            $error("SEQ transfer incorrectly updated data_reg to 10");

        $display("All tests completed");
        $finish;
    end

endmodule