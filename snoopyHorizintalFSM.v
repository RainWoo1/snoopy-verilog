module snoopyHorizontalFSM (clock, reset, input_left, input_right, snoopy_x);

    input clock, reset;
    input input_left, input_right;
    output [9:0] snoopy_x;

    reg [9:0] x_speed, x_pos;

    reg [1:0] state;

    localparam S_LEFT = 2'b01,
                S_RIGHT = 2'b10,
                S_IDLE_X = 2'b00;

    always @ (posedge clock)
    begin : next_state_and_output_logic
        if (reset) begin
            x_speed <= 0;
            state <= S_IDLE_X;
        end
        else begin
            case (state)
                S_IDLE_X: begin
                    if (input_left) begin
                        state <= S_LEFT;
                        x_speed = -2; //adjust
                    end 
                    else if (input_right) begin
                        state <= S_RIGHT;
                        x_speed = 2; //adjust
                    end 
                end
                S_LEFT : begin
                    if (!input_left) begin
                        state = S_IDLE_X;
                        x_speed = 0;
                    end
                end
                S_RIGHT: begin
                    if (!input_right) begin
                        state = S_IDLE_X;
                        x_speed = 0;
                    end
                end
            endcase
        end
    end

    //update snoopy's position
    always@ (posedge clock) begin
        x_pos <= x_pos + x_speed;
    end

    //assign output coordinate
    assign snoopy_x = x_pos;

endmodule
