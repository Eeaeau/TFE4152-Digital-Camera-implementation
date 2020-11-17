//
//
// Top-level verilog module
//
`timescale 100 us / 1 us

module re_control(
	input logic init, Exp_increase, Exp_decrease, reset, clk,
	output logic expose, erase, ADC_enable, NRE_1, NRE_2);
	
	// decleration of variables
	logic start_time, reset_count, ovf4, ovf5;
	reg [5:0] Countdown_time;
	
	// FSM controll unit
	FSM_control fsmControl (init, 
		clk, 
		reset, 
		ovf4,
		ovf5,
		NRE_1, 
		NRE_2, 
		ADC_enable, 
		expose, 
		erase, 
		start_time);
	
	// counter control unit
	CTRL_exp_time ctrlExp( 
		Exp_increase, 
		Exp_decrease, 
		clk,
		reset, Countdown_time);
	
	// counter unit
	Time_counter timeCounter(Countdown_time,
		start_time,
		clk,
		reset,
		ovf5);
	
	// Set timings of row read
	always @(negedge expose) begin
		#40 ovf4 <= 1; #10 ovf4<=0;
		#30 ovf4 <= 1; #10 ovf4<=0;
		end
	
endmodule // re_control



module re_control_TB();
	
	//in
	logic init, Exp_increase, Exp_decrease, reset, clk;
	//out
	logic expose, erase, ADC_enable, NRE_1, NRE_2;
	
	// instantiate device under test
	re_control dut(init, Exp_increase, Exp_decrease, reset, clk, expose, erase, ADC_enable, NRE_1, NRE_2);
	
	reg [31:0] vectornum;
	reg [4:0] testVectors[100:0];
						 
	
	// generate clock
	always
		begin
			assign clk = 1; #5; 
			assign clk = 0; #5;
			//$display("Exp_time", Exp_time);
		end
	
	// at start of test, load vectors
	// and pulse reset
	initial begin
			$readmemb("re_control_testVectors.txt", testVectors);
			vectornum = 0;
		end
	
	always @(posedge clk)
		begin
			{init, Exp_increase, Exp_decrease, reset} =
			testVectors[vectornum];
		end
	
	always @(negedge clk)begin

			vectornum <= vectornum + 1;
			if (testVectors[vectornum] === 4'bx) begin
					$finish;
			end
			if (vectornum == 29) $finish;
		end
endmodule  // re_control_TB