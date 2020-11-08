//
//
// Top-level verilog module example
//

module re_control(
	input init, Exp_increase, Exp_decrease, reset, clk,
	output expose, erase, ADC, NRE_1, NRE_2);
	
	
	//
	// Your code goes here
	//
	
	FSM_control fsmControl (init, 
	clk, 
	reset, 
	ovf,
	NRE_1, 
	NRE_2, 
	ADC_enable, 
	expose, 
	erase, 
	start_time,
	currentState, 
	nextState);
	
	CTRL_exp_time ctrlExp( 
	Exp_increase, 
	Exp_decrease, 
	clk,
	reset, Exp_time);
	
	Time_counter timeCounter(Exp_time,
	start,
	clk,
	reset,
	ovf);
	
	
	
	
endmodule // re_control

