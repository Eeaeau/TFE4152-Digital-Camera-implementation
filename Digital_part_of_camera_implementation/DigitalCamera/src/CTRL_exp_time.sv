


module CTRL_exp_time(
	input logic 
	Exp_increase, 
	Exp_decrease, 
	clk,
	reset,
	output logic [5:0] Exp_time);
	
	//oldExp_time 
	
	//assign newExp_time = oldExp_time;
	
	always_ff @(posedge clk)
	if (reset) Exp_time <= 6'b10;
	else if(Exp_increase & (Exp_time < 30)) Exp_time <= Exp_time + 1;
	else if (Exp_decrease & 2 < Exp_time) Exp_time <= Exp_time - 1;

endmodule