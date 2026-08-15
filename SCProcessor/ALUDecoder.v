module ALUDecoder(op, funct3, funct7, ALUOp, ALUControl);

	input [2:0] funct3;
	input [1:0] ALUOp;
	input funct7, op;
	
	output reg [2:0] ALUControl;
	
	always@(*) begin
	
		ALUControl = 3'b000;  // valor padrão evita latch inferido
		
		case (ALUOp) 
		
			2'b00 : begin
			
						ALUControl = 3'b000;
							
					end
			
			2'b01 : begin 
			
						ALUControl = 3'b001;
			
					end
					
			2'b10 : begin 
			
						case(funct3)
						
							3'b000 : begin 
							
											if ({op, funct7} == 2'b11) begin
											
												ALUControl = 3'b001;
											
											end else begin
											
												ALUControl = 3'b000;
											
											end
										end
										
							3'b010 : begin
											ALUControl = 3'b101;
										end
							
							3'b110 : begin
											ALUControl = 3'b011;
										end
										
							3'b111 : begin 
											ALUControl = 3'b010;
										end
							
							default : begin
											
											ALUControl = 3'b000;   // funct3 não mapeado → ADD
											
										end
							
						endcase 
					
					end 
					
			default : begin
					
						ALUControl = 3'b000;   // ALUOp não mapeado → ADD
					
					end
		
		endcase
	
	end

endmodule 