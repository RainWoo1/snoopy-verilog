module snoopyVerticalFSM #(parameter JUMP_HEIGHT = 20, GRAVITY = 2, MAX_JUMPS = 2, MAX_HEIGHT = 120, GROUND_HEIGHT = 100)(clock, reset, input_jump, snoopy_y);

    input clock, reset;
    input input_jump;
    output [6:0] snoopy_y;

    reg [6:0] y_pos;
    reg [1:0] jump_counter; // Counter for jumps
    reg [1:0] state;

    localparam S_JUMP = 2'b01,
               S_FALL = 2'b10,
               S_IDLE_Y = 2'b00;

    always @(posedge clock) begin
        if (!reset) begin
            state <= S_IDLE_Y;
            jump_counter <= 0;
            y_pos <= GROUND_HEIGHT; // Initial position on the ground
        end else begin
            // Check if Snoopy is on the ground
            if (y_pos >= GROUND_HEIGHT) begin
                jump_counter <= 0; // Reset jump counter on the ground
            end

            case (state)
                S_IDLE_Y: begin
                    if (input_jump && (y_pos >= GROUND_HEIGHT || jump_counter < MAX_JUMPS)) begin
                        state <= S_JUMP;
                        y_pos <= y_pos - JUMP_HEIGHT; // Move up
                        jump_counter <= jump_counter + 1;
                    end
                end
                S_JUMP: begin
                    if (y_pos <= 0) begin
                        state <= S_FALL;
                    end else if (jump_counter < MAX_JUMPS && input_jump) begin
                        state <= S_JUMP;
                        y_pos <= y_pos - JUMP_HEIGHT; // Continue moving up
                        jump_counter <= jump_counter + 1;
                    end else begin
                        state <= S_FALL;
                    end
                end
                S_FALL: begin
                    if (y_pos >= GROUND_HEIGHT) begin
                        state <= S_IDLE_Y;
                        y_pos <= GROUND_HEIGHT; // Ensure Snoopy is on the ground
                    end else if (input_jump && jump_counter < MAX_JUMPS) begin
                        state <= S_JUMP;
                        y_pos <= y_pos - JUMP_HEIGHT; // Move up from mid-air
                        jump_counter <= jump_counter + 1;
                    end else begin
                        y_pos <= y_pos + GRAVITY; // Apply gravity
                    end
                end
            endcase
        end
    end

    assign snoopy_y = y_pos;

endmodule
