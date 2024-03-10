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
    $fsdbDumpfile("tb_selectIO.fsdb");
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
	
//module slect_io#(
//    parameter                       DW          = 4   ,
//    parameter                       SP_Mult     = 4            
//)
// (
//   input REFCLK_200m,
//   input clk_125M,
//	input i_rst,
//	
//	input i_dclk,
//   
//   //input serial 
//	input i_clk_p,
//   input i_clk_n,
//	input [DW-1 : 0] i_data_p,
//	input [DW-1 : 0] i_data_n,
//	
//   //output serial
//   output o_clk_p,
//   output o_clk_n,
//	output [DW-1 : 0]    o_data_p,
//	output [DW-1 : 0]    o_data_n,
//   
//   //oout inter logic
//   output               o_fclk,
//   output [DW*SP_Mult-1 : 0]          o_pardata,
//   //input inter logic
//   input  [DW*SP_Mult-1 : 0]          i_pardata,
//   
//   //iserdes/oserdes  loop
//   input  [DW-1 : 0] IFB,
//   output [DW-1 : 0] OFB
//	);

    select_io u_mselect_io(
	.REFCLK_200m(REFCLK_200m),
	.clk_125M(clk_125M),
	.i_rst(),
	.i_dclk(),
	.i_clk_p(),
	.i_clk_n(),
	.i_data_p(),
	.i_data_n(),
	.o_clk_p(),
	.o_clk_n(),
	.o_data_p(),
	.o_data_n(),
	.o_fclk(),
	.o_pardata(),
	.i_pardata(),
	.IFB(),
	.OFB()
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