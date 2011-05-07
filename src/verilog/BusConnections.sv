//Noah Bacon
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
assign slave.we_i = master.we_o;
assign slave.stb_i = master.stb_o;
assign slave.sel_i = master.sel_o;

endmodule
