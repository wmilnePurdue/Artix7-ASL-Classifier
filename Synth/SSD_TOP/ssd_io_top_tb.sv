`timescale 1ns / 1ps

module ssd_io_top_tb;

    // Testbench signals
    logic        clk;       // 100 MHz clock
    logic        btnC;      // Reset button (active high)
    logic [5:0]  sw;       // Switches: sw[4:0] for data_reg, sw[5] for display mode
    logic [6:0]  seg;      // 7-segment cathodes
    logic [3:0]  an;       // 7-segment anodes

    // Instantiate ssd_io_top
    ssd_io_top u_ssd_io_top (
        .clk(clk),
        .btnC(btnC),
        .sw(sw),
        .seg(seg),
        .an(an)
    );

    // Clock generation (100 MHz, 10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Task to test SSD display
    task automatic test_display(input logic [4:0] value, input logic SW0, input logic [4:0] expected_value);
        logic [6:0] expected_seg_an0, expected_seg_an1;
        logic [3:0] expected_an_an0, expected_an_an1;
        logic invalid_letter;

        // Set switches
        sw = {SW0, value};
        // Wait for AHB writes to complete (monitor hready)
        repeat (200) @(posedge clk); // Increased wait for state machine
        while (!u_ssd_io_top.u_ssd_io.ahb_s0_hready_o) @(posedge clk);
        repeat (200) @(posedge clk); // Ensure done_flag is processed

        // Wait for refresh cycle (2^15 cycles per digit)
        repeat (2*(2**15)) @(posedge clk);

        // Debug output
        $display("Debug: value=%0d, SW0=%b, data_reg=%0d, display_value=%0d, haddr=%h, hwdata=%h, htrans=%b, hwrite=%b, hready=%b, sw=%b, sw_last=%b, sw_changed=%b, state=%0d",
                 value, SW0, u_ssd_io_top.u_ssd_io.data_reg, u_ssd_io_top.u_ssd_io.display_value,
                 u_ssd_io_top.ahb_s0_haddr, u_ssd_io_top.ahb_s0_hwdata, u_ssd_io_top.ahb_s0_htrans,
                 u_ssd_io_top.ahb_s0_hwrite, u_ssd_io_top.u_ssd_io.ahb_s0_hready_o,
                 u_ssd_io_top.sw_sync, u_ssd_io_top.sw_last, u_ssd_io_top.sw_changed,
                 u_ssd_io_top.state);

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
                expected_seg_an0 = 7'b0010000; // 9 (ones)
                expected_seg_an1 = 7'b0010000; // 9 (tens)
            end else begin
                case (expected_value % 10) // AN0: ones
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
                case (expected_value / 10) // AN1: tens
                    4'd0: expected_seg_an1 = 7'b1000000; // 0
                    4'd1: expected_seg_an1 = 7'b1111001; // 1
                    4'd2: expected_seg_an1 = 7'b0100100; // 2
                    default: expected_seg_an1 = 7'b1111111;
                endcase
            end
        end

        // Check AN0 (ones)
        while (an !== expected_an_an0) @(posedge clk);
        if (seg !== expected_seg_an0)
            $error("AN0 incorrect: value=%0d, SW0=%b, expected_seg=%b, got=%b",
                   value, SW0, expected_seg_an0, seg);

        // Check AN1 (tens)
        while (an !== expected_an_an1) @(posedge clk);
        if (seg !== expected_seg_an1)
            $error("AN1 incorrect: value=%0d, SW0=%b, expected_seg=%b, got=%b",
                   value, SW0, expected_seg_an1, seg);
    endtask

    // Main test sequence
    initial begin
        // Initialize signals
        btnC = 1; // Assert reset
        sw = '0;
        #20;
        btnC = 0; // Deassert reset
        @(posedge clk);
        repeat (200) @(posedge clk); // Wait for state machine stabilization

        // Test 1: Reset state (should display "99")
        $display("Test 1: Checking reset state (expect '99')");
        repeat (2*(2**15)) @(posedge clk);
        while (an !== 4'b1110) @(posedge clk);
        if (seg !== 7'b0010000 || an !== 4'b1110)
            $error("Reset AN0 incorrect: expected_seg=0010000, expected_an=1110, got seg=%b, an=%b", seg, an);
        while (an !== 4'b1101) @(posedge clk);
        if (seg !== 7'b0010000 || an !== 4'b1101)
            $error("Reset AN1 incorrect: expected_seg=0010000, expected_an=1101, got seg=%b, an=%b", seg, an);

        // Test 2: Numeric mode (SW0=0)
        //seems to have error on write write after reset (?)
        test_display(5'b0, 1'b0, 5'b0);
        $display("Test 2: Numeric mode (SW0=0)");
        for (int i = 0; i <= 6; i++) begin
            $display("Testing value=%0d, SW0=0, expected_value=%0d", i, i);
            test_display(i[4:0], 1'b0, i[4:0]);
        end
        $display("Testing value=23, SW0=0, expected_value=23");
        test_display(5'd23, 1'b0, 5'd23); // Display "23"
        $display("Testing value=24, SW0=0, expected_value=31");
        test_display(5'd24, 1'b0, 5'd31); // Display "99"
        test_display(5'b0, 1'b0, 5'b0); //looks like I have some logic in the top level preventing it from writing zero after reset, but this is no problem for actual system

        // Test 3: Alphanumeric mode (SW0=1)
        $display("Test 3: Alphanumeric mode (SW0=1)");
        $display("Testing value=0, SW0=1, expected_value=0");
        test_display(5'd0, 1'b1, 5'd0);   // Display "A"
        $display("Testing value=15, SW0=1, expected_value=15");
        test_display(5'd15, 1'b1, 5'd15); // Display "q"
        $display("Testing value=9, SW0=1, expected_value=9");
        test_display(5'd9, 1'b1, 5'd9);   // Invalid letter "k", display "09"
        $display("Testing value=24, SW0=1, expected_value=31");
        test_display(5'd24, 1'b1, 5'd31); // Display "99"

        // Test 4: Switch transitions
        $display("Test 4: Switch transitions");
        // Toggle SW0 (display mode) and value
        sw = {1'b0, 5'd10}; // Numeric, value=10
        repeat (200) @(posedge clk);
        while (!u_ssd_io_top.u_ssd_io.ahb_s0_hready_o) @(posedge clk);
        repeat (2*(2**15)) @(posedge clk);
        while (an !== 4'b1110) @(posedge clk);
        if (seg !== 7'b1111001 || an !== 4'b1110) // Expect "1" for ones
            $error("Switch transition (value=10, SW0=0) AN0 incorrect: expected_seg=1111001, got=%b", seg);
        while (an !== 4'b1101) @(posedge clk);
        if (seg !== 7'b1000000 || an !== 4'b1101) // Expect "0" for tens
            $error("Switch transition (value=10, SW0=0) AN1 incorrect: expected_seg=1000000, got=%b", seg);

        sw = {1'b1, 5'd10}; // Alphanumeric, value=10
        repeat (200) @(posedge clk);
        while (!u_ssd_io_top.u_ssd_io.ahb_s0_hready_o) @(posedge clk);
        repeat (2*(2**15)) @(posedge clk);
        while (an !== 4'b1110) @(posedge clk);
        if (seg !== 7'b1000111 || an !== 4'b1110) // Expect "L"
            $error("Switch transition (value=10, SW0=1) AN0 incorrect: expected_seg=1000117, got=%b", seg);

        // Test 5: Rapid switch changes
        $display("Test 5: Rapid switch changes");
        sw = {1'b0, 5'd5}; // Numeric, value=5
        repeat (100) @(posedge clk);
        sw = {1'b0, 5'd6}; // Numeric, value=6
        repeat (200) @(posedge clk);
        while (!u_ssd_io_top.u_ssd_io.ahb_s0_hready_o) @(posedge clk);
        repeat (2*(2**15)) @(posedge clk);
        while (an !== 4'b1110) @(posedge clk);
        if (seg !== 7'b0000010 || an !== 4'b1110) // Expect "6" for ones
            $error("Rapid switch change (value=6, SW0=0) AN0 incorrect: expected_seg=0000010, got=%b", seg);
        while (an !== 4'b1101) @(posedge clk);
        if (seg !== 7'b1000000 || an !== 4'b1101) // Expect "0" for tens
            $error("Rapid switch change (value=6, SW0=0) AN1 incorrect: expected_seg=1000000, got=%b", seg);

        $display("All tests completed");
        $finish;
    end

endmodule