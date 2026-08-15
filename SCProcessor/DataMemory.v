module DataMemory(clk, WE, A, WD, RD);
	
	input clk;
	input WE; // Recebe MemWrite
	input [31:0] A, WD; 
	output [31:0] RD;
	
	reg [7:0] RAM [0:10239]; // 256 bytes de 8 bits

	assign RD = {RAM[A[7:0]], RAM[A[7:0] + 1], RAM[A[7:0] + 2], RAM[A[7:0] + 3]};
	
	// Inicializa RAM com valores conhecidos
	initial begin
		RAM[8'h00] = 0;  
		RAM[8'h01] = 0;
		RAM[8'h02] = 0;
		RAM[8'h03] = 10; 
	end
 	
	
	// Escrita
	always@(posedge clk) begin
	
		if (WE) begin
			RAM[A[7:0]] = WD[7:0];
			RAM[A[7:0] + 1] = WD[15:8];
			RAM[A[7:0] + 2] = WD[23:16];
			RAM[A[7:0] + 3] = WD[31:24];
		end
		
	
	end
	
	
endmodule 