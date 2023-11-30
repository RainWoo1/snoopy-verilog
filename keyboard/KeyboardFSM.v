module KeyboardFSM(
    input clk,
    input reset,
    input [7:0] data_in,  // 8-bit input from PS/2
    output reg input_up,
    output reg input_right,
    output reg input_left
);

    // State Encoding
    reg [2:0] state;
    localparam IDLE                   = 3'b000,
               EXTENDED_SEQUENCE      = 3'b001,
               AWAIT_RELEASE_SEQUENCE = 3'b010,
               PROCESS_RELEASE        = 3'b011;

    // Last Byte Storage
    reg [7:0] last_byte;

    // FSM Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            // Reset outputs
            input_up <= 0;
            input_right <= 0;
            input_left <= 0;
            last_byte <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (data_in == 8'hE0) state <= EXTENDED_SEQUENCE;
                    else if (data_in == 8'hF0) state <= AWAIT_RELEASE_SEQUENCE;
                end
                EXTENDED_SEQUENCE: begin
                    if (data_in == 8'hF0) state <= PROCESS_RELEASE;
                    else begin
                        case (data_in)
                            8'h75: input_up <= 1;
                            8'h74: input_right <= 1;
                            8'h6B: input_left <= 1;
                        endcase
                        state <= IDLE;
                    end
                    last_byte <= data_in;
                end
                AWAIT_RELEASE_SEQUENCE: begin
                    last_byte <= data_in;
                    state <= PROCESS_RELEASE;
                end
                PROCESS_RELEASE: begin
                    if (last_byte == 8'hE0) begin
                        case (data_in)
                            8'h75: input_up <= 0;
                            8'h74: input_right <= 0;
                            8'h6B: input_left <= 0;
                        endcase
                    end
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
