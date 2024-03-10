`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2023 02:21:05 PM
// Design Name: 
// Module Name: top_lvds
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ADC_write(  
    input	rst, 
	input 	clk, 
	input	clk_200M,	
//	input 	capt_mode,
	input	capt_start,
	input 	Bit_start,
	input 	adc_valid,
	input [23:0]	adc_tdata,
	input [15:0]	capt_length,
	output reg wea,
	output reg [15:0] addra,
	output reg [23:0] dina
    );
 
	reg	vld_capt;
	reg [ 3:0]	count0;
  	always@(posedge clk or negedge rst)
	begin
		if (1'b0 == rst)
		begin
			count0		<= 4'h0;
			vld_capt	<= 1'b0;
		end
		else
		begin
			if (1'b1 == capt_start)
			begin
				count0		<= 4'hF;
				vld_capt	<= 1'b1;
			end
			else if (4'h0 != count0)	
				count0		<= count0 - 1'b1;
			else
				vld_capt	<= 1'b0;
		end
	end
	
	reg capt_en;
	reg [7:0]	vld1_capt;
	reg [7:0]	vld2_capt;
	always@(posedge clk_200M or negedge rst)
	begin
		if (1'b0 == rst)
		begin
			capt_en		<= 1'b0;
			vld1_capt	<= 8'h00;
			vld2_capt	<= 8'h00;
		end
		else
		begin
			vld1_capt	<= {vld1_capt[6:0],vld_capt};
			vld2_capt	<= {vld2_capt[6:0],Bit_start};
			if ((2'b10 == vld1_capt[7:6]) || (2'b01 == vld2_capt[7:6]))
				capt_en	<= 1'b1;
			else
				capt_en	<= 1'b0;
		end
	end 

	reg [15:0]	tmp1,tmp2,tmp3,tmp4;
	reg [15:0]	Gate;
   	always@(posedge clk_200M or negedge rst)
	begin
		if (1'b0 == rst)
		begin
			wea		<= 1'b0;
			addra	<= 16'hFFFF;	
			dina	<= 24'h0;
			tmp1	<= 16'h0;
			tmp2	<= 16'h0;
			tmp3	<= 16'h0;
			tmp4	<= 16'h0;
			Gate	<= 16'h0;
		end
		else
		begin
			tmp4	<= tmp3;
			tmp3	<= tmp2;
			tmp2	<= tmp1;
			tmp1	<= capt_length;
			if (1'b1 == capt_en)
			begin	
				wea		<= 1'b0;		
				addra	<= 16'hFFFF;
				Gate	<= tmp4;
			end
			if ((16'h0 != Gate) )
			begin
				if (1'b1 == adc_valid)
				begin
					wea		<= 1'b1;
					Gate	<= Gate - 1'b1;
					addra	<= addra + 1'b1;
					dina	<= adc_tdata;
				end
				else
					wea		<= 1'b0;
			end
			else
			begin		
				wea		<= 1'b0;
				addra	<= 16'hFFFF;
				dina	<= 24'h0;
			end
		end
	end

endmodule
