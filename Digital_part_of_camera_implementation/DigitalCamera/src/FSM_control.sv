
/*
A=idle, B=exposure, C=readout	   
`define A 4'b0000
`define B 4'b0001
`define C 4'b0010
*/

`timescale 100 us / 1 us

typedef enum logic [2:0] {Idle, Exp, Read_R1, Read_R2} statetype;

module FSM_control (
	input logic 
	init, 
	clk, 
	reset, 
	ovf4,
	ovf5,
	output logic 	 
	NRE_1, 
	NRE_2, 
	ADC_enable, 
	expose, 
	erase, 
	start_count
	);
	statetype currentState, nextState;
	
	
	logic skip; // logic for skipping clk cycle
	
	// managing of state change
	always_ff @(posedge clk)
	if(reset) begin 
			currentState = Idle;
		end
	else currentState = nextState;
	
	
	// conditional change of internal and output signals based on state
	always @(posedge clk) begin
			case(currentState)
				Idle: 
					//reset skip
					if (skip) skip <= 0;
					// set idle state 
					else begin 
							assign 
								{NRE_1, 
								NRE_2, 
								ADC_enable, 
								expose, 
								erase, 
								start_count} = 6'b110010;
							skip <= 0;
						end
				Exp: begin 
						// start exposing
						assign erase = 0;
						assign expose = 1;
						assign start_count = 1;	
						skip <= 1;
					end
				
				Read_R1: begin
						assign expose = 0;
						assign start_count = 0;
						// reading prosedure for row 0
						// end adc
						if (ADC_enable) begin 
								assign ADC_enable = 0;
								skip <= 1;
							end
						// start adc
						else if (!skip &!NRE_1) begin 
								assign ADC_enable = 1;
								skip <= 1;
							end
						// disable reading of row again
						else if (!NRE_1) begin 
								assign NRE_1 = 1;
								skip <= 0;
							end
						// start reading of first row
						else if (!skip) begin 
								assign NRE_1 = 0;	
							end	
						
						// skip clock cycle
						else begin 
								skip <= 0;
							end
					end
				Read_R2:
					begin
						assign expose = 0;
						assign start_count = 0;
						// reading prosedure for row 0
						// end adc
						if (ADC_enable) begin 
								assign ADC_enable = 0;
								skip <= 1;
							end
						// start adc
						else if (!skip &!NRE_2) begin 
								assign ADC_enable = 1;
								skip <= 1;
							end	 
						// disable reading of row again
						else if (!NRE_2) begin 
								assign NRE_2 = 1;
								skip <= 0;
							end
						// start reading of second row
						else if (!skip) begin 
								assign NRE_2 = 0;
								//skip <= 1;	
							end
						// wait skip cycle
						else begin 
								skip <= 0;
							end
					end
				
			endcase
		end // always @(posedge clk)
	
	
	// implimentation on FSM transitions
	always_comb
	case(currentState)
		Idle: if (init & !reset) nextState = Exp;
		
		Exp: if(ovf5) begin 
					nextState = Read_R1;
					//assign expose = 0;
					//assign start_count = 0;
				end
		
		Read_R1: begin
				// reading prosedure for row 0
				// Go to next read stage
				if(ovf4) begin 
						nextState = Read_R2;
					end
			end
		Read_R2:
			// reading prosedure for row 1
			// Go to next read stage
			if(ovf4 & NRE_2 & !ADC_enable) begin 
					nextState = Idle;
				end
		default: nextState = Idle;
	endcase // always_comb
	
	initial	begin
			
			assign {NRE_1, 
				NRE_2, 
				ADC_enable, 
				expose, 
				erase, 
				start_count} = 6'b110010;
		end
	
endmodule //FSM_control	


module FSM_control_TB();
	
	reg [4:0] test_reg = 4'b0;
	
	//in
	logic init, clk, reset, ovf4, ovf5;
	//out
	logic NRE_1, NRE_2, 
	ADC_enable, 
	expose, 
	erase, 
	start_count;
	
	reg [31:0] vectornum;
	reg [4:0] testVectors[100:0];
	
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
		start_count);
	
	// generate clock
	always
		begin
			assign clk = 1; #5; 
			assign clk = 0; #5;
		end 
	
	// read testvectors from file
	initial begin
			$readmemb("FSM_control_testVectors.txt", testVectors);
			vectornum = 0;
		end
	
	//reading new test vector
	always @(posedge clk)
		begin
			{init, reset, ovf4, ovf5} =
			testVectors[vectornum];
		end
	
	// mangage test vector
	always @(negedge clk)begin
			
			vectornum <= vectornum + 1; // increment test vector
			
			//Condition for stopping reading of test vectors
			if (testVectors[vectornum] === 4'bx) begin
					$finish;
				end
			if (vectornum == 26) $finish; ;
		end
endmodule //FSM_control_TB

/*	

// Go to next read stage
//if(ovf4) begin 
//nextState = Read_R2;
//skip <= 1;
//end

Read_R1: 
// reading prosedure for row 0
if(!row) begin
// Go to next read stage
if(ovf4) begin 
row <= 1;
skip <= 1;
end
// start adc
else if (!skip & !NRE_1) begin 
assign ADC_enable = 1;

end
// end adc
else if (ADC_enable) begin 
assign ADC_enable = 0;
skip <= 1;
end
// start first read
else if (!skip) begin 
assign NRE_1 = 0;
skip <= 1;

end
// wait skip cycle
else  skip <= 0;
end
// reading prosedure for row 1
else begin 
// Go to next read stage
if(ovf4 & NRE_2 & !ADC_enable) begin 
nextState = Idle;
skip <= 1;
end
// start adc
else if (!skip & !NRE_2) begin 
assign ADC_enable = 1;

end
// end adc
else if (ADC_enable) begin 
assign ADC_enable = 0;
skip <= 1;
end
// start first read
else if (!skip) begin 
assign NRE_2 = 0;
skip <= 1;		
end
// wait skip cycle
else  skip <= 1;
end


*/			



/* old read row 2 

// reading prosedure for row 1
// Go to next read stage 
begin
assign NRE_1 = 1;
if(ovf4 & NRE_2 & !ADC_enable) begin 
//nextState = Idle;
skip <= 1;
end
// start adc
else if (!skip & !NRE_2) begin 
assign ADC_enable = 1;

end
// end adc
else if (ADC_enable) begin 
assign ADC_enable = 0;
skip <= 1;
end
// start first read
else if (!skip) begin 
assign NRE_2 = 0;
skip <= 1;		
end
// wait skip cycle
else  skip <= 0; 
end
//default: nextState = Idle;*/
