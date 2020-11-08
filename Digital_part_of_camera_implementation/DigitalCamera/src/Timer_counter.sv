

module Time_counter(
	input logic 
	[5:0] Exp_time,
	start,
	clk,
	reset,
	output logic 
	ovf);
	
	reg [5:0] q = Exp_time;
	//wait( == 1);
	
	always @(posedge clk)
		wait(start);		
	
	always_ff @(posedge clk)

	assign ovf = !ovf;
	/*
	if (reset) assign q = Exp_time;
	else if(q == 0)	assign ovf = 1;
	else assign q = Exp_time - 1;
	*/
	initial assign ovf = 0;	
	
endmodule // Time_counter 

//module countDown(input logic clk, q)

module Time_counter_TB();
	
	logic start,
	clk,
	reset, ovf;
	
	reg [5:0] Exp_time;
	
	
	//reg [2:0] comb = 2'b0;
	
	Time_counter timeCounter (Exp_time,
		start,
		clk,
		reset,
		ovf);

	
	// generate clock
	always
		begin
			assign clk = 1; #1; 
			assign clk = 0; #1;
			//$display("Exp_time", Exp_time);
		end  
	
	//$display("comb", comb);
	/*
	always @(posedge clk)
	
	if (comb == 8) $finish;
	else begin 
	{reset, start} <= comb;
	comb = comb + 3'b1;
	end
	
	*/
	
	initial	begin
			start = 0; reset = 0; 
			Exp_time = 5'b01000; #4;
			start = 1; #20;
			$finish;
		end
	
	
	
	
endmodule