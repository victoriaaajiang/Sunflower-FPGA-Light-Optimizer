module sunflower_prj(CLOCK_50, KEY, HEX0, HEX1, HEX2, HEX3, GPIO_0);

   input [35:0] GPIO_0;
   input CLOCK_50;
   input [2:0] KEY; // reset 0, enable 1, and clk 2
   output [6:0] HEX0, HEX1, HEX2, HEX3;

   reg [11:0] ADC_value = 12'b000000000101; // Record the previous ADC value for comparison
   wire [11:0] previous;
   wire [11:0] greater;
   wire [11:0] max;

   // Assign pins from ADC output (from left to right)
//    always @ (posedge CLOCK_50) begin
//          ADC_value <= {
//          GPIO_0[25], GPIO_0[23], GPIO_0[21], GPIO_0[19], GPIO_0[17], GPIO_0[15],
//          GPIO_0[13], GPIO_0[11], GPIO_0[7], GPIO_0[5], GPIO_0[3], GPIO_0[1]};
//    end

   //wire clk = KEY[2]; // Clock signal from KEY[2]

   // Setup HEX display digits
   wire [15:0] bcd_digits;
//   wire [3:0] digits0, digits1, digits2, digits3;

   // Module connections
   //previous p1(CLOCK_50, ADC_value, previous);
   //max_value_comparator comp1(ADC_value, previous, greater);
   //shift s1(CLOCK_50, KEY[0], KEY[1], greater, max);

   // Display Functions
   //bin_to_bcd bcd(max, digits0, digits1, digits2, digits3);
   Binary_to_BCD bcd(CLOCK_50, ADC_value, bcd_digits);

   seg voltage1(bcd_digits[3:0], HEX0);
   seg voltage2(bcd_digits[7:4], HEX1);
   seg voltage3(bcd_digits[11:8], HEX2);
   seg voltage4(bcd_digits[15:12], HEX3);

endmodule

// Record previous ADC value
module previous(clk, ADC_value, previous);
   input clk;
   input [11:0] ADC_value;
   output reg [11:0] previous;

   always @(posedge clk) begin
       previous <= ADC_value;
   end
endmodule

// Comparator: Takes in 2 12-bit voltage values and outputs the greater value
module max_value_comparator(a, b, greater);
   input [11:0] a, b;
   output [11:0] greater;

   assign greater = (a > b) ? a : b;
endmodule

// Register: Stores the current max voltage
module shift(clk, reset, enable, greater, max);
   input clk, reset, enable;
   input [11:0] greater;
   output reg [11:0] max;

   always @(posedge clk or posedge reset) begin
       if (reset) begin
           max <= 12'b0; // Reset value
       end else if (enable) begin
           max <= greater; // Update value if enabled
       end
   end
endmodule

//// BCD Converter: Converts binary to BCD for display (Old function that doesn't work)
//module bin_to_bcd(max, digits0, digits1, digits2, digits3);
//   input [11:0] max;
//   output reg [3:0] digits0, digits1, digits2, digits3;
//   integer i;
//   reg [19:0] shift_reg; // Shift register for binary-to-BCD conversion
//
//   always @(*) begin
//       shift_reg = {8'b0, max}; // Initialize shift register
//
//       // Perform double-dabble algorithm
//       for (i = 0; i < 12; i = i + 1) begin
//           if (shift_reg[19:16] >= 5) shift_reg[19:16] = shift_reg[19:16] + 3;
//           if (shift_reg[15:12] >= 5) shift_reg[15:12] = shift_reg[15:12] + 3;
//           if (shift_reg[11:8] >= 5) shift_reg[11:8] = shift_reg[11:8] + 3;
//           if (shift_reg[7:4] >= 5) shift_reg[7:4] = shift_reg[7:4] + 3;
//
//           shift_reg = shift_reg << 1; // Shift left
//       end
//
//       digits3 = shift_reg[19:16];
//       digits2 = shift_reg[15:12];
//       digits1 = shift_reg[11:8];
//       digits0 = shift_reg[7:4];
//   end
//endmodule

// BCD Converter: Converts binary to BCD for display


module Binary_to_BCD
   (input i_Clock,
    input [11:0] i_Binary,
    output [15:0] o_BCD
   );

  parameter s_IDLE              = 3'b000;
  parameter s_SHIFT             = 3'b001;
  parameter s_CHECK_SHIFT_INDEX = 3'b010;
  parameter s_ADD               = 3'b011;
  parameter s_CHECK_DIGIT_INDEX = 3'b100;
  parameter s_BCD_DONE          = 3'b101;

  reg [2:0] r_SM_Main = s_IDLE;
  reg [15:0] r_BCD = 0;
  reg [11:0] r_Binary = 0;
  reg [11:0] r_Prev_Binary = 0; // Tracks the last processed value of i_Binary
  reg [3:0] r_Digit_Index = 0;
  reg [7:0] r_Loop_Count = 0;
  wire [3:0] w_BCD_Digit;

  always @(posedge i_Clock) begin
    // Check if the input binary value has changed
    //r_BCD only resets when starting a new cycle.
    if (i_Binary != r_Prev_Binary && r_SM_Main == s_IDLE) begin
      r_Binary <= i_Binary; // Load new binary value
      r_Prev_Binary <= i_Binary; // Update the previous value tracker
      r_BCD <= 0;          // Reset BCD result
      r_Loop_Count <= 0;   // Reset loop counter
      r_Digit_Index <= 0;  // Reset digit index
      r_SM_Main <= s_SHIFT; // Start conversion
    end

    case (r_SM_Main)
      s_SHIFT: begin
        r_BCD <= r_BCD << 1;
        r_BCD[0] <= r_Binary[11];
        r_Binary <= r_Binary << 1;
        r_SM_Main <= s_CHECK_SHIFT_INDEX;
      end

      s_CHECK_SHIFT_INDEX: begin
        if (r_Loop_Count == 11) begin
          r_Loop_Count <= 0;
          r_SM_Main <= s_BCD_DONE;
        end else begin
          r_Loop_Count <= r_Loop_Count + 1;
          r_SM_Main <= s_ADD;
        end
      end

      s_ADD: begin
        if (w_BCD_Digit > 4) begin
          r_BCD[(r_Digit_Index * 4) +: 4] <= w_BCD_Digit + 3;
        end
        r_SM_Main <= s_CHECK_DIGIT_INDEX;
      end

      s_CHECK_DIGIT_INDEX: begin
        if (r_Digit_Index == 3) begin
          r_Digit_Index <= 0;
          r_SM_Main <= s_SHIFT;
        end else begin
          r_Digit_Index <= r_Digit_Index + 1;
          r_SM_Main <= s_ADD;
        end
      end

      s_BCD_DONE: begin
        r_SM_Main <= s_IDLE;
      end

      default: r_SM_Main <= s_IDLE;
    endcase
  end

  assign w_BCD_Digit = r_BCD[r_Digit_Index * 4 +: 4];
  assign o_BCD = r_BCD;

endmodule


// 7-Segment Decoder
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