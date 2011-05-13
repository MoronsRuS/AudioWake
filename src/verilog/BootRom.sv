//****************************************************************************
//	BootRom.sv
//	This is the rom that holds the code to run when the processor boots.
//
//	This file is a part of the AudioWake project
//	http://github.com/MoronsRuS/AudioWake
//
//	Description:
//	
//	TODO:
//		- Document
//
//	Author:
//		MoronsRuS, https://github.com/MoronsRuS
//		(based off example from Altera Recommended HDL Coding Styles, 
//		http://www.altera.com/literature/hb/qts/qts_qii51007.pdf)
//****************************************************************************
module __BOOTROM
#(
	parameter DATA_WIDTH =		32,
	parameter ADDRESS_WIDTH =	12
)
(
	input	wire				clock,
	input	wire	[ADDRESS_WIDTH-1:0]	address,
	output	reg	[DATA_WIDTH-1:0]	data
);
	logic [DATA_WIDTH-1:0] rom[0:2**ADDRESS_WIDTH-1];
	
	initial //Init ROM from file
	begin
		$readmemh("../software/boot.dat", rom);
	end
	
	always @ (posedge clock)
	begin
		data <= rom[address];
//		data = 32'h87654321;
	end
	
	initial
	begin
		data <= 'hDEADBEEF;
	end
endmodule
	
module BootRom
#(
	parameter DATA_WIDTH =		32,
	parameter ADDRESS_WIDTH =	12,
	parameter TGD =			0
)
(
	wishboneSlave	bus
);
	logic	error;//Indicates bus error state.
	logic	active;//Indicates an active write or read.

	assign error = bus.we_i;//If a write is attempted we error.
	assign active = bus.cyc_i & bus.stb_i;
	assign bus.ack_o = active & (~error);
	assign bus.rty_o = 1'b0;
	assign bus.err_o = active & error;
	
	__BOOTROM #(.DATA_WIDTH(DATA_WIDTH),.ADDRESS_WIDTH(ADDRESS_WIDTH))
		rom (
			.clock(~bus.clk_i),
//			.address(bus.adr_i),
			.address(bus.adr_i[ADDRESS_WIDTH-1:2]),
//			.address(0),
			.data(bus.dat_o)
		);
	assign bus.tgd_o = TGD;//Not using data tag.
endmodule

