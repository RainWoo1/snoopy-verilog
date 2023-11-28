module characterCounter (
	input reset,
    input wire clk,
    output reg [2:0] x_coordinate,
    output reg [2:0] y_coordinate,
	output reg [2:0] color,
    output reg [4:0] address
);

reg [2:0] x; // 0 to 5 3 bit
reg [2:0] y; // 0 to 20 (+5) [3:0]

always @(posedge clk) begin
	 if (reset) begin
		x_coordinate <= 3'b000;
		y_coordinate <= 3'b000;
		color <= 3'b000;
		address <= 5'b00000;
        x <= 3'b000;
		y <= 3'b000;
	 end
    // Loop over y values from 0 to 20 with a step of 5
    if (y <= 4) begin
        // Loop over x values from 0 to 4
        if (x <= 4) begin
            // Calculate the address, x_coordinate, and y_coordinate
            address  <= x + 5*y;
            x_coordinate <= x;
            y_coordinate <= y;
            //address  <= {1'b0, x + y};

            // Increment x for the inner loop
            x <= x + 1;
        end else begin
            // Reset x for the next iteration of the inner loop
            x <= 0;

            // Increment y for the outer loop
            y <= y + 1;
        end
    end
end
    // Extract x, y coordinates and color from the address and data
//    assign x_coordinate = x;
//    assign y_coordinate = y;
//    assign color = data;

endmodule
