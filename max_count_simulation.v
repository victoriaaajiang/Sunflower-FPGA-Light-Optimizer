module sunflower_prj(input CLOCK_50,
                     input [0:0] KEY,
                     input [11:0] ADC_value,
                     output [11:0] max
                     );

   reg [11:0] greatest =  12'b0;
   wire [11:0] greater;

   // Module connections
   max_value_comparator comp1(ADC_value, greatest, greater);

always @(posedge CLOCK_50) begin
       greatest <= greater; // Update greatest value on each clock cycle
   end

   shift s1(CLOCK_50, KEY[0], greater, max);

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