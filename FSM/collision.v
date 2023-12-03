module collision_end (x_coord, y_coord, colour, clock, resetn, collided, reached_screen_end);

    input [6:0] y_coord; // Added x_coord as input
	input [7:0] x_coord;
    input clock, resetn;
    input [2:0] colour;
    output reg collided, reached_screen_end;
//
//    always @(posedge clock) begin
//        if (!resetn) begin
//            collided <= 1'b0;
//        end else if (colour == 3'b010) begin
//            collided <= 1'b1;
//        end
//        // No else clause
//    end

    always @(posedge clock) begin
        if (!resetn) begin
            reached_screen_end <= 1'b0;
        end else if (x_coord == 7'd156) begin // Check if x_coord is 159
            reached_screen_end <= 1'b1;
        end 
    end
endmodule
