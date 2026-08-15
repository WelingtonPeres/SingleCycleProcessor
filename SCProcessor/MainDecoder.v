module MainDecoder(op, RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump);

	input [6:0] op;
	
	output reg RegWrite, ALUSrc, MemWrite, Branch, Jump;
	output reg [1:0] ImmSrc, ResultSrc, ALUOp;
	
	always@(*) begin
	
		case(op)
		
			7'b0000011 : begin
			
								RegWrite = 1'b1;
								ImmSrc = 2'b00;
								ALUSrc = 1'b1;
								MemWrite = 1'b0;
								ResultSrc = 1'b1;
								Branch = 1'b0;
								ALUOp = 2'b00;
								Jump = 1'b0;
			
							end
							
			7'b0100011 : begin
			
								RegWrite = 1'b0;
								ImmSrc = 2'b01;
								ALUSrc = 1'b1;
								MemWrite = 1'b1;
								ResultSrc = 2'bxx;
								Branch = 1'b0;
								ALUOp = 2'b00;
								Jump = 1'b0;
			
							end
							
			7'b0110011 : begin
			
								RegWrite = 1'b1;
								ImmSrc = 2'bxx;
								ALUSrc = 1'b0;
								MemWrite = 1'b0;
								ResultSrc = 2'b00;
								Branch = 1'b0;
								ALUOp = 2'b10;
								Jump = 1'b0;
			
							end
							
			7'b1100011 : begin
			
								RegWrite = 1'b0;
								ImmSrc = 2'b10;
								ALUSrc = 1'b0;
								MemWrite = 1'b0;
								ResultSrc = 2'bxx;
								Branch = 1'b1;
								ALUOp = 2'b01;
								Jump = 1'b0;
			
							end
							
			7'b0010011 : begin
			
								RegWrite = 1'b1;
								ImmSrc = 2'b00;
								ALUSrc = 1'b1;
								MemWrite = 1'b0;
								ResultSrc = 2'b00;
								Branch = 1'b0;
								ALUOp = 2'b10;
								Jump = 1'b0;
			
							end
							
			7'b1101111 : begin
			
								RegWrite = 1'b1;
								ImmSrc = 2'b11;
								ALUSrc = 1'bx;
								MemWrite = 1'b0;
								ResultSrc = 2'b10;
								Branch = 1'b0;
								ALUOp = 2'bxx;
								Jump = 1'b1;
			
							end
							
		endcase
		
	end
	

endmodule 
