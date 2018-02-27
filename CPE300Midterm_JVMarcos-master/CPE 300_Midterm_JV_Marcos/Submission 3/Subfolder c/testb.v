module testb;
	wire displayRes;
	wire [7:0] sum;
	reg [7:0] nIn;
	reg start, restart, clk;

	reg [7:0] nArr [7:0];
	
	integer i = 128;
	
	initial
	begin
		start = 1;
		restart = 1;
		clk = 0;
		// Clock generator 
		forever
		  #2 clk = ~clk;
	end

	always
	begin
		#10 restart = 1;
		nIn <= i;
		start = 0;

	// Waiting for the work to finish, DispRes (Done)=1
		while(displayRes != 1)
			#5 begin end
	  
	$write(sum);
			 
		restart = 0;
		start = 1;
		
		i = -128
		#10 restart = 1;
		nIn <= i;
		start = 0;

	// Waiting for the work to finish, DispRes (Done)=1
		while(displayRes != 1)
			#5 begin end
	  
	$write(sum);
			 
		restart = 0;
		start = 1;
		
	$stop;
	end
      
//Initialize GDP	
GDP main (sum, 
	          start, 
	          restart, 
	          clk, 
	          nIn,
	          displayRes);
	
endmodule
