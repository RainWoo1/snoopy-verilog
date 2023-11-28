module temp2 (
    input resetn,
    input wire clk,
    output reg [3:0] x_coordinate,
    output reg [3:0] y_coordinate,
    output reg [7:0] address
);

    reg [3:0] x; // 0 to 15 (4 bits)
    reg [3:0] y; // 0 to 15 (4 bits)

    always @(posedge clk) begin
        if (resetn) begin
            x_coordinate <= 4'b0000;
            y_coordinate <= 4'b0000;
            address <= 8'b00000000;
            x <= 4'b0000;
            y <= 4'b0000;
        end else begin
            // Calculate the address, x_coordinate, and y_coordinate
            address <= x + 16*y;
            x_coordinate <= x;
            y_coordinate <= y;

            // Increment x and y for the inner loop
            if (x == 15) begin
                x <= 0;
                y <= y + 1;
            end else begin
                x <= x + 1;
            end
        end
    end
endmodule
