
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
	start_time, output statetype currentState, nextState
	);
	// 
	
	
	always_ff @(posedge clk)
	if(reset) begin 
			currentState = Idle;
		end
	else currentState = nextState;
	
	always_comb
	case(currentState)
		Idle: if(init & !reset) begin 
					nextState = Exp;
					assign erase = 0;
					assign expose = 1;
				end
			else begin 
					assign {NRE_1, 
						NRE_2, 
						ADC_enable, 
						expose, 
						erase, 
						start_time} = 6'b110000;
				end
		Exp: if(ovf) begin 
					nextState = Read_R1;
					assign expose = 0;
					
				end
		Read_R1: if(ovf) begin 
					nextState = Read_R2;
					assign NRE_1 = 0;
				end
		
		Read_R2: if(reset | ovf) begin 
					nextState = Idle;
					assign NRE_2 = 0;
					
				end
		default: nextState = Idle;
	endcase
	
	initial
		assign {NRE_1, 
			NRE_2, 
			ADC_enable, 
			expose, 
			erase, 
			start_time} = 6'b110000;
	
	
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


