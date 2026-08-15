	module ControlUnit(op, funct3, funct7, Zero, PCSrc, ResultSrc, MemWrite, ALUControl, ALUSrc, ImmSrc, RegWrite);

	input [6:0] op;
	input [2:0] funct3;
	input funct7, Zero;
	
	output RegWrite, ALUSrc, MemWrite, PCSrc;
	output [1:0] ImmSrc, ResultSrc;
	output [2:0] ALUControl;
	
	wire op5;
	assign op5 = op[5];
	
	wire Branch, Jump;
	wire [1:0] ALUOp;
	
	MainDecoder main(
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
	
	ALUDecoder alu(
		.op(op5),
		.funct3(funct3),
		.funct7(funct7),
		.ALUOp(ALUOp),
		.ALUControl(ALUControl)
	);
	
	assign PCSrc = (Zero && Branch) || Jump;
	
endmodule 