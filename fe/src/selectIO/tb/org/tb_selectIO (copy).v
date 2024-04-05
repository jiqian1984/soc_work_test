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
`define DW 4
`define SP_Mult 4 
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
	reg REFCLK_200m = 1'b0;
	reg axi_clk_125m = 1'b0;
	reg i_dclk_500m = 1'b0;
	reg rst_sys = 1'b1;
	reg [`DW-1 : 0] i_bitslip = {(`DW){1'b0}};
	reg [`DW-1 : 0] i_bitslip_slap1 = {(`DW){1'b0}};
	reg [`DW*`SP_Mult-1 : 0] i_pardata = {(`DW*`SP_Mult){1'b0}};
	reg [`DW*`SP_Mult-1 : 0] o_pardata_before = {(`DW*`SP_Mult){1'b0}};
	
	wire clk_p;
	wire clk_n;  
	wire [`DW-1 : 0] data_p;
	wire [`DW-1 : 0] data_n;
	
	wire [`DW*`SP_Mult-1 : 0] o_pardata;
	wire [`DW*`SP_Mult-1 : 0] o_pardata_temp;
	wire o_fclk;
	wire o_dclk_div;
	
	always #2.5 REFCLK_200m = ~REFCLK_200m;
	always #4 axi_clk_125m = ~axi_clk_125m;
	always #1 i_dclk_500m = ~i_dclk_500m;
	
	initial begin
		rst_sys=1'b1;
		#500;
		rst_sys=1'b0;
	end
	
	integer count_num;
	//every 2048 one frame, easy to verify
	always@(posedge o_dclk_div)begin
		if(rst_sys) begin
			i_pardata <= {(`DW*`SP_Mult){1'b0}};
			count_num <= 0;
		end
		else begin
			if(count_num == 0) begin
				i_pardata <= {(`DW*`SP_Mult/4){4'h1}};
			end
			else if(count_num < 15)begin
			    i_pardata <= {(`DW*`SP_Mult/4){4'h1}};
			end 
			else if(count_num == 15) begin
			    i_pardata <= {(`DW*`SP_Mult){1'b0}};
			end 
			else if(count_num < 2048) begin
			    i_pardata <= i_pardata + 1;
			end
			else begin
				i_pardata <= {(`DW*`SP_Mult){1'b0}};
			end
			
			if(count_num < 2048)  
				count_num <= count_num + 1;
			else 
				count_num <= 0;
		end 
	end 
	integer receive_data_count;
	integer receive_head;
	integer bit_cycle;
	//assign i_bitslip =  (o_pardata != 16'hcccc) && (receive_head == 0) ?  {(`DW){1'b1}} : {(`DW){1'b0}};
	//check data_ca_temp
	always@(posedge o_fclk)begin
		if(rst_sys) begin
			receive_head <= 0;
			receive_data_count <= 0;
			bit_cycle <= 0;
			o_pardata_before <= {(`DW*`SP_Mult){1'b0}};
			i_bitslip <= {(`DW){1'b0}};
		end 
		else begin
			i_bitslip_slap1 <= i_bitslip;
			o_pardata_before <= o_pardata;
            //case()
			//	2'b00 : begin //idle,wait for ysnc
//
			//	end
			//	2'b01 : begin //change bitslp
//
			//	end
			//	2'b10 : begin //wait atleast 3cycle
//
			//	end
			//	2'b11 : begin //receive data
//
			//	end
//
			//endcase 


			if(o_pardata == 16'h1111 )begin
				if(receive_head == 0) begin
					receive_head <= receive_head + 1;
					$display("haven detect the sync byte");
				end
				else begin
					if(o_pardata_before == 16'h1111) begin
						receive_head <= receive_head + 1;
						$display("Now detect the %0d sync 7*0xcccc",receive_head);
					end
					else begin
						$display("it's a data 0xcccc detect");
					end 
				end
			end
			else begin
				if(receive_head == 0) begin
					if(bit_cycle == 0) begin
						i_bitslip <= {(`DW){1'b1}};
						bit_cycle <= 4;
						$display("haven't detect the sync byte, change i_bitslip once");
					end
					else begin
						i_bitslip <= {(`DW){1'b0}};
						bit_cycle <= bit_cycle - 1;
					end 
				end
				else begin
					$display("Now begin data transfer"); 
				end 
			end


//
//if((o_pardata != 16'hcccc) && (receive_head == 0) && (i_bitslip == {(`DW){1'b0}})) begin
//    i_bitslip <= {(`DW){1'b1}};
//	$display("haven't detect the sync byte, change i_bitslip once");
//	receive_head <= 0;
//end
//else begin
//	if((o_pardata == 16'hcccc) && (receive_head == 0)) begin
//		receive_head <= receive_head + 1;
//		i_bitslip <= {(`DW){1'b0}};
//		$display("Now detect the first sync 7*0xcccc");
//	end
//	else begin
//		if((o_pardata == 16'hcccc) && (o_pardata_before == 16'hcccc)) begin
//			receive_head <= receive_head + 1;
//			i_bitslip <= {(`DW){1'b0}};
//			$display("Now detect the %0d sync 7*0xcccc",receive_head);
//		end
//		else begin
//				i_bitslip <= {(`DW){1'b0}};
//				$display("Now begin data transfer"); 
//		end
//	end
//
//	
//end 
			
			if(receive_head > 0) begin
				if(o_pardata != (o_pardata_before + 1)) begin
					$display("Now detect the errordata @ o_pardata_before =0x%4h,  o_pardata = 0x%4h",o_pardata_before,o_pardata);
				end 
			end 
			
			
			
			//if((o_pardata == {(`DW*`SP_Mult/2){2'b01}}) || (receive_head == 0)) begin
			//	receive_head <= receive_head + 1;
			//	i_bitslip <= {(`DW){1'b0}};
			//	$display("Now detect the first sync 7*0x5555");
			//end
			//else if((o_pardata == ~o_pardata_before) || (receive_head <7)) begin
			//	receive_head <= receive_head + 1;
			//	i_bitslip <= {(`DW){1'b0}};
			//	$display("Now detect the sync byte 0x%4h",o_pardata);
			//end
			//else begin
			//    if(receive_head <7) begin
			//	    i_bitslip <= {(`DW){1'b1}};
			//		$display("Now bitslip once");
			//	    receive_head <= receive_head + 1;
			//	end 
			//	else begin
			//	    $display("Now detect the sync 7*0x5555");
			//		receive_head <= 0;
			//		receive_data_count <= receive_data_count + 1;
			//	end 
			//	//if(receive_head == 7) begin
			//	//	$display("Now detect the sync 7*0x5555");
			//	//	receive_head <= 0;
			//	//	receive_data_count <= 0;
			//	//end
			//	//else begin
			//	//	receive_head <= 0;
			//	//	receive_data_count <= receive_data_count + 1;
			//	//    if(o_pardata != (o_pardata_before + 1)) begin
			//	//		$display("Now detect the errordata @ o_pardata_before =0x%4h,  o_pardata = 0x%4h",o_pardata_before,o_pardata);
			//	//	end 
			//	//end
			//end
		
		end
	
	end
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
	
//    test_multi_freq u_test_multi_freq(
//    .i_clk(i_clk),
//	.o_rst(rst_temp),
//    .o_data_vld(data_vld_temp),
//	.o_data_ca(data_ca_temp),
//	.o_data_i(data_i_temp),
//	.o_data_q(data_q_temp),
//	.o_sin_coff(sin_coff_temp), 
//	.o_cos_coff(cos_coff_temp), 
//	.i_data_vld(after_multi_vld),
//	.i_data_ca(after_multi_ca),
//	.i_data_i(after_multi_i),
//	.i_data_q(after_multi_q)
//);


endmodule