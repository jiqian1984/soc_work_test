#*!*******************************************************************
# * Copyright (C) NSN 2014
# * 
# * Project     : FISU I2C Agent 
# * File        : Makefile_example_env<br>
# * Description : Makefile for Synopsys VCS. Make is modular and agent is compiled through separate Makefile
# * 
# * 
# * $Revision: 2456 $
# * $LastChangedDate: 2016-05-17 14:57:06 +0300 (Tue, 17 May 2016) $
# * $LastChangedBy: rautakou $
# * 
# * $HeadURL: https://svne1.access.nokiasiemensnetworks.com/isource/svnroot/soc_verif_common/tags/i2c_vip/v1_1/sim/Makefile_example_env $
# * 
# *******************************************************************/

################################################################################

INCL      = +incdir+../env/+../tests/

################################################################################

SV_FILES = \
top_tb.sv \
dut.v 

MODULE_TOP = $(TC)
#######################################################################
#dut src source
FE_SC=$()../src

#tb src sorce
TB_SC=$()../tb

################################################################################
# 1.1 & 1.2 supported for UVM_VER
UVM_VER = 1.2
DEFINES   = +define+VCS_ENV
VCS_VLOG_OPTIONS = -V -work WORK -override_timescale=1ps/1ps -nc -full64 -sverilog +UVM_OBJECTION_TRACE -l vcs.log +warn=all -ntb_opts  uvm-$(UVM_VER) $(DEFINES) 
ELAB_OPTS = -licqueue -lca -nc -notice -full64 +memcbk -override_timescale=1fs/1fs +vcs+vcdpluson \
-ntb_opts nde_virtf -ntb_opts uvm-$(UVM_VER) -l vcs_elab.log
RUN_OPTS  = -licqueue -l simv.log

SEED      = 1 # Default seed set to 1
VERBOSITY = UVM_HIGH
MODE      = NORMAL # Default configuration record-replay mode set to NORMAL
#UVM_TEST  = i2c_ref_test
#VCS_VLOG_OPTIONS  = -V -work WORK -nc -full64 -sverilog 
VCS_VHDL_OPTIONS  = -work WORK -nc -full64
all: clean config comp elaborate run 


help:
	@echo "############################################################################################";
	@echo "#Makefile Help Page:"
	@echo "#    Testcase:"
	@echo "#           TC=test_name:    specify testcase name"
	@echo "#    Targets:"
	@echo "#           comp:        compile dut and testbench"
	@echo "#           comp_dut:    only compile dut"
	@echo "#           comp_tb:     only compile tb"
	@echo "#           elaborate:   elaborate"
	@echo "#           run:         run the simulation"
	@echo "#           clean:       clean simulation directory"
	@echo "#           view:        show simulation wave in verdi"
	@echo "#           all:         compile dut and testbench and run simulation"
	@echo "#     example:make comp"
	@echo "#     example:make all TC=test_name"
	@echo "############################################################################################";
	
config :
	@echo '================ Config work library ================'
	@mkdir -p worklib
	@echo $(LD_LIBRARY_PATH)
	@echo "WORK > worklib"       > synopsys_sim.setup
	@echo "worklib : ./worklib" >> synopsys_sim.setup
#	@echo "OTHERS=/RRU_FPGA/VIVADO_VCS_LIBRARY_201704/synopsys_sim.setup" >> synopsys_sim.setup
	@echo "OTHERS=/home/jjyoyo/work/compile_simlib/vcs/synopsys_sim.setup" >> synopsys_sim.setup


verilog_analysis:
	@echo '================ verilog_analysis ================'
	vlogan -ntb_opts uvm-$(UVM_VER)
#	$(MAKE) -f Makefile analysis "VLOG_CMD=vlogan $(COMP_OPTS) -debug_all"
	vlogan $(VCS_VLOG_OPTIONS) -f ./vlog.list
	
vhdl_analysis:
	vhdlan $(VCS_VHDL_OPTIONS) -f ./vhdl.list

#comp_c:
#	@echo "============== Bulid C file to .so lib ================"
#	$(CC) $(FILESC) $(CFLAGS) -I$(DIRSC) -o $(TARGET) 
#	
#comp_cexe:
#	@echo "============== Bulid C file to exefile for lib examples ================"
#	$(CC) -g -Wall  -I$(DIRSC) -I$(DIRSC)/examples $(FILESC) $(DIRSC)/examples/main.c -o  $(TARGETEXE)   


pre_dut_init:
	@echo "Update DUT RTL filelist";
	rm -f $(IP_LIST_TMP) $(VLOG_LIST_TMP) $(VHDL_LIST_TMP)
	rm -f $(IP_LIST) $(VLOG_LIST) $(VHDL_LIST)
	for d in $(FE_SC) ; do \
		for i in `find $$d -maxdepth 3 -name *_ip.f -print | xargs` ; do \
			cat $$i >> $(IP_LIST_TMP) ; \
		done ; \
		for i in `find $$d -maxdepth 3 -name *_v.f -print | xargs` ; do \
			if [ $$i != $(EX_VLOG1) ] && [ $$i != $(EX_VLOG2) ] ; then \
				cat $$i >> $(VLOG_LIST_TMP); \
			fi ; \
		done ; \
		for i in `find $$d -maxdepth 3 -name *_vhd.f -print | xargs` ; do \
			if [ $$i != $(EX_VHDL) ] ; then \
			  cat $$i >> $(VHDL_LIST_TMP); \
			fi ; \
		done ; \
	done ; \
	
	dos2unix $(IP_LIST_TMP) $(VLOG_LIST_TMP) $(VHDL_LIST_TMP)
	awk NF $(IP_LIST_TMP) > $(IP_LIST) 
	awk NF $(VLOG_LIST_TMP) > $(VLOG_LIST) 
	awk NF $(VHDL_LIST_TMP) > $(VHDL_LIST)
	sed -i '/bfmaster_fpga_R5/'d $(VHDL_LIST)
	awk '/bfmaster_fpga_R5/' $(VHDL_LIST_TMP) >> $(VHDL_LIST)
	sed -i '/aenb_top.vhd/'d $(VHDL_LIST)
	awk '/aenb_top.vhd/' $(VHDL_LIST_TMP) >> $(VHDL_LIST)
	rm -f $(IP_LIST_TMP) $(VLOG_LIST_TMP) $(VHDL_LIST_TMP)
#这里递归遍历3级子目录
#DIRS := $(shell find . -maxdepth 3 -type d)
#这里循环遍历目录的cpp文件
#FILES = $(foreach dir,$(DIRS),$(wildcard $(dir)/*.c))


pre_tb_init:
	@echo "Update TestBench filelist";
	rm -f $(IP_LIST_TMP) $(VLOG_LIST_TMP) $(VHDL_LIST_TMP)
	rm -f $(IP_LIST) $(VLOG_LIST) $(VHDL_LIST)

comp_dut:
	pre_dut_init
	verilog_analysis
	vhdl_analysis
	
comp_tb:
	pre_tb_init
	verilog_analysis
	vhdl_analysis

elaborate:
#	vlogan -ntb_opts uvm-$(UVM_VER)
#	$(MAKE) -f Makefile analysis "VLOG_CMD=vlogan $(COMP_OPTS) -debug_all"
#	vlogan $(COMP_OPTS)  \
	-debug_all $(SV_FILES)
	vcs $(ELAB_OPTS) \
	-debug_all WORK.$(MODULE_TOP)
   
comp:
#   pre_dut_init
#	pre_tb_init
	verilog_analysis
	vhdl_analysis


run: 
	@echo "============== sim design ================"
	./simv  $(RUN_OPTS) +UVM_VERBOSITY=$(VERBOSITY) \
        +ntb_random_seed=$(SEED)
	urg -dir simv.vdb -report text
	
	
view :
	@echo '================ View simulate waveform ================'
	@if [ -f $(MODULE_TOP).rc ]; then \
		verdi -ssf $(MODULE_TOP).fsdb -sswr $(MODULE_TOP).rc; \
	else \
		verdi -ssf $(MODULE_TOP).fsdb; \
	fi
	
clean:
	rm -rf simv* csrc
	rm -rf vc_hdrs.h .vcsmx_rebuild *.log
	rm -rf work/* *.svshell vcs_version
	rm -rf AN.DB
	rm -rf DVEfiles ucli.key vcdplus.vpd
	rm -rf *~
	rm -rf *.tag

sim:
	@echo "============== sim design ================"
	./simv -ucli -i run.ucli "+NUM+10" -l run.log  +UVM_TESTNAME=$(UVM_TEST)
#    ./simv -ucli -i run.ucli -l run.log -sv_lib  ../lib/upsample_2x
	urg -dir simv.vdb -report text

