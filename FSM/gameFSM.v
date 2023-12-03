module gameFSM (reset, clock, collided, reached_screen_end, user_input);

    localparam S_BEGIN = 2'b00,
                S_CONTINUE = 2'b01,
                S_LOST = 2'b10,
                S_WON = 2'b11 ;

    input collided, reached_screen_end, user_input; //user input is a boolean value (=1 when user is providing some input )
    input reset, clock;
    reg [1:0] current_state, next_state;

    always @ (*)  //next state logic
    begin : state_table
        if (reset) next_state = S_BEGIN;
        case (current_state)
            S_BEGIN : next_state = user_input ? S_CONTINUE : S_BEGIN;

            S_CONTINUE : begin
                if (collided)
                    next_state = S_LOST;
                else if (reached_screen_end)
                    next_state = S_WON;
            end

            S_LOST : next_state = S_BEGIN;
            S_WON : next_state = S_BEGIN;

            default : next_state = S_BEGIN;
        endcase
    end 

//what output to give from this module?
	// State update logic
    always @ (posedge clock) begin
        if (reset) 
            current_state <= S_BEGIN;
        else 
            current_state <= next_state;
    end
endmodule

//module which returns collided = 1; reached_screen_end = 1
module collision_end (x_coord, y_coord, colour, clock, resetn, collided, reached_screen_end);

    input [6:0] y_coord; // Added x_coord as input
	input [7:0] x_coord;
    input clock, resetn;
    input [2:0] colour;
    output reg collided, reached_screen_end;

    always @(posedge clock) begin
        if (!resetn) begin
            collided <= 1'b0;
        end else if (colour == 3'b010) begin
            collided <= 1'b1;
        end
        // No else clause
    end

    always @(posedge clock) begin
        if (!resetn) begin
            reached_screen_end <= 1'b0;
        end else if (x_coord == 7'd159) begin // Check if x_coord is 159
            reached_screen_end <= 1'b1;
        end 
    end
endmodule
