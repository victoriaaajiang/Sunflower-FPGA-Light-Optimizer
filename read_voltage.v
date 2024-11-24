module read_voltage(input CLOCK_50,
                    input [0:0] KEY,
                    // input [11:0] ADC_value,
                    input [25:0] GPIO_0,
                    output [6:0] HEX0,output [6:0] HEX1,
                    output [6:0] HEX2,
                    output [6:0] HEX3);

//Assign pins from ADC output (from left to right)
    reg [11:0] ADC_value;
    always @ (posedge CLOCK_50) begin
        ADC_value <= 
        {GPIO_0[25], GPIO_0[23], GPIO_0[21], GPIO_0[19], GPIO_0[17], GPIO_0[15],
        GPIO_0[13], GPIO_0[11], GPIO_0[7], GPIO_0[5], GPIO_0[3], GPIO_0[1]};
        end
    reg [11:0] greatest =  12'b0;
    wire [11:0] greater;

    // Module connections
    max_value_comparator comp1(ADC_value, greatest, greater);

    always @(posedge CLOCK_50) begin
        greatest <= greater; // Update greatest value on each clock cycle
    end

    shift s1(CLOCK_50, KEY[0], greater, max);
    four_digit_bcd fourbcd(max, HEX0, HEX1, HEX2, HEX3);

endmodule

// Comparator: Takes in 2 12-bit voltage values and outputs the greater value
module max_value_comparator(compare, greatest, greater);
    input [11:0] compare, greatest;
    output [11:0] greater;

    assign greater = (compare > greatest) ? compare : greatest;

endmodule

// Register: Stores the current max voltage
module shift(clk, reset, greater, max);
    input clk, reset;
    input [11:0] greater;
    output reg [11:0] max;

    always @(posedge clk  or posedge reset) begin
        if (reset) begin
            max <= 12'b0; // Reset value
        end else begin
            max <= greater; // Update value if enabled
        end
    end
endmodule

module four_digit_bcd(ADC_value, HEX0, HEX1, HEX2, HEX3);
    input [11:0] ADC_value;
    output [6:0] HEX0, HEX1, HEX2, HEX3;
    wire [15:0] bcd_value;

    bin_to_bcd bcd(ADC_value, bcd_value);
    seg h3(bcd_value[15:12], HEX3);
    seg h2(bcd_value[11:8], HEX2);
    seg h1(bcd_value[7:4], HEX1);
    seg h0(bcd_value[3:0], HEX0);
endmodule

//binary to bcd converter
module bin_to_bcd (bin, bcd);
    input [11:0] bin; //12 bit binary input
    output reg [15:0] bcd; //16 bit bcd output
        reg [3:0] i;

        always @(bin) begin
    bcd = 0; //initializes bcd to zero
    for (i = 0; i< 12; i = i+1) begin
        bcd = {bcd[14:0], bin[11-i]}; //concatenation

        if (i<11 && bcd[3:0] > 4)
        bcd[3:0] = bcd[3:0] + 3;
        if (i<11 && bcd[7:4] > 4)
        bcd[7:4] = bcd[7:4] + 3;
        if (i<11 && bcd[11:8] > 4)
        bcd[11:8] = bcd[11:8] + 3;
        if (i<11 && bcd[15:12] > 4)
        bcd[15:12] = bcd[15:12] + 3;
        end
    end

endmodule

// 7-Segment Decoder module
module seg(X, HEX);
   input [3:0] X;
   output [6:0] HEX;

   assign HEX[0] = ~((X[3])|(X[1])|(X[2]&X[0])|(~X[2]&~X[1]&~X[0]));
   assign HEX[1] = ~((X[3])|(~X[3]&~X[2])|(~X[1]&~X[0])|(X[1]&X[0]));
   assign HEX[2] = ~((~X[1])|(X[0])|(X[2]));
   assign HEX[3] = ~((~X[2]&~X[1]&~X[0])|(X[2]&~X[1]&X[0])|(~X[3]&~X[2]&X[1])|(X[1]&~X[0]));
   assign HEX[4] = ~((~X[2]&~X[1]&~X[0])|(X[1]&~X[0]));
   assign HEX[5] = ~((X[3])|(~X[1]&~X[0])|(X[2]&~X[1])|(X[2]&X[1]&~X[0]));
   assign HEX[6] = ~((X[3])|(X[2]&~X[1])|(X[1]&~X[0])|(~X[3]&~X[2]&X[1]));
endmodule 