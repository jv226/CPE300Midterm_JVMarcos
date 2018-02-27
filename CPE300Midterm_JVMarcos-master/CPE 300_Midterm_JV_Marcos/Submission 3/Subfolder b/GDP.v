module GDP(Sum, start, restart, clk, n, done);
	input start, clk, restart;
	input [7:0] n;
	output [7:0] Sum;
	output done;
	
	wire WE, RAE, RBE, OE, nEqZero, IE;
	wire [1:0] WA, RAA, RBA, SH;
	wire [2:0] ALU;
	
 	CU control (IE, WE, WA, RAE, RAA, RBE, RBA, ALU, SH, OE, ~start, clk, ~restart, nEqZero);
	DP datapath (nEqZero, Sum, n, clk, IE, WE, WA, RAE, RAA, RBE, RBA, ALU, SH, OE);
	
	assign done = OE;

endmodule

module CU(IE, WE, WA, RAE, RAA, RBE, RBA, ALU, SH, OE, start, clk, restart, nEqZero, Uovf, Sovf);

	input start, clk, restart, Sovf, Uovf;
	output IE, WE, RAE, RBE, OE;
	output [1:0] WA, RAA, RBA, SH;
	output [2:0] ALU;
	
	input wire nEqZero;
	reg [1:0] state;
	reg [1:0] nextstate;

	parameter S0 = 2'b00;
	parameter S1 = 2'b01;
	parameter S2 = 2'b10;
	parameter S3 = 2'b11;
	
	initial
		state = S0;
	
	// State register
	always @ (posedge clk)
	begin
		state <= nextstate;
	end
	// NS logic
	always @ (*)
		case(state)
			S0: if(start) nextstate = S1;
					else 	nextstate = S0;
			S1:	nextstate = S2;
			S2:	nextstate = S3;
			S3:	if(restart)	nextstate = S0;
					else	nextstate = S3;
			default: nextstate = S0;
		endcase
		
		// output logic
	assign IE = state == state[1] && ~state[0] || ~state[1] && state[0];
		
	assign WE = state == state[1] || state[0];
	assign WA[1] = state == S3;
	assign WA[0] = state == S2;
		
	assign RAE = state == S3;
	assign RAA[1] = 0;
	assign RAA[0] = 0;
		
	assign RBE = state == S3;
	assign RBA[1] = 0;
	assign RBA[0] = 1;
		
	assign ALU[2] = 1;
	assign ALU[1] = 0;
	assign ALU[0] = 0;
		
	assign SH[1] = 0;
	assign SH[0] = 0;
	assign OE = 0;
		
endmodule

module DP(nEQZero, sum, nIn, clk, IE, WE, WA, RAE, RAA, RBE, RBA, ALU, SH, OE, Sovf, Uovf);

	input clk, IE, WE, RAE, RBE, OE;
	input [1:0] WA, RAA, RBA, SH;
	input [2:0] ALU;
	input [7:0] nIn;
	
	output wire ovf;
	output nEQZero;
	output wire [7:0] sum;
	
	reg [7:0] rfIn;
	wire [7:0] RFa, RFb, aluOut, shOut, n;
	
	initial 
	 rfIn = 0;
	 
	always @ (*)
	 rfIn = n;
	
	mux8 muxs (n, shOut, nIn, IE);
	Regfile RF (clk, RAA, RFa, RBA, RFb, WE, WA, rfIn, RAE, RBE);
	alu theALU (aluOut, RFa, RFb, ALU, Uovf, Sovf);
	shifter SHIFT (shOut, aluOut, SH);
	buff buffer1 (sum, shOut, OE);
	
	assign nEQZero = n == 0;
	
endmodule







