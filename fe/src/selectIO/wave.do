onerror {resume}
quietly virtual signal -install {/tb_selectio/u_select_io/genblk2[0]/OSERDESE2_inst} { (context /tb_selectio/u_select_io/genblk2[0]/OSERDESE2_inst )&{D1 , D2 , D3 , D4 }} Oserdes0_Din
quietly virtual signal -install {/tb_selectio/u_select_io/genblk2[0]/OSERDESE2_inst} { (context /tb_selectio/u_select_io/genblk2[0]/OSERDESE2_inst )&{D4 , D3 , D2 , D1 }} Oserdes0_Din001
quietly virtual signal -install {/tb_selectio/u_select_io/genblk1[0]/ISERDESE2_inst} { (context /tb_selectio/u_select_io/genblk1[0]/ISERDESE2_inst )&{Q4 , Q3 , Q2 , Q1 }} Iserdes0_DO
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_selectio/u_select_io/DW
add wave -noupdate /tb_selectio/u_select_io/SP_Mult
add wave -noupdate /tb_selectio/u_select_io/REFCLK_200m
add wave -noupdate /tb_selectio/u_select_io/clk_125M
add wave -noupdate /tb_selectio/u_select_io/i_rst
add wave -noupdate /tb_selectio/u_select_io/i_dclk
add wave -noupdate /tb_selectio/u_select_io/i_pardata
add wave -noupdate /tb_selectio/u_select_io/o_dclk_div
add wave -noupdate /tb_selectio/u_select_io/o_clk_p
add wave -noupdate /tb_selectio/u_select_io/o_clk_n
add wave -noupdate /tb_selectio/u_select_io/o_data_p
add wave -noupdate /tb_selectio/u_select_io/o_data_n
add wave -noupdate /tb_selectio/u_select_io/i_clk_p
add wave -noupdate /tb_selectio/u_select_io/i_clk_n
add wave -noupdate /tb_selectio/u_select_io/i_data_p
add wave -noupdate /tb_selectio/u_select_io/i_data_n
add wave -noupdate /tb_selectio/u_select_io/o_fclk
add wave -noupdate /tb_selectio/u_select_io/o_pardata
add wave -noupdate /tb_selectio/u_select_io/IFB
add wave -noupdate /tb_selectio/u_select_io/OFB
add wave -noupdate /tb_selectio/u_select_io/data_ibuf_o
add wave -noupdate /tb_selectio/u_select_io/data_delay_o
add wave -noupdate /tb_selectio/u_select_io/o_serdesdata_buf
add wave -noupdate /tb_selectio/u_select_io/dclk_f
add wave -noupdate /tb_selectio/u_select_io/i_dclk_div
add wave -noupdate /tb_selectio/rst_sys
add wave -noupdate /tb_selectio/i_pardata
add wave -noupdate /tb_selectio/o_dclk_div
add wave -noupdate /tb_selectio/count_num
add wave -noupdate {/tb_selectio/u_select_io/genblk2[0]/OSERDESE2_inst/RST}
add wave -noupdate {/tb_selectio/u_select_io/genblk2[0]/OSERDESE2_inst/OFB}
add wave -noupdate -expand {/tb_selectio/u_select_io/genblk2[0]/OSERDESE2_inst/Oserdes0_Din001}
add wave -noupdate {/tb_selectio/u_select_io/genblk2[0]/OSERDESE2_inst/CLK}
add wave -noupdate {/tb_selectio/u_select_io/genblk2[0]/OSERDESE2_inst/OQ}
add wave -noupdate {/tb_selectio/u_select_io/genblk1[0]/IBUFDS_inst/O}
add wave -noupdate {/tb_selectio/u_select_io/genblk1[0]/IDELAYE2_inst/IDATAIN}
add wave -noupdate {/tb_selectio/u_select_io/genblk1[0]/IDELAYE2_inst/DATAOUT}
add wave -noupdate {/tb_selectio/u_select_io/genblk1[0]/ISERDESE2_inst/Q1}
add wave -noupdate {/tb_selectio/u_select_io/genblk1[0]/ISERDESE2_inst/Q2}
add wave -noupdate {/tb_selectio/u_select_io/genblk1[0]/ISERDESE2_inst/Q3}
add wave -noupdate {/tb_selectio/u_select_io/genblk1[0]/ISERDESE2_inst/Q4}
add wave -noupdate {/tb_selectio/u_select_io/genblk1[0]/ISERDESE2_inst/CLK}
add wave -noupdate {/tb_selectio/u_select_io/genblk1[0]/ISERDESE2_inst/CLKB}
add wave -noupdate {/tb_selectio/u_select_io/genblk1[0]/ISERDESE2_inst/CLKDIV}
add wave -noupdate {/tb_selectio/u_select_io/genblk1[0]/ISERDESE2_inst/RST}
add wave -noupdate {/tb_selectio/u_select_io/genblk1[0]/ISERDESE2_inst/D}
add wave -noupdate {/tb_selectio/u_select_io/genblk1[0]/ISERDESE2_inst/DDLY}
add wave -noupdate {/tb_selectio/u_select_io/genblk1[0]/ISERDESE2_inst/Iserdes0_DO}
add wave -noupdate {/tb_selectio/u_select_io/genblk1[0]/ISERDESE2_inst/Q1}
add wave -noupdate {/tb_selectio/u_select_io/genblk1[0]/ISERDESE2_inst/Q2}
add wave -noupdate {/tb_selectio/u_select_io/genblk1[0]/ISERDESE2_inst/Q3}
add wave -noupdate {/tb_selectio/u_select_io/genblk1[0]/ISERDESE2_inst/Q4}
add wave -noupdate {/tb_selectio/u_select_io/genblk1[0]/ISERDESE2_inst/BITSLIP}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {507000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 383
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {493909 ps} {599741 ps}
