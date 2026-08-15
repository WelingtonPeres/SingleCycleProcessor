module ControlUnitTB();
	
	reg [6:0] op;
	reg [2:0] funct3;
	reg funct7, Zero;
	
	wire RegWrite, ALUSrc, MemWrite, PCSrc;
	wire [1:0] ImmSrc, ResultSrc;
	wire [2:0] ALUControl;

	ControlUnit unit(
		.op(op),
		.funct3(funct3),
		.funct7(funct7),
		.Zero(Zero),
		.PCSrc(PCSrc),
		.ResultSrc(ResultSrc),
		.MemWrite(MemWrite),
		.ALUControl(ALUControl),
		.ALUSrc(ALUSrc),
		.ImmSrc(ImmSrc),
		.RegWrite(RegWrite)
	);
 
    initial begin
	 
        funct3 = 3'b000;
        funct7 = 1'b0;
        Zero   = 1'b0;
 
        op = 7'b0000011; 
		  #10; 
		  $display("lw       | %b    %b     %b      %b    %b        %b     %b", RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, ALUControl, PCSrc);
        
		  op = 7'b0100011; 
		  #10; 
		  $display("sw       | %b    %b     %b      %b    %b        %b     %b", RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, ALUControl, PCSrc);
        
		  op = 7'b0110011; 
		  #10; 
		  $display("R-type   | %b    %b     %b      %b    %b        %b     %b", RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, ALUControl, PCSrc);
        
		  op = 7'b0010011; 
		  #10; 
		  $display("I-typeALU| %b    %b     %b      %b    %b        %b     %b", RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, ALUControl, PCSrc);
        
		  op = 7'b1101111; 
		  #10; 
		  $display("jal      | %b    %b     %b      %b    %b        %b     %b", RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, ALUControl, PCSrc);
 
        op = 7'b1100011; 
		  Zero = 1'b0; 
		  #10;
        $display("beq Z=0  | %b    %b     %b      %b    %b        %b     %b", RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, ALUControl, PCSrc);
 
        Zero = 1'b1; 
		  #10;
        $display("beq Z=1  | %b    %b     %b      %b    %b        %b     %b", RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, ALUControl, PCSrc);
 
    end
 
endmodule