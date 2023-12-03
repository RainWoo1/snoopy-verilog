module snoopyVerticalFSM #(parameter JUMP_VELOCITY = 5, GRAVITY = 1, MAX_JUMPS = 2, MAX_HEIGHT = 120, GROUND_HEIGHT = 100)
    (clock, reset, input_jump, snoopy_y);

    input clock, reset;
    input input_jump;
    output [6:0] snoopy_y;

    reg [6:0] y_pos;
    reg [6:0] jump_velocity;
    reg [1:0] jump_counter;
    reg [1:0] state;

    localparam S_JUMP = 2'b01,
               S_FALL = 2'b10,
               S_IDLE_Y = 2'b00;

    always @(posedge clock) begin
        if (!reset) begin
            state <= S_IDLE_Y;
            jump_counter <= 0;
            y_pos <= GROUND_HEIGHT; // Initial position on the ground
            jump_velocity <= 0; // Initialize jump velocity
        end else begin
            // Check if Snoopy is on the ground
            if (y_pos >= GROUND_HEIGHT) begin
                jump_counter <= 0; // Reset jump counter on the ground
            end

            case (state)
                S_IDLE_Y: begin
                    if (input_jump && (y_pos >= GROUND_HEIGHT || jump_counter < MAX_JUMPS)) begin
                        state <= S_JUMP;
                        jump_velocity <= JUMP_VELOCITY; // Set jump velocity
                        jump_counter <= jump_counter + 1;
                    end
                end
                S_JUMP: begin
                    if (jump_velocity > 0 || y_pos > 0) begin
                        y_pos <= y_pos - jump_velocity; // Ascend
                        jump_velocity <= jump_velocity - GRAVITY; // Decrease velocity
                    end else begin
                        state <= S_FALL; // Transition to fall when velocity <= 0
                    end
                end
                S_FALL: begin
                    if (y_pos < GROUND_HEIGHT) begin
                        y_pos <= y_pos + GRAVITY; // Apply gravity
                    end else begin
                        y_pos <= GROUND_HEIGHT; // Ensure Snoopy is on the ground
                        state <= S_IDLE_Y; // Reset to idle state
                    end
                end
            endcase
        end
    end

    assign snoopy_y = y_pos;

endmodule
