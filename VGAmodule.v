module VGAmodule(iResetn,iX,iY,iColour,iLoadX,iClock,oX,oY,oColour,oPlot,oDone);

    input wire iResetn, iLoadX;
    input wire [2:0] iColour;
    input wire [7:0] iX;         // VGA pixel coordinates
    input wire [6:0] iY;
	
    input wire 	    iClock;
    output wire [7:0] oX;         // VGA pixel coordinates
    output wire [6:0] oY;

    output wire [2:0] oColour;     // VGA pixel colour (0-7)
    output wire oPlot;       // Pixel draw enable
    output wire oDone;       // goes high when finished drawing frame

    wire ld_x, ld_draw, ld_black_wait, ld_black_wait_wait, ld_clear, ld_done, ld_done_done;

    wire [3:0] xyCounter; // count 16
    wire [3:0] xyzCounter; // count 16

    wire [2:0] current_state, next_state;

    counter c0(.clock(iClock), .reset(iResetn), .enable(ld_draw), .count(xyCounter));

    counter c2(.clock(iClock), .reset(iResetn), .enable(ld_clear), .count(xyzCounter));

    control c1( .iClock(iClock), .iResetn(iResetn), .iLoadX(iLoadX),
	.ld_x(ld_x), .ld_draw(ld_draw), .ld_black_wait(ld_black_wait), .ld_black_wait_wait(ld_black_wait_wait), .ld_clear(ld_clear), .ld_done(ld_done), .ld_done_done(ld_done_done),
	.current_state(current_state), .next_state(next_state), .xyCounter(xyCounter), .xyzCounter(xyzCounter) );

    datapath d0(.iClock(iClock), .iResetn(iResetn), .ld_x(ld_x), .ld_draw(ld_draw), .ld_black_wait(ld_black_wait), .ld_black_wait_wait(ld_black_wait_wait), .ld_clear(ld_clear),
	.ld_done(ld_done), .ld_done_done(ld_done_done), .iX(iX), .iY(iY), .iColour(iColour), .oX(oX), .oY(oY), .oColour(oColour), .oDone(oDone), .oPlot(oPlot), .counter(xyCounter), .counter1(xyzCounter), .iLoadX(iLoadX) );
endmodule


module counter(clock, reset, enable, count);

    input wire clock, reset, enable;
    output reg [3:0] count;

    always @(posedge clock) begin
        if (!reset)
            count <= 4'b0;
        if (enable) begin
            if (count == 4'b1111)
                count <= 4'b0;
            else
                count <= count + 1;
	end
        else
            count <= 4'b0;
    end
endmodule


module control( iClock, iResetn, iLoadX, ld_x, ld_draw, ld_black_wait, ld_black_wait_wait, ld_clear, ld_done, ld_done_done, 
current_state, next_state, xyCounter, xyzCounter );

    input iClock, iResetn, iLoadX;

    input [3:0] xyCounter;
    input [3:0] xyzCounter;

    output reg ld_x, ld_draw, ld_black_wait, ld_black_wait_wait, ld_clear, ld_done, ld_done_done;
    output reg [2:0] current_state, next_state;

    localparam LOAD = 4'd0,
                LOAD_WAIT = 4'd1,
                DRAW = 4'd2,
				BLACK_WAIT = 4'd3,
				BLACK_WAIT_WAIT = 4'd4,
                BLACK = 4'd5,
                DONE = 4'd6,
				DONE_DONE = 4'd7;

    always @ (*) begin : state_table
        case(current_state)
            LOAD: begin
			if (iLoadX == 1'b1)
				next_state = LOAD_WAIT;
			else
				next_state = LOAD;
            end
            LOAD_WAIT: begin
                next_state = DRAW;
            end
            DRAW: begin
			if (xyCounter == 4'd15)
				next_state = BLACK_WAIT;
			else
				next_state = DRAW;
            end
			BLACK_WAIT: begin
				next_state = BLACK_WAIT_WAIT;
			end
			BLACK_WAIT_WAIT: begin
				next_state = BLACK;
			end
			BLACK: begin
			if (xyzCounter == 4'd15)
				next_state = DONE;
			else
				next_state = BLACK;
			end
			DONE: begin
				next_state = DONE_DONE;
			end
			DONE_DONE: begin
				next_state = LOAD;
			end
            default:
                next_state = LOAD;
        endcase
    end

    always @(*) begin : enable_signals

        ld_x = 1'b0;
        ld_draw = 1'b0;
		ld_black_wait = 1'b0;
		ld_black_wait_wait = 1'b0;
        ld_clear = 1'b0;
		ld_done <= 1'b0;
		ld_done_done <= 1'b0;
		
        case(current_state)
				LOAD_WAIT: begin
					ld_x <= 1'b1;
                end
                DRAW: begin
                    ld_draw <= 1'b1;
                end
				BLACK_WAIT: begin
					ld_black_wait <= 1'b1;
				end
				BLACK_WAIT_WAIT: begin
					ld_black_wait_wait <= 1'b1;
				end
                BLACK: begin
                    ld_clear <= 1'b1;
                end
				DONE: begin
					ld_done <= 1'b1;
				end
				DONE_DONE: begin
					ld_done_done <= 1'b1;
				end
        endcase
    end

    // current_state registers
    always @(posedge iClock) begin: state_FFs
        if (!iResetn)
            current_state <= LOAD;
        else
            current_state <= next_state;
    end
endmodule


module datapath(iClock, iResetn, ld_x, ld_draw, ld_black_wait, ld_black_wait_wait, ld_clear, ld_done, ld_done_done, iX, iY, iColour, oX, oY, oDone, oColour, oPlot, counter, counter1, iLoadX); //  

    input iClock, iResetn, iLoadX;
    input ld_x, ld_draw, ld_black_wait, ld_black_wait_wait, ld_clear, ld_done, ld_done_done;
    input [7:0] iX;
	input [6:0] iY;
    input [2:0] iColour;

    input [3:0] counter;
    input [3:0] counter1;

    output reg [7:0] oX;
    output reg [6:0] oY;
    output reg [2:0] oColour;
    output reg oPlot, oDone;

    reg [7:0] x;
    reg [6:0] y;
    reg [2:0] colour;

    always @(posedge iClock) begin
        if (!iResetn) begin
            x <= 8'b0;
            y <= 7'b0;
            colour <= 3'b0;
        end
        else begin
            if (ld_x) begin
                x <= iX;
                y <= iY;
					 colour <= iColour;
            end
	    else if (ld_draw) begin
				colour <= iColour;
	    end
            else if (ld_clear) begin
                colour <= 3'd0;
            end
        end
    end

    // output result register
    always @(posedge iClock) begin
        if (!iResetn) begin
            oX <= 8'b0;
            oY <= 7'b0;
            oColour <= 3'b000;
				oDone <= 1'b0;
        end
		if (ld_x) begin
			oDone <= 1'b0;
			oPlot <= 1'b0;
//		oX <= x;
//			oY <= y;
//			oColour <= colour;
		end
        if (ld_draw) begin
            oPlot <= 1'b1;
            oX <= x + counter[1:0];
            oY <= y + counter[3:2];
	    oColour <= colour;
        end
		else if (ld_black_wait) begin
			oPlot <= 1'b0;
		end
        else if (ld_clear) begin
		oPlot <= 1'b1;
		oColour <= 3'b000;
            	oX <= x + counter1[1:0];
            	oY <= y + counter1[3:2];
	end
	else if (ld_done) begin
		oDone <= 1'b1;
		oPlot <= 1'b0;
	end
	else if (ld_done_done) begin
		oDone <= 1'b0;
		end
	end
endmodule
