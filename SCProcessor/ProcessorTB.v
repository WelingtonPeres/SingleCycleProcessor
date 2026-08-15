// Arquivo central de Teste de Integração

`include "ProgramCounter.v"
`include "InstructionMemory.v"
`include "ControlUnit.v"
`include "MainDecoder.v"
`include "ALUDecoder.v"
`include "RegisterFile.v"
`include "Extend.v"
`include "ALU.v" 
`include "DataMemory.v"
`include "MUX2x1.v"
`include "MUX3x1.v"
`include "PCTarget.v"
`include "PCPlus4.v"

module ProcessorTB();

	// reg
	reg CLK;
	//reg [31:0] PCNext;

	// wires

	// InstructionMemory / ProgramCounter
	wire [31:0] wPC;
	wire [31:0] wRD;
	wire [31:0] wPCNext;

	// ControlUnit
	wire [6:0] wOp;
	wire [2:0] wFunct3;
	wire wFunct7;
	wire wRegWrite;
	wire wALUSrc;
	wire wMemWrite;
	wire wPCSrc;
	wire [1:0] wImmSrc;
	wire [1:0] wResultSrc;
	wire [2:0] wALUControl;

	// RegisterFile
	wire [4:0] wA1;
	wire [4:0] wA2;
	wire [4:0] wA3;
	wire [31:0] wWD3;
	wire [31:0] wRD1;
	wire [31:0] wRD2;

	// Extend
	wire [24:0] wInstr;
	wire [31:0] wImmExt;

	// ALU
	wire [31:0] wSrcA;
	wire [31:0] wSrcB;
	wire wZero;
	wire [31:0] wALUResult;

	// DataMemory
	wire [31:0] wWriteData;
	wire [31:0] wReadData;
	
	// Result MUX (Mux3x1)
	wire [31:0] wResult;    
	
	// PCPlus4
	wire [31:0] wPCPlus4;

	// PCTarget
	wire [31:0] wPCTarget;

	// ProgramCounter / InstructionMemory
	
	// MUX do PC, seleciona entre PC+4 e PCTarget
	MUX2x1 muxPC(
		.E1(wPCPlus4), 
		.E2(wPCTarget), 
		.S(wPCSrc), 
		.X(wPCNext)
	);
	
	ProgramCounter programCounter(
	  .CLK(CLK),
	  .PCNext(wPCNext),
	  .PC(wPC)
	);

	InstructionMemory instructionMemory(
	  .A(wPC),
	  .RD(wRD)
	);

	// ControlUnit
	assign wOp = wRD[6:0];
	assign wFunct3 = wRD[14:12];
	assign wFunct7 = wRD[30];

	ControlUnit controlUnit(
	  .op(wOp),
	  .funct3(wFunct3),
	  .funct7(wFunct7),
	  .Zero(wZero),
	  .PCSrc(wPCSrc),
	  .ResultSrc(wResultSrc),
	  .MemWrite(wMemWrite),
	  .ALUControl(wALUControl),
	  .ALUSrc(wALUSrc),
	  .ImmSrc(wImmSrc),
	  .RegWrite(wRegWrite)
	);

	// RegisterFile
	assign wA1 = wRD[19:15];
	assign wA2 = wRD[24:20];
	assign wA3 = wRD[11:7];

	RegisterFile registerFile(
	  .CLK(CLK),
	  .A1(wA1),
	  .A2(wA2),
	  .WE3(wRegWrite),
	  .A3(wA3),
	  .WD3(wWD3),
	  .RD1(wRD1),
	  .RD2(wRD2)
	);

	// Extend
	assign wInstr = wRD[31:7];

	Extend extend(
	  .Instr(wInstr),
	  .ImmSrc(wImmSrc),
	  .ImmExt(wImmExt)
	);

	// ALU

	assign wSrcA = wRD1;
	
	MUX2x1 muxALU(
		.E1(wRD2), 
		.E2(wImmExt), 
		.S(wALUSrc), 
		.X(wSrcB)
	);

	ALU alu(
	  .SrcA(wSrcA),
	  .SrcB(wSrcB),
	  .ALUControl(wALUControl),
	  .Zero(wZero),
	  .ALUResult(wALUResult)
	);

	// DataMemory
	assign wWriteData = wRD2;

	DataMemory dataMemory(
	  .clk(CLK),
	  .WE(wMemWrite),
	  .A(wALUResult),
	  .WD(wWriteData),
	  .RD(wReadData)
	);
	
	MUX3x1 muxResult(
		.E1(wALUResult), 
		.E2(wReadData), 
		.E3(wPCPlus4), 
		.S(wResultSrc), 
		.X(wResult)
	);
	
	// PCPlus4
	PCPlus4 pcplus4(
		.PC(wPC), 
		.PCPlus4(wPCPlus4)
	);
	
	assign wWD3 = wResult;
	
	PCTarget pctarget(
		.PC(wPC), 
		.ImmExt(wImmExt), 
		.PCTarget(wPCTarget)
	);
	
	
	initial begin

	  CLK = 0;
	  #50;
	  
	  CLK = 1;
	  #50;
	  
	  

	end

endmodule 

