
module PS2_Demo (
	// Inputs
	CLOCK_50,
	KEY,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	HEX0,
	HEX1,
	HEX2,
	LEDR
);

// Inputs
input				CLOCK_50;
input		[3:0]	KEY; //reset

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

// Outputs
output		[6:0]	HEX0;
output		[6:0]	HEX1;
output		[6:0]	HEX2;
output 		[2:0] LEDR;

assign LEDR[0] = i_up; 
assign LEDR[1] = i_left; 
assign LEDR[2] = i_right; 

// Internal Wires
wire		[7:0]	ps2_key_data;
wire				ps2_key_pressed;

PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(CLOCK_50),
	.reset				(KEY[0]),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);

hex_decoder h0 (
	.hex_number			({3'b000, i_up}),
	.seven_seg_display	(HEX0)
);

hex_decoder h1 (
	.hex_number			({3'b000, i_left}),
	.seven_seg_display	(HEX1)
);

hex_decoder h2 (
	.hex_number			({3'b000, i_right}),
	.seven_seg_display	(HEX2)
);

wire i_up, i_right, i_left;

KeyboardFSM ps2U0(
    .clk(CLOCK_50),
    .reset(KEY[0]),
    .data_in(ps2_key_data),  // 8-bit input from PS/2
    .input_up(i_up),
    .input_right(i_right),
    .input_left(i_left)
);


endmodule
