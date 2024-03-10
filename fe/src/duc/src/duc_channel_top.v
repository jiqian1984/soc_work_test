//-----------------------------------------------------------------------------
// Title    : CPRI SerDes Top Test Bench
// Project  : CPRI
// Author   : Author:
// Revision : Revision: 1.0
// Date     : Date:
//-----------------------------------------------------------------------------
// Description  : freq multi,using the below foundation:
//                modulate_i = input_i * cos - input_q * sin;
//                modulate_q = input_i * sin + input_q * cos;
//                use two cascade setp,b9.b6 float
//                step1 caluate input_q * sin, and input_q * cos
//                step2 caluate input_i * cos (cascade is "-input_q*sin"); input_i_sin (cascade is "+input_q*cos");
//-----------------------------------------------------------------------------
// Copyright (C) Nokia Siemens Networks
// All rights reserved. Reproduction in whole or part is prohibited
// without the written permission of the copyright owner.
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps
`define WIDTH 5
module duc_channel(
	input i_clk,
	input i_reset,
	
	//input filter coffei interface
	input          i_config_clk,
	input          i_config_rst,
	input          load_parameter_firstfilter_in,
	input          load_parameter_122to245m_in,
	input          load_parameter_245to491m_in,
	input [15 : 0] i_parameter_data,
	
	//input data: i & q;
	input          i_data_vld,
	input          i_data_ca,
	input  [15:0]  i_data_i,
	input  [15:0]  i_data_q,
	
	//input the multi frea sin & cos in
	input  [15:0]  i_sin_coff,
	input  [15:0]  i_cos_coff,
	
	//output data: i & q
	output         o_data_vld,
	output         o_data_ca,
	output [15:0]  o_data_i,
	output [15:0]  o_data_q
	
);

wire        data_vld_afterfilter;
wire        data_ca_afterfilter;
wire [15:0] data_i_afterfilter;
wire [15:0] data_q_afterfilter;

wire        data_vld_up245m;
wire        data_ca_up245m;
wire [15:0] data_i_up245m;
wire [15:0] data_q_up245m;

wire        data_vld_aftermulti;
wire        data_ca_aftermulti;
wire [15:0] data_i_aftermulti;
wire [15:0] data_q_aftermulti;

wire        data_vld_up491m;
wire        data_ca_up491m;
wire [15:0] data_i_up491m;
wire [15:0] data_q_up491m;

    //--------------step1: input data through filter of(xM),channel_i
	direct_fir_filter #(
		.W1(16),
		.W2(32),
		.W3(33),
		.W4(18),
		.L(16),
		.Mpipe(3)
	)
    channel_i_fir_filter_50M(
	.clk_in(i_clk),
	.reset_in(i_reset),

	.i_config_clk(i_config_clk),
	.i_config_rst(i_config_rst),	

	.load_x_in(i_data_vld),
	.data_x_in(i_data_i),
	.data_h_parameter_in(i_parameter_data),
	.load_parameter_in(load_parameter_firstfilter_in),
		
	.data_y_out(data_i_afterfilter)
	);

	//channel_q
	direct_fir_filter #(
		.W1(16),
		.W2(32),
		.W3(33),
		.W4(18),
		.L(16),
		.Mpipe(3)
	)
    channel_q_fir_filter_50M(
	.clk_in(i_clk),
	.reset_in(i_reset),
		
	.i_config_clk(i_config_clk),
	.i_config_rst(i_config_rst),

	.load_x_in(i_data_vld),
	.data_x_in(i_data_q),
	.data_h_parameter_in(i_parameter_data),
	.load_parameter_in(load_parameter_firstfilter_in),
		
	.data_y_out(data_q_afterfilter)
	);
	
	///////delay vld and ca to aglin with after filter data .
    xbit_shift #(
    .DW(1),
    .SHIFT_NUM(36)
    )
    data_vld_delay(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(i_data_vld),
    .o_data(data_vld_afterfilter)
	);
	
	xbit_shift #(
    .DW(1),
    .SHIFT_NUM(37)
    )
    data_ca_delay(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(i_data_ca),
    .o_data(data_ca_afterfilter)
	);


	//--------------step 2: up122m_to_245m
    up122m_to_245m channel_i_up122m_to_245m
    (
	.i_clk(i_clk),
	.i_rst(i_reset),
	
	//input of data,at 122M sample
	.i_data_vld(data_vld_afterfilter),
	.i_data_ca(data_ca_afterfilter),
	.i_data(data_i_afterfilter),
	
	.o_data_vld(data_vld_up245m),
	.o_data_ca(data_ca_up245m),
	.o_data(data_i_up245m),
	
	//filter config
	.i_config_clk(i_config_clk),
	.i_config_rst(i_config_rst),
	.i_load_parameter(load_parameter_122to245m_in),
	.i_parameter_data(i_parameter_data)
    );
    
	up122m_to_245m channel_q_up122m_to_245m
    (
	.i_clk(i_clk),
	.i_rst(i_reset),
	
	//input of data,at 122M sample
	.i_data_vld(data_vld_afterfilter),
	.i_data_ca(data_ca_afterfilter),
	.i_data(data_q_afterfilter),
	
	.o_data_vld(),
	.o_data_ca(),
	.o_data(data_q_up245m),
	
	//filter config
	.i_config_clk(i_config_clk),
	.i_config_rst(i_config_rst),
	.i_load_parameter(load_parameter_122to245m_in),
	.i_parameter_data(i_parameter_data)
    );

	//--------------step 3: multi the carrier data to mid freq
	multi_freq u_multi_freq(
	.i_clk(i_clk),
	.i_reset(i_reset),
	
	//input data: i & q;
	.i_data_vld(data_vld_up245m),
	.i_data_ca(data_ca_up245m),
	.i_data_i(data_i_up245m),
	.i_data_q(data_q_up245m),
	
	//input the multi frea sin & cos in
	.i_sin_coff(i_sin_coff),
	.i_cos_coff(i_cos_coff),
	
	//output data: i & q
	.o_data_vld(data_vld_aftermulti),
	.o_data_ca(data_ca_aftermulti),
	.o_data_i(data_i_aftermulti),
	.o_data_q(data_q_aftermulti)
	
    );
    
	//--------------step 4: up 245 to 491M
	up245m_to_491m channel_i_up245m_to_491m
    (
	.i_clk(i_clk),
	.i_rst(i_reset),
	
	//input of data,at 122M sample
	.i_data_vld(data_vld_aftermulti),
	.i_data_ca(data_ca_aftermulti),
	.i_data(data_i_aftermulti),
	
	.o_data_vld(data_vld_up491m),
	.o_data_ca(data_ca_491m),
	.o_data(data_i_up491m),
	
	//filter config
	.i_config_clk(i_config_clk),
	.i_config_rst(i_config_rst),
	.i_load_parameter(load_parameter_245to491m_in),
	.i_parameter_data(i_parameter_data)
    );
	
	up245m_to_491m channel_q_up245m_to_491m
    (
	.i_clk(i_clk),
	.i_rst(i_reset),
	
	//input of data,at 122M sample
	.i_data_vld(data_vld_aftermulti),
	.i_data_ca(data_ca_aftermulti),
	.i_data(data_q_aftermulti),
	
	.o_data_vld(),
	.o_data_ca(),
	.o_data(data_q_up491m),
	
	//filter config
	.i_config_clk(i_config_clk),
	.i_config_rst(i_config_rst),
	.i_load_parameter(load_parameter_245to491m_in),
	.i_parameter_data(i_parameter_data)
    );

	//----------------------------rnd the step2 result,generate the final result
	always@(negedge i_reset or posedge i_clk)
	begin
	    if(i_reset == 1'b1) begin
			o_data_i <= {(16){1'b0}};
			o_data_q <= {(16){1'b0}};
			o_data_vld <= 1'b0;
			o_data_ca <= 1'b0;
		end
		else begin
		    if(i_clk == 1'b1 ) begin
			    o_data_i <= data_i_up491m;
				o_data_q <= data_q_up491m;
			    o_data_vld <= data_vld_up491m;
			    o_data_ca <= data_ca_491m;
			end 
		end 
	end
	
end module : duc_channel	