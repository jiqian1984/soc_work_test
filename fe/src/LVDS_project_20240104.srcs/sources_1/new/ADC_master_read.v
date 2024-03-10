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

module ADC_master_read(  
    input	rst,  
    input	clk,

	input   read_start,
	input 	read_channel,
	input [15:0]	channelA_len,
	input [15:0]	channelB_len,
	input [23:0]	read_data,

	output reg Bit_clk,
	output reg [15:0] addrb,
	output reg [11:0] Bit_dat
    );

	localparam	CLK_period	= 20;

	reg clk_vld;
	reg [7:0]	count;
	reg [3:0]	read1_en;
  	always@(posedge clk or negedge rst)
	begin
		if (1'b0 == rst)
		begin
			count		<= 8'h00;
			clk_vld		<= 1'b0;
			read1_en	<= 4'h0;
			addrb		<= 16'h0;	
			Bit_clk		<= 1'b0;
			Bit_dat		<= 12'h000;
		end
		else
		begin
			read1_en <= {read1_en[2:0],read_start};
			if (2'b01 == read1_en[3:2])
			begin
				clk_vld	<= 1'b1;
				Bit_clk	<= 1'b0;
				count	<= 8'h00;
				addrb	<= 16'hFFFF;
				Bit_dat	<= 12'h000;
			end
			if (1'b1 == clk_vld)
			begin
				count	<=	count + 1'b1;
				if (8'h01 == count)
				begin
					addrb	<= addrb + 1'b1;
					if ((1'b0 == read_channel) && (addrb == channelA_len-1))
						clk_vld	<= 1'b0;
					else if ((1'b1 == read_channel) && (addrb == channelB_len-1))
						clk_vld	<= 1'b0;
				end
				else if (8'h04 == count)
				begin
					if (1'b0 == read_channel)
						Bit_dat	<= read_data[11:0];
					else
						Bit_dat	<= read_data[23:12];
				end
				else if (CLK_period/2 == count)
					Bit_clk	<= 1'b1;
				else if (CLK_period == count)
				begin
					Bit_clk <= 1'b0;
					count	<= 8'h01;
				end	
			end
		end
	end

endmodule

