module snoopy
#(parameter CLOCK_FREQUENCY = 50000000)(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,							// On Board Keys
		HEX0,
		HEX1,
		HEX2,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;
	output [6:0] HEX0, HEX1, HEX2;	
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	wire [7:0] x = {4'b0000, x_c};
	wire [6:0] y= {3'b000, y_c};
	wire writeEn;  //is this ok?

	//wire [7:0] x_temp = {5'b00000, x_c};
	//wire [6:0] y_temp = {4'b0000, y_c};

	wire [7:0] address;
	
	// rate divider
 
	hex_decoder uA( .c(colour[2]), .display(HEX2[6:0]) );
	hex_decoder uB( .c(colour[1]), .display(HEX1[6:0]) );
	hex_decoder uC( .c(colour[0]), .display(HEX0[6:0]) );
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "image.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
	characterCounter u0(.resetn(resetn), .clk(enable), .x_coordinate(x_c), .y_coordinate(y_c), .address(address), .done(WriteEn));
	snoopyCharacter u1(.address(address), .clock(enable), .data(3'b000), .wren(1'b0), .q(colour));
	
	RateDivider #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) RDInst ( .ClockIn(CLOCK_50), .Reset(resetn), .Enable(enable));
	
endmodule


module RateDivider
#(parameter CLOCK_FREQUENCY = 500) (
input ClockIn,
input Reset,
output reg Enable
);

    reg [26:0] down_count;
    reg temp;

    always @ (*)
    begin

			temp = CLOCK_FREQUENCY;

    end

    always @ (posedge ClockIn)
    begin
        if ((Reset == 1'b1) || (down_count == 27'd0))
            begin
                Enable = 1'b0; //start with enable = 1 or 0??
                down_count <= temp;
            end
        else
            begin
                Enable = 1'b0;
                down_count <= down_count - 1;
            end
    end
    assign enable = (down_count == 27'd0)? 1'b1:1'b0;
endmodule


module hex_decoder (c, display);

	input[3: 0] c;
	output[6: 0] display;

	wire m0, ml, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15;

	assign m0 = ~c[3] & ~c[2] & ~c[1] & ~c[0];
	assign m1 = ~c[3] & ~c[2] & ~c[1] & c[0];
	assign m2 = ~c[3] & ~c[2] & c[1] & ~c[0];
	assign m3 = ~c[3] & ~c[2] & c[1] & c[0];
	assign m4 = ~c[3] & c[2] & ~c[1] & ~c[0];
	assign m5 = ~c[3] & c[2] & ~c[1] & c[0];
	assign m6 = ~c[3] & c[2] & c[1] & ~c[0];
	assign m7 = ~c[3] & c[2] & c[1] & c[0];
	assign m8 = c[3] & ~c[2] & ~c[1] & ~c[0];
	assign m9 = c[3] & ~c[2] & ~c[1] & c[0];
	assign m10 = c[3] & ~c[2] & c[1] & ~c[0];
	assign m11 = c[3] & ~c[2] & c[1] & c[0];
	assign m12 = c[3] & c[2] & ~c[1] & ~c[0];
	assign m13 = c[3] & c[2] & ~c[1] & c[0];
	assign m14 = c[3] & c[2] & c[1] & ~c[0];
	assign m15 = c[3] & c[2] & c[1] & c[0];

	assign display[0] = ~(m0 | m2 | m3 | m5 | m6 | m7 | m8 | m9 | m10 | m12 | m14 | m15); //sum of product of minterms
	assign display[1] = ~(m0 | m1 | m2 | m3 | m4 | m7 | m8 | m9 | m10 | m13);
	assign display[2] = ~(m0 | m1 | m3 | m4 | m5 | m6 | m7 | m8 | m9 | m10 | m11 | m13);
	assign display[3] = ~(m0 | m2 | m3 | m5 | m6 | m8 | m9 | m11 | m12 | m13 | m14);
	assign display[4] = ~(m0 | m2 | m6 | m8 | m10 | m11 | m12 | m13 | m14 | m15);
	assign display[5] = ~(m0 | m4 | m5 | m6 | m8 | m9 | m10 | m11 | m12 | m14 | m15);
	assign display[6] = ~(m2 | m3 | m4 | m5 | m6 | m8 | m9 | m10 | m11 | m14 | m15);


endmodule
