//****************************************************************************
//	Top.sv
//	AudioWake Top Level
//
//	This file is a part of the AudioWake project
//	http://github.com/MoronsRuS/AudioWake
//
//	Description:
//		This is the top level structural file for the AudioWake 
//		project.
//	
//	TODO:
//		- Connect processor to source of instructions.
//		- Connect processor to board I/O (buttons, lights, etc).
//		- Connect processor to off-board I/O:
//			- Real time clock.
//			- Audio Codec.
//
//	Author:
//		MoronsRuS, https://github.com/MoronsRuS
//****************************************************************************
module AudioWake (
	input	wire		clk4, //50 MHz
	input	wire		clk9, //50 MHz
	input	wire	[9:0]	switches,
	input	wire	[2:0]	buttons,
	output	wire	[9:0]	leds,
	output	wire	[7:0]	seg70,
	output	wire	[7:0]	seg71,
	output	wire	[7:0]	seg72,
	output	wire	[7:0]	seg73
);

assign leds = {7'D0, buttons};
hexToSeg7 decoder0 (.hex(switches[3:0]), .seg7(seg70[6:0]));
assign seg70[7] = switches [4];
assign seg71 = seg70;
assign seg72 = seg70;
assign seg73 = seg70;

logic		sClock;//Processor clock
logic		bClock;//Bus clock
logic	[1:0]	clmode;//Some kind of clock mode for processor
assign sClock = clk4;
assign bClock = sClock;
assign clmode = 2'b00;//Bus clock == Processor clock ?

logic		sReset;//System reset
logic		bReset;//Bus reset
assign sReset = 1'b0;
assign bReset = 1'b0;

logic	[19:0]	processor0_interrupts;
assign processor0_interrupts = 20'h0;

wishboneMaster #(.TGC_WIDTH(3),.TGA_WIDTH(2))
	processor0_instruction_bus();
assign processor0_instruction_bus.syscon.clk_o = bClock;
assign processor0_instruction_bus.syscon.rst_o = bReset;
assign processor0_instruction_bus.intercon.tgd_i = 0;

wishboneMaster #(.TGC_WIDTH(3),.TGA_WIDTH(2))
	processor0_data_bus();
assign processor0_data_bus.syscon.clk_o = bClock;
assign processor0_data_bus.syscon.rst_o = bReset;
assign processor0_data_bus.intercon.tgd_i = 0;

powerManagement processor0_powerManagement();
debug processor0_debug();

or1200 processor0(
	.clock(sClock),
	.reset(sReset),
	.interrupts(processor0_interrupts),
	.clmode(clmode),
	.debugInterface(processor0_debug),
	.pmInterface(processor0_powerManagement),
	.instruction_bus(processor0_instruction_bus),
	.data_bus(processor0_data_bus)
);

endmodule
