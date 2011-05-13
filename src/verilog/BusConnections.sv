//****************************************************************************
//	BusConnections.sv
//	Intercon modules for the wishbone bus.
//
//	This file is a part of the AudioWake project
//	http://github.com/MoronsRuS/AudioWake
//
//	Description:
//		This file contains intercon modules for the wishbone bus.
//			directConnect -	An interconn module with no 
//					connection logic, just a point to 
//					point connection.
//	
//	TODO:
//		- Nothing right now.
//
//	Author:
//		MoronsRuS, https://github.com/MoronsRuS
//****************************************************************************

//****************************************************************************
//	directConnect
//	An intercon module for point to point bus connection.
//
//	Description:
//		This is an intercon module for the wishbone bus with no 
//		connection logic.  It's just a point to point connection 
//		between a master and a slave.
//	
//	Interfaces:
//		master:	A wishbone bus master.
//		slave:	A wishbone bus slave.
//
//	TODO:
//		- Nothing right now.
//****************************************************************************
module directConnect(
	wishboneMaster.intercon	master,
	wishboneSlave.intercon	slave
);

assign master.dat_i = slave.dat_o;
assign master.tgd_i = slave.tgd_o;
assign master.ack_i = slave.ack_o;
assign master.err_i = slave.err_o;
assign master.rty_i = slave.rty_o;
assign slave.dat_i = master.dat_o;
assign slave.tgd_i = master.tgd_o;
assign slave.cyc_i = master.cyc_o;
assign slave.tgc_i = master.tgc_o;
assign slave.adr_i = master.adr_o;
assign slave.tga_i = master.tga_o;
assign slave.we_i = master.we_o;
assign slave.stb_i = master.stb_o;
assign slave.sel_i = master.sel_o;

endmodule
