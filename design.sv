module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16,
    parameter ADDR_WIDTH = 4    // log2(DEPTH)
)(
    input                       clk,
    input                       rst,

    input                       wr_en,
    input                       rd_en,
    input  [DATA_WIDTH-1:0]     din,

    output reg [DATA_WIDTH-1:0] dout,
    output                      full,
    output                      empty
);

    // FIFO Memory
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Read and Write pointers
    reg [ADDR_WIDTH-1:0] wr_ptr;
    reg [ADDR_WIDTH-1:0] rd_ptr;

    // Counter to track number of elements
    reg [ADDR_WIDTH:0] count;

    // Write operation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
        end
        else if (wr_en && !full) begin
            mem[wr_ptr] <= din;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read operation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_ptr <= 0;
            dout <= 0;
        end
        else if (rd_en && !empty) begin
            dout <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end
    end

    // Count logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
        end
        else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1; // Write only
                2'b01: count <= count - 1; // Read only
                2'b11: count <= count;     // Simultaneous read & write
                default: count <= count;
            endcase
        end
    end

    // Status signals
    assign full  = (count == DEPTH);
    assign empty = (count == 0);

endmodule