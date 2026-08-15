module Extend (Instr, ImmSrc, ImmExt);

	input [24:0] Instr;
	input [1:0] ImmSrc;	
	output reg [31:0] ImmExt;
	
	always@(*) begin
	
		case (ImmSrc)
		
			2'b00 : ImmExt = {{20{Instr[24]}},Instr[24:13]}; // Type I
			
			2'b01 : ImmExt = {{20{Instr[24]}},Instr[24:18],Instr[4:0]}; // Type S
			
			2'b10 : ImmExt = { {{20{Instr[24]}}, Instr[0], Instr[23:18], Instr[4:1], 1'b0} }; // Type B
			
			2'b11 : ImmExt = { {12{Instr[24]}}, Instr[12:5], Instr[13], Instr[23:14], 1'b0 }; // Type J
		
		endcase
		
	
	end
		
	
endmodule 