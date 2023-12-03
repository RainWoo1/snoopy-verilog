module on_ground #(parameter GROUND_HEIGHT = 104)(snoopy_y, on_ground);

    input [7:0] snoopy_y;
    output on_ground;

    // Check if Snoopy is at or below the ground level
    assign on_ground = (snoopy_y <= GROUND_HEIGHT);
endmodule

module snoopyVerticalFSM #(parameter JUMP_HEIGHT = 20, GRAVITY = 5, MAX_JUMPS = 2, MAX_HEIGHT = 120)(clock, reset, on_ground, input_jump, snoopy_y); //adjust jump height

    input clock, reset;
    input input_jump, on_ground;
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
            y_pos <= 100; // Initial position on the ground
        end else begin
            if (on_ground) jump_counter <= 0;
            case (state)
                S_IDLE_Y: begin
                    if (input_jump && (on_ground || jump_counter < MAX_JUMPS)) begin
                        state <= S_JUMP;
                        y_pos <= y_pos - JUMP_HEIGHT; // Move up
                        jump_counter <= jump_counter + 1;
                    end
                end
                S_JUMP: begin
                    if (!input_jump || y_pos <= 0) begin
                        state <= S_FALL;
                    end else if (jump_counter < MAX_JUMPS) begin
                        state <= S_JUMP;
                        y_pos <= y_pos - JUMP_HEIGHT; // Continue moving up
                        jump_counter <= jump_counter + 1;
                    end
                end
                S_FALL: begin
                    if (on_ground) begin
                        state <= S_IDLE_Y;
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
