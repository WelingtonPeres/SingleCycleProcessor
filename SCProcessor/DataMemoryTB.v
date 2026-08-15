module DataMemoryTB();

	reg clk, WE;
	reg [31:0] A, WD;
	wire [31:0] RD;

	DataMemory dm(
		.clk(clk),
		.WE(WE),
		.A(A),
		.WD(WD),
		.RD(RD)
	);

	initial clk = 0;
	always #10 clk = ~clk;

	initial begin

		WE = 0;
		A  = 32'h0;
		WD = 32'd0;
		

		@(negedge clk); // espera Descida
		WE = 1; 
		A = 32'h2000;
		WD = 32'd10;
		
		@(posedge clk); // Na Subida Escreve
		#1;
		$display("Escrita: RAM[%h] = %0d", A, WD);
		
		
		@(negedge clk); 
		WE = 1; 
		A = 32'h2004;
		WD = 32'd20;
		
		@(posedge clk); 
		#1;
		$display("Escrita: RAM[%h] = %0d", A, WD);
		
		
		@(negedge clk); 
		WE = 0; 
		A = 32'h2000;
		#1;
		$display("Escrita: RAM[%h] = %0d", A, RD);
		
		
		@(negedge clk); 
		A = 32'h2004;
		#1;
		$display("Escrita: RAM[%h] = %0d", A, RD);
		
		#20;
		
		//sobrescrever
		@(negedge clk); 
		WE = 1; 
		A = 32'h2000;
		WD = 32'd30;
		
		@(posedge clk);
		#1;
		$display("Escrita: RAM[%h] = %0d", A, WD);
		
		
		@(negedge clk); 
		WE = 0; 
		A = 32'h2000;
		#1;
		$display("Escrita: RAM[%h] = %0d", A, RD);
		
		#20;
		
		// Teste de verificação byte a byte
		@(negedge clk);
		WE = 1;
		A  = 32'h2008;
		WD = 32'h0A0B0C0D;
		
		@(posedge clk);
		#1;
		$display("Escrita: RAM[%h] = %h", A, WD);
		
		@(negedge clk);
		WE = 0;
		A  = 32'h2008;
		#1;
		$display("Leitura completa: RAM[%h] = %h", A, RD);
		
		A = 32'h2008;
		#1;
		$display("Byte 0: RAM[%h] = %h", A, RD[7:0]);
		
		A = 32'h2009;
		#1;
		$display("Byte 1: RAM[%h] = %h", A, RD[7:0]);
		
		A = 32'h200A;
		#1;
		$display("Byte 2: RAM[%h] = %h", A, RD[7:0]);
		
		A = 32'h200B;
		#1;
		$display("Byte 3: RAM[%h] = %h", A, RD[7:0]);
		
		#20;
		
		$finish;
	
	end
	
	

endmodule