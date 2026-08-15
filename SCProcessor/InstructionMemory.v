module InstructionMemory(A, RD);

	input [31:0] A;
	output reg[31:0] RD;
	
	reg[7:0] memory[0:255];
	
	
	initial begin
	
		$readmemh("program.hex", memory);
	
	end
	
	always@(*) begin
	
		RD = {memory[A], memory[A + 1], memory[A + 2], memory[A + 3]};
	
	end

endmodule 