
/*
A=idle, B=exposure, C=readout	   
`define A 4'b0000
`define B 4'b0001
`define C 4'b0010
*/



module FSM_control (
	input logic 
	init, 
	clk, 
	reset, 
	ovf, 
	output logic 
	NRE_1, 
	NRE_2, 
	ADC, 
	expose, 
	erase, 
	start_time,
	);
	
	typedef enum logic [2:0] {Idle, Exp, Read} statetype;
	
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
			//assign NRE_1 = 0;
			//assign NRE_2 = 0;
				end
		default: nextState = Idle;
	endcase
endmodule	


