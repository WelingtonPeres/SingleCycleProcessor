module PCPlus4TB();

	reg [31:0] PC;
	wire [31:0] PCPlus4;
	
	PCPlus4 pcplus4(
		.PC(PC),
		.PCPlus4(PCPlus4)
	);
	
	initial begin
	
		
	PC = 32'h100C;
	#10;
	$display("Esperado 0x1010 : Obtido %h", PCPlus4);

	PC = 32'h1000;

	#10;
	$display("Esperado 0x1004 : Obtido %h", PCPlus4);


	end

endmodule 