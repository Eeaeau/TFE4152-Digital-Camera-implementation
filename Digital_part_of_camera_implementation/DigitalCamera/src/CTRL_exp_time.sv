


module CTRL_exp_time(
	input logic 
	Exp_increase, 
	Exp_decrease, 
	clk,
	reset,
	output logic [5:0] Exp_time);
	
	// set inital value
	initial Exp_time = 5'b10; 
	
		
	always @(posedge clk)
		if (reset) Exp_time <= 5'b10; // reset time to default value
		else if (Exp_increase & (Exp_time < 30)) Exp_time <= Exp_time + 1; // increase time
		else if (Exp_decrease & (2 < Exp_time)) Exp_time <= Exp_time - 1; // decrease time
	
endmodule // CTRL_exp_time


module CTRL_exp_time_TB();
	
	reg [4:0] test_reg = 4'b0;
	reg [3:0] Exp_time;
	
	logic Exp_increase, 
	Exp_decrease, 
	clk,
	reset;
	
	
	// initiate module to be tested
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
	
	//$display("comb", test_reg);
	always @(posedge clk)
		
		if (test_reg == 16) $finish; // condition for stopping sim
		else begin 
				// increment test vector
				{reset, Exp_increase, Exp_decrease } <= test_reg;
				test_reg = test_reg + 4'b1;
			end
endmodule // CTRL_exp_time_TB