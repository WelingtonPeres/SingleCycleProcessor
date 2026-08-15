module PCTargetTB();

	reg [31:0] PC;
	reg [31:0] ImmExt;
	wire [31:0] PCTarget;
	
	PCTarget pctarget(
		.PC(PC),
		.ImmExt(ImmExt),
		.PCTarget(PCTarget)
	);
	
	initial begin
	
		PC = 32'h100C;
		ImmExt = 32'hFFFFFFF4; // -12
		#10;
		$display("Esperado 0x1000 : Obtido 0x%h", PCTarget);

		PC = 32'h1000;
		ImmExt = 32'h00000008; // +8
		#10;
		$display("Esperado 0x1008 : Obtido 0x%h", PCTarget);

		PC = 32'h1000;
		ImmExt = 32'h00000000; // +0
		#10;
		$display("Esperado 0x1000 : Obtido 0x%h", PCTarget);

	end

endmodule 