// ALU
module alu (out,a,b,sel,ovf);
    input [7:0] a,b;
    input [2:0] sel; 
    output [7:0] out;
    reg [7:0] out;
	output reg ovf;

    always @ (*) 
    begin 
        case(sel) 
            3'b000: out=a;                  
            3'b001: out=a*b;                  
            3'b010: out=a|b;                  
            3'b011: out=!a;                  
            3'b100: {ovf,out} = {1'b0,a} + {1'b0,b};                 
            3'b101: out=a-b;     
            3'b110: out=a+1;                 
            3'b111: out=a-1;                  
        endcase
    end
endmodule
