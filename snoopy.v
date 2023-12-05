module snoopy
#(parameter CLOCK_FREQUENCY = 50000000)(
		CLOCK_50,						//	On Board 50 MHz
		KEY,							// On Board Keys
		SW,
		HEX0,
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
		PS2_DAT,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		FPGA_I2C_SDAT,

		// Outputs
		AUD_XCK,
		AUD_DACDAT,

		FPGA_I2C_SCLK	
	);


	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;
	input [9:0] SW;
	output [9:0] LEDR;
	output [6:0] HEX0;
	//output [6:0] HEX1;

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
	//wire [14:0] addTemp = (xTemp + 8'd4) * (yTemp + 7'd2);
	wire [14:0] addTemp;
	//addTemp = xTemp * yTemp;
//	reg i_r;
//	i_r = ~KEY[1] || input_right;
//	reg i_l;
//	i_l = ~KEY[2] || input_left;
//	reg i_u;
//	i_u = ~KEY[3] || input_up;
	wire input_right, input_left, input_up;
	wire isInput = i_r || i_l || i_u;
	wire is_collided, is_end, q_out;
	wire [3:0] score;
	
reg i_r, i_l, i_u;

always @(*) begin
    // Update i_r, i_l, i_u based on KEY inputs or input directions
    i_r = ~KEY[1] || input_right;
    i_l = ~KEY[2] || input_left;
    i_u = ~KEY[3] || input_up;

    // Existing logic for handling game end or collision
    if (is_collided || is_end) begin
        i_r = 1'b0;
        i_l = 1'b0;
        i_u = 1'b0;
    end
end
	
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
		defparam VGA.BACKGROUND_IMAGE = "imagefinalnewnew.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
	input				AUD_ADCDAT;

	// Bidirectionals
	inout				AUD_BCLK;
	inout				AUD_ADCLRCK;
	inout				AUD_DACLRCK;

	inout				FPGA_I2C_SDAT;

	// Outputs
	output				AUD_XCK;
	output				AUD_DACDAT;

	output				FPGA_I2C_SCLK;

	// Internal Wires and Registers Declarations

	// Internal Wires
	wire				audio_in_available;
	wire		[31:0]	left_channel_audio_in;
	wire		[31:0]	right_channel_audio_in;
	wire				read_audio_in;

	wire				audio_out_allowed;
	wire		[31:0]	left_channel_audio_out;
	wire		[31:0]	right_channel_audio_out;
	wire				write_audio_out;

	// Internal Registers

	reg [18:0] delay_cnt;
	wire [18:0] delay;

	reg snd;

	// State Machine Registers

	// Finite State Machine(s)
	// Sequential Logic

	always @(posedge CLOCK_50)
		if(delay_cnt == delay) begin
			delay_cnt <= 0;
			snd <= !snd;
		end else delay_cnt <= delay_cnt + 1;

	// Combinational Logic

	assign delay = 19'd113636; // SW[3:0] 15'd3000 KEY[1], KEY[2], 

	wire [31:0] sound = (i_u == 0) ? 0 : snd ? 32'd10000000 : -32'd10000000; 


	assign read_audio_in			= audio_in_available & audio_out_allowed;

	assign left_channel_audio_out	= left_channel_audio_in+sound;
	assign right_channel_audio_out	= right_channel_audio_in+sound;
	assign write_audio_out			= audio_in_available & audio_out_allowed;

	// Internal Modules

	Audio_Controller Audio_Controller (
		// Inputs
		.CLOCK_50						(CLOCK_50),
		.reset						(~KEY[0]),

		.clear_audio_in_memory		(),
		.read_audio_in				(read_audio_in),
		
		.clear_audio_out_memory		(),
		.left_channel_audio_out		(left_channel_audio_out),
		.right_channel_audio_out	(right_channel_audio_out),
		.write_audio_out			(write_audio_out),

		.AUD_ADCDAT					(AUD_ADCDAT),

		// Bidirectionals
		.AUD_BCLK					(AUD_BCLK),
		.AUD_ADCLRCK				(AUD_ADCLRCK),
		.AUD_DACLRCK				(AUD_DACLRCK),


		// Outputs
		.audio_in_available			(audio_in_available),
		.left_channel_audio_in		(left_channel_audio_in),
		.right_channel_audio_in		(right_channel_audio_in),

		.audio_out_allowed			(audio_out_allowed),

		.AUD_XCK					(AUD_XCK),
		.AUD_DACDAT					(AUD_DACDAT)

	);

	avconf #(.USE_MIC_INPUT(1)) avc (
		.FPGA_I2C_SCLK					(FPGA_I2C_SCLK),
		.FPGA_I2C_SDAT					(FPGA_I2C_SDAT),
		.CLOCK_50					(CLOCK_50),
		.reset						(~KEY[0])
	);

	
	
//	characterCounter u0(.resetn(resetn), .clk(enable), .x_coordinate(x_c), .y_coordinate(y_c), .address(address), .done(WriteEn));
//	snoopyCharacter u1(.address(address), .clock(enable), .data(3'b000), .wren(1'b0), .q(colour));

		// VGA connectvga (.resetn(resetn), .writeEn(writeEn), .clock(CLOCK_50), .iX(~KEY[1]), .iY(~KEY[0]), .iColour(3'b100), .oX(x), .oY(y), .oColour(colour) );
//		VGAmodule vgaadapter (.iResetn(resetn), .iColour(3'b110), .iX(SW[7:0]), .iY(SW[6:0]), .iPlotBox(~KEY[1]), .iBlack(~KEY[2]), .iLoadX(~KEY[3]), .iClock(CLOCK_50),
//		.oX(x), .oY(y), .oColour(colour), .oPlot(writeEn), .oDone(Done) );
//
//	always @(posedge CLOCK_50) begin
//		if (!resetn) begin
//			xTemp <= 8'd0;
//			yTemp <= 7'd104;
//		end
//	end


		RateDivider #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) RDInst ( .ClockIn(CLOCK_50), .Reset(resetn), .Enable(enable) );

		snoopyHorizontalFSM fsm1( .clock(enable), .reset(resetn), .input_left(i_l), .input_right(i_r), .snoopy_x(xTemp));
		
		snoopyVerticalFSM fsm3 ( .clock(enable), .reset(resetn), .input_jump(i_u), .snoopy_y(yTemp) );
		
		VGAmodule vgaplay( .iResetn(resetn),.iColour(colTemp),.iX(xTemp),.iY(yTemp),.iLoadX(SW[0]),.iClock(CLOCK_50),.oX(x),.oY(y),.oColour(colour),.oPlot(writeEn),.oDone(Done) );
		
		score SCR(.clock(CLOCK_50), .reset(resetn), .x_pos(xTemp), .score(score), .HEX0(HEX0));
		
		gameFSM fsm4(.reset(resetn), .clock(CLOCK_50), .collided(is_collided), .reached_screen_end(is_end), .user_input(isInput), .col(colTemp));
		
		collision_end colInst(.x_c(xTemp), .y_c(yTemp), .colour(q_out), .clock(CLOCK_50), .resetn(resetn), .collided(is_collided), .reached_screen_end(is_end));
		
		//vga_address_translator Translator(.x(xTemp + 8'd4), .y(yTemp + 7'd2), .mem_address(addTemp));
		
		stagebg mem(.address(addTemp), .clock(CLOCK_50), .q(q_out));
		
		PS2_Demo keyboard(CLOCK_50, KEY, PS2_CLK, PS2_DAT,LEDR, input_right, input_left, input_up);
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
