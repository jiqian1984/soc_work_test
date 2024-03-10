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

module ADC_uart_read(  
    input	rst,  
    input	clk,

	input   read_start,
	input 	read_channel,
	input [15:0]	channelA_len,
	input [15:0]	channelB_len,
	input [23:0]	read_data,

	output reg ad_valid,
	output reg [15:0] addrb,
	output reg [31:0] ad_tdata
    );

	localparam time_gap = 16'h0080;
	localparam time_per = 16'h0C00;

	reg clk_vld;
	reg [15:0]	count;
	reg [ 3:0]	read1_en;
    reg [31:0]  tmp_tdata;
    always@(posedge clk or negedge rst)
	begin
		if (1'b0 == rst)
		begin
			count		<= 16'h0;
			clk_vld		<= 1'b0;
			read1_en	<= 4'h0;
			addrb		<= 16'h0;	
			ad_valid	<= 1'b0;
			ad_tdata	<= 32'h0;
            tmp_tdata   <= 32'h0;
		end
		else
		begin
			read1_en <= {read1_en[2:0],read_start};
			if (2'b01 == read1_en[3:2])
			begin
				clk_vld	    <= 1'b1;
				ad_valid    <= 1'b0;
				count	    <= 16'h00;
				addrb	    <= 16'hFFFF;
				ad_tdata    <= 32'h0;
                tmp_tdata   <= 32'h0;
			end
			if (1'b1 == clk_vld)
			begin
				count	<=	count + 1'b1;
                if (count == time_gap)
                	addrb	<= addrb + 1'b1; 
				else if (count == 2*time_gap)
				begin
					addrb	<= addrb + 1'b1;
                    if (1'b0 == read_channel)
                        tmp_tdata[31:16] <= {read_data[11:0],4'h0};
                    else
                        tmp_tdata[31:16] <= {read_data[23:12],4'h0};
				end
                else if (count == 3*time_gap)
                begin          
                    if (1'b0 == read_channel)
                    begin
                        tmp_tdata[15:0]  <= {read_data[11:0],4'h0};
                        if (addrb >= channelA_len)
						    clk_vld	<= 1'b0;
                    end
                    else
                    begin
                        tmp_tdata[15:0]  <= {read_data[23:12],4'h0};
                        if (addrb >= channelB_len)
						    clk_vld	<= 1'b0;
                    end                   
                end
                else if (count == 4*time_gap)
                begin
                    ad_valid    <= 1'b1;
                    ad_tdata    <= tmp_tdata;
                end
				else if (count == time_per)
					count		<= 16'h0;
                else
                    ad_valid    <= 1'b0;	
			end
		end
	end

endmodule