
module BusControl (
	input	logic	clock,
	input	logic	reset,
	wishboneMaster.syscon	proc0IBus,
	wishboneMaster.syscon	proc0DBus,
	wishboneSlave.syscon	bootRomBus,
	wishboneSlave.syscon	ramBus,
	wishboneSlave.syscon	ledBus,
	wishboneSlave.syscon	i2c0Bus
);
	assign proc0IBus.clk_o = clock;
	assign proc0IBus.rst_o = reset;
	assign proc0DBus.clk_o = clock;
	assign proc0DBus.rst_o = reset;
	assign bootRomBus.clk_o = clock;
	assign bootRomBus.rst_o = reset;
	assign ramBus.clk_o = clock;
	assign ramBus.rst_o = reset;
	assign ledBus.clk_o = clock;
	assign ledBus.rst_o = reset;
	assign i2c0Bus.clk_o = clock;
	assign i2c0Bus.rst_o = reset;
endmodule
