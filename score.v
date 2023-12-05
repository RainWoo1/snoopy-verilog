module score(clock, reset, x_pos, score, HEX0);

	input clock, reset;
	input [8:0] x_pos;
	output reg [3:0] score;
	output [6:0] HEX0;
	
	always @ (posedge clock) begin
		if (!reset) begin
			score <= 4'b0;
	end else begin
		case (x_pos)  //+1 score after crossing one obstacle
					8'd40 : score <= 4'd1;
					8'd61 : score <= 4'd2;
					8'd81 : score <= 4'd3;
					8'd111 : score <= 4'd4;
					8'd127 : score <= 4'd5;
					8'd154 : score <= 4'd6;
					//default : score <= 4'd0;
		endcase
	end
	end
	
	Hexadecimal_To_Seven_Segment Segment0 ( .hex_number(score), .seven_seg_display(HEX0));
	
endmodule
