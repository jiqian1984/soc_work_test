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
module tb_up122m_to_245m();
//-----------------------------------------------------------------------------
// Dump fsdb file
//-----------------------------------------------------------------------------

initial
begin
    $fsdbDumpoff;
    //#50; //run 1250us, before start dump wave file
    $fsdbDumpon;
    $fsdbDumpfile("tb_up122m_to_245m.fsdb");
    //$fsdbAutoSwitchDumpfile(800,"tb_cpri_serdes_top.fsdb",100); //file size 800M, 100 files total
    $fsdbDumpvars;
	$fsdbDumpMDA();//dump the memory in simulation
end

always #10000 $display("Simluate time == %0dus",$time/1000);

glbl glbl();


reg i_clk = 1'b0;
reg i_config_clk = 1'b0;

wire rst_temp;
wire          data_vld_temp;
wire          data_ca_temp;
wire [15:0]   data_temp;

wire          config_rst;
wire          load_parameter;
wire [15:0]   parameter_data;

wire          after_filter_vld;
wire          after_filter_ca;
wire [15:0]   after_filter_data;


//always #4ns i_clk = ~i_clk;
//always #4ns slowclk = ~slowclk;
//always #4 clk_125m = ~clk_125m;
always #1.0173 i_clk = ~i_clk;
always #10 i_config_clk = ~i_config_clk;
//always #1.63 clk_b = ~clk_b;

   up122m_to_245m u_up122m_to_245m(
	.i_clk(i_clk),
	.i_rst(rst_temp),
	.i_data_vld(data_vld_temp),
	.i_data_ca(data_ca_temp),
	.i_data(data_temp),
	
	.i_config_clk(i_config_clk),
	.i_config_rst(config_rst),
	.i_load_parameter(load_parameter),
	.i_parameter_data(parameter_data),
	
	.o_data_vld(after_filter_vld),
	.o_data_ca(after_filter_ca),
	.o_data(after_filter_data)
	
	
);

    test_upsample_filter u_test_upsample_filter(
    .i_clk(i_clk),
	.o_rst(rst_temp),
    .o_data_vld(data_vld_temp),
	.o_data_ca(data_ca_temp),
	.o_data(data_temp),
	
	.i_config_clk(i_config_clk), 
	.o_config_rst(config_rst), 
	.o_load_parameter(load_parameter), 
	.o_parameter_data(parameter_data),
	
	.i_data_vld(after_filter_vld),
	.i_data_ca(after_filter_ca),
	.i_data(after_filter_data)
);


endmodule