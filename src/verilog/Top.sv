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

wishboneMaster	#(.TGC_WIDTH(3),.TGA_WIDTH(2)) proc0IBus();
wishboneMaster	#(.TGC_WIDTH(3),.TGA_WIDTH(2)) proc0DBus();
wishboneSlave	#(.TGC_WIDTH(3),.TGA_WIDTH(2)) bootRomBus();
//wishboneSlave	#(.TGC_WIDTH(3),.TGA_WIDTH(2)) ramBus();
wishboneSlave	#(.TGC_WIDTH(3),.TGA_WIDTH(2)) ledBus();

BusControl syscon (.clock(bClock),.reset(bReset),
	.proc0IBus(proc0IBus),.proc0DBus(proc0DBus),
	.bootRomBus(bootRomBus),//.ramBus(ramBus),
	.ledBus(ledBus)
);

powerManagement processor0_powerManagement();
debug processor0_debug();

or1200 processor0(
	.clock(sClock),
	.reset(sReset),
	.interrupts(processor0_interrupts),
	.clmode(clmode),
	.debugInterface(processor0_debug),
	.pmInterface(processor0_powerManagement),
	.instruction_bus(proc0IBus),
	.data_bus(proc0DBus)
);

PowerManager proc0pm(processor0_powerManagement);
Debuger proc0db(processor0_debug);

directConnect bootConn (.master(proc0IBus),.slave(bootRomBus));
BootRom #(.ADDRESS_WIDTH(12)) boot (.bus(bootRomBus));

directConnect portLeds (.master(proc0DBus),.slave(ledBus));
outputReg #(.RESET_PAT(32'h11335577))
	LEDS (.reset(sReset),.bus(ledBus),.out(leds[7:0]));/**/
//NullSlave LEDS (.bus(ledBus));


always @(*) case (switches[4:1])
	4'h0	: disp32 = proc0IBus.intercon.adr_o;
	4'h1	: disp32 = proc0IBus.intercon.dat_i;
	4'h2	: disp32 = bootRomBus.slave.adr_i;
	4'h3	: disp32 = bootRomBus.slave.dat_o;
	4'h4	: disp32 = proc0DBus.intercon.adr_o;
	4'h5	: disp32 = proc0DBus.intercon.dat_o;
	4'h6	: disp32 = ledBus.slave.adr_i;
	4'h7	: disp32 = ledBus.slave.dat_i;
	default	: disp32 = 32'hBADDF00D;
endcase

endmodule
