// 7 SEGMENT
`timescale 1 ps / 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Hamzeh Ahangari
// 
// Create Date: 
// Design Name: 
// Module Name: 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.02 - Changed according to new implementation on calculator project by Münevver
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// this module shows 4 decimal numbers on 4-digit 7-Segment.  
// 4 digits are scanned with high speed, then you do not notice that every time 
// only one of them is ON. dp is always off.

// LED positions inside 7-segment
//    A -->  /seg[6]
//  F   B
//    G -->  /seg[0]
//  E   C
//    D   DP

// digit positions on Basys3 :
// in3(left), in2, in1, in0(right)


module SevSeg_4digit( input display,
 input clk,
 input [4:0] in0, in1, in2, in3, //user inputs for each digit (hexadecimal value)
 output [6:0]seg, logic dp, // just connect them to FPGA pins (individual LEDs).
 output [3:0] an   // just connect them to FPGA pins (enable vector for 4 digits active low)
 );
 
// divide system clock (100Mhz for Basys3) by 2^N using a counter, which allows us to multiplex at lower speed
localparam N = 18;
logic [N-1:0] count = {N{1'b0}}; //initial value
always@ (posedge clk)
	count <= count + 1;

 
logic [4:0]digit_val; // 7-bit register to hold the current data on output
logic [3:0]digit_en;  //register for the 4 bit enable
 
always@ (*)
 begin
 digit_en = 4'b1111; //default
 digit_val = in0; //default
 
  case(count[N-1:N-2]) //using only the 2 MSB's of the counter 
    
   2'b00 :  //select first 7Seg.
    begin
     digit_val = in0;
     digit_en = 4'b1110;
    end
    
   2'b01:  //select second 7Seg.
    begin
     digit_val = in1;
     digit_en = 4'b1101;
    end
    
   2'b10:  //select third 7Seg.
    begin
     digit_val = in2;
     digit_en = 4'b1011;
    end
     
   2'b11:  //select forth 7Seg.
    begin
     digit_val = in3;
     digit_en = 4'b0111;
    end
  endcase
 end
 

//Convert digit number to LED vector. LEDs are active low.
logic [6:0] sseg_LEDs; 
always @(*)
 begin 
  if(display)
    begin
      sseg_LEDs = 7'b1111111; //default
      case(digit_val)
      5'd0 : sseg_LEDs = 7'b1000000; //to display 0
      5'd1 : sseg_LEDs = 7'b1111001; //to display 1
      5'd2 : sseg_LEDs = 7'b0100100; //to display 2
      5'd3 : sseg_LEDs = 7'b0110000; //to display 3
      5'd4 : sseg_LEDs = 7'b0011001; //to display 4
      5'd5 : sseg_LEDs = 7'b0010010; //to display 5
      5'd6 : sseg_LEDs = 7'b0000010; //to display 6
      5'd7 : sseg_LEDs = 7'b1111000; //to display 7
      5'd8 : sseg_LEDs = 7'b0000000; //to display 8
      5'd9 : sseg_LEDs = 7'b0010000; //to display 9
      5'd10: sseg_LEDs = 7'b0001000; //to display a
      5'd11: sseg_LEDs = 7'b0000011; //to display b
      5'd12: sseg_LEDs = 7'b1000110; //to display c
      5'd13: sseg_LEDs = 7'b0100001; //to display d
      5'd14: sseg_LEDs = 7'b0000110; //to display e
      5'd15: sseg_LEDs = 7'b0001110; //to display f
      5'd14: sseg_LEDs = 7'b0000110; //to display e
      5'd15: sseg_LEDs = 7'b0001110; //to display f    
      5'd16: sseg_LEDs = 7'b0111111; //to display -
      5'd17 : sseg_LEDs = 7'b11101111; //to display _
      5'd18 : sseg_LEDs = 7'b10000001; //to display U
       default : sseg_LEDs = 7'b11001111; //dash
       endcase
      end
   else 
    sseg_LEDs = 7'b11111111;
    
 end
 
assign an = digit_en;
assign seg = sseg_LEDs; 
assign dp = 1'b1; //turn dp off
 
 
endmodule


module led_sw(input logic [7:0] firstNum, secondNum, output [15:0] leds);
    assign leds = { firstNum[7:0], secondNum[7:0] };
endmodule

