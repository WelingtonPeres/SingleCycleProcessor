module MUX3x1(E1, E2, E3, S, X);

	input [31:0] E1, E2, E3;
	input [1:0] S;
	output reg [31:0] X;
	
	always@(*) begin
	
		case (S)
		
			2'b00 : X = E1;
			2'b01 : X = E2;
			2'b10 : X = E3;
			2'b11 : X = {32{1'bx}};
					
		endcase 
	
	end

endmodule 
