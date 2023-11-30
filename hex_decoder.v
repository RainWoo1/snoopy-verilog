module hex_decoder (c, display);

input[3: 0] c;

output[6: 0] display;

    wire m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15;

 

    assign m0 = ~c[3] & ~c[2] & ~c[1] & ~c[0]; //define the minterms

    assign m1 = ~c[3] & ~c[2] & ~c[1] & c[0];

    assign m2 = ~c[3] & ~c[2] & c[1] & ~c[0];

    assign m3 = ~c[3] & ~c[2] & c[1] & c[0];

    assign m4 = ~c[3] & c[2] & ~c[1] & ~c[0];

    assign m5 = ~c[3] & c[2] & ~c[1] & c[0];

    assign m6 = ~c[3] & c[2] & c[1] & ~c[0];

    assign m7 = ~c[3] & c[2] & c[1] & c[0];

    assign m8 = c[3] & ~c[2] & ~c[1] & ~c[0];

    assign m9 = c[3] & ~c[2] & ~c[1] & c[0];

    assign m10 = c[3] & ~c[2] & c[1] & ~c[0];

    assign m11 = c[3] & ~c[2] & c[1] & c[0];

    assign m12 = c[3] & c[2] & ~c[1] & ~c[0];

    assign m13 = c[3] & c[2] & ~c[1] & c[0];

    assign m14 = c[3] & c[2] & c[1] & ~c[0];

    assign m15 = c[3] & c[2] & c[1] & c[0];

 

    assign display[0] = ~(m0 | m2 | m3 | m5 | m6 | m7 | m8 | m9 | m10 | m12 | m13 | m14 | m15); //sum of product of minterms

    assign display[1] = ~(m0 | m1 | m2 | m3 | m4 | m7 | m8 | m9 | m10 | m13);

    assign display[2] = ~(m0 | m1 | m3 | m4 | m5 | m6 | m7 | m8 | m9 | m10 | m11 | m13);

    assign display[3] = ~(m0 | m2 | m3 | m5 | m6 | m8 | m9 | m11 | m12 | m13 | m14);

    assign display[4] = ~(m0 | m2 | m6 | m8 | m10 | m11 | m12 | m13 | m14 | m15);

    assign display[5] = ~(m0 | m4 | m5 | m6 | m8 | m9 | m10 | m11 | m12 | m14 | m15);

    assign display[6] = ~(m2 | m3 | m4 | m5 | m6 | m8 | m9 | m10 | m11 | m14 | m15);

 

endmodule
