module RegisterFile(CLK, A1, A2, WE3, A3, WD3, RD1, RD2);

	input CLK, WE3;
	input [4:0] A1, A2, A3;
	input [31:0] WD3;
	output [31:0] RD1, RD2;
	
	reg[31:0] registers[0:31];
	
	initial begin
		registers[0] = 32'd0;       // x0 é sempre 0 por definição
		registers[5] = 32'd6;       // x5 começa com 6 
		registers[9] = 32'h2004;    // x9 começa com o endereço base 
	end
	
	assign RD1 = registers[A1];
	assign RD2 = registers[A2];
	
	always@(posedge CLK) begin
	
		if (WE3 == 1'b1) begin
			registers[A3] <= WD3;
		
		end
	end
	
endmodule 