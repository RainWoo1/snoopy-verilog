module gameFSM (reset, clock, collided, reached_screen_end, user_input, col);

    localparam S_BEGIN = 2'b00,
               S_CONTINUE = 2'b01,
               S_LOST = 2'b10,
               S_WON = 2'b11;

    input collided, reached_screen_end, user_input, reset, clock;
    output reg [2:0] col;
    reg [1:0] current_state, next_state;

    // Next state logic
    always @ (*) begin
        if (!reset) begin
            next_state = S_BEGIN;
            col = 3'b110; // Default color
        end else begin
            case (current_state)
                S_BEGIN:
                    next_state = user_input ? S_CONTINUE : S_BEGIN;

                S_CONTINUE:
                    if (collided)
                        next_state = S_LOST;
                    else if (reached_screen_end)
                        next_state = S_WON;
                    else
                        next_state = S_CONTINUE;

                S_LOST:
                    next_state = S_BEGIN;

                S_WON:
                    next_state = S_BEGIN;

                default:
                    next_state = S_BEGIN;
            endcase
        end
    end

    // State update logic
    always @ (posedge clock) begin
        if (!reset)
            current_state <= S_BEGIN;
        else
            current_state <= next_state;
    end

    // Output logic based on state
    always @ (*) begin
        case (current_state)
            S_LOST:
                col = 3'b100; // Color for lost
            S_WON:
                col = 3'b010; // Color for won
            default:
                col = 3'b110; // Default color
        endcase
    end
endmodule
