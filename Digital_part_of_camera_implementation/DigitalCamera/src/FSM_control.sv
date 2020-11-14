
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
	ovf4,
	ovf5,
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
	
	
	logic skip, row; // logic for skipping clk cycle
	
	always_ff @(posedge clk)
	if(reset) begin 
			currentState = Idle;
		end
	else currentState = nextState;
	
	
	// conditional within state
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
								start_time} = 6'b110010;
							skip <= 0;
							row <=0;
						end
				Exp: begin 
						// start exposing
						assign erase = 0;
						assign expose = 1;
						assign start_time = 1;	
						//skip <= 1;
						row <=0;
						skip <= 1;
					end
				
				Read_R1: begin
						assign expose = 0;
						assign start_time = 0;
						// reading prosedure for row 0
						// Go to next read stage
						if(ovf4) begin 
								//nextState = Read_R2;
								skip <= 1;
							end
						//else if (ADC_enable) assign ADC_enable = 0;
						// end adc
						else if (ADC_enable) begin 
								assign ADC_enable = 0;
								skip <= 1;
							end
						// start adc
						else if (!skip &!NRE_1) begin 
								assign ADC_enable = 1;
								skip <= 1;
						end
						else if (!NRE_1) begin 
								assign NRE_1 = 1;
								//skip <= 1;
							end
						// start first read
						else if (!skip) begin 
								assign NRE_1 = 0;
								//skip <= 1;	
							end	
						
						// wait skip cycle
						else begin 
								skip <= 0;
								assign start_time =!start_time;
							end
					end
				Read_R2:
				
					begin
						assign expose = 0;
						assign start_time = 0;
						// reading prosedure for row 0
						// Go to next read stage
						if(ovf4) begin 
								//nextState = Read_R2;
								skip <= 1;
							end
						//else if (ADC_enable) assign ADC_enable = 0;
						// end adc
						else if (ADC_enable) begin 
								assign ADC_enable = 0;
								skip <= 1;
							end
						// start adc
						else if (!skip &!NRE_2) begin 
								assign ADC_enable = 1;
								skip <= 1;
						end
						else if (!NRE_2) begin 
								assign NRE_2 = 1;
								//skip <= 1;
							end
						// start first read
						else if (!skip) begin 
								assign NRE_2 = 0;
								//skip <= 1;	
							end	
						
						// wait skip cycle
						else begin 
								skip <= 0;
								assign start_time =!start_time;
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
					//assign start_time = 0;
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
				start_time} = 6'b110010;
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
	start_time;
	
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
		start_time);
	
	// generate clock
	always
		begin
			assign clk = 1; #1; 
			assign clk = 0; #1;
		end 
	
	initial begin
			$readmemb("FSM_control_testVectors.txt", testVectors);
			vectornum = 0;
			//reset = 1; #1; reset = 0;
			
			
		end
	//random testing
	/*
	always @(posedge clk)
	if (test_reg == 16) $finish;
	else begin 
	{ovf4, ovf5, init} <= test_reg;
	test_reg = test_reg + 4'b1;
	end	 
	
	*/
	
	//test vector
	
	always @(posedge clk)
		begin
			{init, reset, ovf4, ovf5} =
			testVectors[vectornum];
		end
	
	always @(negedge clk)begin
			/*
			if (~reset) begin // skip during reset
			vectornum = vectornum + 1;
			
			end	
			*/
			vectornum <= vectornum + 1;
			if (testVectors[vectornum] === 4'bx) begin
					$finish;
				end
			if (vectornum == 26) $finish; ;
		end
endmodule

/*
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
