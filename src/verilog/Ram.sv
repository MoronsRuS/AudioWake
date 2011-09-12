
module __RAM
#(
	parameter	DAT_WIDTH	=8,
	parameter	ADR_WIDTH	=13
)
(
	input	wire			clock,
	input	wire			writeEnable,
	input	wire	[ADR_WIDTH-1:0]	writeAddress,readAddress,
	input	wire	[DAT_WIDTH-1:0]	dataIn,
	output	reg	[DAT_WIDTH-1:0]	dataOut
);

logic	[DAT_WIDTH-1:0]	ram[0:2**ADR_WIDTH-1];
always_ff@ (posedge clock) begin
	if (writeEnable) begin
		ram[writeAddress] = dataIn;
	end
	dataOut = ram[readAddress];
end

endmodule


module Ram
#(
	parameter	DAT_WIDTH	=32,
	parameter	ADR_WIDTH	=13,
	parameter	SEL_WIDTH	=4,
	parameter	GRN_WIDTH	=8,
	parameter	TGD =			2'h0
)
(
	wishboneSlave.slave	bus
);
`include "oitConstant.sv"
logic	error;//Indicates bus error state.
logic	active;//Indicates an active write or read.

assign active = bus.cyc_i & bus.stb_i;
assign bus.ack_o = active;
assign bus.rty_o = 1'b0;
assign bus.err_o = 1'b0;

genvar i;
generate for(i=0;i<SEL_WIDTH;i=i+1) begin:bank

__RAM #(.DAT_WIDTH(GRN_WIDTH),
	.ADR_WIDTH(ADR_WIDTH-oitBits(SEL_WIDTH)))
	ram (
		.clock(bus.clk_i),
		.writeEnable(bus.we_i & bus.sel_i[i] & active),
		.writeAddress(bus.adr_i[ADR_WIDTH-1:oitBits(SEL_WIDTH)]),
		.readAddress(bus.adr_i[ADR_WIDTH-1:oitBits(SEL_WIDTH)]),
		.dataIn(bus.dat_i[(i+1)*GRN_WIDTH-1:i*GRN_WIDTH]),
		.dataOut(bus.dat_o[(i+1)*GRN_WIDTH-1:i*GRN_WIDTH])
	);

end endgenerate
assign bus.tgd_o = TGD;//Not using data tag.

endmodule
