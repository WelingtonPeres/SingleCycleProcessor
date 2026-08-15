module ALUTB();

	reg [31:0] SrcA, SrcB;
	reg [2:0] ALUControl;
	
	wire Zero;
	
	wire [31:0] ALUResult;
	
	ALU alu(
		.SrcA(SrcA),
		.SrcB(SrcB),
		.ALUControl(ALUControl),
		.Zero(Zero),
		.ALUResult(ALUResult)
	);
	
	initial begin
	
		#5;

		ALUControl = 0;
		
		SrcA = 100;
		SrcB = 200;
				
		#10;
		ALUControl = 1;
		
		#10;		ALUControl = 1;
		SrcA = 100;
		SrcB = 100;
		
		#10;
		
		ALUControl = 0;
		SrcA = {32{1'b1}};
		SrcB = {32{1'b1}};
		
		#10;
		
		
		
		
		
	
	end

endmodule
