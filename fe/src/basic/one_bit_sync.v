//=========================================================
//    Begin of Verilog HDL Header 
//    Copyright (C) 2016 by Nokia Shanghai Bell. All rights reserved.
//    Filename          : bcn_n2_latch.v
//    Function          : using signal (ca,vld,id) to latch the bcn_n2
//    FpgaName          : Xilinx Zynq Ultra+
//    Project           : --
//    Tools             : "Vivado 2016.2, Modelsim SE 10.1"
//    Reference         : 
//--------------------------------------------------------------------------------------------
//    Version Updates   :
//    XXmth201X  YY
//    V1.0   30Oct2019  : first version
//
//    End of Verilog HDL Header 
//
//=========================================================

//module describation:
//sync one bit from quick clock to solw clock,it use sync the plus signal,not for continues signal
module one_bit_sync
(
    //inputs
    input                             rst_i      ,
	
    input                             clk_high_i      ,
    input                             clk_low_i   ,
    //input control signal 
    input                             data_high_i,
	
    output                            data_low_o
);

///*********************************************************************
///internal singals defination
///*********************************************************************

reg     data_high_reg;
reg     data_low_reg0;
reg     data_low_reg1;
reg     data_low_reg2;
reg     data_low_outreg;
//wire    data_high_inreg;
//**********
//lanth the bcn_n2, 
//the data_id default is 5'b00000
//**********

//**********
//trans the ca form 491m to 307m,delay 307
//**********
always @ (posedge clk_high_i or posedge rst_i)
begin
    if(rst_i == 1'b1)begin
        data_high_reg <= 1'b0;
    end 
    else begin
	    if(data_high_i == 1'b1) 
		begin
		    data_high_reg <= not data_high_reg;
		end 
		else
		begin
		    data_high_reg <=  data_high_reg;
		end
        //data_high_reg <= data_high_inreg;
    end 
end


always @ (posedge clk_low_i or posedge rst_i)
begin
    if(rst_i == 1'b1)begin
        data_low_reg0 <= 1'b0;
        data_low_reg1 <= 1'b0;
        data_low_reg2 <= 1'b0;
		data_low_outreg <= 1'b0;
    end 
    else begin
	    data_low_reg0 <= data_high_reg;
		data_low_reg1 <= data_low_reg0;
		data_low_reg2 <= data_low_reg1;
		if((data_low_reg2 xor data_low_reg1) == 1'b1)
		    data_low_outreg <= 1'b1;
		else
		    data_low_outreg <= 1'b0;
    end 
end

assign data_low_o = data_low_outreg;


endmodule
