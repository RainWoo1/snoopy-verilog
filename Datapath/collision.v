module collision_end (x_c, y_c, colour, clock, resetn, collided, reached_screen_end);

    input [6:0] y_c; // Added x_coord as input
	input [7:0] x_c;
    input clock, resetn;
    input [2:0] colour;
    output reg collided, reached_screen_end;
//
//   always @(posedge clock) begin
//       if (!resetn) begin
//           collided <= 1'b0;
//       end else if (colour == 3'b010) begin
//           collided <= 1'b1;
//       end
//       // No else clause
//   end

	always @(posedge clock) begin
	if (!resetn) begin
		collided <= 1'b0;
	end else if (// Top-left corner (x_c, y_c)
    (((x_c >= 8'd32 && x_c <= 8'd40) && (y_c >= 7'd99 && y_c <= 7'd103)) ||
    // ((x_c >= 8'd51 && x_c <= 8'd55) && (y_c >= 7'd100 && y_c <= 7'd103)) ||
     ((x_c >= 8'd56 && x_c <= 8'd61) && (y_c >= 7'd88 && y_c <= 7'd103)) ||
     ((x_c >= 8'd73 && x_c <= 8'd81) && (y_c >= 7'd96 && y_c <= 7'd103)) ||
     ((x_c >= 8'd105 && x_c <= 8'd111) && (y_c >= 7'd88 && y_c <= 7'd103)) ||
     ((x_c >= 8'd121 && x_c <= 8'd127) && (y_c >= 7'd97 && y_c <= 7'd103)) ||
     ((x_c >= 8'd146 && x_c <= 8'd154) && (y_c >= 7'd96 && y_c <= 7'd103)))
    // Top-right corner (x_c + 3, y_c)
    || (((x_c + 3 >= 8'd32 && x_c + 3 <= 8'd40) && (y_c >= 7'd99 && y_c <= 7'd103)) ||
       // ((x_c + 3 >= 8'd51 && x_c + 3 <= 8'd55) && (y_c >= 7'd100 && y_c <= 7'd103)) ||
        ((x_c + 3 >= 8'd56 && x_c + 3 <= 8'd61) && (y_c >= 7'd88 && y_c <= 7'd103)) ||
        ((x_c + 3 >= 8'd73 && x_c + 3 <= 8'd81) && (y_c >= 7'd96 && y_c <= 7'd103)) ||
        ((x_c + 3 >= 8'd105 && x_c + 3 <= 8'd111) && (y_c >= 7'd88 && y_c <= 7'd103)) ||
        ((x_c + 3 >= 8'd121 && x_c + 3 <= 8'd127) && (y_c >= 7'd97 && y_c <= 7'd103)) ||
        ((x_c + 3 >= 8'd146 && x_c + 3 <= 8'd154) && (y_c >= 7'd96 && y_c <= 7'd103)))
    // Bottom-left corner (x_c, y_c + 3)
    || (((x_c >= 8'd32 && x_c <= 8'd40) && (y_c + 3 >= 7'd99 && y_c + 3 <= 7'd103)) ||
       // ((x_c >= 8'd51 && x_c <= 8'd55) && (y_c + 3 >= 7'd100 && y_c + 3 <= 7'd103)) ||
        ((x_c >= 8'd56 && x_c <= 8'd61) && (y_c + 3 >= 7'd88 && y_c + 3 <= 7'd103)) ||
        ((x_c >= 8'd73 && x_c <= 8'd81) && (y_c + 3 >= 7'd96 && y_c + 3 <= 7'd103)) ||
        ((x_c >= 8'd105 && x_c <= 8'd111) && (y_c + 3 >= 7'd88 && y_c + 3 <= 7'd103)) ||
        ((x_c >= 8'd121 && x_c <= 8'd127) && (y_c + 3 >= 7'd97 && y_c + 3 <= 7'd103)) ||
        ((x_c >= 8'd146 && x_c <= 8'd154) && (y_c + 3 >= 7'd96 && y_c + 3 <= 7'd103)))
    // Bottom-right corner (x_c + 3, y_c + 3)
    || (((x_c + 3 >= 8'd32 && x_c + 3 <= 8'd40) && (y_c + 3 >= 7'd99 && y_c + 3 <= 7'd103)) ||
       // ((x_c + 3 >= 8'd51 && x_c + 3 <= 8'd55) && (y_c + 3 >= 7'd100 && y_c + 3 <= 7'd103)) ||
        ((x_c + 3 >= 8'd56 && x_c + 3 <= 8'd61) && (y_c + 3 >= 7'd88 && y_c + 3 <= 7'd103)) ||
        ((x_c + 3 >= 8'd73 && x_c + 3 <= 8'd81) && (y_c + 3 >= 7'd96 && y_c + 3 <= 7'd103)) ||
        ((x_c + 3 >= 8'd105 && x_c + 3 <= 8'd111) && (y_c + 3 >= 7'd88 && y_c + 3 <= 7'd103)) ||
        ((x_c + 3 >= 8'd121 && x_c + 3 <= 8'd127) && (y_c + 3 >= 7'd97 && y_c + 3 <= 7'd103)) ||
        ((x_c + 3 >= 8'd146 && x_c + 3 <= 8'd154) && (y_c + 3 >= 7'd96 && y_c + 3 <= 7'd103)))
) begin
	collided <= 1'b1;
	end
	end

    always @(posedge clock) begin
        if (!resetn) begin
            reached_screen_end <= 1'b0;
        end else if (x_c >= 8'd154) begin // Check if x_coord is 159
            reached_screen_end <= 1'b1;
        end 
    end
endmodule
