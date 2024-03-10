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
`define WIDTH 5
module dual_ram #(
parameter DWA = 16,
parameter AWA = 4,
parameter DWB = 16,
parameter AWB = 4,
parameter MULTNUM = 1
)
(

	input            fastclk_a,
	input            rst_a,
	
	input  [DWA-1:0] i_data_a,
	input  [AWA-1:0] i_addr_a,
	input            i_wr_en_a,
	output [DWA-1:0] o_data_a,
	
	input            clk_b,
	input            rst_b,
	
	input  [DWB-1:0]  i_data_b,
	input  [AWB-1:0]  i_addr_b,
	input             i_wr_en_b,
	output [DWB-1:0]  o_data_b
	
);

reg [DWA-1:0] memory_whole [calculate_2N(AWA)-1:0];
reg [DWA-1:0] o_data_a_reg;
integer       ADDR_VALUE_A;


reg [DWB-1:0] memory_b [15:0];
reg [AWB-1:0] addr_b   [15:0];
reg [DWA-1:0] datareg_b [calculate_2N(AWA-AWB)-1:0];
reg [AWA-AWB-1:0] count_low;
//reg [AWA-1:0] addrreg_b [calculate_2N():0];


    
reg [DWB-1:0] memory_b [15:0];
reg [AWB-1:0] addr_b [15:0];
reg [DWB-1:0] o_data_b_reg;
reg [3:0]     addr_b_grey;
reg [3:0]     addr_b_grey_reg1;
reg [3:0]     addr_b_grey_reg2;
integer       ADDR_VALUE_B;

reg [AWA-1:0] i_addr_a_reg1;
reg [AWA-1:0] i_addr_a_reg2;
reg           i_wr_en_a_reg1;
reg           i_wr_en_a_reg2;
reg           i_wr_en_b_reg1;
reg           i_wr_en_b_reg2;
reg           wra_wrb_confilct;
reg [DWB-1:0] memory_atob_reg;

wire conncet_type;
	
integer addra_i;
integer addrb_i;

//function calculate 2^N;
function integer calculate_2N;
input integer bits_wide;
integer bits_i;
begin
    if(bits_wide = 0) begin
	    calculate_2N = 1;
	end
	else begin
	    for(bits_i = 0;bits_i < bits_wide;bits_i = bits_i + 1)
	    begin
	        calculate_2N = calculate_2N * 2;
	    end
	end
end 
endfunction 

//function calculate the data width (DWB is multi DWA);
function integer calculate_datawide;
input  integer  wide_a;
input  integer  wide_b;
begin
    calculate_datawide = wide_b / wide_a;
end 
endfunction 


//port A operation
always@(posedge rst_a or posedge fastclk_a)
begin
    if(rst_a == 1'b1) begin
	    o_data_a_reg <= {(DWA-1){1'b0}};
		ADDR_VALUE_A <= calculate_2N(DWA);
	    for(addra_i=0;addra_i < ADDR_VALUE_A;addra_i = addra_i + 1)
	    begin
	        memory_whole[addra_i] <= {{(DWA-2){1'b0}},1'b0};
	    end
	end 
	else begin
	    if(fastclk_a == 1'b1) begin
		    //write A
		    if(i_wr_en_a == 1'b1) begin
			    memory_whole[i_addr_a] <= i_data_a;
			end 
			//read A
			else begin
			    o_data_a_reg <= memory_whole[i_addr_a];
			end
		end 
	end
end
//output drive
assign o_data_a = o_data_a_reg;




generate
genvar i;
    for(i = 0;i < MULTNUM;i <= i + 1)
	begin : gen_read
        datareg_b[i] <= memory_b[addr_b_grey_before][((i+1)*DWA-1):(i)*DWA];
	end
endgenerate
//data and signal cross clock domain A to domain B(clk_a -> clk_b)
always@(posedge rst_a or posedge fastclk_a)
begin
    if(rst_a == 1'b1) begin
	    addr_b_grey_reg1 <= {(4){1'b0}};
	    addr_b_grey_reg2 <= {(4){1'b0}};
		i_addr_a_reg1 <= {(AWA){1'b0}};
		i_addr_a_reg2 <= {(AWA){1'b0}};
		i_wr_en_a_reg1 <= 1'b0;
		i_wr_en_a_reg2 <= 1'b0;
		i_wr_en_b_reg1 <= 1'b0;
		i_wr_en_b_reg2 <= 1'b0;
		memory_atob_reg <= {(DWB){1'b0}};
	    wra_wrb_confilct <= 1'b0;
	end
	else begin
	    if(fastclk_a == 1'b1) begin
		    //delay2,cross clock domain 
		    addr_b_grey_reg1 <= addr_b_grey;
			addr_b_grey_reg2 <= addr_b_grey_reg1;
			//trans the grey to normal
			
			i_wr_en_b_reg1 <= i_wr_en_b;
			i_wr_en_b_reg2 <= i_wr_en_b_reg1;
			
			i_wr_en_a_reg2 <= i_wr_en_a;
			i_wr_en_a_reg2 <= i_wr_en_a_reg1;
			
			i_addr_a_reg1 <= i_addr_a;
			i_addr_a_reg2 <= i_addr_a_reg1;
			//judge the addr_b input is confilct of addr_a input,
			if(addr_a_grey != addr_b_grey_reg2) begin
			    case(addr_a_grey)
				    4'b0000 : addr_a_grey <= 4'b0001;
					4'b0001 : addr_a_grey <= 4'b0011;
					4'b0011 : addr_a_grey <= 4'b0010;
					4'b0010 : addr_a_grey <= 4'b0110;
					4'b0110 : addr_a_grey <= 4'b0111;
					4'b0111 : addr_a_grey <= 4'b0101;
					4'b0101 : addr_a_grey <= 4'b1101;
					4'b1101 : addr_a_grey <= 4'b1111;
					4'b1111 : addr_a_grey <= 4'b1110;
					4'b1110 : addr_a_grey <= 4'b1100;
					4'b1100 : addr_a_grey <= 4'b1101;
					4'b1101 : addr_a_grey <= 4'b1001;
					4'b1001 : addr_a_grey <= 4'b1011;
					4'b1011 : addr_a_grey <= 4'b1010;
					4'b1010 : addr_a_grey <= 4'b1110;
					4'b1010 : addr_a_grey <= 4'b1110;
				endcase;
			end
			else begin
			    addr_a_grey <= addr_a_grey;
			end 
			
			if(((i_wr_en_b_reg2 == 1'b1) && (i_wr_en_a_reg2 != 1'b1)) || ((i_wr_en_b_reg2 == 1'b1) && (i_wr_en_a_reg2 == 1'b1) && (addr_b[addr_a_grey] != i_addr_a_reg2))) begin
				if(count_low < MULTNUM) begin
				    count_low <= count_low + 1;
					memory_whole[{addr_b[addr_b_grey_reg2],count_low}] <= datareg_b[count_low];
				end
				else begin
				    count_low <= {};
				end
				//memory_whole[{addr_b[addr_b_grey_reg2],count_low}] <= memory_b[addr_b_grey_reg2][(DWA-1):0];
				wra_wrb_confilct <= 1'b0;
			end
			else begin
			    if((i_wr_en_b_reg2 == 1'b1) && (i_wr_en_a_reg2 == 1'b1) && (addr_b[addr_b_grey_reg2] == i_addr_a_reg2)) begin
				    wra_wrb_confilct <= 1'b1;
				end 
				else begin
				    
				    wra_wrb_confilct <= 1'b0;
				end 
			end
		end
	end
end

generate
genvar i;
    for(i = 0;i < MULTNUM;i <= i + 1)
	begin : gen_read
        memory_atob_reg[i*DWA-1:(i-1)*DWA] <= memory_regb[MULTNUM];
	end
endgenerate

//port B operation,has 16 input buffer,
always@(posedge rst_b or posedge clk_b)
begin
    if(rst_a == 1'b1) begin
	    o_data_b_reg <= {(DWB-1){1'b0}};
		//ADDR_VALUE_B <= calculate_2N(DWB);
	    for(addrb_i=0;addrb_i < 16;addrb_i = addrb_i + 1)
	    begin
	        memory_b[addrb_i] <= {(DWB-1){1'b0}};
	    end
		addr_b_grey <= 4'b0000;
		addr_b_grey_before <= 4'b0000;
	end 
	else begin
	    if(clk_b == 1'b1) begin
		    //write A
		    if(i_wr_en_b == 1'b1) begin
			    //for(count_b=0;count_b<MULTNUM;count_b = count_b + 1)
				//begin
				//    memory_b[addr_b_grey][] <= i_data_b[((count_b+1)*DWA-1):(count_b)*DWA]
				//end
				addr_b_grey_before <= addr_b_grey;
			    memory_b[addr_b_grey] <= i_data_b;
				addr_b[addr_b_grey] <= i_addr_b;
				//grey code ++
				case(addr_b_grey)
				    4'b0000 : addr_b_grey <= 4'b0001;
					4'b0001 : addr_b_grey <= 4'b0011;
					4'b0011 : addr_b_grey <= 4'b0010;
					4'b0010 : addr_b_grey <= 4'b0110;
					4'b0110 : addr_b_grey <= 4'b0111;
					4'b0111 : addr_b_grey <= 4'b0101;
					4'b0101 : addr_b_grey <= 4'b1101;
					4'b1101 : addr_b_grey <= 4'b1111;
					4'b1111 : addr_b_grey <= 4'b1110;
					4'b1110 : addr_b_grey <= 4'b1100;
					4'b1100 : addr_b_grey <= 4'b1101;
					4'b1101 : addr_b_grey <= 4'b1001;
					4'b1001 : addr_b_grey <= 4'b1011;
					4'b1011 : addr_b_grey <= 4'b1010;
					4'b1010 : addr_b_grey <= 4'b1110;
					4'b1010 : addr_b_grey <= 4'b1110;
				endcase;
			end 
			//read A
			else begin
			    o_data_b_reg <= memory_atob_reg;
			end
		end 
	end
end

//output drive
assign o_data_b <= o_data_b_reg;
	
	
end module : dual_ram	