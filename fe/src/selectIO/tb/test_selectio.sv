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
`include "selectio.svh"
//`define DWA 16
//`define AWB 4
//`define DWB 16
//`define MULTNUM  1
program test_selectio
(
	input i_dclk,

    output logic o_rst,
	
   
//   //input serial 
//	input i_clk_p,
//    input i_clk_n,
//	input [DW-1 : 0] i_data_p,
//	input [DW-1 : 0] i_data_n,
//	
//   //output serial
//    output o_clk_p,
//    output o_clk_n,
//	output [DW-1 : 0]    o_data_p,
//	output [DW-1 : 0]    o_data_n,
   
   //oout inter logic
   input 									i_dclk_div,
   output logic [`DW*`SP_Mult-1 : 0]          o_pardata,
	//in-dir inter logic
   output logic [`DW-1 : 0] 					o_bitslip,
   input               				  		i_fclk,
   input  logic [`DW*`SP_Mult-1 : 0]          i_pardata
   

);

//define a data mode control to control data generate pattern 
class data_control;
	rand logic [`DW-1:0] data_mode;
	constraint reasonable{
		data_mode dist {0:= 1 , 1 := 1 , 2 := 1, 3 := 1};
	}
endclass

class sync_control;
	rand logic [4:0] sync_control_length;
	constraint reasonable{
		sync_control_length dist {[16:32]:/1};
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


//function logic[31:0] reference_model;
//input shortint input_i;
//input shortint input_q;
//input shortint i_sin;
//input shortint i_cos;
//int step_i;
//int step_q;
//shortint result_i;
//shortint result_q;
//begin
//    step_i = (-(input_q * i_sin)) + input_i * i_cos ;
//	step_q = input_i * i_sin + input_q * i_cos;
//    result_i = shortint'(step_i >>> 10);
//    result_q = shortint'(step_q >>> 10);
//`ifdef DEBUG
//	$write("---input_i is 'h%0h;  input_q is 'h%0h;  i_sin is 'h%0h;  i_cos is 'h%0h;\n",input_i,input_q,i_sin,i_cos);
//	$write("---step_i is 'h%0h;  step_q is 'h%0h\n",step_i,step_q);
//	$write("---result_i is 'h%0h;  result_q is 'h%0h\n",result_i,result_q);
//`endif
//	reference_model = {result_i,result_q};
//end 
//endfunction 

//////////////////////////////////////////
// Definition: Coverage Group 
//////////////////////////////////////////
    covergroup selectio_cvr ;
        DMODE: coverpoint IO_DATA_TYPE.data_mode { 
            bins ZERO  = { 0 }; 
			bins ONE_FORTH  = { 1 };
            bins TWO_FORTH  = { 2 }; 
            bins THREE_FORTH  = { 3 }; 
        }
		SYNCMODE: coverpoint SYNC_TYPE.sync_control_length { 
            bins SHORT  = { [16:24]}; 
            bins LONG  = { [25:32]}; 
        }
		DMODExSYNCMODE: cross DMODE,SYNCMODE; 
    endgroup



//define the control and cvr check point 
data_control  IO_DATA_TYPE;
sync_control  SYNC_TYPE;
selectio_cvr my_msg_crv_0;

logic [`DW*`SP_Mult-1:0] data_io_msg0[$]; 


logic [31:0] data_coff_msg0[$]; 
mailbox mbox_after_reveive; 

int NUM = 0;
int num_current_a = 0;
int num_current_b = 0;
int num_current_din = 0;
int rate_count_max = 0;
int wrong_receive_count = 0;
//reset the previous reset; 
task init_reset(input [9:0] rst_delay = 200);
    $write("Here is the init,reset\n");
	o_rst <= 1'b1;
	o_pardata <= {(`DW*`SP_Mult){1'b0}};
	o_bitslip <= {(`DW){1'b0}};
	repeat(rst_delay) @(posedge i_dclk);
	o_rst <= 1'b0;
	o_pardata <= {(`DW*`SP_Mult){1'b0}};
	o_bitslip <= {(`DW){1'b0}};
	@(posedge i_dclk);
endtask 



int sycn_length = 4;
//generate io_data ,according io_data mode and io_data sync control
task io_data_generate(input frame_first = 0);
    //rand the begin addr of wr addr .
    assert(IO_DATA_TYPE.randomize())
  	else $write("TEST: IO_DATA_TYPE randomize error!!!\n"); 
    assert(SYNC_TYPE.randomize())
  	else $write("TEST: SYNC_TYPE randomize error!!!\n"); 
    
	//TEST_NUM.test_mode,MULT_NUM.mult_mode,$time);
	$write("here is IO data generate;this is the %4d times,the data_mode is %4d &&& the SYNC_Length is %4d at time: %12d \n",num_current_a,IO_DATA_TYPE.data_mode,SYNC_TYPE.sync_control_length,$time);
	sycn_length = SYNC_TYPE.sync_control_length;
	//accroding the addr_mode,set o_addr_a init value;
	case(IO_DATA_TYPE.data_mode)
	    0 : o_pardata   = {16'h5555};
		1 : o_pardata   = {(16){1'b0}};
		2 : o_pardata   = {(16){1'b0}};
		3 : o_pardata   = {(16){1'b0}};
		default :      
		    o_pardata   = {(16){1'b0}};
	endcase;   
    //generate one whole cycle(0-31 byte sync, 1024byte data)
	for(int sample_cycle = 0; sample_cycle < sycn_length; sample_cycle ++)
	begin
		o_pardata = {16'hCCCC};
		`ifdef DEBUG
		    $write("IO_DATA SYNC generate is:sample_cycle is %4d,o_pardata is 'h%0h\n",sample_cycle,o_pardata);
		`endif
		@(posedge i_dclk_div);
	end
	o_pardata = {16'h5555};
	for(int sample_cycle = 0; sample_cycle < `ONE_FRAME_LENGTH; sample_cycle ++)
	begin
		`ifdef DEBUG
		    $write("IO_DATA data generate is:sample_cycle is %4d,o_pardata is 'h%0h\n",sample_cycle,o_pardata);
		`endif
		 case(IO_DATA_TYPE.data_mode) 
			0 : o_pardata   = ~o_pardata;
			1 : o_pardata   = o_pardata + 1;
			2 : o_pardata   = o_pardata + 16'h1111;
			3 : o_pardata   = my_sin(sample_cycle,`ONE_FRAME_LENGTH);	
			default :      
		    	o_pardata   = {(16){1'b0}};
		 endcase 
			//`ifdef DEBUG
			//    $write("IQ_DATA generate is:sample_cycle is %4d,sample_tc is %d,o_data_i is 'h%0h,o_data_q is 'h%0h\n",sample_cycle,sample_tc,o_data_i,o_data_q);
			//`endif
			data_io_msg0.push_back(o_pardata);
		    @(posedge i_dclk_div);
	end
	o_pardata   = {(16){1'b0}};
	@(posedge i_dclk_div);	
    num_current_a = num_current_a + 1;
endtask

//monitor data 
integer data_read_count = 0;
task data_input(input read_delay = 1);
	integer receive_data_count;
	integer receive_head;
	integer bit_cycle;
	logic [`DW*`SP_Mult-1 : 0]          i_pardata_before;
    //rand the begin addr of rd addr .
	$write("here is data input read;this is the %4d times, at time: %12d \n",num_current_din,$time);
	receive_data_count = 0;
	receive_head = 0;
	bit_cycle = 0;
	while(data_read_count < `ONE_FRAME_LENGTH) begin
	    i_pardata_before = i_pardata;
	    @(posedge i_fclk);	
	    if(i_pardata == 16'hcccc )begin
	    	if(receive_head == 0) begin
	    		receive_head <= receive_head + 1;
	    		$display("haven detect the sync byte");
	    	end
	    	else begin
	    		if(i_pardata_before == 16'hcccc) begin
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
	    			o_bitslip <= {(`DW){1'b1}};
	    			bit_cycle <= 4;
	    			$display("haven't detect the sync byte, change o_bitslip once");
	    		end
	    		else begin
	    			o_bitslip <= {(`DW){1'b0}};
	    			bit_cycle <= bit_cycle - 1;
	    		end 
	    	end
	    	else begin
	    		$display("Now begin data transfer"); 
	    		for(int read_i = 0; read_i < `ONE_FRAME_LENGTH; read_i ++)
	    		begin
	    		    //if(i_data_vld == 1'b1) begin
	    			    mbox_after_reveive.put({i_pardata});
	    			//end
	    			`ifdef DEBUG
	    			    $write("data_input is:i_data_io is 'h%0h;it is %4d times at time: %12d \n",i_pardata,data_read_count,$time);
	    			`endif
	    			data_read_count = data_read_count + 1;
	    		    @(posedge i_fclk);
	    		end 
	    	end 
	    end
	end
	data_read_count = 0;
    num_current_din = num_current_din + 1;
endtask




//check the output data from axc_ul module , the simulate function is 
task data_check(input [2:0] delay_cycle = 6);
	logic [`DW*`SP_Mult-1 : 0]          i_pardata_receive;
	logic [`DW*`SP_Mult-1 : 0]          o_pardata_orginal;
	
    $write("check the data read in port a\n");
	while(1)
	begin
	    begin
        // Get the data that is read(poped) out of the mailbox                 
        mbox_after_reveive.get(i_pardata_receive);
		//Get the expected data from top of the quene
		o_pardata_orginal = data_io_msg0.pop_front();
		
		//$write("TEST: FIFO read dataaaaa addr: 'h%0h & data: 'h%0h; dataa_ram : 'h%0h; datab_ram : 'h%0h\n",tempAddr,tempOut, wra_data_temp,wrb_data_temp); 
        // Compare the two
        assert(o_pardata_orginal == i_pardata_receive)
	    //     $write("TEST: FIFO read data 'h%0h matched expected\n",tempOut); 
  	    else 
			$write("TEST: after receive data i:'h%0h != expcted data 'h%0h ;\n",i_pardata_receive, o_pardata_orginal); 
        end
		if(o_pardata_orginal != i_pardata_receive)begin
			wrong_receive_count = wrong_receive_count+1;
		end 
	end
endtask


////////////////////////////////
  //    Instantiation of objects    
  ////////////////////////////////
 initial begin : main_prog
  my_msg_crv_0 = new(); 
  mbox_after_reveive = new(); 
  IO_DATA_TYPE = new();
  SYNC_TYPE = new();
  //@(posedge i_dclk); //%%%%%%%%%%%%%cause the error of initial unclear status 
 
  //////////////////////////////////////////
  //    Read in NUM value - how many sets of 
  //    Data we want to simulate 
  //////////////////////////////////////////

  if (!$value$plusargs("NUM=%0d",NUM)) 
    NUM = 10; 
  $write("FIFO_TEST: Start simulation %d sets of data to the FIFO \n",NUM); 


  //////////////////////////////////////////
  //    Reset  and check for proper 
  //    signals from DUT
  //////////////////////////////////////////
 
  fork
    init_reset(300);
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
  repeat(NUM)  
  fork
    io_data_generate(1);
    //refsin_generate(1);
	data_input(1);
	$write("------complete the first data only A synchronously generate and check----------\n");
	@(posedge i_dclk) my_msg_crv_0.sample();
  join
   
  repeat(10)@(posedge i_dclk); 
  #100us;
  $write("FIFO_TEST: end simulation %d sets of data to the FIFO \n",NUM); 
  if(wrong_receive_count == 0) begin
		$write("Congratulations, Simulation PASSED on! \n");
  end else begin
		$write("ERROR: simulation failed! check error in the log. Failed %0d times.\n",wrong_receive_count);
  end 

end : main_prog



endprogram : test_selectio	