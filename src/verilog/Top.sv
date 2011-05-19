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
	output	logic	[7:0]	seg73,
	inout	logic		i2c0_scl,
	inout	logic		i2c0_sda
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
//assign seg70[7] = switches[4];
//assign seg71[7] = switches[4];
//assign seg72[7] = switches[4];
//assign seg73[7] = switches[4];

//assign {hex3,hex2,hex1,hex0} = (switches[0])?(disp32[31:16]):(disp32[15:0]);

logic		sClock;//Processor clock
logic		bClock;//Bus clock
logic	[1:0]	clmode;//Some kind of clock mode for processor

logic [23:0] clkCount;
always @(posedge clk4) clkCount = clkCount+1;
//assign sClock = clkCount[23];
logic	[2:0][3:0]	dbButtons;
always @(posedge clkCount[13]) begin
	dbButtons[0] = {~buttons[0],dbButtons[0][3:1]};
	dbButtons[1] = {~buttons[1],dbButtons[1][3:1]};
	dbButtons[2] = {~buttons[2],dbButtons[2][3:1]};
end

//assign sClock = clk4;
assign sClock = clkCount[0];
assign bClock = sClock;
assign clmode = 2'b00;//Bus clock == Processor clock ?

logic poReset;
powerOnReset #(.WIDTH(2),.TARGET(2'b10)) POR (.clock(sClock),.reset(poReset));

logic		sReset;//System reset
logic		bReset;//Bus reset
assign sReset = poReset | &dbButtons[0];
assign bReset = sReset;

logic	[19:0]	proc0Interrupts;
assign proc0Interrupts[19:11] = 9'h0;
assign proc0Interrupts[9:0] = 10'h0;

wishboneMaster	#(.TGC_WIDTH(3),.TGA_WIDTH(2)) proc0IBus();
wishboneMaster	#(.TGC_WIDTH(3),.TGA_WIDTH(2)) proc0DBus();
wishboneSlave	#(.TGC_WIDTH(3),.TGA_WIDTH(2)) bootRomBus();
wishboneSlave	#(.TGC_WIDTH(3),.TGA_WIDTH(2)) ramBus();
wishboneSlave	#(.TGC_WIDTH(3),.TGA_WIDTH(2)) ledBus();
wishboneSlave	#(.TGC_WIDTH(3),.TGA_WIDTH(2)) seg7Bus();
wishboneSlave	#(.TGC_WIDTH(3),.TGA_WIDTH(2)) swtchBus();
wishboneSlave	#(.TGC_WIDTH(3),.TGA_WIDTH(2)) bttnBus();
wishboneSlave	#(.TGC_WIDTH(3),.TGA_WIDTH(2)) i2c0Bus();

BusControl syscon (.clock(bClock),.reset(bReset),
	.proc0IBus(proc0IBus),.proc0DBus(proc0DBus),
	.bootRomBus(bootRomBus),.ramBus(ramBus),
	.ledBus(ledBus),.seg7Bus(seg7Bus),
	.swtchBus(swtchBus),.bttnBus(bttnBus),
	.i2c0Bus(i2c0Bus)
);

powerManagement processor0_powerManagement();
debug processor0_debug();

or1200 processor0(
	.clock(sClock),
	.reset(sReset),
	.interrupts(proc0Interrupts),
	.clmode(clmode),
	.debugInterface(processor0_debug),
	.pmInterface(processor0_powerManagement),
	.instruction_bus(proc0IBus),
	.data_bus(proc0DBus)
);

PowerManager proc0pm(processor0_powerManagement);
Debuger proc0db(processor0_debug);

AddressedConnect #(.LOW(32'h0000_0000),.HIGH(32'h0000_3FFF))
	bootConn (.master(proc0IBus),.slave(bootRomBus));
BootRom #(.ADDRESS_WIDTH(14)) boot (.bus(bootRomBus));

AddressedConnect #(.LOW(32'h7000_0000),.HIGH(32'h7000_1FFF))
	ramConnect (.master(proc0DBus),.slave(ramBus));
Ram ram (.bus(ramBus));

AddressedConnect #(.LOW(32'hF000_0000),.HIGH(32'hF000_000F))
	portLedsConnect (.master(proc0DBus),.slave(ledBus));
outputReg #(.RESET_PAT(32'h11335577))
	portLeds (.reset(sReset),.bus(ledBus),.out(leds));

logic	[3:0][7:0]	seg7Digits;
AddressedConnect #(.LOW(32'hF000_0010),.HIGH(32'hF000_001F))
	portSeg7Connect (.master(proc0DBus),.slave(seg7Bus));
outputReg #(.RESET_PAT(32'h11335577))
	portSeg7 (.reset(sReset),.bus(seg7Bus),.out(seg7Digits));
assign hex0	= seg7Digits[3][3:0];
assign seg70[7]	= ~seg7Digits[3][7];
assign hex1	= seg7Digits[2][3:0];
assign seg71[7]	= ~seg7Digits[2][7];
assign hex2	= seg7Digits[1][3:0];
assign seg72[7]	= ~seg7Digits[1][7];
assign hex3	= seg7Digits[0][3:0];
assign seg73[7]	= ~seg7Digits[0][7];

AddressedConnect #(.LOW(32'hF000_0020),.HIGH(32'hF000_0023))
	portSwitchesConnect (.master(proc0DBus),.slave(swtchBus));
InputSlave portSwitches (
	.bus(swtchBus),
	.in({22'h0,switches})
);

AddressedConnect #(.LOW(32'hF000_0024),.HIGH(32'hF000_0027))
	portButtonsConnect (.master(proc0DBus),.slave(bttnBus));
InputSlave portButtons (
	.bus(bttnBus),
	.in({29'h0,&dbButtons[2],&dbButtons[1],&dbButtons[0]})
);

logic	i2c0_sclOut,i2c0_sdaOut;
AddressedConnect #(.LOW(32'hF400_0000),.HIGH(32'hF400_0007))
	i2c0Connect (.master(proc0DBus),.slave(i2c0Bus));
I2CMaster i2c0 (
	.reset(sReset),
	.bus(i2c0Bus),
	.interrupt(proc0Interrupts[10]),
	.sclIn(i2c0_scl),
	.sclOut(i2c0_sclOut),
	.sdaIn(i2c0_sda),
	.sdaOut(i2c0_sdaOut)
);
assign i2c0_scl = (i2c0_sclOut)?(1'bz):(1'b0);
assign i2c0_sda = (i2c0_sdaOut)?(1'bz):(1'b0);


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
