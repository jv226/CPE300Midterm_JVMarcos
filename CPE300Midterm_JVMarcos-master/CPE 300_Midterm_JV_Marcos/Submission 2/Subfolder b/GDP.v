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

module CU(IE, WE, WA, RAE, RAA, RBE, RBA, ALU, SH, OE, start, clk, restart, aLE3, bGE4);

	input start, clk, restart;
	output IE, WE, RAE, RBE, OE;
	output [1:0] WA, RAA, RBA, SH;
	output [2:0] ALU;
	
	input wire aLE3;
	input wire bGE4;
	reg [2:0] state;
	reg [2:0] nextstate;

	parameter S0 = 3'b000;
	parameter S1 = 3'b001;
	parameter S2 = 3'b010;
	parameter S3 = 3'b011;
	parameter S4 = 3'b100;
	parameter S5 = 3'b101;
	parameter S6 = 3'b110;
	
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
			S1:	if(aLE3 && bGE4) nextstate = S3;
					else 	nextstate = S2;
			S2:	if(restart)	nextstate = S0;
					else	nextstate = S2;
			S3:	nextstate = S6;
			S4:	nextstate = S5;
			S5:	if(restart)	nextstate = S0;
					else	nextstate = S5;
			S6:	nextstate = S4;
			default: nextstate = S0;
		endcase
		
		// output logic
	assign IE = state == ~state[2] && ~state[1];
		
	assign WE = 1;
	assign WA[1] = ~state[2] && state[1] || state[2] && ~state[1];
	assign WA[0] = state == S2;
		
	assign RAE = state[2] || state[1];
	assign RAA[1] = ~state[2] || ~state[1];
	assign RAA[0] = 0;
		
	assign RBE = state[2] && ~state[1] || state == S2;
	assign RBA[1] = state == S2;
	assign RBA[0] = state == S5;
		
	assign ALU[2] = ~state[2] || ~state[1];
	assign ALU[1] = state == S3;
	assign ALU[0] = state == S2;
		
	assign SH[1] = 0;
	assign SH[0] = state == S3 || state == S6;
	assign OE = 0;
		
endmodule

module DP(aLE3, bGE4, sum, nIn, clk, IE, WE, WA, RAE, RAA, RBE, RBA, ALU, SH, OE);

	input clk, IE, WE, RAE, RBE, OE;
	input [1:0] WA, RAA, RBA, SH;
	input [2:0] ALU;
	input [7:0] nIn;
	
	output aLE3, bGE4;
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
	
endmodule







