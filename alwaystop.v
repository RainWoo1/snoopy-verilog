reg i_r, i_l, i_u;

always @(*) begin
    // Update i_r, i_l, i_u based on KEY inputs or input directions
    i_r = ~KEY[1] || input_right;
    i_l = ~KEY[2] || input_left;
    i_u = ~KEY[3] || input_up;

    // Existing logic for handling game end or collision
    if (is_end || is_collided) begin
        i_r = 1'b0;
        i_l = 1'b0;
        i_u = 1'b0;
    end
end
