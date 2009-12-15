# 
# td4: SFL version of TD4
# 
# m8:small example processor simulation environment
#    Naohiko Shimizu, IP ARCH, Inc. http://www.ip-arch.jp/
#
# This package requires: sfl2vl, Icarus Verilog, GTKWAVE

SIMDIR=./SIM
SFLDIR=./SFL
FPGADIR=./FPGA

VERILOG=iverilog

SFL2VLOPT=

CLEANSIM=board.v board.exe board_led.vcd board_timer.vcd sim_led.log sim_timer.log  td4.mem
CLEANSFL=td4.v
CLEAN=$(FPGADIR)/board.v $(FPGADIR)/td4.mem $(FPGADIR)/td4.v
SYN=$(SIMDIR)/board.v $(SIMDIR)/td4.mem $(SFLDIR)/td4.v

all: $(SIMDIR)/sim_led.log  $(SIMDIR)/sim_timer.log syn

gtk: $(SIMDIR)/td4.sig $(SIMDIR)/sim_timer.log $(SIMDIR)/board_timer.vcd
	gtkwave $(SIMDIR)/board_timer.vcd $(SIMDIR)/td4.sig

gtk_led: $(SIMDIR)/td4.sig $(SIMDIR)/sim_led.log $(SIMDIR)/board_led.vcd
	gtkwave $(SIMDIR)/board_led.vcd $(SIMDIR)/td4.sig

syn: $(SYN)
	cp $(SYN) $(FPGADIR)

clean:
	-(rm $(CLEAN) )
	-(cd $(SIMDIR); \
	rm $(CLEANSIM))
	-(cd $(SFLDIR); \
	rm $(CLEANSFL))

$(SFLDIR)/td4.v: $(SFLDIR)/td4.sfl
	(cd $(SFLDIR); \
	sfl2vl td4.sfl $(SFL2VLOPT);)

$(SIMDIR)/board.v: $(SIMDIR)/board.sfl
	(cd $(SIMDIR); \
	sfl2vl board.sfl $(SFL2VLOPT);)

$(SIMDIR)/board.exe: $(SFLDIR)/td4.v $(SIMDIR)/board.main $(SIMDIR)/board.v
	iverilog -o $(SIMDIR)/board.exe $(SIMDIR)/board.main $(SIMDIR)/board.v $(SFLDIR)/td4.v

$(SIMDIR)/sim_timer.log: $(SIMDIR)/board.exe $(SIMDIR)/td4_timer.mem
	(cd $(SIMDIR); \
	cp td4_timer.mem td4.mem; \
	vvp ./board.exe |tee sim_timer.log; \
	mv board.vcd board_timer.vcd )

$(SIMDIR)/sim_led.log: $(SIMDIR)/board.exe $(SIMDIR)/td4_led.mem 
	(cd $(SIMDIR); \
	cp td4_led.mem td4.mem; \
	vvp ./board.exe |tee sim_led.log; \
	mv board.vcd board_led.vcd )

GTK:	$(SIMDIR)/sim.log
	(cd $(SIMDIR); \
	gtkwave board.vcd td4.sig )






