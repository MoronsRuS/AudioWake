//****************************************************************************
//	util.sv
//	Generic usefule modules for the project.
//
//	This file is a part of the AudioWake project
//	http://github.com/MoronsRuS/AudioWake
//
//	Description:
//		This file contains some useful module related to the AudioWake
//		project.
//			hexToSeg7 -	A generic hexidecimal to 7 segment
//					decoder.
//			powerOnReset -	A counter to hold drive a reset line 
//					for a duration after power on.
//	
//	TODO:
//		- Move the Power Manager to it's own file.
//		- Move the Debuger to it's own file.
//
//	Author:
//		MoronsRuS, https://github.com/MoronsRuS
//****************************************************************************
//****************************************************************************
//	hexToSeg7
//	A generic hexidecimal to 7 segment decoder.
//	
//
//	Description:
//		A simplie hexidecimal 7 segment decoder with active high 
//		input and active low output.
//
//	Inputs:
//		hex:	A 4 bit vector to be displayed as hexidecimal. Active
//			high signal.
//	
//	Outputs:
//		seg7:	The 7 segments of the display in order
//			{a,b,c,d,e,f,g}. Active low signal.
//
//	TODO:
//		- Nothing right now.
//****************************************************************************
module hexToSeg7 (
	input	wire	[3:0]	hex,
	output	reg	[6:0]	seg7
);
always @(*) begin
	case(hex)
		// _
		//| |
		//|_|
		4'h0	: seg7 = 7'b0000001;
		//  
		//  |
		//  |
		4'h1	: seg7 = 7'b1001111;
		// _
		// _|
		//|_ 
		4'h2	: seg7 = 7'b0010010;
		// _
		// _|
		// _|
		4'h3	: seg7 = 7'b0000110;
		//  
		//|_|
		//  |
		4'h4	: seg7 = 7'b1001100;
		// _
		//|_ 
		// _|
		4'h5	: seg7 = 7'b0100100;
		// _
		//|_ 
		//|_|
		4'h6	: seg7 = 7'b0100000;
		// _
		//  |
		//  |
		4'h7	: seg7 = 7'b0001111;
		// _
		//|_|
		//|_|
		4'h8	: seg7 = 7'b0000000;
		// _
		//|_|
		//  |
		4'h9	: seg7 = 7'b0001100;
		// _
		//|_|
		//| |
		4'hA	: seg7 = 7'b0001000;
		//  
		//|_ 
		//|_|
		4'hB	: seg7 = 7'b1100000;
		// _
		//|  
		//|_ 
		4'hC	: seg7 = 7'b0110001;
		//  
		// _|
		//|_|
		4'hD	: seg7 = 7'b1000010;
		// _
		//|_ 
		//|_ 
		4'hE	: seg7 = 7'b0110000;
		// _
		//|_ 
		//|  
		4'hF	: seg7 = 7'b0111000;
		default	: seg7 = 7'b1111111;
	endcase;
end

endmodule
//****************************************************************************
//	powerOnReset
//	A counter to hold a reset line until it reaches TARGET.
//	
//
//	Description:
//		In FPGA's flip flops are ususally initialized to a uniform 
//		state.  A power on reset module like this counts to a target 
//		in the middle of the range so that the counter doesn't start 
//		in a finished state.
//
//	Inputs:
//		clock:	The clock for the counter (posedge triggered).
//	
//	Outputs:
//		reset:	The reset line (active high).
//
//	TODO:
//		- Nothing right now.
//****************************************************************************
module powerOnReset #(parameter WIDTH=8,parameter TARGET=8'h55) (
	input	logic	clock,
	output	logic	reset
);
logic [WIDTH-1:0] count;
always @(posedge clock) begin
	if (count < TARGET) begin
		reset = 1'b1;
		count = count + {{WIDTH-2{1'b0}},1'b1};
	end else begin
		reset = 1'b0;
		count = count;
	end
end
endmodule

module PowerManager (
	powerManagement.peripheral	proc
);
	assign proc.cpustall = 1'b0;
endmodule

module Debuger (
	debug.peripheral	proc
);
	assign proc.stall = 1'b0;
	assign proc.ewt = 1'b0;
	assign proc.stb = 1'b0;
	assign proc.we = 1'b0;
	assign proc.adr = 32'h0;
	assign proc.datI = 32'h0;
endmodule
