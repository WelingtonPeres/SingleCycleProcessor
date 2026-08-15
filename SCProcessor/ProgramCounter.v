module ProgramCounter(CLK, PCNext, PC);

	input CLK;
	input [31:0] PCNext;
	output reg[31:0] PC;
	
	initial begin
		PC = 32'd0;
	end
	
	always@(posedge CLK) begin
		
		PC <= PCNext;
		
	end


endmodule 