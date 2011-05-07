//Noah Bacon
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
	//User defined, qualified by strobe
	logic	[TGDO_WIDTH-1:0]	tgd_o;
	//User defined, qualified by strobe
	logic	[TGDI_WIDTH-1:0]	tgd_i;
	//master signals
	//Lock the bus (request lock)
	logic				lock_o;
	//Bus Cycle Complete(success)
	logic				ack_i;
	//Bus Cycle Complete(error)
	logic				err_i;
	//Slave not ready, try again
	logic				rty_i;
	//Cycle in progress (request cycle)
	logic				cyc_o;
	//User defined, qualified by cycle
	logic	[TGC_WIDTH-1:0]		tgc_o;
	//Address for transfer
	logic	[ADR_WIDTH-1:0]		adr_o;
	//User defined, qualified by strobe
	logic	[TGA_WIDTH-1:0]		tga_o;
	//Write/Read
	logic				we_o;
	//Write or Read strobe
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
	//User defined, qualified by strobe
	logic	[TGDO_WIDTH-1:0]	tgd_o;
	//User defined, qualified by strobe
	logic	[TGDI_WIDTH-1:0]	tgd_i;
	//slave signals
	//Bus Cycle Complete(success)
	logic				ack_o;
	//Bus Cycle Complete(error)
	logic				err_o;
	//Slave not ready, try again
	logic				rty_o;
	//Cycle in progress (request cycle)
	logic				cyc_i;
	//User defined, qualified by cycle
	logic	[TGC_WIDTH-1:0]		tgc_i;
	//Address for transfer
	logic	[ADR_WIDTH-1:0]		adr_i;
	//User defined, qualified by strobe
	logic	[TGA_WIDTH-1:0]		tga_i;
	//Write/Read
	logic				we_i;
	//Write or Read strobe
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
