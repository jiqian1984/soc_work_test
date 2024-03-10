//-----------------------------------------------------------------------------
// Title    : CPRI SerDes Top Test Bench
// Project  : CPRI
// Author   : Author:
// Revision : Revision: 1.0
// Date     : Date:
//-----------------------------------------------------------------------------
// Description  : Test bench of cpri_serdes_top
//-----------------------------------------------------------------------------
// Copyright (C) Nokia Siemens Networks
// All rights reserved. Reproduction in whole or part is prohibited
// without the written permission of the copyright owner.
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps
module tb_multi_freq();
//-----------------------------------------------------------------------------
// Dump fsdb file
//-----------------------------------------------------------------------------

initial
begin
    $fsdbDumpoff;
    //#50; //run 1250us, before start dump wave file
    $fsdbDumpon;
    $fsdbDumpfile("tb_multi_freq.fsdb");
    //$fsdbAutoSwitchDumpfile(800,"tb_cpri_serdes_top.fsdb",100); //file size 800M, 100 files total
    $fsdbDumpvars;
	$fsdbDumpMDA();
end

always #10000 $display("Simluate time == %0dus",$time/1000);

glbl glbl();


reg i_clk = 1'b0;
reg reset_temp = 1'b0;
wire rst_temp;
wire          data_vld_temp;
wire          data_ca_temp;
wire [15:0]   data_i_temp;
wire [15:0]   data_q_temp;
wire [15:0]   sin_coff_temp;
wire [15:0]   cos_coff_temp;
wire          after_multi_vld;
wire          after_multi_ca;
wire [15:0]   after_multi_i;
wire [15:0]   after_multi_q;

//always #4ns i_clk = ~i_clk;
//always #4ns slowclk = ~slowclk;
//always #4 clk_125m = ~clk_125m;
always #1.0173 i_clk = ~i_clk;
//always #1.63 clk_b = ~clk_b;
	
    multi_freq u_multi_freq(
	.i_clk(i_clk),
	.i_reset(rst_temp),
	.i_data_vld(data_vld_temp),
	.i_data_ca(data_ca_temp),
	.i_data_i(data_i_temp),
	.i_data_q(data_q_temp),
	.i_sin_coff(sin_coff_temp),
	.i_cos_coff(cos_coff_temp),
	.o_data_vld(after_multi_vld),
	.o_data_ca(after_multi_ca),
	.o_data_i(after_multi_i),
	.o_data_q(after_multi_q)
	
);

    test_multi_freq u_test_multi_freq(
    .i_clk(i_clk),
	.o_rst(rst_temp),
    .o_data_vld(data_vld_temp),
	.o_data_ca(data_ca_temp),
	.o_data_i(data_i_temp),
	.o_data_q(data_q_temp),
	.o_sin_coff(sin_coff_temp), 
	.o_cos_coff(cos_coff_temp), 
	.i_data_vld(after_multi_vld),
	.i_data_ca(after_multi_ca),
	.i_data_i(after_multi_i),
	.i_data_q(after_multi_q)
);


endmodule