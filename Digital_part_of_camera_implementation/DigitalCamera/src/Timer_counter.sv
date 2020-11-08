

module Time_counter(
	input logic 
	[5:0] Exp_time,
	start,
	clk,
	reset,
	output logic 
	ovf);
	
	
	reg [5:0] q;
	q <= start;
	
	always_ff @(posedge clk)
	if (reset) q <= 5'b0;
	else q <= start- 1;
	
endmodule