module CounterExample (
    input wire clk,
    output reg [2:0] xCoordinate,
    output reg [2:0] yCoordinate,
    output reg [4:0] address,
    output reg [7:0] data
);

    reg [2:0] x;
    reg [2:0] y;

always @(posedge clk) begin
    // Loop over y values from 0 to 20 with a step of 5
    if (y <= 20) begin
        // Loop over x values from 0 to 4
        if (x <= 4) begin
            // Calculate the address, xCoordinate, and yCoordinate
            address  <= x + y;
            xCoordinate <= x;
            yCoordinate <= y / 5;

            // Data stored in the address (you need to define your data)
            data <= your_data_here;

            // Increment x for the inner loop
            x <= x + 1;
        end else begin
            // Reset x for the next iteration of the inner loop
            x <= 0;

            // Increment y for the outer loop
            y <= y + 5;
        end
    end
end

endmodule
