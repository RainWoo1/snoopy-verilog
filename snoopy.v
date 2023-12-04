module snoopy
#(parameter CLOCK_FREQUENCY = 50000000)(
		CLOCK_50,						//	On Board 50 MHz
		KEY,							// On Board Keys
		SW,
		HEX0,
		HEX1,
		LEDR,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		PS2_CLK,
		PS2_DAT		
	);
	// 		HEX0,
//		HEX1,
//		HEX2,

	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;
	input [9:0] SW;
	output [9:0] LEDR;
	output [6:0] HEX0;
	output [6:0] HEX1;
//	output [6:0] HEX0, HEX1, HEX2;	
inout				PS2_CLK;
inout				PS2_DAT;

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
	
	wire [2:0] colour;
//	wire [7:0] x = {4'b0000, x_c};
//	wire [6:0] y = {3'b000, y_c};
	wire [7:0] x;
	wire [6:0] y;
	
	wire [7:0] xTemp;
	wire [6:0] yTemp;
	wire writeEn;
	wire Done;
	wire ifGround;
	wire [2:0] colTemp;

	wire [7:0] address;
	wire [14:0] addTemp = xTemp * yTemp;
	wire i_r = ~KEY[1] || input_right;
	wire i_l = ~KEY[2] || input_left;
	wire i_u = ~KEY[3] || input_up;
	wire input_right, input_left, input_up;
	wire isInput = i_r || i_l || i_u;
	wire is_collided, is_end, q_out;
	
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
		defparam VGA.BACKGROUND_IMAGE = "image1.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
	
//	characterCounter u0(.resetn(resetn), .clk(enable), .x_coordinate(x_c), .y_coordinate(y_c), .address(address), .done(WriteEn));
//	snoopyCharacter u1(.address(address), .clock(enable), .data(3'b000), .wren(1'b0), .q(colour));

		// VGA connectvga (.resetn(resetn), .writeEn(writeEn), .clock(CLOCK_50), .iX(~KEY[1]), .iY(~KEY[0]), .iColour(3'b100), .oX(x), .oY(y), .oColour(colour) );
//		VGAmodule vgaadapter (.iResetn(resetn), .iColour(3'b110), .iX(SW[7:0]), .iY(SW[6:0]), .iPlotBox(~KEY[1]), .iBlack(~KEY[2]), .iLoadX(~KEY[3]), .iClock(CLOCK_50),
//		.oX(x), .oY(y), .oColour(colour), .oPlot(writeEn), .oDone(Done) );


		RateDivider #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) RDInst ( .ClockIn(CLOCK_50), .Reset(resetn), .Enable(enable) );

		snoopyHorizontalFSM fsm1( .clock(enable), .reset(resetn), .input_left(i_l), .input_right(i_r), .snoopy_x(xTemp) );
		
		snoopyVerticalFSM fsm3 ( .clock(enable), .reset(resetn), .input_jump(i_u), .snoopy_y(yTemp) );
		
		VGAmodule vgaplay( .iResetn(resetn),.iColour(colTemp),.iX(xTemp),.iY(yTemp),.iLoadX(SW[0]),.iClock(CLOCK_50),.oX(x),.oY(y),.oColour(colour),.oPlot(writeEn),.oDone(Done) );
		
		gameFSM fsm4(.reset(resetn), .clock(enable), .collided(1'b0), .reached_screen_end(is_end), .user_input(isInput), .col(colTemp));
		
		collision_end colInst(.x_coord(xTemp), .y_coord(yTemp), .colour(q_out), .clock(enable), .resetn(resetn), .collided(is_collided), .reached_screen_end(is_end));
		
		stage mem(.address(addTemp), .clock(enable), .data(3'b000), .wren(1'b0), .q(q_out));
		
		PS2_Demo keyboard(CLOCK_50, KEY, PS2_CLK, PS2_DAT, HEX0, HEX1, LEDR, input_right, input_left, input_up);
// 	snoopyCharacter2 v1 (.address(address), .clock(CLOCK_50), .q(colour) );
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



module RateDivider
#(parameter CLOCK_FREQUENCY = 250) (
input ClockIn,
input Reset,
output reg Enable
);

    reg [26:0] down_count;
 //   reg temp;

//    always @ (*)
//    begin
//
//	temp = CLOCK_FREQUENCY;
//
//    end

    always @ (posedge ClockIn)
    begin
        if (!Reset)
            begin
                Enable = 1'b0; //start with enable = 1 or 0??
                down_count <= 2500000;
            end
		  else if (down_count == 27'd0)
				begin
					Enable = 1'b1;
					down_count <= 2500000;
				end
        else
            begin
                Enable = 1'b0;
                down_count <= down_count - 1;
            end
    end
    // assign Enable = (down_count == 27'd0)? 1'b1:1'b0;
endmodule
