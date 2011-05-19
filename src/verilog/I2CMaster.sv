
//Requires 32 bit bus data width and 8 bit granularity.
module I2CMaster
#(
	parameter TGD	=2'b0
)
(
	input	logic		reset,//Asynchronus reset
	wishboneSlave.slave	bus,
	output	logic		interrupt,
	input	logic		sclIn,
	output	logic		sclOut,
	input	logic		sdaIn,
	output	logic		sdaOut
);

logic		error,decodeError;
logic	[1:0]	decodeAddress;
logic	[7:0]	dataIn,dataOut;
logic		strobe;
logic		scl_pad_o,sda_pad_o;

assign	error = decodeError;
assign	strobe = bus.stb_i & ~error;

assign	bus.rty_o = 1'b0;
assign	bus.err_o = bus.cyc_i & bus.stb_i & error;
assign	bus.tgd_o = TGD;

always @(*) begin
	bus.dat_o = 32'h12345678;
	case (bus.sel_i)
		4'h1	:begin
			decodeError = 1'b0;
			decodeAddress=2'h3;
			dataIn = bus.dat_i[7:0];
			bus.dat_o[7:0] = dataOut;
		end
		4'h2	:begin
			decodeError = 1'b0;
			decodeAddress=2'h2;
			dataIn = bus.dat_i[15:8];
			bus.dat_o[15:8] = dataOut;
		end
		4'h4	:begin
			decodeError = 1'b0;
			decodeAddress=2'h1;
			dataIn = bus.dat_i[23:16];
			bus.dat_o[23:16] = dataOut;
		end
		4'h8	:begin
			decodeError = 1'b0;
			decodeAddress=2'h0;
			dataIn = bus.dat_i[31:24];
			bus.dat_o[31:24] = dataOut;
		end
		default	:begin
			decodeError = 1'b1;
			decodeAddress=2'h0;
			dataIn = 8'h0;
			bus.dat_o = 32'h3355AACC;
		end
	endcase
end
//assign dataOut = {1'b1,bus.adr_i[2],decodeAddress,bus.sel_i};

i2c_master_top	i2c (
	.wb_clk_i(bus.clk_i),
	.wb_rst_i(bus.rst_i),
	.arst_i(~reset),
	.wb_adr_i({bus.adr_i[2],decodeAddress}),
	.wb_dat_i(dataIn),
	.wb_dat_o(dataOut),
	.wb_we_i(bus.we_i),
	.wb_stb_i(strobe),
	.wb_cyc_i(bus.cyc_i),
	.wb_ack_o(bus.ack_o),
	.wb_inta_o(interrupt),
	.scl_pad_i(sclIn),
	.scl_pad_o(scl_pad_o),
	.scl_padoen_o(sclOut),
	.sda_pad_i(sdaIn),
	.sda_pad_o(sda_pad_o),
	.sda_padoen_o(sdaOut)
);

endmodule
