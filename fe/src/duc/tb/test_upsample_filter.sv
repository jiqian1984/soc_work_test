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
program test_upsample_filter
(
    input                    i_clk,
	output logic             o_rst,

	//output the data
    output logic             o_data_vld,
	output logic             o_data_ca,
	output logic  [15:0]     o_data,

    //input the data after filter
	input                    i_data_vld, 
	input                    i_data_ca, 
	input         [15:0]     i_data, 
    
	//the filter config 
	input                     i_config_clk,
	output logic              o_config_rst,
	output logic              o_load_parameter,
	output logic [15:0]       o_parameter_data
);

class data_control;
	rand logic [1:0] data_rate;
	constraint reasonable{
		data_rate dist {0:= 1 , 1 := 1 , 2 := 1, 3 := 1};
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


import "DPI-C" function upsample_2x(input real din[320],input real length,input real samplefreq,input real samplelen,output real dout[320]);
const real LENGTH = 1000;
const real SAMPLEFREQ = 30000;
const real SAPLELEN = 30000;
typedef shortint queue_of_shortint[320];
function queue_of_shortint reference_model(input shortint input_data[160]);
real indata_temp[0:319];
real reference_temp[0:319] ;
begin
	for(int i = 0;i < 160; i ++)
	begin
	    indata_temp[i*2] = real'(0);
        indata_temp[i*2+1] = real'(input_data[i]);
	end
	upsample_2x(indata_temp,LENGTH,SAMPLEFREQ,SAPLELEN,reference_temp);
	//convert real to integer
	for(int i = 0;i < 320; i ++)
	begin
	    reference_model[i] = shortint'(reference_temp[i]);
	end
`ifdef DEBUG
    for(int i = 0;i < 320; i ++)
	begin
	    $write("---input_i is 'h%0h;  result_i is 'h%0h;---\n",input_data[i],reference_model[i]);
	end
	
`endif
end 
endfunction 

//////////////////////////////////////////
// Definition: Coverage Group 
//////////////////////////////////////////
    covergroup msg_cvr ;
        DRATE: coverpoint IQ_DATA.data_rate{ 
            bins ZERO  = { 0 }; 
			bins ONE_FORTH  = { 1 };
            bins TWO_FORTH  = { 2 }; 
            bins THREE_FORTH  = { 3 }; 
        }
    endgroup




data_control IQ_DATA;
msg_cvr my_msg_crv_0;

logic [15:0] data_iq_msg0[$]; 
logic [15:0] data_coff_msg0[$]; 

logic [15:0] quene_after_filter[$]; 
mailbox mbox_after_filter; 

int NUM = 0;
int num_current_a = 0;
int num_current_b = 0;
int num_current_din = 0;
int rate_count_max = 0;

int data_read_count = 0;


//reset the init set of filter coff; 
task init_reset(input [3:0] rst_delay = 3);
    $write("Here is the init,reset\n");
	o_rst = 1'b1;
	o_data_vld = 1'b0;
	o_data_ca = 1'b0;
	o_data = {(16){1'b0}};
	o_config_rst = 1'b1;
	o_load_parameter = 1'b0;
	o_parameter_data = {(16){1'b0}};
	repeat(rst_delay) @(posedge i_clk);
	o_rst = 1'b0;
	o_data_vld = 1'b0;
	o_data_ca = 1'b0;
	o_data = {(16){1'b0}};
	o_config_rst = 1'b0;
	o_load_parameter = 1'b0;
	o_parameter_data = {(16){1'b0}};
	
	@(posedge i_clk);
endtask 


task iq_data_generate(input frame_first = 0);
    int tc_mux;
    //rand the begin addr of wr addr .
    IQ_DATA.randomize();
	//TEST_NUM.test_mode,MULT_NUM.mult_mode,$time);
	$write("here is i q data generate;this is the %4d times,the data_mode is %4d at time: %12d \n",num_current_a,IQ_DATA.data_rate,$time);
	o_data_vld = 1'b0;
	o_data_ca = 1'b0;
	//accroding the addr_mode,set o_addr_a init value;
	o_data   = {(16){1'b0}};
	tc_mux = IQ_DATA.data_rate;
    //generate one whole cycle(16 TC,1TC = 80clk(include 64clk vld(4*16mode)))
	for(int sample_cycle = 0; sample_cycle < 16; sample_cycle ++)
	begin
	    for(int sample_tc = 0;sample_tc < (16*tc_mux);sample_tc ++)
		begin
			
            for(int sample_4vld = 0;sample_4vld < 4;sample_4vld ++)
			begin
                if((sample_4vld == 0) && (sample_cycle < 12)) begin
                    o_data_vld = 1'b1;
					o_data = my_sin(sample_tc,(16*tc_mux));
				end
				else begin
				    o_data_vld = 1'b0;
					o_data = {(16){1'b0}};
				end
				if((sample_4vld == 0) && (sample_tc == 1'b0) && (sample_cycle == 1'b0))
			        o_data_ca = 1'b1;
			    else
			        o_data_ca = 1'b0;
			    
			    //`ifdef DEBUG
			    //    $write("IQ_DATA generate is:sample_cycle is %4d,sample_tc is %d,o_data_i is 'h%0h,o_data_q is 'h%0h\n",sample_cycle,sample_tc,o_data_i,o_data_q);
			    //`endif
				if((sample_4vld == 0) && (sample_cycle < 12))
			        data_iq_msg0.push_back(o_data);
		        @(posedge i_clk);
			end
			
		end
		
		//$write("here is port a write;this is the %4d times,the read addr is %4d,data is : %4d ,for sample_a is: %4d, at time: %12d \n",num_current_a,o_addr_a,o_wrdata_a,sample_a,$time);
	end 
	o_data_vld = 1'b0;
	o_data_ca = 1'b0;
	o_data   = {(16){1'b0}};
	@(posedge i_clk);	
    num_current_a = num_current_a + 1;
endtask


task filter_config_generate(input frame_first = 0);
    //begin the filter parameter generate
	$write("Here is the init filter coff set\n");
	o_load_parameter = 1'b0;
	o_parameter_data = 16'd0;
	@(negedge o_config_rst);
	//output the load_x and data_x 
	@(posedge i_config_clk);
	for(int coff_num = 0;coff_num < 16;coff_num ++)
	begin
	    o_load_parameter = 1'b1;
	    case(coff_num)
	        0 : o_parameter_data = 16'hFBF3;
			1 : o_parameter_data = 16'h031D;
	        2 : o_parameter_data = 16'h066E;
			3 : o_parameter_data = 16'h0B69;
			4 : o_parameter_data = 16'h1138;
			5 : o_parameter_data = 16'h16E2;
			6 : o_parameter_data = 16'h1B60;
			7 : o_parameter_data = 16'h1DDF;
			8 : o_parameter_data = 16'h1DDF;
			9 : o_parameter_data = 16'h1B60;
			10 : o_parameter_data = 16'h16E2;
			11 : o_parameter_data = 16'h1138; 
			12 : o_parameter_data = 16'h0B69;
			13 : o_parameter_data = 16'h066E;
			14 : o_parameter_data = 16'h031D;
			15 : o_parameter_data = 16'hFBF3;
	        default : o_parameter_data = 16'd0;
	    endcase;
		@(posedge i_config_clk);
	end
	o_load_parameter = 1'b0;
	//inter one clk
	@(posedge i_config_clk);
    
endtask

task data_input(input read_delay = 1);
    //rand the begin addr of rd addr .
	$write("here is data input read;this is the %4d times, at time: %12d \n",num_current_din,$time);
	
	@(posedge i_data_ca);
	for(int read_i = 0; read_i < 320; read_i ++)
	begin
	    if(i_data_vld == 1'b1) begin
		    quene_after_filter.push_back(i_data);
			$write("push reveive data into the quene it is %4d times  ;;;;..... at time: %12d\n",read_i,$time);
			
			`ifdef DEBUG
		        $write("data_input is:i_data is 'h%0h;it is %4d times at time: %12d \n",i_data,data_read_count,$time);
		        data_read_count = data_read_count + 1;
		    `endif
		end
		if(read_i == 319) begin
		    mbox_after_filter.put(2'b01);
			$write("---------------------------------write ont mbox at time: %12d----------------------------------\n",$time);
		end 
	    @(posedge i_clk);
	end 
    num_current_din = num_current_din + 1;
endtask




//check the output data from axc_ul module , the simulate function is 
task data_check(input [2:0] delay_cycle = 6);
    logic [1:0] after_filte_flag;
    shortint original_data[160];
    logic [31:0] after_filter[0:319];
    shortint reference_data[320];
	
    $write("check the data read in port a\n");
	while(1)
	begin
	    begin
        // Get the data that is read(poped) out of the mailbox                 
        mbox_after_filter.get(after_filte_flag);
		for(int i = 0; i < 320 ;i ++)
		begin
		    after_filter[i] = quene_after_filter.pop_front();
			`ifdef DEBUG
		    $write("after filter is: 'h%0h;it is %4d times at time: %12d \n",after_filter[i],data_read_count,$time);
		    data_read_count = data_read_count + 1;
		    `endif
		end 
		//Get the expected data from top of the quene
		for(int i = 0; i < 160 ;i ++)
		begin
		    original_data[i] = data_iq_msg0.pop_front();
			`ifdef DEBUG
		    $write("the org data is:data is 'h%0h;times at time: %12d \n",original_data[i],$time);
		`endif
		end 
		//
		
		reference_data = reference_model(original_data);
		
		//$write("TEST: FIFO read dataaaaa addr: 'h%0h & data: 'h%0h; dataa_ram : 'h%0h; datab_ram : 'h%0h\n",tempAddr,tempOut, wra_data_temp,wrb_data_temp); 
        // Compare the two
		for(int i = 0; i < 320 ;i ++)
		begin
            assert(after_filter[i] == reference_data[i])  
	        //     $write("TEST: FIFO read data 'h%0h matched expected\n",tempOut); 
  	        else $write("TEST: after filter data i:'h%0h != expcted data 'h%0h \n",
		         after_filter[i], reference_data[i]); 
            end
		end 
	end
endtask


////////////////////////////////
  //    Instantiation of objects    
  ////////////////////////////////
 initial begin : main_prog
  my_msg_crv_0 = new(); 
  mbox_after_filter = new(); 
  IQ_DATA = new();
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
    filter_config_generate(1);
  join
  
  
  //////////////////////////////////////////
  //  The checker block is spawn in the 
  //  background ( fork join_none construct)
  //////////////////////////////////////////
  fork
    data_check(1);
  join_none

   @(posedge i_clk);

  ////////////////////////////////////////////
  //  Basic Test, read/write every clock cycle 
  //  start write and read in parallel and 
  //  sample the covergroups initially
  ////////////////////////////////////////////
  repeat(1)  
  fork
    iq_data_generate(1);
	data_input(1);
	$write("------complete the data generate and check----------\n");
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



endprogram : test_upsample_filter