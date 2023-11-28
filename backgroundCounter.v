/*module backgroundCounter (
	 input reset,
    output wire [7:0] x_coordinate,
    output wire [6:0] y_coordinate,
    output wire [2:0] color,
    output reg enable
);

    reg [7:0] x_addr;
    reg [6:0] y_addr;
    wire [2:0] data;
    wire wren;
    wire [2:0] q;
    // reg enable;

    // Logic for iterating through memory cells
    always @(posedge clk) begin
		  if (reset) begin
				x_addr <= 0;
				y_addr <= 0;
				color <= 0;
			end
        if (enable) begin
            if (x_addr < 159) begin
                x_addr <= x_addr + 1;
            end else if (y_addr < 119) begin
                x_addr <= 0;
                y_addr <= y_addr + 1;
            end else begin
                x_addr <= 0;
                y_addr <= 0;
            end
            enable <= 0; // Reset the enable signal after each iteration
        end
    end

    // Connect the address, data, wren, and q signals to the stage1 module
    stage1 stage1_instance (
        .address({y_addr, x_addr}),
        .clock(clk), // Replace with your clock signal
        .data(data),
        .wren(wren),
        .q(q)
    );

    // Extract x, y coordinates and color from the address and data
    assign x_coordinate = x_addr;
    assign y_coordinate = y_addr;
    assign color = data;
	 
endmodule
	 
//
//
//module backgroundCounter (
//    output wire [119:0] x_coordinate,
//    output wire [159:0] y_coordinate,
//    output wire [2:0] color,
//    output wire enable
//);
//
//    reg [14:0] address;
//    wire [2:0] data;
//    wire wren;
//    wire [2:0] q;
//
//    // Logic for iterating through memory cells
//	 assign enable <= 1;
//	 
//    always @(posedge clk or posedge rst) begin
//        if (rst) begin
//            address <= 0;
//        end else if (enable) begin
//            if (address < 32767) begin
//                address <= address + 1;
//            end else begin
//                address <= 0;
//					 enable <= 0;
//            end
//        end
//    end
//
//    // Connect the address, data, wren, and q signals to the stage1 module
//    stage1 stage1_instance (
//        .address(address),
//        .clock(clk), // Replace with your clock signal
//        .data(data),
//        .wren(wren),
//        .q(q)
//    );
//
//    // Extract x, y coordinates and color from the address and data
//    assign x_coordinate = address[6:0];
//    assign y_coordinate = address[13:7];
//    assign color = data;
//
//    // Enable signal can be controlled externally
////    assign enable = external_enable_signal; // Replace with your enable signal source
//
//endmodule
//
//
//


//module backgroundCounter(iResetn,iPlotBox,iColour,iXY_Coord,iClock,oX,oY,oColour,oDone);
//
//	
//
//	 vgaCounter v0(.reset(iResetn), .enable(ld_clear), .clock(iClock), .x_dim(X_SCREEN_PIXELS), .y_dim(Y_SCREEN_PIXELS),
//    .xCounter(xCounter), .yCounter(yCounter));
//
//endmodule
//
//module vgaCounter(clock, reset, enable, x_dim, y_dim, xCounter, yCounter);
//    input wire clock, reset, enable;
//    input wire [7:0] x_dim;
//    input wire [6:0] y_dim;
//    output reg [7:0] xCounter;
//    output reg [6:0] yCounter;
//    reg ifStop;
//
//    always @ (posedge clock) begin
//	if (!reset) begin
//		xCounter <= 8'b0;
//		yCounter <= 7'b0;
//		ifStop <= 1'b0;
//	end
//	else if (enable && !ifStop) begin // && !ld_reached
//		if (xCounter == x_dim - 1) begin
//			xCounter <= 8'b0;
//			if (yCounter == y_dim - 1) begin
//				ifStop <= 1'b1;
//				yCounter <= 7'b0;
//			end
//			else begin
//				yCounter <= yCounter + 1;
//			end
//		end
//		else begin
//			xCounter <= xCounter + 1;
//		end
//	end
//	else begin
//		xCounter <= 8'b0;
//		yCounter <= 7'b0;
//	end
//    end
//
//endmodule
*/
