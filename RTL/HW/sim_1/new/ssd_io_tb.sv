`timescale 1ns / 1ps

module ssd_io_tb;

    // Testbench signals
    logic        clk;              // 100 MHz clock
    logic        resetn;           // Active-low reset
    logic [31:0] ahb_haddr;        // AHB-L address
    logic        ahb_hwrite;       // AHB-L write enable
    logic [2:0]  ahb_hsize;        // AHB-L size
    logic [2:0]  ahb_hburst;       // AHB-L burst
    logic [3:0]  ahb_hprot;        // AHB-L protection
    logic [1:0]  ahb_htrans;       // AHB-L transfer type
    logic        ahb_hmastlock;    // AHB-L master lock
    logic [31:0] ahb_hwdata;       // AHB-L write data
    logic [31:0] ahb_hrdata;       // AHB-L read data
    logic        ahb_hready;       // AHB-L ready signal
    logic        ahb_hresp;        // AHB-L response
    logic        SW0;              // Switch for display mode
    logic [6:0]  seg;              // SSD cathode segments
    logic [3:0]  an;               // SSD anode control

    // Instantiate AHB master
    ahb_master u_ahb_master (
        .clk(clk),
        .resetn(resetn),
        .ahb_haddr_o(ahb_haddr),
        .ahb_hwrite_o(ahb_hwrite),
        .ahb_hsize_o(ahb_hsize),
        .ahb_hburst_o(ahb_hburst),
        .ahb_hprot_o(ahb_hprot),
        .ahb_htrans_o(ahb_htrans),
        .ahb_hmastlock_o(ahb_hmastlock),
        .ahb_hwdata_o(ahb_hwdata),
        .ahb_hready_i(ahb_hready),
        .ahb_hresp_i(ahb_hresp),
        .ahb_hrdata_i(ahb_hrdata)
    );

    // Instantiate SSD IO slave
    ssd_io u_ssd_io (
        .clk(clk),
        .resetn(resetn),
        .ahb_s0_haddr_i(ahb_haddr),
        .ahb_s0_hwrite_i(ahb_hwrite),
        .ahb_s0_hsize_i(ahb_hsize),
        .ahb_s0_hburst_i(ahb_hburst),
        .ahb_s0_hprot_i(ahb_hprot),
        .ahb_s0_htrans_i(ahb_htrans),
        .ahb_s0_hmastlock_i(ahb_hmastlock),
        .ahb_s0_hwdata_i(ahb_hwdata),
        .SW0(SW0),
        .ahb_s0_hrdata_o(ahb_hrdata),
        .ahb_s0_hready_o(ahb_hready),
        .ahb_s0_hresp_o(ahb_hresp),
        .seg(seg),
        .an(an)
    );

    // Clock generation (100 MHz, 10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Override ahb_master initial block for comprehensive testing
    initial begin
        // Initialize signals
        resetn = 0;
        SW0 = 0;
        #20;
        resetn = 1;

        // Wait for reset to propagate
        @(posedge clk);

        // Test 1: Reset state
        $display("Test 1: Checking reset state");
        if (seg !== 7'b1111111 || an !== 4'b1111 || ahb_hready !== 1'b1 || ahb_hresp !== 1'b0)
            $error("Reset state incorrect: seg=%b, an=%b, hready=%b, hresp=%b", seg, an, ahb_hready, ahb_hresp);

        // Test 2: Numeric mode (SW0=0)
        $display("Test 2: Numeric mode (SW0=0)");
        SW0 = 0;
        for (int i = 0; i <= 24; i++) begin
            test_display(i, SW0, (i > 23) ? 31 : i);
        end

        // Test 3: Alphabetic mode (SW0=1)
        $display("Test 3: Alphabetic mode (SW0=1)");
        SW0 = 1;
        for (int i = 0; i <= 24; i++) begin
            test_display(i, SW0, (i > 23) ? 31 : i);
        end

        // Test 4: Invalid address write
        $display("Test 4: Invalid address write");
        u_ahb_master.ahb_write(32'hD000_0008, 32'hDEADBEEF);
        @(posedge clk);
        if (ahb_hready !== 1'b1)
            $error("Invalid address write should not affect hready");

        // Test 5: Read back data_reg
        $display("Test 5: Read back data_reg");
        u_ahb_master.ahb_write(32'hD000_0000, 32'h00000015); // Write 15 (q)
        u_ahb_master.ahb_read(32'hD000_0000);
        @(posedge clk);
        if (u_ahb_master.rd_data[4:0] !== 5'd15)
            $error("Read back data_reg incorrect: expected=15, got=%d", u_ahb_master.rd_data[4:0]);

        // Test 6: Non-NSEQ transfer
        $display("Test 6: Non-NSEQ transfer");
        @(posedge clk);
        u_ahb_master.ahb_haddr_o = 32'hD000_0000;
        u_ahb_master.ahb_hwrite_o = 1;
        u_ahb_master.ahb_htrans_o = 2'b01; // HTRANS_BUSY
        @(posedge clk);
        #0.1;
        u_ahb_master.ahb_htrans_o = 2'b00; // HTRANS_IDLE
        u_ahb_master.ahb_hwrite_o = 0;
        @(posedge clk);
        if (ahb_hready !== 1'b1)
            $error("Non-NSEQ transfer should not affect hready");

        $display("All tests completed");
        $finish;
    end

    // Task to test display for a given value
    task test_display(input [4:0] value, input SW0, input [4:0] expected_value);
        logic [6:0] expected_seg_an3, expected_seg_an2;
        logic [3:4] expected_an_an3, expected_an_an2;
        logic invalid_letter;

        // Write value to data_reg
        u_ahb_master.ahb_write(32'hD000_0000, {27'b0, value});
        // Write done_flag
        u_ahb_master.ahb_write(32'hD000_0004, 32'h00000001);

        // Wait for refresh counter to cycle through AN2 and AN3
        repeat (2**18) @(posedge clk); // Ensure full refresh cycle (~2.6 ms)

        // Determine expected display
        invalid_letter = (expected_value == 5'd9 || expected_value == 5'd11 || 
                          expected_value == 5'd20 || expected_value == 5'd21 || expected_value == 5'd22);
        if (SW0 && expected_value <= 5'd23 && !invalid_letter) begin
            // Alphabetic mode, valid letter
            expected_an_an3 = 4'b1110; // AN3 active
            expected_an_an2 = 4'b1111; // AN2 off
            case (expected_value)
                5'd0:  expected_seg_an3 = 7'b0001000; // A
                5'd1:  expected_seg_an3 = 7'b0000011; // b
                5'd2:  expected_seg_an3 = 7'b1000110; // C
                5'd3:  expected_seg_an3 = 7'b0100001; // d
                5'd4:  expected_seg_an3 = 7'b0000110; // E
                5'd5:  expected_seg_an3 = 7'b0001110; // F
                5'd6:  expected_seg_an3 = 7'b1000010; // G
                5'd7:  expected_seg_an3 = 7'b0001001; // H
                5'd8:  expected_seg_an3 = 7'b1111001; // i
                5'd10: expected_seg_an3 = 7'b1000111; // L
                5'd12: expected_seg_an3 = 7'b0101011; // n
                5'd13: expected_seg_an3 = 7'b0100011; // o
                5'd14: expected_seg_an3 = 7'b0001100; // P
                5'd15: expected_seg_an3 = 7'b0011000; // q
                5'd16: expected_seg_an3 = 7'b0101111; // r
                5'd17: expected_seg_an3 = 7'b0010010; // S
                5'd18: expected_seg_an3 = 7'b1111000; // t
                5'd19: expected_seg_an3 = 7'b1000001; // U
                5'd23: expected_seg_an3 = 7'b0010001; // y
                default: expected_seg_an3 = 7'b1111111;
            endcase
            expected_seg_an2 = 7'b1111111;
        end else begin
            // Numeric mode or invalid letter or >23
            expected_an_an3 = 4'b1110; // AN3 active
            expected_an_an2 = 4'b1101; // AN2 active
            if (expected_value == 5'd31) begin
                expected_seg_an2 = 7'b0010000; // 9
                expected_seg_an3 = 7'b0010000; // 9
            end else begin
                case (expected_value / 10)
                    4'd0: expected_seg_an2 = 7'b1000000; // 0
                    4'd1: expected_seg_an2 = 7'b1111001; // 1
                    4'd2: expected_seg_an2 = 7'b0100100; // 2
                    default: expected_seg_an2 = 7'b1111111;
                endcase
                case (expected_value % 10)
                    4'd0: expected_seg_an3 = 7'b1000000; // 0
                    4'd1: expected_seg_an3 = 7'b1111001; // 1
                    4'd2: expected_seg_an3 = 7'b0100100; // 2
                    4'd3: expected_seg_an3 = 7'b0110000; // 3
                    4'd4: expected_seg_an3 = 7'b0011001; // 4
                    4'd5: expected_seg_an3 = 7'b0010010; // 5
                    4'd6: expected_seg_an3 = 7'b0000010; // 6
                    4'd7: expected_seg_an3 = 7'b1111000; // 7
                    4'd8: expected_seg_an3 = 7'b0000000; // 8
                    4'd9: expected_seg_an3 = 7'b0010000; // 9
                    default: expected_seg_an3 = 7'b1111111;
                endcase
            end
        end

        // Monitor and check SSD outputs
        $display("Testing value=%d, SW0=%b, expected_value=%d", value, SW0, expected_value);
        @(posedge clk);
        while (an !== expected_an_an3) @(posedge clk); // Wait for AN3
        if (seg !== expected_seg_an3)
            $error("AN3 incorrect: value=%d, SW0=%b, expected_seg=%b, got=%b", value, SW0, expected_seg_an3, seg);
        while (an !== expected_an_an2) @(posedge clk); // Wait for AN2
        if (seg !== expected_seg_an2)
            $error("AN2 incorrect: value=%d, SW0=%b, expected_seg=%b, got=%b", value, SW0, expected_seg_an2, seg);
    endtask

endmodule