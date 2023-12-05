module snoopyHorizontalFSM (clock, reset, input_left, input_right, snoopy_x, score);

    input clock, reset;
    input input_left, input_right;
    output [7:0] snoopy_x;
    output [3:0] score;

    reg [7:0] x_pos;
    //reg [1:0] x_speed;

    reg [1:0] state;

    localparam S_LEFT = 2'b01,
                S_RIGHT = 2'b10,
                S_IDLE_X = 2'b00;

    localparam MAX_X_POS = 160;

    always @ (posedge clock)
    begin : next_state_and_output_logic
        if (reset) begin
            //x_speed <= 0;
           // x_pos <= 0;
            state <= S_IDLE_X;
            score <= 4'b0;
        end
        else begin
            case (state)
                S_IDLE_X: begin
                    if (input_left) begin
                        state <= S_LEFT;
                        //x_speed <= 1; //adjust
                    end 
                    else if (input_right) begin
                        state <= S_RIGHT;
                        //x_speed <= 1; //adjust
                    end 
                end
                S_LEFT : begin
                    if (!input_left) begin
                        state <= S_IDLE_X;
                        //x_speed <= 0;
                    end
                end
                S_RIGHT: begin
                    if (!input_right) begin
                        state <= S_IDLE_X;
                        //x_speed <= 0;
                    end
                end
            endcase
        end
    end

    // Update Snoopy's position with bounds
always @(posedge clock) begin
    if (reset) begin
        x_pos <= 0; // Reset x_pos
    end else begin
        case (state)
            S_LEFT: begin
                if (x_pos > 0) begin
                    x_pos <= x_pos - 1; // Move left, decrement x_pos
                end
            end
            S_RIGHT: begin
                if (x_pos < MAX_X_POS) begin
                    x_pos <= x_pos + 1; // Move right, increment x_pos
                end
            end
        endcase
        case (x_pos + 8'b1)  //+1 score after crossing one obstacle
            8'd55 : score <= 4'd1;
            8'd61 : score <= 4'd2;
            8'd81 : score <= 4'd3;
            8'd114 : score <= 4'd4;
            8'd127 : score <= 4'd5;
            8'd154 : score <= 4'd6;
            default : score <= 4'd0;
        endacase
            
    end
end

    //assign output coordinate
    assign snoopy_x = x_pos;

endmodule
