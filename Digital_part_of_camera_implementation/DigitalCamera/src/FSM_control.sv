
/*
A=idle, B=exposure, C=readout	   
`define A 4'b0000
`define B 4'b0001
`define C 4'b0010
*/



module FSM_control (input logic init, clk, reset, ovf, output logic NRE_1, NRE_2, ADC, expose, erase, start_time);
	typedef enum logic [2:0] {A, B, C} statetype;
	
	statetype currentState, nextState;
	
	always_ff @(posedge clk)
	if(reset) currentState = A;
	else currentState = nextState;
	
	always_comb
	case(currentState)
		A: if(init & !reset) nextState = B;
			else nextState = A;
		B:
			if(ovf) nextState = C;
			else nextState = A;
		C:
			if(reset | ovf) nextState = A;
		
		default: nextState = A;
	endcase
	
endmodule



module counter(input logic clk,
	input logic reset,
	output logic [3:0] q);
	always_ff @(posedge clk)
	if (reset) q <= 4'b0;
	else q <= q+1;
endmodule