module MUX2x1TB();

	reg [31:0] E1, E2;
	reg S;
	wire [31:0] X;
	
	MUX2x1 mux(
		.E1(E1),
		.E2(E2),
		.S(S),
		.X(X)
	);
	
	initial begin
	
		#5;
		
		E1 = 32'h1010;
		E2 = 32'h1000;
		
		S = 0;
		
		#10;
		$display("%h", X);
		
		S = 1;
		#10;
		$display("%h", X);
		
	
	end


endmodule