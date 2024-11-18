//Comparator: Compare the value between voltages from solar panel
//Max_counter: Find the maximum voltage
//Theta counter: Find the 
//Phi counter: Find the angle of phi
//Register: stores previous state voltage
//7-seg decoder: Display angles and on board

module sunflower(GPIO_0, KEY, HEX0, HEX1, HEX2, HEX3, clk);

    input [35:0] GPIO_0;
    input KEY[0], KEY[1]; //resent and enable
    input clk;
    output [6:0]HEX0, HEX1, HEX2, HEX3;

    wire [11:0] ADC_value; //record the preivous ADC value for comparison
    reg [11:0] previous;
    wire [11:0] greater;
    reg [11:0] max;
    //assign pins from ADC output from left to right)
    assign ADC_value = {
        GPIO_0[25],
        GPIO_0[23],
        GPIO_0[21],
        GPIO_0[19],
        GPIO_0[17],
        GPIO_0[15],
        GPIO_0[13],
        GPIO_0[11],

        GPIO_0[7],
        GPIO_0[5],
        GPIO_0[3],
        GPIO_0[1]
    };

//setup hex display digits
    reg [3:0] digits0;
    reg [3:0] digits1;
    reg [3:0] digits2;
    reg [3:0] digits3;

    //max_value_comparator(clk, reset, ADC, previous, greater)
    previous p1(clk, ADC_value, previous);
    max_value_comparator comp1(clk, ADC_value, previous, greater);
    shift s1(clk, KEY[0], KEY[1], greater, max);
    //shift(clk, reset, enable, greater, max)

    //Display Functions
    bin_to_bcd bcd(max, digits0, digits1, digits2, digits3);

    seg voltage1(digits0, HEX0);
    seg voltage2(digits1, HEX1);
    seg voltage3(digits2, HEX2);
    seg voltage4(digits3, HEX3);

endmodule

//record previous ADC
module previous(clk, ADC_value, previous);
    input clk;
    input [11:0] ADC_value;
    output reg [11:0] previous;

    always@ (posedge clk) begin
        previous <= ADC_value;
    end

endmodule

//Comparator: takes in 2 12 bit voltage values and sends the greater to the register
module max_value_comparator(clk, a, b, greater);
    //takes in 2 voltage values to compare
    input [11:0] a, b;
    //outputs the greater one
    output [11:0] greater;

    assign greater = (a > b) ? a : b;
endmodule


//Register: stores the current max voltage
//sends output to comparater to compare all raw value voltages from the ADC
module shift(clk, reset, enable, greater, max);
    input clk, reset, enable;
    //value to change to
    input [11:0] greater;
    output reg [11:0] max;

    always@ (posedge clk or posedge reset)
        begin
            if (reset) begin
                max <= 12'b0;//reset value
            end
            //if enable is high, changes value and updates previous
            else if (enable)
                begin
                    max <= greater;
                end
            //if enable is low, does not change value
        end
endmodule


//BCD converter, to display the voltage on the HEX
module bin_to_bcd (max, digits0, digits1, digits2, digits3);
    input [11:0] max;
    output reg [3:0] digits0, digits1, digits2, digits3;
    integer i;
    reg [19:0] shift_reg; // Shift register for binary-to-BCD conversion

    always @(*) begin
        // Initialize shift register
        shift_reg = {8'b0, max}; // 8 MSBs for BCD digits, 12 LSBs for binary input

        // Perform double-dabble algorithm
        for (i = 0; i < 12; i = i + 1) begin
            // Add 3 if BCD digit >= 5
            if (shift_reg[19:16] >= 5) shift_reg[19:16] = shift_reg[19:16] + 3;
            if (shift_reg[15:12] >= 5) shift_reg[15:12] = shift_reg[15:12] + 3;
            if (shift_reg[11:8] >= 5) shift_reg[11:8] = shift_reg[11:8] + 3;
            if (shift_reg[7:4] >= 5) shift_reg[7:4] = shift_reg[7:4] + 3;

            // Shift left
            shift_reg = shift_reg << 1;
        end

        // Assign BCD digits
        digits3 = shift_reg[19:16];
        digits2 = shift_reg[15:12];
        digits1 = shift_reg[11:8];
        digits0 = shift_reg[7:4];
    end
endmodule


module seg7(X, HEX);
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