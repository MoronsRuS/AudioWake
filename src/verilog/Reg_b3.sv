//Noah Bacon
module reg_b3
#(
	parameter	DATA_WIDTH =	32,
	parameter	SELECT_WIDTH =	4,
	parameter	RESET_PAT =	0
)
(
	input	logic		reset,
	wishbone_b3.slave	bus
);
	parameter	DATA_GRANULARITY = DATA_WIDTH/SELECT_WIDTH;
	logic	error;//Indicates a bus error state
	logic	active;//Indicates we are performing a write or read action.

	//The value of the register.
	logic	[DATA_WIDTH-1:0]	value;
	//The next value to load.
	logic	[DATA_WIDTH-1:0]	nextValue;

	assign error = bus.writeEnable & reset;
	assign active = bus.cycle & bus.strobe;
	assign bus.ack = active & ~(error);
	assign bus.rty = 1'b0;
	assign bus.err = active & error;
	
generate
	genvar upper,lower;
	for (i=0; i<SELECT_WIDTH; i=i+1) begin
		logic	[DATA_GRANULARITY-1:0]	incoming;
		logic	[DATA_GRANULARITY-1:0]	last;
		logic	[DATA_GRANULARITY-1:0]	next;
		upper = DATA_GRANULARITY*(i+1) - 1;
		lower = DATA_GRANULARITY*(i);
		assign incoming = bus.dataMaster[upper:lower];
		assign last = value[upper:lower];
		
		always @(*) begin
			if (active & bus.writeEnable & bus.select[i]) begin
				case(bus.address[1:0])
					2'h0:next = incoming;
					2'h1:next = value | incoming;
					2'h2:next = value & ~incoming;
					2'h3:next = value ^ incoming;
				endcase
			end else begin
				next = last;
			end
		end
		nextValue[upper:lower] = next;
	end
endgenerate
	
	always @(negedge bus.clock or posedge reset) begin
		if (reset) begin
			value = RESET_PAT;
		end else begin
			value = nextValue;
		end
	end
	assign bus.dataSlave = value;

endmodule
