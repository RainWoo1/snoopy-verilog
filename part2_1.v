module VGA (resetn, clock, iX, iY, iColour, oX, oY, oColour);

    input wire [2:0] colour;
    input wire resetn;
    input wire clock;

    input wire [7:0] iX;
    input wire [6:0] iY;

    output wire [7:0] oX;
    output wire [6:0] oY;

    output wire [2:0] oColour;
    // output wire oDone;

    // output reg enableCharacter; // enable signal for snoopyCharacter
    // instantiate the module
    wire go, erase, plotEn, update, reset;

//    wire [7:0] delayCount;
    wire [2:0] current_state, next_state;

    // for boxes
    wire [7:0] xCounter;
    wire [6:0] yCounter;
    wire [3:0] xyCounter;
    wire [25:0] freq;

    control c1 (.clock(clock), .resetn(resetn), .colour(colour), .ld_draw(ld_draw), .ld_erase(ld_erase), .ld_done(ld_done), .xCounter(xCounter),
	 .yCounter(yCounter), .current_state(current_state), .next_state(next_state), .freq(clock), .go(go), .update(update), .reset(reset), .erase(erase), .plotEn(plotEn));

    // delayCounter count1 (.clock(clock), .resetn(resetn), .xyCounter(xyCounter) );
    counter c0(.clock(clock), .resetn(resetn), .enable(plotEn), .count(xyCounter));
    datapath data(.clock(clock), .resetn(resetn), .iX(iX), .iY(iY), .oX(oX), .oY(oY), .freq(clock), .iColour(iColour), .oColour(oColour),
	 .go(go), .update(update), .reset(reset), .erase(erase), .plotEn(plotEn), .current_state(current_state), .next_state(next_state) );

endmodule


module control(clock, resetn, colour, ld_draw, ld_erase, ld_done, xyCounter, current_state, next_state, freq, go, update, reset, erase, plotEn);
    
    input clock, resetn; // oDone
    input [2:0] colour;
    output reg [2:0] current_state, next_state;

    output reg go, update, reset, erase, plotEn;

    // output reg enableCharacter;
	 input wire [3:0] xyCounter;
	 input wire [25:0] freq;

    localparam RESET = 2'd0,
                DRAW = 2'd1,
                WAIT = 2'd2,
                ERASE = 2'd3,
                DONE = 2'd4;

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
                next_state = INITIAL;
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
                erase = 1'b0;
                plotEn = 1'b1;
            end
            ERASE: begin
                go = 1'b1;
                erase = 1'b1;
                plotEn = 1'b1;
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


module datapath( clock, resetn, iX, iY, oX, oY, freq, iColour, oColour, go, update, reset, erase, plotEn, current_state, next_state); // oDone, 

    input clock, resetn;
    input [2:0] iColour;
    output reg [2:0] current_state, next_state;

    output reg go, update, reset, erase, plotEn;
    output reg [7:0] xCounter;
    output reg [6:0] yCounter;
    output reg [25:0] freq;
    output reg oX, oY;

    reg [7:0] x;
    reg [6:0] y;
    reg [2:0] colour;
    
    output reg oDone;

    always @(posedge clock) begin
        if (reset || !resetn) begin
            x <= 8'd0;
            y <= 7'd0;
            colour <= 3'd0;
        end
        else begin
            if (erase & !plotEn) begin // drawing another box
                x <= iX + xyCounter[1:0];
                y <= iY + xyCounter[3:2];
                colour <= 3'b000; // black
            end
            if (!erase)
                colour <= iColour;
            
            if (freq == 26'd12499999)
                freq <= 26'd0;
            else
                freq <= freq + 1;

            if (plotEn) begin
                // oPlot <= 1'b1;
                x <= iX + xyCounter[1:0];
                y <= iY + xyCounter[3:2];
                colour <= iColour;
            end
        end
    end

    // // output result register
    // always @(posedge clock) begin
    //     if (!resetn) begin
    //         oX <= 8'd0;
    //         oY <= 7'd0;
    //         oColour <= 3'b000;
    //     end
    //     if (ld_draw) begin
    //         enableCharacter <= 1'b1;
    //     end
    //     if (ld_erase) begin
    //         oDone <= 1'b1;
    //     end
    //     if (ld_done) begin
    //         oDone <= 1'b0;
    //     end
    // end
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


// module delayCounter(clock, resetn, enable, delayCount);
// 	input clock, resetn, enable;
// 	output reg [7:0] delayCount;

// 	always @ (posedge clock)
// 		begin
// 			if(!reset)
// 				delayCount <= 0;
// 			else
// 				begin
// 					if(enable)
// 						if(delayCount == 8'b11111111)
// 							delayCount <= 0;
// 						else
// 							delayCount <= delayCount + 1;
// 				end	
// 		end
// endmodule
