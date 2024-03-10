//-----------------------------------------------------------------------------
// Title    : xbit_shift
// Project  : 
// Author   : Author:
// Revision : Revision: 1.0
// Date     : Date:
//-----------------------------------------------------------------------------
// Description  : 
//-----------------------------------------------------------------------------
// Copyright (C) Nokia Siemens Networks
// All rights reserved. Reproduction in whole or part is prohibited
// without the written permission of the copyright owner.
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps
module xbit_shift #(
parameter DW = 1,
parameter SHIFT_NUM = 1
)
(

	input            i_clk,
	input            i_rst,
	
	input  [DW-1:0] i_data,
	output [DW-1:0] o_data
	
);

reg [DW-1:0] memory_whole[1:SHIFT_NUM];

//port A operation
always@(posedge i_rst or posedge i_clk)
begin
    if(i_rst == 1'b1) begin
	    //o_data_a_reg <= {(DWA-1){1'b0}};
		//ADDR_VALUE_A <= calculate_2N(DWA);
	    for(int addra_i=0;addra_i < SHIFT_NUM;addra_i = addra_i + 1)
	    begin
	        memory_whole[addra_i] <= {(DW){1'b0}};
	    end
	end 
	else begin
	    if(i_clk == 1'b1) begin
		    memory_whole[1] <= i_data;
	        for(int addra_i=2;addra_i <= SHIFT_NUM;addra_i = addra_i + 1)
	        begin
	            memory_whole[addra_i] <= memory_whole[addra_i-1];
	        end 
		end 
	end
end
//output drive
assign o_data = memory_whole[SHIFT_NUM];


endmodule	