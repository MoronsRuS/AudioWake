//Noah Bacon
interface wishbone_b3
#(
	parameter	CYCLE_TAG_WIDTH =	0,
	parameter	ADDRESS_WIDTH =		32,
	parameter	ADDRESS_TAG_WIDTH =	0,
	parameter	DATA_WIDTH =		32,
	parameter	SELECT_WIDTH =		4,
	parameter	DATA_TAG_MASTER_WIDTH =	0,
	parameter	DATA_TAG_SLAVE_WIDTH =	0
);
	//Bus Clock
	logic				clock;
	//Bus Reset
	logic				reset;
	//Lock the bus (request lock)
	logic				lock;
	//Bus Cycle Complete(success)
	logic				ack;
	//Bus Cycle Complete(error)
	logic				error;
	//Slave not ready, try again
	logic				retry;
	//Cycle in progress (request cycle)
	logic				cycle;
	//User defined, qualified by cycle
	logic	[CYCLE_TAG_WIDTH-1:0]	cycleTag;
	//Address for transfer
	logic	[ADDRESS_WIDTH-1:0]	address;
	//User defined, qualified by strobe
	logic	[ADDRESS_TAG_WIDTH-1:0]	addressTag;
	//Write/Read
	logic				writeEnable;
	//Write or Read strobe
	logic				strobe;
	//Data from master
	logic	[DATA_WIDTH-1:0]	dataMaster;
	//Data from slave
	logic	[DATA_WIDTH-1:0]	dataSlave;
	//Bank select
	logic	[SELECT_WIDTH-1:0]	select;
	//User defined, qualified by strobe
	logic	[DATA_TAG_MASTER_WIDTH-1:0]	dataTagMaster;
	//User defined, qualified by strobe
	logic	[DATA_TAG_SLAVE_WIDTH-1:0]	dataTagSlave;
	
	modport	syscon(
		output	clock,
		output	reset,
		input	lock
	);
	modport master(
		input	clock,
		input	reset,
		input	ack,
		input	error,
		input	retry,
		output	lock,
		output	cycle,
		output	cycleTag,
		output	address,
		output	addressTag,
		output	writeEnable,
		output	strobe,
		output	dataMaster,
		input	dataSlave,
		output	select,
		output	dataTagMaster,
		input	dataTagSlave
	);
	modport slave(
		input	clock,
		input	reset,
		output	ack,
		output	error,
		output	retry,
		input	cycle,
		input	cycleTag,
		input	address,
		input	addressTag,
		input	writeEnable,
		input	strobe,
		input	dataMaster,
		output	dataSlave,
		input	select,
		input	dataTagMaster,
		output	dataTagSlave
	);
endinterface
