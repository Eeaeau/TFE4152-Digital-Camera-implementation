
/*
A=idle, B=exposure, C=readout	   
`define A 4'b0000
`define B 4'b0001
`define C 4'b0010
*/

`timescale 1 ms / 1 us

typedef enum logic [2:0] {Idle, Exp, Read_R1, Read_R2} statetype;

module FSM_control (
	input logic 
	init, 
	clk, 
	reset, 
	ovf, 
	output logic 	 
	NRE_1, 
	NRE_2, 
	ADC_enable, 
	expose, 
	erase, 
	start_time
	);
	// output statetype currentState, nextState
	
	statetype currentState, nextState;
	
	logic skip; // logic for skipping clk cycle
	
	always_ff @(posedge clk)
	if(reset) begin 
			currentState = Idle;
		end
	else currentState = nextState;
	
	// implimentation on FSM stages
	always_comb
	case(currentState)
		Idle: if(init & !reset) begin 
					nextState = Exp;
					assign erase = 0;
					assign expose = 1;
				end
			else if(!skip) begin 
					assign {NRE_1, 
						NRE_2, 
						ADC_enable, 
						expose, 
						erase, 
						start_time} = 6'b110000;
				end
			else assign skip = 0;
		Exp: if(ovf) begin 
					nextState = Read_R1;
					assign expose = 0;
					assign skip = 1;					
				end
		Read_R1: 
			// Go to next read stage
			if(ovf & NRE_1 & !ADC_enable) begin 
					nextState = Read_R2;
					assign skip = 1;
				end
			// start adc
			else if (!skip & !NRE_1) begin 
					assign ADC_enable = 1;
					
				end
			// end adc
			else if (ADC_enable) begin 
					assign ADC_enable = 0;
					assign skip = 1;
				end
			// start first read
			else if (!skip) begin 
					assign NRE_1 = 0;
					assign skip = 1;
					
				end
			// wait skip cycle
			else assign skip = 1;
		
		Read_R2: 
			// Go to next read stage
			if(ovf & NRE_2 & !ADC_enable) begin 
					nextState = Idle;
					assign skip = 1;
				end
			// start adc
			else if (!skip & !NRE_2) begin 
					assign ADC_enable = 1;
					
				end
			// end adc
			else if (ADC_enable) begin 
					assign ADC_enable = 0;
					assign skip = 1;
				end
			// start first read
			else if (!skip) begin 
					assign NRE_2 = 0;
					assign skip = 1;		
				end
			// wait skip cycle
			else assign skip = 1;
		
		default: nextState = Idle;
	endcase
	
	initial
		assign {NRE_1, 
			NRE_2, 
			ADC_enable, 
			expose, 
			erase, 
			start_time} = 6'b110000;
	assign skip = 1;
	
	
endmodule //FSM_control	

module FSM_control_TB();
	
	reg [3:0] test_reg = 3'b0;
	
	//in
	logic init, clk, reset, ovf;
	//out
	logic NRE_1, NRE_2, 
	ADC_enable, 
	expose, 
	erase, 
	start_time;
	
	FSM_control fsmControl (init, 
		clk, 
		reset, 
		ovf,
		NRE_1, 
		NRE_2, 
		ADC_enable, 
		expose, 
		erase, 
		start_time);
	
	// generate clock
	always
		begin
			assign clk = 1; #1; 
			assign clk = 0; #1;
		end  
	
	//$display("comb", test_reg);
	always @(posedge clk)
		
		if (test_reg == 8) $finish;
		else begin 
				{init, reset, ovf} <= test_reg;
				test_reg = test_reg + 3'b1;
			end
endmodule


