
module PS2_Demo (
	CLOCK_50,
	// Inputs
	KEY,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	HEX0,
	HEX1,
    LEDR[9:0],
	 o_r,
	 o_l,
	 o_u
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input			CLOCK_50;
input		[3:0]	KEY;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

// Outputs
output		[6:0]	HEX0;
output		[6:0]	HEX1;
//output		[6:0]	HEX2;
//output		[6:0]	HEX3;
//output		[6:0]	HEX4;
//output		[6:0]	HEX5;
//output		[6:0]	HEX6;
//output		[6:0]	HEX7;
output      [9:0]   LEDR;
output o_r;
output o_l;
output o_u;

assign o_r = input_right;
assign o_l = input_left;
assign o_u = input_up;


assign LEDR[0] = o_r;
assign LEDR[1] = o_l;
assign LEDR[2] = o_u;
// Internal Wires
wire		[7:0]	ps2_key_data;
wire				ps2_key_pressed;
reg input_right, input_left, input_up;
// Internal Registers
reg			[7:0]	last_data_received;


always @(posedge CLOCK_50)
begin
	if (~KEY[0])
		last_data_received <= 8'h00;
	else if (ps2_key_pressed == 1'b1)
		last_data_received <= ps2_key_data;
	// else 
	// 	last_data_received <= ps2_key_data;
end

always @ (*) begin

    case(last_data_received)

        8'h74: begin
                input_right = 1'b1;
					 input_left = 1'b0;
            end

        8'h6B: begin
                input_left = 1'b1;
					 input_right = 1'b0;
            end

        8'h75: begin
				input_up = 1'b1;
            input_left = 1'b0;
        end 

	8'hF0: begin // Key release code
            input_right = 1'b0;
            input_left = 1'b0;
            input_up = 1'b0;
        end

		// 8'hF074: begin
  //               input_right = 1'b0;
		// 			 input_left = 1'b0;
		// 			 input_up = 1'b0;
  //           end

  //       8'hF06B: begin
  //               input_right = 1'b0;
		// 			 input_left = 1'b0;
		// 			 input_up = 1'b0;
  //           end

  //       8'hF075: begin
		// 			input_right = 1'b0;
		// 			input_left = 1'b0;
		// 			input_up = 1'b0;
  //       end 
     
        default:  begin
            input_right = 1'b0;
            input_left = 1'b0;
            input_up = 1'b0;
        end

    endcase
end

//
//assign HEX2 = 7'h7F;
//assign HEX3 = 7'h7F;
//assign HEX4 = 7'h7F;
//assign HEX5 = 7'h7F;
//assign HEX6 = 7'h7F;
//assign HEX7 = 7'h7F;


PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(CLOCK_50),
	.reset				(~KEY[0]),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);

Hexadecimal_To_Seven_Segment Segment0 (
	// Inputs
	.hex_number			(last_data_received[3:0]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX0)
);

Hexadecimal_To_Seven_Segment Segment1 (
	// Inputs
	.hex_number			(last_data_received[7:4]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX1)
);

endmodule