module MUX2x1(E1, E2, S, X);

	input [31:0] E1, E2;
	input S;
	output reg [31:0] X;
	
	always@(*) begin
	
		case (S)
		
			1'b0 : X = E1;
			1'b1 : X = E2;
			default: X = {32{1'bx}};
					
		endcase 
	
	end

endmodule 