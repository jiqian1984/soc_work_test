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

module ADC_slaver_read(  
    input	rst,  
    input	clk,

	input	Bit_clock,
	input 	Bit_clear,
	input 	Bit_channel,
	input [15:0] channelA_len,
	input [15:0] channelB_len,
	input [23:0] read_data,
	output reg [15:0] addrb,
	output reg [11:0] Bit_dat
    );

	reg clk_ext;
	reg [7:0]	count;
	reg [3:0]	read_en;
	reg [3:0]	clk_delay;
  	always@(posedge clk or negedge rst)
	begin
		if (1'b0 == rst)
		begin
			clk_ext		<= 1'b0;
			read_en		<= 4'h0;
			clk_delay	<= 4'h0;						
			count		<= 8'h00;
			addrb		<= 16'h0000;	
			Bit_dat		<= 12'h000;
		end
		else
		begin
			read_en		<= {read_en[2:0],Bit_clear};
			clk_delay	<= {clk_delay[2:0],Bit_clock};
			if (2'b01 == read_en[3:2])
			begin
				clk_ext		<= 1'b1;
				count		<= 8'h00;
				addrb 		<= 16'hFFFF;
				Bit_dat		<= 12'h000;
			end
			else if (1'b1 == clk_ext)
			begin
				if (2'b01 == clk_delay[1:0])
				begin
					count	<= 8'h02;
					addrb	<= addrb + 1'b1;
					if ((1'b0 == Bit_channel) && (addrb == channelA_len-1))
						clk_ext	<= 1'b0;
					else if ((1'b1 == Bit_channel) && (addrb == channelB_len-1))
						clk_ext	<= 1'b0;
				end
				else
				begin
					if (8'h0 == count)
					begin	
						if (1'b0 == Bit_channel)
							Bit_dat	<= doutb[11:0];
						else
							Bit_dat	<= doutb[23:12];
					end
					else
						count	<= count - 1'b1;
				end
			end
		end
	end

endmodule

