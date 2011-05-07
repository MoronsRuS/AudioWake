//Noah Bacon

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
	wishbone_b3.master	instruction_bus,
	wishbone_b3.master	data_bus,
	powerManagement.processor pmInterface
);
assign instruction_bus.lock = 1'b0;
assign data_bus.lock = 1'b0;

or1200_top processor(
	.clk_i(clock),
	.rst_i(reset),
	.clmode_i(clmode),
	.pic_ints_i(interrupts),
	//Instruction Bus
	.iwb_clk_i	(instruction_bus.clock),
	.iwb_rst_i	(instruction_bus.reset),
	.iwb_ack_i	(instruction_bus.ack),
	.iwb_err_i	(instruction_bus.error),
	.iwb_rty_i	(instruction_bus.retry),
	.iwb_dat_i	(instruction_bus.dataSlave),
	.iwb_cyc_o	(instruction_bus.cycle),
	.iwb_adr_o	(instruction_bus.address),
	.iwb_stb_o	(instruction_bus.strobe),
	.iwb_we_o	(instruction_bus.writeEnable),
	.iwb_sel_o	(instruction_bus.select),
	.iwb_dat_o	(instruction_bus.dataMaster),
	.iwb_cti_o	(instruction_bus.cycleTag[2:0]),
	.iwb_bte_o	(instruction_bus.addressTag[1:0]),
	//Instruction Bus
	.dwb_clk_i	(data_bus.clock),
	.dwb_rst_i	(data_bus.reset),
	.dwb_ack_i	(data_bus.ack),
	.dwb_err_i	(data_bus.error),
	.dwb_rty_i	(data_bus.retry),
	.dwb_dat_i	(data_bus.dataSlave),
	.dwb_cyc_o	(data_bus.cycle),
	.dwb_adr_o	(data_bus.address),
	.dwb_stb_o	(data_bus.strobe),
	.dwb_we_o	(data_bus.writeEnable),
	.dwb_sel_o	(data_bus.select),
	.dwb_dat_o	(data_bus.dataMaster),
	.dwb_cti_o	(data_bus.cycleTag[2:0]),
	.dwb_bte_o	(data_bus.addressTag[1:0]),
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

assign instruction_bus.dataTagMaster = 0;
assign instruction_bus.dataTagMaster = 0;
assign data_bus.dataTagMaster = 0;
assign data_bus.dataTagMaster = 0;

endmodule

