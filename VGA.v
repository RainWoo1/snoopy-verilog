module VGA (resetn, go, clock, iX, iY, iColour, oX, oY, oColour);

    input wire [2:0] iColour;
    input wire resetn, clock;

    input wire [7:0] iX;
    input wire [6:0] iY;
    input wire go;

    output wire [7:0] oX;
    output wire [6:0] oY;

    output wire [2:0] oColour;

    // instantiate the module
    wire erase, plotEn, update, reset;

    wire [2:0] current_state, next_state;

    // for boxes
    wire [7:0] xCounter;
    wire [6:0] yCounter;
    wire [3:0] xyCounter;
    wire [25:0] freq;

    control c1 (.clock(clock), .resetn(resetn), .colour(iColour), .current_state(current_state), .xyCounter(xyCounter),
	 .next_state(next_state), .freq(freq), .go(go), .update(update), .reset(reset), .erase(erase), .plotEn(plotEn));

    counter c0(.clock(clock), .resetn(resetn), .enable(plotEn), .count(xyCounter));

    datapath data(.clock(clock), .resetn(resetn), .iX(iX), .iY(iY), .oX(oX), .oY(oY), .freq(freq), .iColour(iColour), .oColour(oColour),
	 .xCounter(xCounter), .yCounter(yCounter), .xyCounter(xyCounter), .go(go), .update(update), .reset(reset), .erase(erase), .plotEn(plotEn),
	 .current_state(current_state), .next_state(next_state) );

endmodule


module control(clock, resetn, colour, xyCounter, current_state, next_state, freq, go, update, reset, erase, plotEn);
    
    input clock, resetn;
    input [2:0] colour;
    input wire [3:0] xyCounter;
    input wire [25:0] freq;

    output reg [2:0] current_state, next_state;
    output reg go, update, reset, erase, plotEn;

    localparam RESET = 3'd0,
                DRAW = 3'd1,
                WAIT = 3'd2,
                ERASE = 3'd3,
                DONE = 3'd4;

    always @ (*) begin : state_table
        case(current_state)
            RESET: begin
                next_state = DRAW;
            end
            DRAW: begin
                if (xyCounter <= 4'b1111)
                    next_state = DRAW;
                else
                    next_state = WAIT;
            end
            WAIT: begin
                if (freq < 26'd12499999)
                    next_state = WAIT;
                else
                    next_state = ERASE;
            end
            ERASE: begin
                if (xyCounter <= 4'b1111)
                    next_state = ERASE;
                else
                    next_state = DONE;
            end
            DONE: begin
                next_state = RESET;
            end
        endcase
    end

    // control signals
    always @(*) begin : enable_signals
        go = 1'b0;
        update = 1'b0;
        reset = 1'b0;
        erase = 1'b0;
        plotEn = 1'b0;

        case(current_state)
            RESET: reset = 1'b1;
            DRAW: begin
                go = 1'b1;
                // erase = 1'b0;
                plotEn = 1'b1;
            end
            ERASE: begin
                go = 1'b1;
                erase = 1'b1;
                // plotEn = 1'b1;
            end
            DONE : begin
                update = 1'b1;
            end
        endcase
    end

    always @(posedge clock) begin
        if (!resetn)
            current_state <= RESET;
        else
            current_state <= next_state;
    end

endmodule


module datapath( clock, resetn, iX, iY, oX, oY, freq, xCounter, yCounter, xyCounter, iColour, oColour, go, update, reset, erase, plotEn, current_state, next_state); // oDone, 

    input wire [7:0] iX;
    input wire [6:0] iY;
    input clock, resetn;
	 
    input [2:0] iColour;
    output reg [2:0] current_state, next_state;

    output reg go, update, reset, erase, plotEn;
    output reg [7:0] xCounter;
    output reg [6:0] yCounter;
    output reg [3:0] xyCounter;
    output reg [25:0] freq;
	 
    output reg [7:0] oX;
    output reg [6:0] oY;
    output reg [2:0] oColour;

    reg [7:0] x;
    reg [6:0] y;
    reg [2:0] colour;

    always @(posedge clock) begin
	if (!resetn) begin
            x <= 8'd0;
            y <= 7'd0;
            colour <= 3'd0;
	end
	else if (plotEn) begin
	    colour <= iColour;
	end
	else if (erase) begin
	    colour <= 3'd0;
	end
    end

    // output result register
    always @(posedge clock) begin
        if (!resetn) begin
            oX <= 8'd0;
            oY <= 7'd0;
            oColour <= 3'd0;
        end
        else begin
            if (plotEn) begin
                // oPlot <= 1'b1;
                oX <= x + xyCounter[1:0];
                oY <= y + xyCounter[3:2];
                oColour <= colour;
            end
            if (freq == 26'd12499999)
                freq <= 26'd0;
            else
                freq <= freq + 1;
            if (erase) begin // drawing another box
                oX <= x + xyCounter[1:0];
                oY <= y + xyCounter[3:2];
                oColour <= 3'b000; // black
            end
        end
    end

endmodule


module counter(clock, resetn, enable, count);

    input wire clock, resetn, enable;
    output reg [3:0] count;

    always @(posedge clock) begin
        if (!resetn)
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
