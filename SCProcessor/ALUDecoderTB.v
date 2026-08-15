module ALUDecoderTB();

	reg [2:0] funct3;
	reg [1:0] ALUOp;
	reg funct7, op;
	
	wire [2:0] ALUControl;
	
	ALUDecoder decoder(
		.op(op),
		.funct3(funct3),
		.funct7(funct7),
		.ALUOp(ALUOp),
		.ALUControl(ALUControl)
	);
	
	initial begin
	
		#5;
		
		op = 1'bx;
		funct3 = 3'bxx;
		funct7 = 1'bx;
		ALUOp = 2'b00;
		
		#10;
		
		op = 1'bx;
		funct3 = 3'bxx;
		funct7 = 1'bx;
		ALUOp = 2'b01;
		
		#10; 
		
		op = 1'b1;
		funct3 = 3'b000;
		funct7 = 1'b1;
		ALUOp = 2'b10;
		
		#10; 
		
				
		op = 1'b1;
		funct3 = 3'b000;
		funct7 = 1'b0;
		ALUOp = 2'b10;
		
		#10; 
		
		op = 1'b1;
		funct3 = 3'b010;
		funct7 = 1'b0;
		ALUOp = 2'b10;
		
		#10; 
	
		funct3 = 3'b110;	
		
		#10; 
		
		funct3 = 3'b111;
		
		#10;
		
	end

endmodule 