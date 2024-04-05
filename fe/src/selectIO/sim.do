#set COVER_OPT bcefst
quit -sim
#rm tb_top_log.log
set SRC  ./


#set SV_FILES1  ../../pcs_vip/env/pcs_ref_env_pkg.sv 
#set SV_FILES2 ../../pcs_vip/env/pcs_phy_interface.sv 
#set SV_FILES3 ../../pcs_vip/tests/pcs_test_pkg.sv 
#set SV_FILES4 ../top/eth_mod.sv 
#set SV_FILES5 ../top/top.sv

#set VLOG_OPT -nologo -source -sv -sv12compat
#set VHDL_OPT -nologo -source -sv -sv12compat

#set VERBOSITY UVM_MEDIUM
set VERBOSITY UVM_DEBUG
set SEED random
set MODE NORMAL
set UVM_TEST gmii_carrier_extension_test
#set XIP ../../../nokia_ip/xilinx_ip

vlib work
vlog D:/Xilinx/Vivado/2018.3/data/verilog/src/glbl.v
#vlog pcs
vlog  -nologo -source -sv -sv12compat -timescale 1ps/1ps -work work +incdir+$SRC -l select_io.log   select_io.v  ./tb/tb_selectIO.v




#vopt -o tb_dual_ram work.top

#vsim tb_dual_ram -gui -l ./tb_dual_ram.log  +UVM_VERBOSITY=$VERBOSITY -sv_seed $SEED +UVM_TESTNAME=$UVM_TEST -do "run -all"
vsim -novopt tb_selectio -gui -L unisims_ver -L secureip -L unisim -l ./tb_selectio.log   -do "run -all"
log -r /*
run 200us



