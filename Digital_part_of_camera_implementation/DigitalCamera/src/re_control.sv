//
//
// Top-level verilog module example
//
`timescale 1 ms / 1 us

module re_control(
	input logic init, Exp_increase, Exp_decrease, reset, clk,
	output logic expose, erase, ADC_enable, NRE_1, NRE_2);
	
	
	//
	// Your code goes here
	//
	logic start, reset_count, ovf;
	reg [5:0] Countdown_time;
	
	statetype currentState, nextState;
	
	// FSM controll unit
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
	
	
	// counter control unit
	CTRL_exp_time ctrlExp( 
		Exp_increase, 
		Exp_decrease, 
		clk,
		reset, Countdown_time);
	
	// counter unit
	Time_counter timeCounter(Countdown_time,
		start,
		clk,
		reset,
		ovf);
	
	
	
	
	
endmodule // re_control



module re_control_TB();
	
	//in
	logic init, Exp_increase, Exp_decrease, reset, clk;
	//out
	logic expose, erase, ADC_enable, NRE_1, NRE_2;
	
	// instantiate device under test
	re_control dut(init, Exp_increase, Exp_decrease, reset, clk, expose, erase, ADC_enable, NRE_1, NRE_2);
	
	reg [31:0] vectornum;
	reg [4:0] testVectors[10:0];
	
	
	// generate clock
	always
		begin
			assign clk = 1; #1; 
			assign clk = 0; #1;
			//$display("Exp_time", Exp_time);
		end
	
	// at start of test, load vectors
	// and pulse reset
	initial begin
			$readmemb("re_control_testVectors.txt", testVectors);
			vectornum = 0;
			reset = 1; #1; reset = 0;
			
			
		end
	
	always @(posedge clk)
		begin
			{init, Exp_increase, Exp_decrease, reset} =
			testVectors[vectornum];
		end
	
	always @(negedge clk)begin
		/*
		if (~reset) begin // skip during reset
				vectornum = vectornum + 1;
				
		end	
		*/
		vectornum <= vectornum + 1;
		if (testVectors[vectornum] === 'bx) begin
						$finish;
					end
	 end
endmodule