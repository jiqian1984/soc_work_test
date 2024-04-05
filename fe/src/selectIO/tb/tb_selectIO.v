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
//`define DW 4
//`define SP_Mult 4 
`include "selectio.svh"
module tb_selectio();
//-----------------------------------------------------------------------------
// Dump fsdb file
//-----------------------------------------------------------------------------

//initial
//begin
//    $fsdbDumpoff;
//    //#50; //run 1250us, before start dump wave file
//    $fsdbDumpon;
//    $fsdbDumpfile("tb_selectIO.fsdb");
//    //$fsdbAutoSwitchDumpfile(800,"tb_cpri_serdes_top.fsdb",100); //file size 800M, 100 files total
//    $fsdbDumpvars;
//	$fsdbDumpMDA();
//end

always #10000 $display("Simluate time == %0dus",$time/1000);

glbl glbl();


//reg i_clk = 1'b0;
//reg reset_temp = 1'b0;
//wire rst_temp;
//wire          data_vld_temp;
//wire          data_ca_temp;
//wire [15:0]   data_i_temp;
//wire [15:0]   data_q_temp;
//wire [15:0]   sin_coff_temp;
//wire [15:0]   cos_coff_temp;
//wire          after_multi_vld;
//wire          after_multi_ca;
//wire [15:0]   after_multi_i;
//wire [15:0]   after_multi_q;


	reg REFCLK_200m = 1'b0;
	reg axi_clk_125m = 1'b0;
	reg i_dclk_500m = 1'b0;
//	reg rst_sys = 1'b1;
//	reg [`DW-1 : 0] i_bitslip = {(`DW){1'b0}};
//	reg [`DW-1 : 0] i_bitslip_slap1 = {(`DW){1'b0}};
//	reg [`DW*`SP_Mult-1 : 0] i_pardata = {(`DW*`SP_Mult){1'b0}};
//	reg [`DW*`SP_Mult-1 : 0] o_pardata_before = {(`DW*`SP_Mult){1'b0}};
	
	wire clk_p;
	wire clk_n;  
	wire [`DW-1 : 0] data_p;
	wire [`DW-1 : 0] data_n;
	
	wire [`DW*`SP_Mult-1 : 0] o_pardata;
	wire [`DW*`SP_Mult-1 : 0] i_pardata;
	wire [`DW*`SP_Mult-1 : 0] o_pardata_temp;
	wire o_fclk;
	wire o_dclk_div;
	wire rst_sys;
	wire  [`DW-1 : 0] i_bitslip;

	always #2.5 REFCLK_200m = ~REFCLK_200m;
	always #4 axi_clk_125m = ~axi_clk_125m;
	always #1 i_dclk_500m = ~i_dclk_500m;
	
	//always #1.0173 i_clk = ~i_clk;
	
    select_io  #(
	.DW(4),
	.SP_Mult(4)
	)u_select_io 
	(
	.REFCLK_200m(REFCLK_200m),
	.clk_125M(axi_clk_125m),
	.i_rst(rst_sys),

	.i_dclk(i_dclk_500m),
	.o_dclk_div(o_dclk_div),
	.i_pardata(i_pardata),

	.o_clk_p(clk_p),
	.o_clk_n(clk_n),
	.o_data_p(data_p),
	.o_data_n(data_n),

	.i_clk_p(clk_p),
	.i_clk_n(clk_n),
	.i_data_p(data_p),
	.i_data_n(data_n), 

	.i_bitslip(i_bitslip),
	.o_fclk(o_fclk),
	.o_pardata(o_pardata_temp),
	
	.IFB(4'b0000),
	.OFB()
	);
	generate 	
   	genvar slice_count;
	 for (slice_count = 0; slice_count < `DW; slice_count = slice_count + 1) begin: in_slices
        // This places the first data in time on the right
        assign o_pardata[slice_count]       =  o_pardata_temp[`DW*1-1-slice_count];
        assign o_pardata[`DW*1+slice_count] =  o_pardata_temp[`DW*2-1-slice_count];
        assign o_pardata[`DW*2+slice_count] =  o_pardata_temp[`DW*3-1-slice_count];
        assign o_pardata[`DW*3+slice_count] =  o_pardata_temp[`DW*4-1-slice_count];
        // To place the first data in time on the left, use the
        //   following code, instead
        // assign data_in_to_device2[slice_count] =
        //   iserdes_q[slice_count];
     end
	endgenerate
	test_selectio u_test_selectio
	(
	.i_dclk(i_dclk_500m),

    .o_rst(rst_sys),
	
   //oout inter logic
   .i_dclk_div		(o_dclk_div),
   .o_pardata		(i_pardata),
	//in-dir inter logic
   .o_bitslip	(i_bitslip),
   .i_fclk		(o_fclk),
   .i_pardata	(o_pardata)

	);

endmodule