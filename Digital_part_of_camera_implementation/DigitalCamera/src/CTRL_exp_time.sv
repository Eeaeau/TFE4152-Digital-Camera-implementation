


module CTRL_exp_time(
	input logic 
	Exp_increase, 
	Exp_decrease, 
	clk,
	reset,
	output logic [5:0] Exp_time);
	
	//oldExp_time 
	
	//assign newExp_time = oldExp_time;
	
	initial Exp_time = 6'b10; 
	
	always @(posedge clk)
		if (reset) Exp_time <= 6'b10;
		else if(Exp_increase & (Exp_time < 30)) Exp_time <= Exp_time + 1;
		else if (Exp_decrease & 2 < Exp_time) Exp_time <= Exp_time - 1;
	
endmodule // CTRL_exp_time


module CTRL_exp_time_TB();
	
	reg [3:0] comb = 3'b0;
	
	logic Exp_increase, 
	Exp_decrease, 
	clk,
	reset;
	
	reg [3:0] Exp_time;
	
	CTRL_exp_time ctrlTime(Exp_increase, 
		Exp_decrease, 
		clk,
		reset,Exp_time);
	
	// generate clock
	always
		begin
			assign clk = 1; #1; 
			assign clk = 0; #1;
		end  
	
	//$display("comb", comb);
	always @(posedge clk)
		
		if (comb == 8) $finish;
		else begin 
				{Exp_increase, Exp_decrease, reset} <= comb;
				comb = comb + 3'b1;
			end
endmodule