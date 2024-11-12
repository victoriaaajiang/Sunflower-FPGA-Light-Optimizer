//Comparator: Compare the value between voltages from solar panel
//Max_counter: Find the maximum voltage
//Theta counter: Find the 
//Phi counter: Find the angle of phi
//Register: stores previous state voltage
//7-seg decoder: Display angles and on board

module main_module(ADC_DOUT, HEX);
/*
//LEDR, HEX, SW
    //SW[0] for the mode toggle
    input [0:0] SW 

    //KEY[0] for horizontal theta control
    //KEY[1] for vertical phi control
    //KEY[2] for setting the mode/start?
    //KEY[3] for position reset
    input [3:0] KEY;
    input clk;
    //12 bit binary value representing voltage from ADC converter
    input [11: 0] ADC; 


    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    output [9:0] LEDR;


    assign LEDR[0] = SW[0]; //shows mode
    assign LEDR[1] = KEY[2]; //shows mode is set
    assign LEDR[2] = KEY[3]; //shows position is reset

    */
    input [12:0] ADC_DOUT; //takes in voltage and gives 12-bit binary

    assign adc_value = ADC_DOUT; //assigning ADC input pin for 12-bit binary, PIN_AK4

    reg [15:0] voltage_mv; // Voltage in millivolts (16 bits to account for scaling)
    reg[15:0] bcd_out//in decimals 4x4 for the 7-seg display


    // shift s1(clk, reset, enable, greater, max);
    // max_value_comparator comp1(clk, reset, a, b, greater);

    adc_voltage_reader adc(adc_value, voltage_mv);// 12-bit digital value from ADC
        // Voltage in millivolts (16 bits to account for scaling)
    BinaryToBCD bcd(voltage_mv, bcd_out);

    seg7_0 d1(bcd_out[3:0], HEX0);
    seg7_0 d2(bcd_out[7:4], HEX1);
    seg7_0 d3(bcd_out[11:8], HEX2);
    seg7_0 d4(bcd_out[15:12], HEX3);


endmodule



//Register: stores the current max voltage
//sends output to comparater to compare all raw value voltages from the ADC
module shift(clk, reset, enable, greater, max);
    input clk, reset, enable;
    //value to change to
    input [11:0] greater;
    output [11:0] max;

    always@ (posedge clk or posedge reset)
        begin
            if (reset) begin
                max <= 12'b0;//reset value
            end
            //if enable is high, changes value and updates previous
            else if (enable)
                begin
                    max <= greater;
                    previous <= greater;
                end
            //if enable is low, does not change value
        end
endmodule

//Comparator: takes in 2 12 bit voltage values and sends the greater to the register
module max_value_comparator(clk, reset, a, b, greater);
    //takes in 2 voltage values to compare
    input [11:0] a, b;
    //outputs the greater one
    output [11:0] greater;

    assign greater = (b > a);
endmodule

//Horizontal & vertical counter, decrements or increments. 
//sends a control signal to FSM to deactivate current counter and activate next one
//after both are done incrementing, their value is stored in the max counter. 


// //Horizontal Counter: Moves regularly 360 degrees around theta
// module horizontal_counter(clk);
//     input clk;
//     output done_H; //done horizontal sweep

//     always@ (posedge clk)
//         begin
//         //counts everytime and moves the motor to move the motor.

// //Maximum Counter: After the horizontal and vertical angles were compared
// module max_counter(clk, greater, max_counter, reset);
//     input clk;
//     input [11:0] greater;
//     output max_counter;
//     output reset;

//     always@ (posedge clk)begin
//         //increment
//         max_counter <= max_counter + 1;




// //Servo driver: controls speed and direction of servo motor 
// module servo_driver(direction, enable, PWM);
//     input direction, enable;
//     output PWM;
    
//ADC voltage input converter
module adc_voltage_reader (
    input [11:0] adc_value,   // 12-bit digital value from ADC
    output [15:0] voltage_mv  // Voltage in millivolts (16 bits to account for scaling)
);

    // Reference voltage (in millivolts)
    parameter VREF_MV = 4096; // 4.096V in millivolts

    // Function to convert ADC value to millivolts
    function [15:0] convert_to_voltage;
        input [11:0] adc_value; // 12-bit ADC value
        begin
            // Voltage calculation scaled to millivolts
            convert_to_voltage = (adc_value * VREF_MV) >> 12; // Divide by 2^12
        end
    endfunction

    // Assign the converted voltage to the output
    assign voltage_mv = convert_to_voltage(adc_value);

endmodule


module BinaryToBCD (
    input [15:0] binary_in,      // 16-bit binary input
    output reg [15:0] bcd_out    // 4-digit BCD output (4 x 4 bits)
);
    integer i;
    reg [27:0] shift_reg;        // 16-bit binary + 4x4 BCD = 28 bits

    always @(binary_in) begin
        // Initialize the shift register
        shift_reg = {12'b0, binary_in};

        // Perform the Double Dabble algorithm
        for (i = 0; i < 16; i = i + 1) begin
            // Check each BCD digit; if >= 5, add 3
            if (shift_reg[27:24] >= 5)
                shift_reg[27:24] = shift_reg[27:24] + 3;
            if (shift_reg[23:20] >= 5)
                shift_reg[23:20] = shift_reg[23:20] + 3;
            if (shift_reg[19:16] >= 5)
                shift_reg[19:16] = shift_reg[19:16] + 3;
            if (shift_reg[15:12] >= 5)
                shift_reg[15:12] = shift_reg[15:12] + 3;

            // Shift left by 1 bit
            shift_reg = shift_reg << 1;
        end

        // Assign the final BCD output
        bcd_out = shift_reg[27:12];
    end
endmodule

module seg7_0(X, HEX);
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