
module RateDivider
#(parameter CLOCK_FREQUENCY = 250) (
input ClockIn,
input Reset,
output reg Enable
);

    reg [26:0] down_count;
 //   reg temp;

//    always @ (*)
//    begin
//
//	temp = CLOCK_FREQUENCY;
//
//    end

    always @ (posedge ClockIn)
    begin
        if (!Reset)
            begin
                Enable = 1'b0; //start with enable = 1 or 0??
                down_count <= 2500000;
            end
		  else if (down_count == 27'd0)
				begin
					Enable = 1'b1;
					down_count <= 2500000;
				end
        else
            begin
                Enable = 1'b0;
                down_count <= down_count - 1;
            end
    end
    // assign Enable = (down_count == 27'd0)? 1'b1:1'b0;
endmodule
