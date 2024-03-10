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
//                step1 caluate input_i * cos, and input_i * sin
//                step2 caluate input_q * sin (cascade is "input_i * cos"); input_q*sin (cascade is "input_i * sin");
//-----------------------------------------------------------------------------
// Copyright (C) Nokia Siemens Networks
// All rights reserved. Reproduction in whole or part is prohibited
// without the written permission of the copyright owner.
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps
`define WIDTH 5
module multi_freq(
	input i_clk,
	input i_reset,
	
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



wire [29:0] data_a_i_step1;
wire [17:0] data_b_i_step1;
wire [47:0] p_i_step1;
wire [29:0] data_a_i_step2;
wire [17:0] data_b_i_step2;
wire [47:0] p_i_step2;


wire [29:0] data_a_q_step1;
wire [17:0] data_b_q_step1;
wire [47:0] p_q_step1;
wire [29:0] data_a_q_step2;
wire [17:0] data_b_q_step2;
wire [47:0] p_q_step2;

reg [15:0] data_q_delay;
reg [15:0] cos_coff_delay;
reg [15:0] sin_coff_delay;

    assign data_a_i_step1 = {{(14){i_data_i[15]}},i_data_i};     
	assign data_b_i_step1 = {{(2){i_cos_coff[15]}},i_cos_coff}; 
    //step 1: input_q * sin
	basic_dsp_module #(
    .MODE(4'd0),
    .AW(30),
    .BW(18),
    .CW(48),
    .DW(25)
    ) 
	i_step1_mult(
    .i_clk(i_clk),
	.i_rst(i_reset),
	.dsp_mode(4'd0),
	.i_data_a(data_a_i_step1),
	.i_data_b(data_b_i_step1),
	.i_data_c(48'd0),
	.i_data_d(25'd0),
	.i_pre_carry(1'b0),
	.i_pcin(48'd0),
	.o_pcout(),
	.o_p(p_i_step1)
	);

    always@(negedge i_reset or posedge i_clk)
	begin
	    if(i_reset == 1'b1) begin
			data_q_delay <= {(16){1'b0}};
			sin_coff_delay <= {(16){1'b0}};
			cos_coff_delay <= {(16){1'b0}};
		end
		else begin
		    if(i_clk == 1'b1 ) begin
			    data_q_delay <= i_data_q;
				sin_coff_delay <= i_sin_coff;
				cos_coff_delay <= i_cos_coff;
			end 
		end 
		
	end
    //delay   i_data_i  and cos_coff to the step2
	//xbit_shift #(
    //.DW(16),
    //.SHIFT_NUM(1)
    //)
    //i_data_i_delay(
    //.i_clk(i_clk),
    //.i_rst(i_reset),
    //.i_data(i_data_q),
    //.o_data(data_q_delay)
	//);
	//
	//xbit_shift #(
    //.DW(16),
    //.SHIFT_NUM(1)
    //)
    //i_cos_coff_delay(
    //.i_clk(i_clk),
    //.i_rst(i_reset),
    //.i_data(i_sin_coff),
    //.o_data(sin_coff_delay)
	//);
	
    assign data_a_i_step2 = {{(14){data_q_delay[15]}},data_q_delay}; 
	assign data_b_i_step2 = {{(2){sin_coff_delay[15]}},sin_coff_delay}; 

    basic_dsp_module #(
    .MODE(4'd1),
    .AW(30),
    .BW(18),
    .CW(48),
    .DW(25)
    )
    i_step2_mult(
    .i_clk(i_clk),
	.i_rst(i_reset),
	.dsp_mode(4'd1),
	.i_data_a(data_a_i_step2),
	.i_data_b(data_b_i_step2),
	.i_data_c(48'd0),
	.i_data_d(25'd0),
	.i_pre_carry(1'b0),
	.i_pcin(p_i_step1),
	.o_pcout(),
	.o_p(p_i_step2)
	);


    //q operation,as the same as i
    assign data_a_q_step1 = {{(14){i_data_i[15]}},i_data_i};     
	assign data_b_q_step1 = {{(2){i_sin_coff[15]}},i_sin_coff}; 
    basic_dsp_module #(
    .MODE(4'd0),
    .AW(30),
    .BW(18),
    .CW(48),
    .DW(25)
    )
    q_step1_mult(
    .i_clk(i_clk),
	.i_rst(i_reset),
	.dsp_mode(4'd0),
	.i_data_a(data_a_q_step1),
	.i_data_b(data_b_q_step1),
	.i_data_c(48'd0),
	.i_data_d(25'd0),
	.i_pre_carry(1'b0),
	.i_pcin(48'd0),
	.o_pcout(),
	.o_p(p_q_step1)
	);

    //delay   i_data_i and sin_coff to the step2
	
	//xbit_shift #(
    //.DW(16),
    //.SHIFT_NUM(1)
    //)
    //i_sin_coff_delay(
    //.i_clk(i_clk),
    //.i_rst(i_reset),
    //.i_data(i_cos_coff),
    //.o_data(cos_coff_delay)
	//);
	
    assign data_a_q_step2 = {{(14){data_q_delay[15]}},data_q_delay};     
	assign data_b_q_step2 = {{(2){cos_coff_delay[15]}},cos_coff_delay};
    basic_dsp_module #(
    .MODE(4'd2),
    .AW(30),
    .BW(18),
    .CW(48),
    .DW(25)
    )
    q_step2_mult(
    .i_clk(i_clk),
	.i_rst(i_reset),
	.dsp_mode(4'd2),
	.i_data_a(data_a_q_step2),
	.i_data_b(data_b_q_step2),
	.i_data_c(48'd0),
	.i_data_d(25'd0),
	.i_pre_carry(1'b0),
	.i_pcin(p_q_step1),
	.o_pcout(),
	.o_p(p_q_step2)
	);


     	
	// output drive:rnd the step2 result,generate the final result
	//assign o_data_i = (p_i_step2[47]) ?  {p_i_step2[47],15'h7fff}: {p_i_step2[47],p_i_step2[24:10]};
	assign o_data_i = {p_i_step2[47],p_i_step2[24:10]};
	assign o_data_q = {p_q_step2[47],p_q_step2[24:10]};
	//assign o_data_q = (p_q_step2[25]) ?  {p_q_step2[47],15'h7fff}: {p_q_step2[47],p_q_step2[24:10]};
	
	//assign o_data_i = p_i_step2;
	//assign o_data_q = p_q_step2;
	//delay vld,ca
	xbit_shift #(
    .DW(1),
    .SHIFT_NUM(4)
    )
    data_vld_delay(
    .i_clk(i_clk),
    .i_rst(i_reset),
    .i_data(i_data_vld),
    .o_data(o_data_vld)
	);
	
	xbit_shift #(
    .DW(1),
    .SHIFT_NUM(4)
    )
    data_ca_delay(
    .i_clk(i_clk),
    .i_rst(i_reset),
    .i_data(i_data_ca),
    .o_data(o_data_ca)
	);
	
endmodule : multi_freq	