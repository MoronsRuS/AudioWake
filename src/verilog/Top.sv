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
	input	logic		clk4, //50 MHz
	input	logic		clk9, //50 MHz
	input	logic	[9:0]	switches,
	input	logic	[2:0]	buttons,
	output	logic	[9:0]	leds,
	output	logic	[7:0]	seg70,
	output	logic	[7:0]	seg71,
	output	logic	[7:0]	seg72,
	output	logic	[7:0]	seg73
);

//assign leds = {7'D0, buttons};
logic [3:0]	hex0,hex1,hex2,hex3;
logic [31:0]	disp32;
//assign hex0 = switches[3:0];
//assign hex1 = switches[3:0];
//assign hex2 = switches[3:0];
//assign hex3 = switches[3:0];
hexToSeg7 decoder0 (.hex(hex0), .seg7(seg70[6:0]));
hexToSeg7 decoder1 (.hex(hex1), .seg7(seg71[6:0]));
hexToSeg7 decoder2 (.hex(hex2), .seg7(seg72[6:0]));
hexToSeg7 decoder3 (.hex(hex3), .seg7(seg73[6:0]));
assign seg70[7] = switches[4];
assign seg71[7] = switches[4];
assign seg72[7] = switches[4];
assign seg73[7] = switches[4];

assign {hex3,hex2,hex1,hex0} = (switches[0])?(disp32[31:16]):(disp32[15:0]);

logic		sClock;//Processor clock
logic		bClock;//Bus clock
logic	[1:0]	clmode;//Some kind of clock mode for processor

//logic [24:0] clkCount;
//always @(posedge clk4) clkCount = clkCount+1;
assign sClock = clk4;
//assign sClock = clkCount[24];
assign bClock = sClock;
assign clmode = 2'b00;//Bus clock == Processor clock ?

logic poReset;
powerOnReset #(.WIDTH(2),.TARGET(2'b10)) POR (.clock(sClock),.reset(poReset));

logic		sReset;//System reset
logic		bReset;//Bus reset
assign sReset = poReset;
assign bReset = sReset;

logic	[19:0]	processor0_interrupts;
assign processor0_interrupts = 20'h0;
//assign leds[8] = sReset;
//assign leds[9] = sClock;

wishboneMaster #(.TGC_WIDTH(3),.TGA_WIDTH(2)) processor0_instruction_bus();
assign processor0_instruction_bus.syscon.clk_o = bClock;
assign processor0_instruction_bus.syscon.rst_o = bReset;
//assign processor0_instruction_bus.intercon.tgd_i = 0;

//assign processor0_instruction_bus.intercon.rty_i = 1;//Force retry.
wishboneMaster #(.TGC_WIDTH(3),.TGA_WIDTH(2)) processor0_data_bus();
assign processor0_data_bus.syscon.clk_o = bClock;
assign processor0_data_bus.syscon.rst_o = bReset;

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
PowerManager proc0pm(processor0_powerManagement);
Debuger proc0db(processor0_debug);

wishboneSlave #(.TGC_WIDTH(3),.TGA_WIDTH(2)) bootBus();
assign bootBus.syscon.clk_o = bClock;
assign bootBus.syscon.rst_o = bReset;
directConnect bootConn (.master(processor0_instruction_bus),.slave(bootBus));
BootRom #(.ADDRESS_WIDTH(12)) boot (.bus(bootBus));
//assign leds[5] = processor0_instruction_bus.intercon.cyc_o;
//assign leds[4] = processor0_instruction_bus.intercon.stb_o;
//assign leds[3] = processor0_instruction_bus.intercon.we_o;
//assign leds[2] = processor0_instruction_bus.intercon.ack_i;
//assign leds[1] = processor0_instruction_bus.intercon.rty_i;
//assign leds[0] = processor0_instruction_bus.intercon.err_i;

wishboneSlave  #(.TGC_WIDTH(3),.TGA_WIDTH(2)) ledBus();
assign ledBus.syscon.clk_o = bClock;
assign ledBus.syscon.rst_o = bReset;
directConnect portLeds (.master(processor0_data_bus),.slave(ledBus));
outputReg #(.RESET_PAT(32'h11335577))
	LEDS (.reset(sReset),.bus(ledBus),.out(leds[7:0]));/**/
//NullSlave LEDS (.bus(ledBus));
//assign leds[7:0] = processor0_data_bus.intercon.dat_o[7:0];


always @(*) case (switches[4:1])
	4'h0	: disp32 = processor0_instruction_bus.intercon.adr_o;
	4'h1	: disp32 = processor0_instruction_bus.intercon.dat_i;
	4'h2	: disp32 = bootBus.slave.adr_i;
	4'h3	: disp32 = bootBus.slave.dat_o;
	4'h4	: disp32 = processor0_data_bus.intercon.adr_o;
	4'h5	: disp32 = processor0_data_bus.intercon.dat_o;
	4'h6	: disp32 = ledBus.slave.adr_i;
	4'h7	: disp32 = ledBus.slave.dat_i;
	default	: disp32 = 32'hBADDF00D;
endcase

endmodule
