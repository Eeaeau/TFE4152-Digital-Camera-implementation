

module Time_counter(
	input logic 
	[5:0] Exp_time,
	start,
	clk,
	reset,
	output logic 
	ovf);
	
	reg [5:0] q;
	
	
	always_ff @(posedge clk) begin
	if(reset) 
		q <= Exp_time;
	else if (start) 
		q <= q - 5'b1;
	
	
		if (q < 5'b1) ovf = 1;
		else ovf = 0;
	
	end
	
	
	//always @(*)
		
	//assign ovf = (q <= 1) ? 1 : 0;
	
	//initial assign ovf = 0;	
	
	
	//assign ovf = (q <= 5'd1) ? 1 : 0;	
	
endmodule // Time_counter 

//module countDown(input logic clk, q)

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
			start = 0; reset = 1;
			Exp_time = 5'b01000; #1;
			start = 1; reset = 0; #20;
			
		end
	always @(*)
	 if (ovf == 1) $finish;
	
	
	
endmodule