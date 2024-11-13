module main_module(SW, KEY, HEX, LEDR);

//LEDR, HEX, SW
    //SW[0] for the mode toggle
    input [0:0] SW ;
    input [0:0] KEY;
    input [11:0] a, b;
    //12 bit binary value representing voltage from ADC converter
    // input [11: 0] ADC; 
    wire [11:0] max;


    // output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    output [0:0] LEDR;
    output [11:0] max;

    wire clk;
    assign clk = KEY[0];
    wire reset = SW[0];
    wire [11:0] max_interval;

    max_value_comparator comp1(clk, reset, a, b, greater);
    shift s1(clk, KEY[1], KEY[2], greater, max_inverval);
    assign max = max_interval;

endmodule

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

    //this line needs to be changed!!!!!!!!!!!!!!!!!!!
    assign greater = (b > a);
endmodule