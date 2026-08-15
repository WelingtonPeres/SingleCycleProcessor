module InstructionMemoryTB();

	reg [31:0] A;
	wire [31:0] RD;
	
	InstructionMemory im(
		.A(A),
		.RD(RD)
	);
	
	initial begin
	
		#50;
		
		A = 0;
		
		#50;
		
		A = 4;
		
		#50;
		
		
	
	end

endmodule 