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

reg [DWA-1:0] memory_whole [15:0];
reg [DWA-1:0] o_data_a_reg;
integer       ADDR_VALUE_A;

reg [DWB-1:0] o_data_b_reg;
reg [DWB-1:0] memory_b [15:0];
reg [AWB-1:0] addr_b [15:0];
reg [3:0]     count_b;
wire [3:0]    count_b_gray;
reg [3:0 ]    count_b_gray_reg1;
reg [3:0 ]    count_b_gray_reg2;
reg           i_wr_en_b_reg1;
reg           i_wr_en_b_reg2;
reg           i_wr_en_b_reg3;
reg           i_wr_en_b_reg4;
integer       memoryb_wraddr_low;
reg [3:0]     memoryb_rdaddr;
wire [3:0]    memoryb_rdaddr_gray;
reg [AWA-1:0] memory_whole_wraddr;
reg [AWA-1:0] memory_whole_rdaddr;

reg [DWA-1:0] memory_atob_reg[MULTNUM-1:0];
wire [DWB-1:0] memory_atob;
wire [DWA-1:0] memory_btoa[MULTNUM-1:0];
reg [DWA-1:0] memory_btoa_DWA;

//function calculate 2^N;
function integer calculate_2N;
input integer bits_wide;
integer bits_i;
begin
    if(bits_wide == 0) begin
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

integer addra_i;
//port A operation
always@(posedge rst_a or posedge fastclk_a)
begin
    if(rst_a == 1'b1) begin
	    o_data_a_reg <= {(DWA-1){1'b0}};
		//ADDR_VALUE_A <= calculate_2N(DWA);
	    for(addra_i=0;addra_i < calculate_2N(AWA);addra_i = addra_i + 1)
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

integer addrb_i;
//port B operation,has 16 input buffer,
always@(posedge rst_b or posedge clk_b)
begin
    if(rst_a == 1'b1) begin
	    o_data_b_reg <= {(DWB-1){1'b0}};
		//ADDR_VALUE_B <= calculate_2N(DWB);
	    for(addrb_i=0;addrb_i < 16;addrb_i = addrb_i + 1)
	    begin
	        memory_b[addrb_i] <= {(DWB-1){1'b0}};
			addr_b[addrb_i] <= {(AWB-1){1'b0}};
	    end
		count_b <= 0;
	end 
	else begin
	    if(clk_b == 1'b1) begin
		    if((i_wr_en_b == 1'b1) || (i_wr_en_b_reg4 == 1'b0)) begin
		        if(count_b < 16)
			        count_b <= count_b + 1;
			    else
				    count_b <= 0;
                addr_b[count_b]	<= 	i_addr_b;
			end
			
		    //write A
		    if(i_wr_en_b == 1'b1) begin
				memory_b[count_b] <= i_data_b;
			end
			//read A
			else begin
			    o_data_b_reg <= memory_atob;
			end
		end 
	end
end

assign count_b_gray = count_b ^ (count_b >> 1);
//output drive
assign o_data_b = o_data_b_reg;


//generate
//genvar i;
//    for(i = 0;i < MULTNUM;i <= i + 1)
//	begin : gen_read
//        datareg_b[i] <= memory_b[addr_b_grey_before][((i+1)*DWA-1):(i)*DWA];
//	end
//endgenerate
////data and signal cross clock domain A to domain B(clk_a -> clk_b)
////
always@(posedge rst_a or posedge fastclk_a)
begin
    if(rst_a == 1'b1) begin
       count_b_gray_reg1 <= 4'b0000;
	   count_b_gray_reg2 <= 4'b0000;
	   i_wr_en_b_reg1 <= 1'b0;
	   i_wr_en_b_reg2 <= 1'b0;
	   i_wr_en_b_reg3 <= 1'b0;
	   i_wr_en_b_reg4 <= 1'b0;
	end
	else begin
	    if(fastclk_a == 1'b1)begin
	        count_b_gray_reg1 <= count_b_gray;
		    count_b_gray_reg2 <= count_b_gray_reg1;
			i_wr_en_b_reg1 <= i_wr_en_b;
			i_wr_en_b_reg2 <= i_wr_en_b_reg1;
			i_wr_en_b_reg3 <= i_wr_en_b_reg2;
			i_wr_en_b_reg4 <= i_wr_en_b_reg3;
		end 
	end 
end 

always@(posedge rst_a or posedge fastclk_a)
begin
    if(rst_a == 1'b1) begin
	   memoryb_wraddr_low <= 0;
       memoryb_rdaddr <= 4'b0000;
	end
	else begin
	    if(fastclk_a == 1'b1) begin
	        if((memoryb_rdaddr_gray != count_b_gray_reg2))begin
			    if(memoryb_wraddr_low < MULTNUM-1) 
			        memoryb_wraddr_low <= memoryb_wraddr_low + 1;
				else 
				    memoryb_wraddr_low <= 0;
				
				if(memoryb_wraddr_low == 0)
				    memoryb_rdaddr <= memoryb_rdaddr + 1;
			end
			else begin
			    if(memoryb_wraddr_low < MULTNUM-1) 
			        memoryb_wraddr_low <= memoryb_wraddr_low + 1;
				else 
				    memoryb_wraddr_low <= memoryb_wraddr_low;
			    memoryb_rdaddr <= memoryb_rdaddr;
			end
		end 
	end 
end
assign memoryb_rdaddr_gray = memoryb_rdaddr ^ (memoryb_rdaddr >> 1);

//write port b to port a
always@(posedge rst_a or posedge fastclk_a)
begin
    if(rst_a == 1'b1) begin
       memory_whole_wraddr <= {(AWA-1){1'b0}};
	   memory_btoa_DWA <= {(DWA-1){1'b0}};
	end
	else begin
	    if(fastclk_a == 1'b1) begin
	        if(i_wr_en_b_reg3 == 1'b1)begin
			    if(memoryb_wraddr_low < MULTNUM-1) 
					memory_whole_wraddr <= memory_whole_wraddr + 1;
				else 
					memory_whole_wraddr <= {addr_b[memoryb_rdaddr],{(AWA-AWB){1'b0}}};
				memory_btoa_DWA <=	memory_btoa[memoryb_wraddr_low];
				//case(memoryb_wraddr_low)
				//    0 : memory_whole[memory_whole_wraddr] <= memory_b[memoryb_rdaddr][DWA-1:0]; 
				//    1 : memory_whole[memory_whole_wraddr] <= memory_b[memoryb_rdaddr][2*DWA-1:DWA]; 
				//    2 : memory_whole[memory_whole_wraddr] <= memory_b[memoryb_rdaddr][3*DWA-1:2*DWA]; 
				//    3 : memory_whole[memory_whole_wraddr] <= memory_b[memoryb_rdaddr][4*DWA-1:3*DWA]; 
				//    4 : memory_whole[memory_whole_wraddr] <= memory_b[memoryb_rdaddr][5*DWA-1:4*DWA]; 
				//    5 : memory_whole[memory_whole_wraddr] <= memory_b[memoryb_rdaddr][6*DWA-1:5*DWA]; 
				//    6 : memory_whole[memory_whole_wraddr] <= memory_b[memoryb_rdaddr][7*DWA-1:6*DWA];
				//    7 : memory_whole[memory_whole_wraddr] <= memory_b[memoryb_rdaddr][8*DWA-1:7*DWA];  
				//	default : memory_whole[memory_whole_wraddr] <= memory_b[memoryb_rdaddr][DWA-1:0];
				//endcase
			end
			else begin
			    memory_whole_wraddr <= memory_whole_wraddr;
			end
			if(i_wr_en_b_reg4 == 1'b1)
				memory_whole[memory_whole_wraddr] <= memory_btoa_DWA;
		end 
	end 
end

generate
    case(MULTNUM)
	    1 : assign memory_btoa[0] = memory_b[memoryb_rdaddr][DWA-1:0];
	    2 : assign memory_btoa[1:0] = memory_b[memoryb_rdaddr][2*DWA-1:0];
	    4 : assign memory_btoa[3:0] = memory_b[memoryb_rdaddr][4*DWA-1:0];
	    8 : assign memory_btoa[7:0] = memory_b[memoryb_rdaddr][8*DWA-1:0];
		default : assign memory_btoa[0] = memory_b[memoryb_rdaddr][DWA-1:0];
	endcase
endgenerate

//read
always@(posedge rst_a or posedge fastclk_a)
begin
    if(rst_a == 1'b1) begin
       memory_whole_rdaddr <= {(AWA-1){1'b0}};
	end
	else begin
	    if(fastclk_a == 1'b1) begin
	        if(i_wr_en_b_reg4 == 1'b0)begin
			    if(memoryb_wraddr_low < MULTNUM-1) 
					memory_whole_rdaddr <= memory_whole_rdaddr + 1;
				else 
					memory_whole_rdaddr <= {addr_b[memoryb_rdaddr],{(AWA-AWB){1'b0}}};
				
				memory_atob_reg[memoryb_wraddr_low] <=	memory_whole[memory_whole_rdaddr];
			end
			else begin
			    memory_whole_rdaddr <= memory_whole_rdaddr;
			end 
		end 
	end 
end

generate
    case(MULTNUM)
	    1 : assign memory_atob = memory_atob_reg[0];
	    2 : assign memory_atob = {memory_atob_reg[0],memory_atob_reg[1]};
	    4 : assign memory_atob = {memory_atob_reg[0],memory_atob_reg[1],memory_atob_reg[2],memory_atob_reg[3]};
	    8 : assign memory_atob = {memory_atob_reg[0],memory_atob_reg[1],memory_atob_reg[2],memory_atob_reg[3],memory_atob_reg[4],memory_atob_reg[5],memory_atob_reg[6],memory_atob_reg[7]};
		default : assign memory_atob = memory_atob_reg[0]; 
	endcase
endgenerate

endmodule	