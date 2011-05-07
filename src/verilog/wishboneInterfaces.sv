//****************************************************************************
//	WishboneInterfaces
//	Verilog interfaces with signals for the wishbone bus.
//
//	This file is a part of the AudioWake project
//	http://github.com/MoronsRuS/AudioWake
//
//	Description:
//		This file contains verilog interfaces for the wishbone bus 
//		(http://opencores.org/opencores,wishbone, version b3). There
//		are two interfaces: wishboneMaster and wishboneSlave. The
//		wishboneMaster connects a wishbone bus master to a syscon
//		module and an intercon module.  The wishboneSlave connects a
//		wishbone bus slave to a syscon module and an intercon module.
//
//		The syscon module controls the bus clock and bus reset.  The 
//		wishbone bus clock and reset aren't related to an individual 
//		module's clock or reset.  Meaning that your module can run off
//		a different clock than the wishbone bus clock, but bus logic 
//		part of your module must run off the bus clock.  Likewise 
//		your module can have a different reset than the wishbone bus
//		reset, but state related to the bus must be reset when the 
//		bus reset is asserted.
//
//		The intercon module represents bus interconnection logic.
//		It's job is to hook masters up to slaves and arbitration and
//		address decoding so that the right master talks to the right
//		slave.
//
//		The master module represents a wishbone bus master.
//
//		The slave module represents a wishbone bus slave.
//	
//	TODO:
//		- Nothing right now.
//
//	Author:
//		MoronsRuS, https://github.com/MoronsRuS
//****************************************************************************
interface wishboneMaster //Version b3
#(
	parameter	TGC_WIDTH =	0,
	parameter	ADR_WIDTH =	32,
	parameter	TGA_WIDTH =	0,
	parameter	DAT_WIDTH =	32,
	parameter	SEL_WIDTH =	4,
	parameter	TGDO_WIDTH =	0,
	parameter	TGDI_WIDTH =	0
);
	//syscon signals:
	//Bus Clock to master and slave
	logic				clk_o;
	//Bus Reset to master and slave
	logic				rst_o;
	//common master/slave signals
	//Bus Clock from syscon
	logic				clk_i;
	//Bus Reset from syscon
	logic				rst_i;
	//Data from master
	logic	[DAT_WIDTH-1:0]		dat_o;
	//Data to master
	logic	[DAT_WIDTH-1:0]		dat_i;
	//Data Tag from master
	logic	[TGDO_WIDTH-1:0]	tgd_o;
	//Data Tag to master
	logic	[TGDI_WIDTH-1:0]	tgd_i;
	//master signals
	//Lock the bus (request lock from intercon)
	logic				lock_o;
	//Bus Cycle Terminated(slave reports success)
	logic				ack_i;
	//Bus Cycle Terminated(slave reports error)
	logic				err_i;
	//Bus Cycle Terminated(slave says to retry)
	logic				rty_i;
	//Cycle in progress (request cycle from intercon, signal
	//cycle to slave)
	logic				cyc_o;
	//Cycle Tag from master.
	logic	[TGC_WIDTH-1:0]		tgc_o;
	//Address for transfer
	logic	[ADR_WIDTH-1:0]		adr_o;
	//Address Tag from master
	logic	[TGA_WIDTH-1:0]		tga_o;
	//Assert for write, deassert for read.
	logic				we_o;
	//Assert to actually write or read.
	logic				stb_o;
	//Bank select
	logic	[SEL_WIDTH-1:0]		sel_o;
	
	modport	syscon(
		output	clk_o,
		output	rst_o
	);
	modport master(
		input	clk_i,
		input	rst_i,
		output	dat_o,
		input	dat_i,
		output	tgd_o,
		input	tgd_i,
		output	lock_o,
		input	ack_i,
		input	err_i,
		input	rty_i,
		output	cyc_o,
		output	tgc_o,
		output	adr_o,
		output	tga_o,
		output	we_o,
		output	stb_o,
		output	sel_o
	);
	modport intercon(
		input	clk_i,
		input	rst_i,
		input	dat_o,
		output	dat_i,
		input	tgd_o,
		output	tgd_i,
		input	lock_o,
		output	ack_i,
		output	err_i,
		output	rty_i,
		input	cyc_o,
		input	tgc_o,
		input	adr_o,
		input	tga_o,
		input	we_o,
		input	stb_o,
		input	sel_o
	);
	assign clk_i = clk_o;
	assign rst_i = rst_o;
endinterface

interface wishboneSlave //Version b3
#(
	parameter	TGC_WIDTH =	0,
	parameter	ADR_WIDTH =	32,
	parameter	TGA_WIDTH =	0,
	parameter	DAT_WIDTH =	32,
	parameter	SEL_WIDTH =	4,
	parameter	TGDO_WIDTH =	0,
	parameter	TGDI_WIDTH =	0
);
	//syscon signals:
	//Bus Clock to master and slave
	logic				clk_o;
	//Bus Reset to master and slave
	logic				rst_o;
	//common master/slave signals
	//Bus Clock from syscon
	logic				clk_i;
	//Bus Reset from syscon
	logic				rst_i;
	//Data from slave
	logic	[DAT_WIDTH-1:0]		dat_o;
	//Data to slave
	logic	[DAT_WIDTH-1:0]		dat_i;
	//Data Tag from slave
	logic	[TGDO_WIDTH-1:0]	tgd_o;
	//Data Tag to slave
	logic	[TGDI_WIDTH-1:0]	tgd_i;
	//slave signals
	//Bus Cycle Terminate(report success to master)
	logic				ack_o;
	//Bus Cycle Terminate(report error to master)
	logic				err_o;
	//Bus Cycle Terminate(tell master to retry)
	logic				rty_o;
	//Cycle in progress (master is performing a bus cycle)
	logic				cyc_i;
	//Cycle tag from master
	logic	[TGC_WIDTH-1:0]		tgc_i;
	//Address for transfer
	logic	[ADR_WIDTH-1:0]		adr_i;
	//Address tag from master
	logic	[TGA_WIDTH-1:0]		tga_i;
	//Write enable (assert for write, deassert for read).
	logic				we_i;
	//Strobe (assert to actually write or read).
	logic				stb_i;
	//Bank select
	logic	[SEL_WIDTH-1:0]		sel_i;
	
	modport	syscon(
		output	clk_o,
		output	rst_o
	);
	modport slave(
		input	clk_i,
		input	rst_i,
		output	dat_o,
		input	dat_i,
		output	tgd_o,
		input	tgd_i,
		output	ack_o,
		output	err_o,
		output	rty_o,
		input	cyc_i,
		input	tgc_i,
		input	adr_i,
		input	tga_i,
		input	we_i,
		input	stb_i,
		input	sel_i
	);
	modport intercon(
		input	clk_i,
		input	rst_i,
		input	dat_o,
		output	dat_i,
		input	tgd_o,
		output	tgd_i,
		input	ack_o,
		input	err_o,
		input	rty_o,
		output	cyc_i,
		output	tgc_i,
		output	adr_i,
		output	tga_i,
		output	we_i,
		output	stb_i,
		output	sel_i
	);
	assign clk_i = clk_o;
	assign rst_i = rst_o;
endinterface
