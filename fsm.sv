module fsmModule( input logic [4:0] buttons, input logic signed [7:0] first, second, input logic clk, 
                    output logic a, b, c, d, e, f, g, dp,
                    output logic [3:0] an,
                    output logic [15:0] led );
                 
    logic [2:0] currentS, nextS; 
    logic signed [19:0] result;
    logic [19:0] complement;
    logic [26:0] count;
    initial count = 0;
    localparam timePart = 50000000;
    logic display;

    parameter S0 = 3'b000;
    parameter S1 = 3'b001;
    parameter S2 = 3'b010;
    parameter S3 = 4'b011;
    parameter S4 = 3'b100;                                                                                                                                                                              
    
    //state register
    always_ff @( posedge clk )begin
        if( buttons == 5'b00001)
            currentS <= S0;
        else
            currentS <= nextS;
    end   
	
	//next state logic
    always_comb
        begin
            case(currentS)
            
            S0:
            begin
                if( buttons  == 5'b00010 )
                     nextS <= S1;
                else if ( buttons == 5'b00100 )
                     nextS <= S2;
                else if ( buttons == 5'b01000 )
                    nextS <= S3;
                else if ( buttons == 5'b10000 )
                    nextS <= S4;
                else 
                    nextS <= S0;
            end
            S1:
            begin
                if( buttons == 5'b00001 )
                    nextS <= S0;
                else
                    nextS <= S1; 
            end
            
            S2:
            begin
                if( buttons == 5'b00001 )
                    nextS <= S0;
                else
                    nextS <= S2; 
            end
            S3:
            begin
                if( buttons == 5'b00001 )
                    nextS <= S0;
                else
                    nextS <= S3; 
            end
            
            S4:
            begin
                if( buttons == 5'b00001 )
                    nextS <= S0;
                else
                    nextS <= S4; 
            end
        
            default : nextS = S0;
         endcase //case end
        end // begin end
        
        //output logic
        always @(currentS)
        case(currentS)
            S0:  
                result <= 20'b0;
            S1 : 
                result <= first + second;
            S2 : 
                result <= first * second;
            S3 : 
                result <= first / second;
            S4 : 
                result <= first % second;
                
            default : 
                result <= 20'b0;
        endcase
      
       //clock divider 
       
        always @( posedge clk )
        begin
            if (count < timePart)
            begin
                display <= 1;
                count <= count + 1;
            end
            
            else if ((count >= timePart) && (count < timePart * 4)) 
            begin
                display <= 0;
                count <= count + 1;
            end
            
            else if (count == (timePart * 4))
                count <= 0;
        end 
        
        
            always @(*)
            begin
                if(result < 0)
                    begin
                        complement = ~result + 1;
                    end
                else
                        complement = result;
            end
            
           
          SevSeg_4digit segm(display ,clk, (result[15] ? 5'b10000 : {complement[15:12]}), 
                                    (result[15] ? {complement[11:8]} : {complement[11:8]}) ,
                                    (result[15] ? {complement[7:4]} : {complement[7:4]}),
                                    (result[15] ? {complement[3:0]} : {complement[3:0]}) , {a, b, c, d, e, f, g} , dp, an);
        
          led_sw leds (first, second, led);

endmodule 
 
