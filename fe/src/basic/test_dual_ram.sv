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
//`define AWA 4
//`define DWA 16
//`define AWB 4
//`define DWB 16
//`define MULTNUM  1
program test_dual_ram 
(

    input             i_clk_a,
	output logic        o_rst_a,
    output logic  [`DWA-1:0] o_wrdata_a,
	output logic  [`AWA-1:0] o_addr_a,
	output logic            o_wr_en_a,
	input   [`DWA-1:0] i_rddata_a,
	
	input              i_clk_b,
	output logic             o_rst_b,
	output logic  [`DWB-1:0]  o_wrdata_b,
	output logic  [`AWB-1:0]  o_addr_b,
	output logic             o_wr_en_b,
	input   [`DWB-1:0]  i_rddata_b
	
);
//-----------------------------------------------------------------------------
// Dump fsdb file
//-----------------------------------------------------------------------------
/***
initial
begin
    $fsdbDumpoff;
    //#1250000; //run 1250us, before start dump wave file
    $fsdbDumpon;
    $fsdbDumpfile("tb_data_trans_1b.fsdb");
    //$fsdbAutoSwitchDumpfile(800,"tb_cpri_serdes_top.fsdb",100); //file size 800M, 100 files total
    $fsdbDumpvars(0,tb_data_trans_1b);
end
***/

//define the data id,first,vld generate class//

//control_interval is the interval between two vld, it is simulate the abnormal errors//

//define the data_freg,random parameter(from 1M - 40M)
//addr_mode : 0 begin at addr - 0;
//addr_mode : 1 begin at addr - 1/4;
//addr_mode : 2 begin at addr - 1/2;
//addr_mode : 3 begin at addr - 3/4;

class port_init_control;
	rand logic [1:0] addr_mode;
	constraint reasonable{
		addr_mode dist {0:= 1 , 1 := 1 , 2 := 1, 3 := 1};
	}
endclass


//
//class mult_mode_control;
//	rand logic [1:0] mult_mode;
//	
//	constraint reasonable{
//	    mult_mode > 0;
//		mult_mode dist {0:= 5 , 1 := 1 , 2 := 1, 3 := 1};
//	}
//endclass
//
//////////////////////////////////////////
// Definition: Coverage Group 
//////////////////////////////////////////
    covergroup msg_cvr ;
        PAW: coverpoint PORTA_WRADDR.addr_mode { 
            bins ZERO  = { 0 }; 
			bins ONE_FORTH  = { 1 };
            bins TWO_FORTH  = { 2 }; 
            bins THREE_FORTH  = { 3 }; 
        }
		PBW: coverpoint PORTB_WRADDR.addr_mode { 
            bins ZERO  = { 0 }; 
			bins ONE_FORTH  = { 1 };
            bins TWO_FORTH  = { 2 }; 
            bins THREE_FORTH  = { 3 }; 
        }
		PAR: coverpoint PORTA_RDADDR.addr_mode { 
            bins ZERO  = { 0 }; 
			bins ONE_FORTH  = { 1 };
            bins TWO_FORTH  = { 2 }; 
            bins THREE_FORTH  = { 3 }; 
        }
		PBR: coverpoint PORTB_RDADDR.addr_mode { 
            bins ZERO  = { 0 }; 
			bins ONE_FORTH  = { 1 };
            bins TWO_FORTH  = { 2 }; 
            bins THREE_FORTH  = { 3 }; 
        }
		PAxPB: cross PAW,PBW,PAR,PBR ; 
    endgroup




port_init_control PORTA_WRADDR;
port_init_control PORTA_RDADDR;
port_init_control PORTB_WRADDR;
port_init_control PORTB_RDADDR;

//random_data_crx_ser DATA_CRX_SER;
msg_cvr my_msg_crv_0;


int NUM = 0;
int num_current_a = 0;
int num_current_b = 0;
int num_current_ar = 0;
int num_current_br = 0;
int write_numa_max = 0;
int write_numb_max = 0;
int read_numa_max = 0;
int read_numb_max = 0;


logic [`DWA-1:0] dataa_ram[calculate_2N(`AWA)-1:0]; 
logic [`DWB-1:0] datab_ram[calculate_2N(`AWB)-1:0]; 
mailbox mbox_porta; 
mailbox mbox_addra;
mailbox mbox_portb; 
mailbox mbox_addrb;


function integer calculate_2N;
input integer bits_wide;
integer bits_i;
begin
    if(bits_wide == 0) begin
	    calculate_2N = 1;
	end
	else begin
	    calculate_2N = 1;
	    for(bits_i = 0;bits_i < bits_wide;bits_i = bits_i + 1)
	    begin
	        calculate_2N = calculate_2N * 2;
	    end
	end
end 
endfunction 

//reset the init set of filter coff; 
task init_reset_a(input [3:0] rst_delay = 3);
    $write("Here is the init port a set,reset\n");
	o_rst_a <= 1'b1;
	o_wr_en_a <= 1'b0;
	o_wrdata_a <= {(`DWA){1'b0}};
	o_addr_a <= {(`AWA){1'b0}};
	repeat(rst_delay) @(posedge i_clk_a);
	o_rst_a <= 1'b0;
	o_wr_en_a <= 1'b0;
	o_wrdata_a <= {(`DWA){1'b0}};
	o_addr_a <= {(`AWA){1'b0}};
	@(posedge i_clk_a);
endtask 

task init_reset_b(input [3:0] rst_delay = 3);
    $write("Here is the init port b set,reset\n");
	o_rst_b <= 1'b1;
	o_wr_en_b <= 1'b0;
	o_wrdata_b <= {(`DWA){1'b0}};
	o_addr_b <= {(`AWA){1'b0}};
	repeat(rst_delay) @(posedge i_clk_b);
	o_rst_b <= 1'b0;
	o_wr_en_b <= 1'b0;
	o_wrdata_b <= {(`DWA){1'b0}};
	o_addr_b <= {(`AWA){1'b0}};
	@(posedge i_clk_b);
endtask 

logic [4:0] sample_count = 5'd0; 
logic [4:0] sample_step = 5'd0; 
reg [31:0]  o_data = 32'd0;
//genate the orginal data;

task dataa_write(input frame_first = 0);
    //rand the begin addr of wr addr .
    PORTA_WRADDR.randomize();
	//TEST_NUM.test_mode,MULT_NUM.mult_mode,$time);
	$write("here is port a write;this is the %4d times,the init_addr is %4d at time: %12d \n",num_current_a,PORTA_WRADDR.addr_mode,$time);
	
	write_numa_max = calculate_2N(`AWA);
	o_wrdata_a = {(`DWA){1'b0}};
	//accroding the addr_mode,set o_addr_a init value;
	case(PORTA_WRADDR.addr_mode)
	    0 : o_addr_a   = {{2'b00},{(`AWA-2){1'b0}}};
		1 : o_addr_a   = {{2'b01},{(`AWA-2){1'b0}}};
		2 : o_addr_a   = {{2'b10},{(`AWA-2){1'b0}}};
		3 : o_addr_a   = {{2'b11},{(`AWA-2){1'b0}}};
		default :      
		    o_addr_a   = {{2'b00},{(`AWA-2){1'b0}}};
	endcase;   
    	
	for(int sample_a = 0; sample_a < write_numa_max; sample_a ++)
	begin
		dataa_ram[o_addr_a] = o_wrdata_a;
		o_wr_en_a = 1'b1;
		//$write("here is port a write;this is the %4d times,the read addr is %4d,data is : %4d ,for sample_a is: %4d, at time: %12d \n",num_current_a,o_addr_a,o_wrdata_a,sample_a,$time);
		@(posedge i_clk_a);
		o_wrdata_a = o_wrdata_a + 1;
		o_addr_a = o_addr_a + 1;
	end 
	o_wr_en_a = 1'b0;
	@(posedge i_clk_a);	
    num_current_a = num_current_a + 1;
endtask

task datab_write(input frame_first = 0);
    //rand the begin addr of wr addr .
    PORTB_WRADDR.randomize();
	$write("here is port b write;this is the %4d times,the init_addr is %4d at time: %12d \n",num_current_b,PORTB_WRADDR.addr_mode,$time);
	
	write_numb_max = calculate_2N(`AWB);
	o_wrdata_b = {(`DWB){1'b0}};
	//accroding the addr_mode,set o_addr_a init value;
	case(PORTB_WRADDR.addr_mode)
	    0 : o_addr_b   = {{2'b00},{(`AWB-2){1'b0}}};
		1 : o_addr_b   = {{2'b01},{(`AWB-2){1'b0}}};
		2 : o_addr_b   = {{2'b10},{(`AWB-2){1'b0}}};
		3 : o_addr_b   = {{2'b11},{(`AWB-2){1'b0}}};
		default : 
		    o_addr_b   = {{2'b00},{(`AWB-2){1'b0}}};
	endcase;
	for(int sample_b = 0; sample_b < write_numb_max; sample_b ++)
	begin
		datab_ram[o_addr_b] = o_wrdata_b;
		o_wr_en_b = 1'b1;
		@(posedge i_clk_b);
		o_wrdata_b = o_wrdata_b + 1;
		o_addr_b = o_addr_b + 1;
		//ul_data_msg1.push_back({ul_data_first_1_o,ul_data_vld_1_o,ul_data_1_o});
	end 
	o_wr_en_b = 1'b0;
	@(posedge i_clk_b);
    num_current_b = num_current_b + 1;
endtask


task dataa_read(input read_delay = 1);
    //rand the begin addr of rd addr .
    PORTA_RDADDR.randomize();
	$write("here is port a read;this is the %4d times,the init_addr is %4d at time: %12d \n",num_current_ar,PORTA_RDADDR.addr_mode,$time);
    num_current_ar = num_current_ar + 1;
	
	read_numa_max = calculate_2N(`AWA);
	//accroding the addr_mode,set o_addr_a init value;
	case(PORTA_RDADDR.addr_mode)
	    0 : o_addr_a   = {{2'b00},{(`AWA-2){1'b0}}};
		1 : o_addr_a   = {{2'b01},{(`AWA-2){1'b0}}};
		2 : o_addr_a   = {{2'b10},{(`AWA-2){1'b0}}};
		3 : o_addr_a   = {{2'b11},{(`AWA-2){1'b0}}};
		default : 
		    o_addr_a   = {{2'b00},{(`AWA-2){1'b0}}};
	endcase;
	for(int sample_ar = 0; sample_ar < read_numa_max; sample_ar ++)
	begin
		@(posedge i_clk_a);
		mbox_porta.put(i_rddata_a);
		mbox_addra.put(o_addr_a);
		//$write("here is port a read;this is the %4d times,the read addr is %4d,data is : %4d at time: %12d \n",num_current_ar,o_addr_a,i_rddata_a,$time);
		o_addr_a = o_addr_a + 1;
		//ul_data_msg1.push_back({ul_data_first_1_o,ul_data_vld_1_o,ul_data_1_o});
	end 
endtask

task datab_read(input read_delay = 1);
    //rand the begin addr of rd addr .
    PORTB_RDADDR.randomize();
	$write("here is port b read;this is the %4d times,the init_addr is %4d at time: %12d \n",num_current_br,PORTB_RDADDR.addr_mode,$time);
    num_current_br = num_current_br + 1;
	
	read_numb_max = calculate_2N(`AWB);
	//accroding the addr_mode,set o_addr_a init value;
	case(PORTB_RDADDR.addr_mode)
	    0 : o_addr_b   = {{2'b00},{(`AWB-2){1'b0}}};
		1 : o_addr_b   = {{2'b01},{(`AWB-2){1'b0}}};
		2 : o_addr_b   = {{2'b10},{(`AWB-2){1'b0}}};
		3 : o_addr_b   = {{2'b11},{(`AWB-2){1'b0}}};
		default : 
		    o_addr_b   = {{2'b00},{(`AWB-2){1'b0}}};
	endcase;
	for(int sample_br = 0; sample_br < read_numb_max; sample_br ++)
	begin
		@(posedge i_clk_b);
		mbox_portb.put(i_rddata_b);
		mbox_addrb.put(o_addr_b);
		o_addr_b = o_addr_b + 1;
	end 
endtask


//check the output data from axc_ul module , the simulate function is 
task porta_check(input [2:0] delay_cycle = 6);
    logic [`DWA-1:0] tempOut;
	logic [`AWA-1:0] tempAddr;
    logic [`DWA-1:0] wra_data_temp;
    logic [`DWB-1:0] wrb_data_temp;
    $write("check the data read in port a\n");
	while(1)
	begin
	    begin
        // Get the data that is read(poped) out of the mailbox                 
        mbox_porta.get(tempOut);
		mbox_addra.get(tempAddr);
		//Get the expected data from top of the ram
		wra_data_temp = dataa_ram[tempAddr];
		wrb_data_temp = datab_ram[tempAddr];
		//$write("TEST: FIFO read dataaaaa addr: 'h%0h & data: 'h%0h; dataa_ram : 'h%0h; datab_ram : 'h%0h\n",tempAddr,tempOut, wra_data_temp,wrb_data_temp); 
        // Compare the two
        assert( (wra_data_temp == tempOut) || (wrb_data_temp == tempOut) )  
	    //     $write("TEST: FIFO read data 'h%0h matched expected\n",tempOut); 
  	    else $write("TEST: FIFO read data 'h%0h DID NOT match expcted dataaaaa 'h%0h or 'h%0h\n",
		     tempOut, wra_data_temp,wrb_data_temp); 
        end
	end
endtask

//check the output data from axc_ul module , the simulate function is 
task portb_check(input [2:0] delay_cycle = 6);
    logic [`DWA-1:0] tempOut;
	logic [`AWA-1:0] tempAddr;
    logic [`DWA-1:0] wra_data_temp;
    logic [`DWB-1:0] wrb_data_temp;
    $write("check the data read in port b\n");
	while(1)
	begin
	    begin
        // Get the data that is read(poped) out of the mailbox                 
        mbox_portb.get(tempOut);
		mbox_addrb.get(tempAddr);
		//Get the expected data from top of the ram
		wra_data_temp = dataa_ram[tempAddr];
		wrb_data_temp = datab_ram[tempAddr];
        // Compare the two
        assert( (wra_data_temp == tempOut) || (wrb_data_temp == tempOut) )  
	    // $write("TEST: FIFO read data 'h%0h matched expected\n",tempOut); 
  	    else $write("TEST: FIFO read data 'h%0h DID NOT match expcted databbbbb 'h%0h or 'h%0h\n",
		     tempOut, wra_data_temp,wrb_data_temp); 
        end
	end
endtask



initial begin : main_prog
////////////////////////////////
  //    Instantiation of objects    
  ////////////////////////////////
  my_msg_crv_0 = new(); 
  mbox_porta = new(); 
  mbox_portb = new(); 
  mbox_addra = new(); 
  mbox_addrb = new();
  PORTA_WRADDR = new();
  PORTA_RDADDR = new();
  PORTB_WRADDR = new();
  PORTB_RDADDR = new();
  @(posedge i_clk_a); //%%%%%%%%%%%%%cause the error of initial unclear status 
 
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
    init_reset_a(1);
	init_reset_b(1);
  join
  
  
  //////////////////////////////////////////
  //  The checker block is spawn in the 
  //  background ( fork join_none construct)
  //////////////////////////////////////////

  //fork
 //   bcn_generate();
	
  //join_none
  
  fork
    porta_check();
    portb_check();
  join_none

  ////////////////////////////////////////////
  //  Basic Test, read/write every clock cycle 
  //  start write and read in parallel and 
  //  sample the covergroups initially
  ////////////////////////////////////////////
  
//  //check the first time,pa_write - pa_read,pb_write - pb_read,
//  fork
//    dataa_write(1);
//	//@(posedge i_clk_a);
//  join
//  
//  fork
//    dataa_read(1);
//	//@(posedge i_clk_a);
//  join
//  
//  fork
//    datab_write(1);
//	//@(posedge i_clk_b);
//  join
//  
//  fork
//	datab_read(1);  
//	$write("------complete the first data generate and check----------\n");
//    //@(posedge i_clk_b);
//	my_msg_crv_0.sample();
//  join
    dataa_write(1);
	dataa_read(1);
	@(posedge i_clk_a);
	datab_write(1);
	datab_read(1);
	@(posedge i_clk_b);
	$write("------complete the first data only A synchronously generate and check----------\n");
	@(posedge i_clk_a) my_msg_crv_0.sample();
	repeat(10)@(posedge i_clk_a);
	
//    fork
//        begin
//	      dataa_write(1);
//	  	  dataa_read(1);
//	  	  datab_write(1);
//	  	  datab_read(1);
//	    end
//	    $write("------complete the first data only A synchronously generate and check----------\n");
//	    @(posedge i_clk_a) my_msg_crv_0.sample();
//    join
  
  
//  fork
//      dataa_write(1);
//	  dataa_read(1);  
//      @(posedge i_clk_a);
//	  my_msg_crv_0.sample();
//  join 
    
//	dataa_write(1);
//	dataa_read(1);
//	datab_write(1);
//	datab_read(1);
//	$write("------complete the first data aabb synchronously generate and check----------\n");
//	dataa_write(1);
//	dataa_read(1);
//	datab_write(1);
//	datab_read(1);
//	$write("------complete the NO.2 data aabb synchronously generate and check----------\n");
//	@(posedge i_clk_a) my_msg_crv_0.sample();
//	dataa_write(1);
//	dataa_read(1);
//	datab_write(1);
//	datab_read(1);
//	$write("------complete the NO.3 data aabb synchronously generate and check----------\n");
//	@(posedge i_clk_a) my_msg_crv_0.sample();
//	dataa_write(1);
//	dataa_read(1);
//	datab_write(1);
//	datab_read(1);
//	$write("------complete the NO.4 data aabb synchronously generate and check----------\n");
//	@(posedge i_clk_a) my_msg_crv_0.sample();
//	
//  fork
//      dataa_write(1);
//	  dataa_read(1);  
//	  $write("------complete the first data only A synchronously generate and check----------\n");
//      @(posedge i_clk_a);
//	  my_msg_crv_0.sample();
//  join 
//  
//  fork
//      datab_write(1);
//	  datab_read(1);
//	  $write("------complete the first data only B synchronously generate and check----------\n");
//      @(posedge i_clk_b);
//	  my_msg_crv_0.sample();
//  join 
//  
    fork
        dataa_write(1);
	    datab_read(1);  
	    $write("------complete the first data a write and data b read synchronously generate and check----------\n");
        @(posedge i_clk_a);
	    my_msg_crv_0.sample();
    join 
     
    repeat(10)@(posedge i_clk_a);	
	
    fork
      dataa_write(1);
	  datab_read(1);  
	  $write("------complete the first data a write and data b read synchronously generate and check----------\n");
      @(posedge i_clk_a);
	  my_msg_crv_0.sample();
    join 
    
	repeat(10)@(posedge i_clk_a);
	
	fork
        datab_write(1);
	    dataa_read(1);  
	    $write("------complete the first data a write and data b read synchronously generate and check----------\n");
        @(posedge i_clk_a);
	    my_msg_crv_0.sample();
    join 
	
    repeat(10)@(posedge i_clk_a);
	
	fork
        datab_write(1);
	    dataa_read(1);  
	    $write("------complete the first data a write and data b read synchronously generate and check----------\n");
        @(posedge i_clk_a);
	    my_msg_crv_0.sample();
    join 
	
	
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



endprogram : test_dual_ram	