module MUX3x1TB();

	reg [31:0] E1, E2, E3;
	reg [1:0] S;
	wire [31:0] X;
	
	MUX3x1 mux(
		.E1(E1),
		.E2(E2),
		.E3(E3),
		.S(S),
		.X(X)
	);
	
	initial begin
	
		#5;
		
		E1 = 32'h1010;
		E2 = 32'h1000;
		E3 = 32'h1100;
		
		S = 2'b00;
		
		#10;
		$display("S=00, X=%h", X);
		
		S = 2'b01;
		#10;
		$display("S=01, X=%h", X);
		
		S = 2'b10;
		#10;
		$display("S=10, X=%h", X);
		
		S = 2'b11;
		#10;
		$display("S=11, X=%h", X);
	
	end

endmodule
