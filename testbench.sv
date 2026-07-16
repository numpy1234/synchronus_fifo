`timescale 1ns/1ps

module tb_sync_fifo;

    parameter DATA_WIDTH = 8;
    parameter DEPTH      = 16;
    parameter ADDR_WIDTH = 4;

    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [DATA_WIDTH-1:0] din;

    wire [DATA_WIDTH-1:0] dout;
    wire full;
    wire empty;

    // Instantiate FIFO
    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    // Clock generation (10 ns period)
    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        rst   = 1;
        wr_en = 0;
        rd_en = 0;
        din   = 0;

        // Apply reset
        #20;
        rst = 0;

        
        // Write 5 values
        
        $display("\nWriting Data...");
        repeat(5) begin
            @(posedge clk);
            wr_en = 1;
            din = din + 8'h11;
        end

        @(posedge clk);
        wr_en = 0;

        
        // Read 5 values
        
        $display("\nReading Data...");
        repeat(5) begin
            @(posedge clk);
            rd_en = 1;
        end

        @(posedge clk);
        rd_en = 0;

        
        // Fill FIFO completely
        
        $display("\nFilling FIFO...");
        repeat(DEPTH) begin
            @(posedge clk);
            wr_en = 1;
            din = din + 1;
        end

        @(posedge clk);
        wr_en = 0;

        
        // Empty FIFO completely
        
        $display("\nEmptying FIFO...");
        repeat(DEPTH) begin
            @(posedge clk);
            rd_en = 1;
        end

        @(posedge clk);
        rd_en = 0;

        
        // Simultaneous Read & Write
        
        $display("\nSimultaneous Read and Write...");

        @(posedge clk);
        wr_en = 1;
        din = 8'hAA;

        @(posedge clk);
        wr_en = 0;

        @(posedge clk);
        wr_en = 1;
        rd_en = 1;
        din = 8'hBB;

        @(posedge clk);
        wr_en = 0;
        rd_en = 0;

        #20;
        $finish;
    end

    // Monitor signals
    initial begin
        $display("Time\tWr\tRd\tDin\tDout\tCount\tFull\tEmpty");
        $monitor("%0t\t%b\t%b\t%h\t%h\t%d\t%b\t%b",
                 $time,
                 wr_en,
                 rd_en,
                 din,
                 dout,
                 uut.count,
                 full,
                 empty);
    end

    initial begin
        $dumpfile("dump.vcd");   
        $dumpvars(0, tb_sync_fifo); 
    end

endmodule