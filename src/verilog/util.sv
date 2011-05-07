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
//			hexToSeg7 -	a generic hexidecimal to 7 segment
//					decoder.
//	
//	TODO:
//		- Nothing right now.
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
