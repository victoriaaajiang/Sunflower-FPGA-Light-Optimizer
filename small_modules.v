//Comparator: Compare the value between voltages from solar panel
//Max_counter: Find the maximum voltage
//Theta counter: Find the 
//Phi counter: Find the angle of phi
//Register: stores previous state voltage
//7-seg decoder: Display angles and on board

module main_module(LEDR, HEX, SW);
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

    shift s1(clk, reset, enable, greater, max);
    max_value_comparator comp1(clk, reset, a, b, greater);

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