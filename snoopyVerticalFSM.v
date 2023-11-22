module on_ground #(parameter GROUND_HEIGHT = 50)(snoopy_y, on_ground);

    input [8:0] snoopy_y;
    output on_ground;

    // Check if Snoopy is at or below the ground level
    assign on_ground = (snoopy_y <= GROUND_HEIGHT);
endmodule

module snoopyVerticalFSM #(parameter JUMP_HEIGHT = 20, GRAVITY = 2)(clock, reset, on_ground, input_jump, snoopy_y); //adjust jump height

    input clock, reset;
    input input_jump, on_ground;
    output [8:0] snoopy_y;

    reg [8:0] y_speed, y_pos;

    reg [1:0] state;

    localparam S_JUMP = 2'b01,
                S_FALL = 2'b10,
                S_IDLE_Y = 2'b00;

    always @ (posedge clock)
    begin : next_state_and_output_logic
        if (reset) begin
            y_speed <= 0;
            state <= S_IDLE_Y;
        end
        else begin
            case (state)
                S_IDLE_Y: begin
                    if (input_jump && on_ground) begin
                        state <= S_JUMP;
                        y_speed = JUMP_HEIGHT; //adjust
                    end  
                end
                S_JUMP : begin
                    if (input_jump) begin                   //allow jumps from mid air?
                        y_speed = JUMP_HEIGHT;
                    end else begin
                        y_speed <= y_speed - GRAVITY;
                        if (y_speed <= 0) begin
                            state = S_FALL;
                        end
                    end
                end
                S_FALL: begin                              //allow jumps from mid air?
                    if (on_ground) begin
                        state = S_IDLE_Y;
                        y_speed = 0;
                    end
                end
            endcase
        end
    end

    //update snoopy's position
    always@ (posedge clock) begin
        y_pos <= y_pos + y_speed;
    end

    //assign output coordinate
    assign snoopy_y = y_pos;

endmodule
