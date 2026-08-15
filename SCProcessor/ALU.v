module ALU(SrcA, SrcB, ALUControl, Zero, ALUResult);

	input [31:0] SrcA, SrcB;
	input [2:0] ALUControl;
	
	output reg Zero;
	
	output reg [31:0] ALUResult;
	
	always@(*) begin 
	
		case(ALUControl)
		
			3'b000 : ALUResult = SrcA + SrcB;                         // add
			3'b001 : ALUResult = SrcA - SrcB;                         // sub
			3'b010 : ALUResult = SrcA & SrcB;                         // and
			3'b011 : ALUResult = SrcA | SrcB;                         // or
			3'b101 : ALUResult = ($signed(SrcA) < $signed(SrcB)) ?    // slt
			                    32'd1 : 32'd0;
			default: ALUResult = 32'd0;
		
		endcase
		
		Zero = (ALUResult == 32'd0);
	
	end



endmodule 