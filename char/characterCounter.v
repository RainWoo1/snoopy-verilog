module characterCounter (
	input resetn,
    input wire clk,
	output reg [3:0] x_coordinate,
	output reg [3:0] y_coordinate,
	output reg [7:0] address
);

	reg [3:0] x; // 0 to 5 3 bit
	reg [3:0] y; // 0 to 20 (+5) [3:0]

always @(posedge clk) begin
	if (resetn) begin
		x_coordinate <= 4'b0000;
		y_coordinate <= 4'b0000;
		address <= 8'b00000000;
        x <= 4'b0000;
		y <= 4'b0000;
	 end
    // Loop over y values from 0 to 20 with a step of 5
	if (y <= 15) begin
        // Loop over x values from 0 to 4
		if (x <= 15) begin
            // Calculate the address, x_coordinate, and y_coordinate
            address  <= x + 16*y;
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
