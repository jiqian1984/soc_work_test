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
`define WIDTH 5
module up245m_to_491m
(
	input   i_clk,
	input   i_rst,
	
	//input of data,at 245M sample
	input          i_data_vld,
	input          i_data_ca,
	input [15:0]   i_data,
	
	output         o_data_vld,
	output         o_data_ca,
	output [15:0]  o_data,
	
	//filter config
	input   i_config_clk,
	input   i_config_rst,
	input   i_load_parameter,
	input  [15:0] i_parameter_data
);

    //interpolation,every two sample interpolate one point;
	always @(negedge i_rst or posedge i_clk)
	begin
	    if(i_rst == 1'b1) begin
			count4_2bit <= 2'b00;
			data_vld_temp <= 1'b0;
			data_temp <= 16'h0000;
			data_temp_reg1 <= 16'h0000;
		end
		else begin
		    if(i_clk == 1'b1) begin
			    //count the data ,every two sample ,add one 
			    if(i_data_ca == 1'b1 and i_data_vld == 1'b1)
				    count4_2bit <= 2'b00;
				else
				    count4_2bit <= count4_2bit + 1;
				//extend the vld;
				case(count4_2bit)
				    2'b00 : data_vld_temp <= 1'b1;
					2'b01 : data_vld_temp <= 1'b1;
					default : data_vld_temp <= 1'b0;
				endcase;
				//delay the data by 2 clk, align at data_vld_temp;
                data_temp <= i_data;
                data_temp_reg1 <= data_temp;				
			end
		end
	end
    
	//put the data in filter, to adapt the freq response of input signal;
	direct_fir_filter #(
		.W1(16),
		.W2(32),
		.W3(33),
		.W4(18),
		.L(16),
		.Mpipe(3)
	)
    u_firect_fir_filter_50M(
	.clk_in(i_clk),
	.reset_in(i_rst),
		
	.load_x_in(data_vld_temp),
	.data_x_in(data_temp_reg1),
	.load_parameter_in(i_load_parameter),
	.data_h_parameter_in(i_parameter_data),
		
	.data_y_out(data_after_filter_temp)
	);
	
	//delay vld,and ca to align at data_after_filter_temp;
	

end module : up122m_to_245m	