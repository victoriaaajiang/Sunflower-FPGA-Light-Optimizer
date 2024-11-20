module bcd(input [11:0] ADC_value,
output [6:0] HEX0,
output [6:0] HEX1,
output [6:0] HEX2,
output [6:0] HEX3
);
four_digit_bcd fourbcd(ADC_value, HEX0, HEX1, HEX2, HEX3);
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