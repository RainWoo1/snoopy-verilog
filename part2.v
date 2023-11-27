module part2(iResetn,iPlotBox,iColour,iX,iY,iClock,oX,oY,oColour,oPlot,oDone);

    input wire iResetn, iPlotBox;
    input wire [2:0] iColour;
    input wire 	    iClock;
    output wire [7:0] oX;         // VGA pixel coordinates
    output wire [6:0] oY;

    output wire [2:0] oColour;     // VGA pixel colour (0-7)
    output wire oPlot;       // Pixel draw enable
    output wire oDone;       // goes high when finished drawing frame

    wire ld_erase, ld_wait, ld_draw, ld_done;

    wire [2:0] xCounter;
    wire [2:0] yCounter;
	 wire [4:0] xyCounter;

    wire [2:0] current_state, next_state;
    wire yEnable;
	
	// erasing box
	xCounter xCount(.clock(iClock), .reset(iResetn), .enable(ld_erase), .xCounter(xCounter), yEnable(yEnable));
	yCounter yCount(.clock(iClock), .reset(iResetn), .enable(yEnable), .yCounter(yCounter));

	// drawing box
	xCounter xCount(.clock(iClock), .reset(iResetn), .enable(ld_erase), .xCounter(xCounter), yEnable(yEnable));
	yCounter yCount(.clock(iClock), .reset(iResetn), .enable(yEnable), .yCounter(yCounter));
	
    control c1(.iClock(iClock), .iResetn(iResetn), .iPlotBox(iPlotBox), .ld_erase(ld_erase), .ld_wait(ld_wait), .ld_draw(ld_draw), .ld_done(ld_done),
	.current_state(current_state), .next_state(next_state), .xyCounter(xyCounter),
	.xCounter(xCounter), .yCounter(yCounter));

    datapath d0(.iClock(iClock), .iResetn(iResetn), .ld_erase(ld_erase), .ld_wait(ld_wait), .ld_draw(ld_draw), .ld_done(ld_done),
	.iColour(iColour), .oX(oX), .oY(oY), .oColour(oColour), .oDone(oDone), .oPlot(oPlot), .counter(xyCounter), .xCounter(xCounter), .yCounter(yCounter), .iPlotBox(iPlotBox));

endmodule


module xCounter(
    input wire clock, reset, enable,
    output reg [2:0] xCounter,
    output wire yEnable
);
    always @(posedge clock) begin
        if (!reset)
            xCounter <= 0;
        else if (enable)
            if (xCounter == 3'b100)
                xCounter <= 0;
            else
                xCounter <= xCounter + 1;
        else
            xCounter <= 0;
    end
    assign yEnable = (xCounter == 3'b100) ? 1'b1 : 1'b0;
endmodule


module yCounter(
    input wire clock, reset, enable,
    output reg [2:0] yCounter
);

    always @(posedge clock) begin
        if (!reset)
            yCounter <= 0;
        else if (enable)
				if (yCounter != 3'b100)
					yCounter <= yCounter + 1;
            else
					yCounter <= 0;
    end
endmodule


module control(iClock, iResetn, iPlotBox, ld_erase, ld_wait, ld_draw, ld_done, 
current_state, next_state, xyCounter, xCounter, yCounter);

    input iClock, iResetn, iPlotBox;

    input [4:0] xyCounter;
    input [7:0] xCounter;
    input [6:0] yCounter;

    output reg ld_erase, ld_wait, ld_draw, ld_done;
    output reg [2:0] current_state, next_state;

    localparam ERASE = 2'd0,
					WAIT = 2'd1,
               DRAW = 2'd2,
					DONE = 2'd3;

    always @ (*) begin : state_table
        case(current_state)
            ERASE: begin
                if
                    next_state = WAIT;
					 else
						  next_state = ERASE;
            end
            WAIT: begin
                  next_state = DRAW;
            end
            DRAW: begin
					if (xyCounter == 5'b11001)
						next_state = DONE;
					else
						next_state = DRAW;
            end
            DONE: begin
						next_state = ERASE;
				end
            default:
                next_state = ERASE;
        endcase
    end


    always @(*) begin : enable_signals
	 
		  ld_erase = 1'b0;
		  ld_wait = 1'b0;
		  ld_draw = 1'b0;
		  ld_done <= 1'b0;

        case(current_state)
                ERASE: begin
                    ld_erase <= 1'b0;
                end
					 WAIT: begin
						  ld_wait <= 1'b1;
                end
					 DRAW: begin
                    ld_draw <= 1'b1;
                end
                DONE: begin
                    ld_done <= 1'b1;
                end
        endcase
    end

    // current_state registers
    always @(posedge iClock) begin: state_FFs
        if (!iResetn)
            current_state <= ERASE;
        else
            current_state <= next_state;
    end
endmodule


module datapath(iClock, iResetn, ld_draw, ld_wait, ld_erase, ld_done, iX, iY,
iColour, oX, oY, oColour, counter, xCounter, yCounter); 

    input iClock, iResetn;
    input ld_erase, ld_wait, ld_draw, ld_done;
    input [6:0] iX, iY;
    input [2:0] iColour;

    input [3:0] counter;
    input [7:0] xCounter;
    input [6:0] yCounter;
    input iPlotBox;

    output reg [7:0] oX;
    output reg [6:0] oY;
    output reg [2:0] oColour;

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
            else if (iPlotBox) begin
					 ld_erase <= 1'b0;
					 x <= iX;
                y <= iY;
                colour <= 3'b0;
            end
        end
    end

    // output result register
    always @(posedge iClock) begin
        if (!iResetn) begin
            oX <= 8'b0;
            oY <= 7'b0;
            oColour <= 3'b000;
		  end
		  
		  if (ld_draw) begin
				oX <= x + 
				oColour <= colour;
		  end
		  
    end
endmodule
