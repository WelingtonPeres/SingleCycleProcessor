module MainDecoderTB();

	reg [6:0] op;
	
	wire RegWrite, ALUSrc, MemWrite, Branch, Jump;
	wire [1:0] ImmSrc, ResultSrc, ALUOp;

	MainDecoder decoder(
		.op(op),
		.RegWrite(RegWrite),
		.ImmSrc(ImmSrc),
		.ALUSrc(ALUSrc),
		.MemWrite(MemWrite),
		.ResultSrc(ResultSrc),
		.Branch(Branch),
		.ALUOp(ALUOp),
		.Jump(Jump)
	);
	
	initial begin
		#5;
		
		op = 7'b0000011;  // lw
		#10;
		
		op = 7'b0100011;  // sw
		#10;
		
		op = 7'b0110011;  // R-type
		#10;
		
		op = 7'b0010011;  // I-type ALU (addi)
		#10;
		
		op = 7'b1101111;  // jal
		#10;
		
		op = 7'b1100011;  // beq
		#10;
		
	end
	
endmodule 