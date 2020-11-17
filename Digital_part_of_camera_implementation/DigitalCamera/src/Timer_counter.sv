

module Time_counter(
	input logic 
	[5:0] Exp_time,
	start,
	clk,
	reset,
	output logic 
	ovf);
	
	// create internal registry
	reg [5:0] q;
	
	
	// countdown logic
	always_ff @(posedge clk) begin
		if(reset) 
			q <= Exp_time; // reset time to input value
		else if (start) 
			q <= q - 5'b1; // decrease time
	   	
		// Set output value
		if (q < 5'b1) ovf = 1; // countdown finished
		else ovf = 0;
		
	end
	
	
endmodule // Time_counter 


module Time_counter_TB();
	
	logic start,
	clk,
	reset, ovf;
	
	reg [5:0] Exp_time;
	
	//reg [2:0] comb = 2'b0;
	
	Time_counter timeCounter (.Exp_time(Exp_time),
		.start(start),
		.clk(clk),
		.reset(reset),
		.ovf(ovf));
	
	// generate clock
	always
		begin
			assign clk = 1; #1; 
			assign clk = 0; #1;
		end  
	
	// initiat output values
	initial	begin
			start = 0; reset = 1;
			Exp_time = 5'b01000; #1;
			start = 1; reset = 0; #20;
			
		end
	always @(*)
		if (ovf == 1) $finish; // stop sim
	
endmodule // Time_counter_TB