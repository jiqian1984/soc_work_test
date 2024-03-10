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
`define NODEBUG
//`define DWA 16
//`define AWB 4
//`define DWB 16
//`define MULTNUM  1
program test_multi_freq 
(
    input                    i_clk,
	output logic             o_rst,
	//output the i&q data
    output logic             o_data_vld,
	output logic             o_data_ca,
	output logic  [15:0]     o_data_i,
	output logic  [15:0]     o_data_q,
	
	output logic  [15:0]     o_sin_coff, 
	output logic  [15:0]     o_cos_coff, 
	
	input                    i_data_vld,
	input                    i_data_ca,
	input [15:0]             i_data_i,
	input [15:0]             i_data_q
);

class data_control;
	rand logic [1:0] data_mode;
	constraint reasonable{
		data_mode dist {0:= 1 , 1 := 1 , 2 := 1, 3 := 1};
	}
endclass

class sin_control;
	rand logic [1:0] sin_rate;
	constraint reasonable{
		sin_rate dist {0:= 1 , 1 := 1 , 2 := 1, 3 := 1};
	}
endclass

import "DPI-C" function real sin(input real r);

function integer my_sin;
input integer value;
input integer length;
integer act_value;
real duble_value;
real duble_sin;
begin
    if(value > length) begin
	    act_value = value - length;
	end
	else begin
	    act_value = value;
	end
	//`ifdef DEBUG
	//	$write("my_sin func:value in is %4d,length is %4d,act_valueis %4d\n",value,length,act_value);
	//`endif
	duble_value = 6.283*(real'(act_value)/real'(length));
	duble_sin = sin(duble_value);
    my_sin = integer'(duble_sin * 1024);
end 
endfunction 


function logic[31:0] reference_model;
input shortint input_i;
input shortint input_q;
input shortint i_sin;
input shortint i_cos;
int step_i;
int step_q;
shortint result_i;
shortint result_q;
begin
    step_i = (-(input_q * i_sin)) + input_i * i_cos ;
	step_q = input_i * i_sin + input_q * i_cos;
    result_i = shortint'(step_i >>> 10);
    result_q = shortint'(step_q >>> 10);
`ifdef DEBUG
	$write("---input_i is 'h%0h;  input_q is 'h%0h;  i_sin is 'h%0h;  i_cos is 'h%0h;\n",input_i,input_q,i_sin,i_cos);
	$write("---step_i is 'h%0h;  step_q is 'h%0h\n",step_i,step_q);
	$write("---result_i is 'h%0h;  result_q is 'h%0h\n",result_i,result_q);
`endif
	reference_model = {result_i,result_q};
end 
endfunction 

//////////////////////////////////////////
// Definition: Coverage Group 
//////////////////////////////////////////
    covergroup msg_cvr ;
        DMODE: coverpoint IQ_DATA.data_mode { 
            bins ZERO  = { 0 }; 
			bins ONE_FORTH  = { 1 };
            bins TWO_FORTH  = { 2 }; 
            bins THREE_FORTH  = { 3 }; 
        }
		REFRATE: coverpoint SINCOS_DATA.sin_rate { 
            bins ZERO  = { 0 }; 
			bins ONE_FORTH  = { 1 };
            bins TWO_FORTH  = { 2 }; 
            bins THREE_FORTH  = { 3 }; 
        }
		DMODExREFRATE: cross DMODE,REFRATE; 
    endgroup




data_control IQ_DATA;
sin_control  SINCOS_DATA;
msg_cvr my_msg_crv_0;

logic [31:0] data_iq_msg0[$]; 
logic [31:0] data_coff_msg0[$]; 
mailbox mbox_after_multi; 

int NUM = 0;
int num_current_a = 0;
int num_current_b = 0;
int num_current_din = 0;
int rate_count_max = 0;

int data_read_count = 0;

//reset the init set of filter coff; 
task init_reset(input [3:0] rst_delay = 3);
    $write("Here is the init,reset\n");
	o_rst <= 1'b1;
	o_data_vld <= 1'b0;
	o_data_ca <= 1'b0;
	o_data_i <= {(16){1'b0}};
	o_data_q <= {(16){1'b0}};
	o_sin_coff <= {(16){1'b0}};
	o_cos_coff <= {(16){1'b0}};
	repeat(rst_delay) @(posedge i_clk);
	o_rst <= 1'b0;
	o_data_vld <= 1'b0;
	o_data_ca <= 1'b0;
	o_data_i <= {(16){1'b0}};
	o_data_q <= {(16){1'b0}};
	o_sin_coff <= {(16){1'b0}};
	o_cos_coff <= {(16){1'b0}};
	@(posedge i_clk);
endtask 


task iq_data_generate(input frame_first = 0);
    //rand the begin addr of wr addr .
    IQ_DATA.randomize();
	//TEST_NUM.test_mode,MULT_NUM.mult_mode,$time);
	$write("here is i q data generate;this is the %4d times,the data_mode is %4d at time: %12d \n",num_current_a,IQ_DATA.data_mode,$time);
	o_data_vld = 1'b0;
	o_data_ca = 1'b0;
	//accroding the addr_mode,set o_addr_a init value;
	case(IQ_DATA.data_mode)
	    0 : o_data_i   = {16'h555};
		1 : o_data_i   = {(16){1'b0}};
		2 : o_data_i   = {(16){1'b0}};
		3 : o_data_i   = {(16){1'b0}};
		default :      
		    o_data_i   = {(16){1'b0}};
	endcase;   
	o_data_q = o_data_i;
    //generate one whole cycle(16 TC,1TC = 80clk(include 64clk vld(4*16mode)))
	for(int sample_cycle = 0; sample_cycle < 16; sample_cycle ++)
	begin
	    for(int sample_tc = 0;sample_tc < 80;sample_tc ++)
		begin
		    if(sample_tc < 64)
			    o_data_vld = 1'b1;
			else
		        o_data_vld = 1'b0;
				
			if((sample_tc == 1'b0) && (sample_cycle == 1'b0))
			    o_data_ca = 1'b1;
			else
			    o_data_ca = 1'b0;
				
			if(sample_tc < 64) begin
			    if(sample_tc == 1'b0 ) begin
				    case(IQ_DATA.data_mode)
	                    0 : o_data_i   = {16'h555};
	                	1 : o_data_i   = {(16){1'b0}};
	                	2 : o_data_i   = {(16){1'b0}};
	                	3 : o_data_i   = {(16){1'b0}};
	                	default :      
	                	    o_data_i   = {(16){1'b0}};
	                endcase;  
				end
				else begin
			        case(IQ_DATA.data_mode)
			            0 : o_data_i =  ~o_data_i;
			        	1 : o_data_i = o_data_i + 16'h1111;
			        	2 : o_data_i = o_data_i + 1;
                        3 : o_data_i = my_sin(sample_tc,64);			
			        endcase;
				end
			end
			o_data_q = o_data_i;
			//`ifdef DEBUG
			//    $write("IQ_DATA generate is:sample_cycle is %4d,sample_tc is %d,o_data_i is 'h%0h,o_data_q is 'h%0h\n",sample_cycle,sample_tc,o_data_i,o_data_q);
			//`endif
			data_iq_msg0.push_back({o_data_i,o_data_q});
		    @(posedge i_clk);
		end
		
		//$write("here is port a write;this is the %4d times,the read addr is %4d,data is : %4d ,for sample_a is: %4d, at time: %12d \n",num_current_a,o_addr_a,o_wrdata_a,sample_a,$time);
	end 
	o_data_vld = 1'b0;
	o_data_ca = 1'b0;
	o_data_i   = {(16){1'b0}};
	o_data_q   = {(16){1'b0}};
	@(posedge i_clk);	
    num_current_a = num_current_a + 1;
endtask

task refsin_generate(input frame_first = 0);
    //rand the begin addr of wr addr .
    SINCOS_DATA.randomize();
	$write("here is refsin signal generate;this is the %4d times,the sin rate is %4d at time: %12d \n",num_current_b,SINCOS_DATA.sin_rate,$time);
	
	o_sin_coff = {(16){1'b0}};
	o_cos_coff = {(16){1'b1}};
	
	//accroding the addr_mode,set o_addr_a init value;
	case(SINCOS_DATA.sin_rate)
	    0 : rate_count_max   = 1;
		1 : rate_count_max   = 2;
		2 : rate_count_max   = 4;
		3 : rate_count_max   = 8;
		default : 
		    rate_count_max   = 1;
	endcase;
	
	for(int total_cycle = 0;total_cycle < (40/rate_count_max);total_cycle ++)
	begin
	    for(int cycle_count = 0;cycle_count < 32;cycle_count ++)
	    begin
	        for(int rate_count = 0;rate_count < rate_count_max;rate_count ++)
	    	begin
	    	    o_sin_coff = my_sin((cycle_count*rate_count_max+rate_count),(32*rate_count_max));
	    		o_cos_coff = my_sin((cycle_count*rate_count_max+rate_count+8*rate_count_max),(32*rate_count_max));
	    		data_coff_msg0.push_back({o_sin_coff,o_cos_coff});
	    		//`ifdef DEBUG
	    		//    $write("SINCOS_DATA generate is:cycle_count is %4d,rate_count is %d,o_sin_coff is 'h%0h,o_cos_coff is 'h%0h\n",cycle_count,rate_count,o_sin_coff,o_cos_coff);
	    		//`endif
	    		@(posedge i_clk);
	    	end 
	    end 
	end
	@(posedge i_clk);
	
    num_current_b = num_current_b + 1;
endtask

task data_input(input read_delay = 1);
    //rand the begin addr of rd addr .
	$write("here is data input read;this is the %4d times, at time: %12d \n",num_current_din,$time);
	
	@(posedge i_data_ca);
	for(int read_i = 0; read_i < 1280; read_i ++)
	begin
	    //if(i_data_vld == 1'b1) begin
		    mbox_after_multi.put({i_data_i,i_data_q});
		//end
		`ifdef DEBUG
		    $write("data_input is:i_data_i is 'h%0h,i_data_q is 'h%0h;it is %4d times at time: %12d \n",i_data_i,i_data_q,data_read_count,$time);
		`endif
		data_read_count = data_read_count + 1;
	    @(posedge i_clk);
	end 
    num_current_din = num_current_din + 1;
endtask




//check the output data from axc_ul module , the simulate function is 
task data_check(input [2:0] delay_cycle = 6);
    logic [15:0] original_i;
    logic [15:0] original_q;
    logic [15:0] sin_coff;
    logic [15:0] cos_coff;
    logic [31:0] after_multi;
    logic [15:0] after_multi_q;
    logic [15:0] after_multi_i;
    logic [15:0] reference_i;
    logic [15:0] reference_q;
	
    $write("check the data read in port a\n");
	while(1)
	begin
	    begin
        // Get the data that is read(poped) out of the mailbox                 
        mbox_after_multi.get(after_multi);
		after_multi_i = after_multi[31:16];
		after_multi_q = after_multi[15:0];
		//Get the expected data from top of the quene
		{original_i,original_q} = data_iq_msg0.pop_front();
		{sin_coff,cos_coff} = data_coff_msg0.pop_front();
		//
		{reference_i,reference_q} = reference_model(original_i,original_q,sin_coff,cos_coff);
		
		//$write("TEST: FIFO read dataaaaa addr: 'h%0h & data: 'h%0h; dataa_ram : 'h%0h; datab_ram : 'h%0h\n",tempAddr,tempOut, wra_data_temp,wrb_data_temp); 
        // Compare the two
        assert((after_multi_i == reference_i) && (after_multi_q == reference_q))  
	    //     $write("TEST: FIFO read data 'h%0h matched expected\n",tempOut); 
  	    else $write("TEST: after multi data i:'h%0h != expcted data 'h%0h ; data q:'h%0h != expcted data 'h%0h ;\n",
		     after_multi_i, reference_i,after_multi_q,reference_q); 
        end
	end
endtask


////////////////////////////////
  //    Instantiation of objects    
  ////////////////////////////////
 initial begin : main_prog
  my_msg_crv_0 = new(); 
  mbox_after_multi = new(); 
  IQ_DATA = new();
  SINCOS_DATA = new();
  @(posedge i_clk); //%%%%%%%%%%%%%cause the error of initial unclear status 
 
  //////////////////////////////////////////
  //    Read in NUM value - how many sets of 
  //    Data we want to simulate 
  //////////////////////////////////////////

  if (!$value$plusargs("NUM+%0d",NUM)) 
    NUM = 10; 
  $write("FIFO_TEST: Start simulation %d sets of data to the FIFO \n",NUM); 


  //////////////////////////////////////////
  //    Reset  and check for proper 
  //    signals from DUT
  //////////////////////////////////////////
 
  fork
    init_reset(1);
  join
  
  
  //////////////////////////////////////////
  //  The checker block is spawn in the 
  //  background ( fork join_none construct)
  //////////////////////////////////////////
  fork
    data_check(1);
  join_none


  ////////////////////////////////////////////
  //  Basic Test, read/write every clock cycle 
  //  start write and read in parallel and 
  //  sample the covergroups initially
  ////////////////////////////////////////////
  repeat(10)  
  fork
    iq_data_generate(1);
    refsin_generate(1);
	data_input(1);
	$write("------complete the first data only A synchronously generate and check----------\n");
	@(posedge i_clk) my_msg_crv_0.sample();
  join
   
  repeat(10)@(posedge i_clk); 
  
//  fork
//    iq_data_generate(1);
//    refsin_generate(1);
//	data_input(1);
//	$write("------complete the first data only A synchronously generate and check----------\n");
//	@(posedge i_clk) my_msg_crv_0.sample();
//  join
//   
//  repeat(10)@(posedge i_clk);
// 
// fork
//      dataa_read(1);
//	  datab_write(1);  
//	  $write("------complete the first data a read and data b write synchronously generate and check----------\n");
//      @(posedge i_clk_a);
//	  my_msg_crv_0.sample();
//  join 
//  
//  repeat(NUM) 
//  fork
//      dataa_write(1);
//	  datab_read(1);
//      datab_write(1);
//	  dataa_read(1);
//	  $write("------complete the first data A & B synchronously generate and check (tims : %d)----------\n",NUM);
//	  my_msg_crv_0.sample();
//  join 


end : main_prog



endprogram : test_multi_freq	