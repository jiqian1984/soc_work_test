//-----------------------------------------------------------------------------
// Title    : basic dual_ram
// Project  : 
// Author   : Author:
// Revision : Revision: 1.0
// Date     : Date:
//-----------------------------------------------------------------------------
// Description  : This is a basic dual_ram module.For simplifying the design, it constraint the clk_a is the fast clk.
//-----------------------------------------------------------------------------
// Copyright (C) Nokia Siemens Networks
// All rights reserved. Reproduction in whole or part is prohibited
// without the written permission of the copyright owner.
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps
module basic_dds 
(

	input            i_clk,
	input            i_rst,
	
	input  [31:0]    i_data,
	input            i_we,
	input            i_ce,
	
	output [15:0]    sine,
	output [15:0]    cose
);

reg [31:0] ADD_A;
reg [31:0] ADD_B;
reg [15:0] cose_DR;
reg [15:0] sine_DR;

wire [31:0]    data;
wire [9:0]     ROM_A;
wire [15:0]    cose_D;
wire [15:0]    sine_D;

assign cose = cose_DR;
assign sine = sine_DR;
assign ROM_A = ADD_B[31 : 22];

always@(posedge i_clk or posedge i_rst)
begin
    if(i_rst == 1'b1) begin
	    ADD_A <= 0;
	end
	else begin
	    ADD_A <= i_data;
	end
end 

always@(posedge i_clk or posedge i_rst)
begin
    if(i_rst == 1'b1) begin
	    ADD_B <= 0;
	end
	else begin
	    ADD_B <= ADD_B + ADD_A;
	end
end 

always@(posedge i_clk or posedge i_rst)
begin
    if(i_rst == 1'b1) begin
	    cose_DR <= 0;
	end
	else begin
	    cose_DR <= cose_D;
	end
end 

always@(posedge i_clk or posedge i_rst)
begin
    if(i_rst == 1'b1) begin
	    sine_DR <= 0;
	end
	else begin
	    sine_DR <= sine_D;
	end
end 

rom_cose cose1(
.addra(ROM_B),
.clka(i_clk),
.douta(cose_D)
);

rom_sine sine1(
.addra(ROM_B),
.clka(i_clk),
.douta(sine_D)
);


endmodule	