//****************************************************************************
//	or1200.sv
//	Wrapper and interfaces for or1200 processor.
//
//	This file is a part of the AudioWake project
//	http://github.com/MoronsRuS/AudioWake
//
//	Description:
//		This file contains a wrapper and verilog interfaces for an 
//		or1200 (http://opencores.org/openrisc,or1200).  The 
//		interfaces are the powerManagement interface and the 
//		debug interface.  The wrapper module is or1200.
//		
//		I'm not really sure what to do with the power management and 
//		debug signals right now.
//	
//	TODO:
//		- Figure out more about the power management and debug 
//		signals.
//
//	Author:
//		MoronsRuS, https://github.com/MoronsRuS
//****************************************************************************

interface powerManagement;
	logic		cpustall;
	logic	[3:0]	clksd;
	logic		dc_gate;
	logic		ic_gate;
	logic		dmmu_gate;
	logic		immu_gate;
	logic		tt_gate;
	logic		cpu_gate;
	logic		wakeup;
	logic		lvolt;
	
	modport processor(
		input	cpustall,
		output	clksd,
		output	dc_gate,
		output	ic_gate,
		output	dmmu_gate,
		output	immu_gate,
		output	tt_gate,
		output	cpu_gate,
		output	wakeup,
		output	lvolt
	);
	modport peripheral(
		output	cpustall,
		input	clksd,
		input	dc_gate,
		input	ic_gate,
		input	dmmu_gate,
		input	immu_gate,
		input	tt_gate,
		input	cpu_gate,
		input	wakeup,
		input	lvolt
	);
endinterface

interface debug
#(
	parameter	ADDRESS_WIDTH =	32,
	parameter	DATA_WIDTH =	32
);
	logic		stall;// External Stall Input
	logic		ewt;// External Watchpoint Trigger Input
	logic	[3:0]	lss;// External Load/Store Unit Status
	logic	[1:0]	is;// External Insn Fetch Status
	logic	[10:0]	wp;// Watchpoints Outputs
	logic		bp;// Breakpoint Output
	logic		stb;// External Address/Data Strobe
	logic		we;// External Write Enable
	logic	[ADDRESS_WIDTH-1:0]	adr;// External Address Input
	logic	[DATA_WIDTH-1:0]	datI;// External Data Input
	logic	[DATA_WIDTH-1:0]	datO;// External Data Output
	logic		ack;// External Data Acknowledge (not WB compatible)
	
	modport processor(
		input		stall,
		input		ewt,
		output		lss,
		output		is,
		output		wp,
		output		bp,
		input		stb,
		input		we,
		input		adr,
		input		datI,
		output		datO,
		output		ack
	);
	modport peripheral(
		output		stall,
		output		ewt,
		input		lss,
		input		is,
		input		wp,
		input		bp,
		output		stb,
		output		we,
		output		adr,
		output		datI,
		input		datO,
		input		ack
	);
endinterface

module or1200 (
	//System
	input	logic		clock,
	input	logic		reset,
	input	logic	[19:0]	interrupts,
	//clmode: 00 WB=RISC, 01 WB=RISC/2, 10 N/A, 11 WB=RISC/4
	input	logic	[1:0]	clmode,
	debug.processor		debugInterface,
	wishboneMaster.master	instruction_bus,
	wishboneMaster.master	data_bus,
	powerManagement.processor pmInterface
);

or1200_top processor(
	.clk_i(clock),
	.rst_i(reset),
	.clmode_i(clmode),
	.pic_ints_i(interrupts),
	//Instruction Bus
	.iwb_clk_i	(instruction_bus.clk_i),
	.iwb_rst_i	(instruction_bus.rst_i),
	.iwb_ack_i	(instruction_bus.ack_i),
	.iwb_err_i	(instruction_bus.err_i),
	.iwb_rty_i	(instruction_bus.rty_i),
	.iwb_dat_i	(instruction_bus.dat_i),
	.iwb_cyc_o	(instruction_bus.cyc_o),
	.iwb_adr_o	(instruction_bus.adr_o),
	.iwb_stb_o	(instruction_bus.stb_o),
	.iwb_we_o	(instruction_bus.we_o),
	.iwb_sel_o	(instruction_bus.sel_o),
	.iwb_dat_o	(instruction_bus.dat_o),
	//Cycle Type Indicator is part of Cycle Tag.
	.iwb_cti_o	(instruction_bus.tgc_o[2:0]),
	//Burst type indicator is part of Address Tag.
	.iwb_bte_o	(instruction_bus.tga_o[1:0]),
	//Instruction Bus
	.dwb_clk_i	(data_bus.clk_i),
	.dwb_rst_i	(data_bus.rst_i),
	.dwb_ack_i	(data_bus.ack_i),
	.dwb_err_i	(data_bus.err_i),
	.dwb_rty_i	(data_bus.rty_i),
	.dwb_dat_i	(data_bus.dat_i),
	.dwb_cyc_o	(data_bus.cyc_o),
	.dwb_adr_o	(data_bus.adr_o),
	.dwb_stb_o	(data_bus.stb_o),
	.dwb_we_o	(data_bus.we_o),
	.dwb_sel_o	(data_bus.sel_o),
	.dwb_dat_o	(data_bus.dat_o),
	//Cycle Type Indicator is part of Cycle Tag.
	.dwb_cti_o	(data_bus.tgc_o[2:0]),
	//Burst type indicator is part of Address Tag.
	.dwb_bte_o	(data_bus.tga_o[1:0]),
	//Debug Interface
	.dbg_stall_i	(debugInterface.stall),
	.dbg_ewt_i	(debugInterface.ewt),
	.dbg_lss_o	(debugInterface.lss),
	.dbg_is_o	(debugInterface.is),
	.dbg_wp_o	(debugInterface.wp),
	.dbg_bp_o	(debugInterface.bp),
	.dbg_stb_i	(debugInterface.stb),
	.dbg_we_i	(debugInterface.we),
	.dbg_adr_i	(debugInterface.adr),
	.dbg_dat_i	(debugInterface.datI),
	.dbg_dat_o	(debugInterface.datO),
	.dbg_ack_o	(debugInterface.ack),
	//Power Management Interface
	.pm_cpustall_i	(pmInterface.cpustall),
	.pm_clksd_o	(pmInterface.clksd),
	.pm_dc_gate_o	(pmInterface.dc_gate),
	.pm_ic_gate_o	(pmInterface.ic_gate),
	.pm_dmmu_gate_o	(pmInterface.dmmu_gate),
	.pm_immu_gate_o	(pmInterface.immu_gate),
	.pm_tt_gate_o	(pmInterface.tt_gate),
	.pm_cpu_gate_o	(pmInterface.cpu_gate),
	.pm_wakeup_o	(pmInterface.wakeup),
	.pm_lvolt_o	(pmInterface.lvolt)
);

assign instruction_bus.tgd_o = 0;//Set Data Tag to 0, we don't use it.
assign instruction_bus.lock_o = 0;//Set lock to 0, we don't use it.
assign data_bus.tgd_o = 0;//Set Data Tag to 0, we don't use it.
assign data_bus.lock_o = 0;//Set lock to 0, we don't use it.

endmodule

