module ExtendTB();

	reg [24:0] Instr;
	reg [1:0] ImmSrc;	
	wire [31:0] ImmExt;
	
	Extend extend(
		.Instr(Instr),
		.ImmSrc(ImmSrc),
		.ImmExt(ImmExt)
	);
	
	initial begin
	
		#50;
		
		Instr = 25'b1111111111000100101000110;
		ImmSrc = 2'b00;
		
		
		#50;
		$display("%H", ImmExt);
	
		Instr = 25'b0000000001100100101001000;
		ImmSrc = 2'b01;
	
		#50;
		$display("%H", ImmExt);
		
		Instr = 25'b1111111001000010000010101; 
		ImmSrc = 2'b10;
		
		#50;
		$display("%H", ImmExt);
		
	end

endmodule 