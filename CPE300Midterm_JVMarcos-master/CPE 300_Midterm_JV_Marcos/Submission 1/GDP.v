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

module CU(IE, WE, WA, RAE, RAA, RBE, RBA, ALU, SH, OE, start, clk, restart, nEqZero);

	input start, clk, restart;
	output IE, WE, RAE, RBE, OE;
	output [1:0] WA, RAA, RBA, SH;
	output [2:0] ALU;
	
	input wire nEqZero;
	reg [2:0] state;
	reg [2:0] nextstate;

	parameter S0 = 3'b000;
	parameter S1 = 3'b001;
	parameter S2 = 3'b010;
	parameter S3 = 3'b011;
	parameter S4 = 3'b100;
	
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
			S0: if(start) nextstate = S0;
					else 	nextstate = S1;
			S1:	if(start == 1'b0) nextstate = S0;
				else if(nEqZero) nextstate = S4;
					else 	nextstate = S2;
			S2:	nextstate = S3;
			S3:	if(start == 1'b0) nextstate = S0;
				else if(nEqZero) nextstate = S4;
					else 	nextstate = S2;
			S4:	if(start == 1'b0) nextstate = S0;
				else if(nEqZero) nextstate = S0;
					else	nextstate = S4;
			default: nextstate = S0;
		endcase
		
		// output logic
	assign IE = state == S1;
		
	assign WE = 1;
	assign WA[1] = 0;
	assign WA[0] = state[0];
		
	assign RAE = ~state[2] && state[1] || ~state[1] && ~state[0];
	assign RAA[1] = 0;
	assign RAA[0] = state == S3;
		
	assign RBE = ~state[2] && ~state[0];
	assign RBA[1] = 0;
	assign RBA[0] = state == S2;
		
	assign ALU[2] = ~state[2];
	assign ALU[1] = state == S3;
	assign ALU[0] = state == S0 || state == S3;
		
	assign SH[1] = 0;
	assign SH[0] = 0;
	assign OE = state == S4;
		
endmodule

module DP(nEQZero, sum, nIn, clk, IE, WE, WA, RAE, RAA, RBE, RBA, ALU, SH, OE);

	input clk, IE, WE, RAE, RBE, OE;
	input [1:0] WA, RAA, RBA, SH;
	input [2:0] ALU;
	input [7:0] nIn;
	
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
	alu theALU (aluOut, RFa, RFb, ALU);
	shifter SHIFT (shOut, aluOut, SH);
	buff buffer1 (sum, shOut, OE);
	
	assign nEQZero = n == 0;
	
endmodule







