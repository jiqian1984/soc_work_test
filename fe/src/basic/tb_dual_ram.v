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
module tb_dual_ram();
//-----------------------------------------------------------------------------
// Dump fsdb file
//-----------------------------------------------------------------------------

initial
begin
    $fsdbDumpoff;
    //#50; //run 1250us, before start dump wave file
    $fsdbDumpon;
    $fsdbDumpfile("tb_dual_ram.fsdb");
    //$fsdbAutoSwitchDumpfile(800,"tb_cpri_serdes_top.fsdb",100); //file size 800M, 100 files total
    $fsdbDumpvars;
	$fsdbDumpMDA();
end

always #10000 $display("Simluate time == %0dus",$time/1000);

//glbl glbl();
parameter AWA = 5;
parameter DWA = 16;
parameter AWB = 5;
parameter DWB = 16;
parameter MULTNUM = 1;

reg fastclk = 1'b0;
reg slowclk = 1'b0;
wire rst_a;
wire rst_b;
wire        wren_a;
wire [DWA-1:0] wrdata_a;
wire [DWA-1:0] rddata_a;
wire [AWA-1:0] addr_a;
wire        wren_b;
wire [DWB-1:0] wrdata_b;
wire [DWB-1:0] rddata_b;
wire [AWB-1:0] addr_b;

always #4ns fastclk = ~fastclk;
always #4ns slowclk = ~slowclk;
//always #4 clk_125m = ~clk_125m;
//always #1.0173 clk_trx = ~clk_trx;
//always #1.63 clk_b = ~clk_b;

    dual_ram #(
		.AWA(AWA),
		.DWA(DWA),
		.AWB(AWB),
		.DWB(DWB),
		.MULTNUM(MULTNUM)
	)
    u_dual_ram(
	.fastclk_a(fastclk),
	.rst_a(rst_a),
		
	.i_data_a(wrdata_a),
	.i_addr_a(addr_a),
	.i_wr_en_a(wren_a),
	.o_data_a(rddata_a),
		
	
	.clk_b(slowclk),
	.rst_b(rst_b),
		
	.i_data_b(wrdata_b),
	.i_addr_b(addr_b),
	.i_wr_en_b(wren_b),
	.o_data_b(rddata_b)
	
	);

    test_dual_ram u_test_dual_ram 
	(
    .i_clk_a(fastclk),
	.o_rst_a(rst_a),
	
	.o_wrdata_a(wrdata_a),
    .o_addr_a(addr_a),
    .o_wr_en_a(wren_a),
	.i_rddata_a(rddata_a),
	//2.portb
    .i_clk_b(slowclk),
	.o_rst_b(rst_b),
	
	.o_wrdata_b(wrdata_b),
    .o_addr_b(addr_b),
    .o_wr_en_b(wren_b),
	.i_rddata_b(rddata_b)
	
    );


endmodule