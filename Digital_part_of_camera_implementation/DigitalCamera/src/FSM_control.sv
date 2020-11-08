
/*
A=idle, B=exposure, C=readout	   
`define A 4'b0000
`define B 4'b0001
`define C 4'b0010
*/

`timescale 1 ms / 1 us

typedef enum logic [2:0] {Idle, Exp, Read} statetype;

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
	start_time,
	);
	// output statetype currentState, nextState
	statetype currentState, nextState;
	
	always_ff @(posedge clk)
	if(reset) begin 
			currentState = Idle;
			assign erase = 1;
		end
	else currentState = nextState;
	
	always_comb
	case(currentState)
		Idle: if(init & !reset) begin 
					nextState = Exp;
					assign erase = 0;
					assign expose = 1;
				end
		Exp: if(ovf) begin 
					nextState = Read;
					assign expose = 0;
					
				end
		Read: if(reset | ovf) begin 
					nextState = Idle; //#10;
					//for (int i=0; i<60000; i=i+1) @(posedge clk);
					assign NRE_1 = 1;
					assign NRE_2 = 1;
				end
		default: nextState = Idle;
	endcase
	
	initial
		assign {NRE_1, 
			NRE_2, 
			ADC_enable, 
			expose, 
			erase, 
			start_time} = 6'b0;
	
	
endmodule	

module FSM_control_TB();
	
	reg [3:0] comb = 3'b0;
	
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
	
	//$display("comb", comb);
	always @(posedge clk)
		
		if (comb == 8) $finish;
		else begin 
				{init, reset, ovf} <= comb;
				comb = comb + 3'b1;
			end
endmodule


