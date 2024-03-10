`timescale 1ns / 1ps

module REG_mapper(
	input 	clk,
	input 	rst_n,

	input 	rx_valid,
	input [7:0]	rx_data,

	output reg	ver_valid,
	output reg [31:0]	ver_tdata,
	output reg  spi_valid,
	output reg [31:0]	spi_tdata,
	output reg 	capt_mode,
	output reg [15:0]	capt_length,	
	output reg [15:0]	channelA_len,
	output reg [15:0]	channelB_len,
	output reg  capt_start,
	output reg  read_start,
	output reg 	read_channel,
	output reg  adc_out,
	output reg  div_valid,
	output reg [7:0] adc_div,
	output reg  adc_rst
	);

	localparam	UART_flag	= 16'hAAAA;
	localparam	FPGA_ver	= 32'h2024_0104;
	
	reg cmd_valid;
	reg	[ 3:0] 	tmp_valid;
	reg [63:0]	tmp_tdata;
	reg [63:0]	cmd_tdata;
	always@(posedge clk or negedge rst_n)
	begin
		if (1'b0 == rst_n)
		begin
			tmp_valid	<= 4'h0;
			tmp_tdata	<= 64'h0;	
			cmd_valid	<= 1'b0;
			cmd_tdata	<= 64'h0;	
		end
		else
		begin
			if (1'b1 == rx_valid)
				tmp_tdata	<= {tmp_tdata[55:0],rx_data};
			if (UART_flag == tmp_tdata[15:0])
			begin
				cmd_tdata	<= tmp_tdata;
				tmp_valid	<= {tmp_valid[2:0],1'b1};
			end
			else
			begin
				tmp_valid	<= 4'h0;
				cmd_tdata	<= 64'h0;	
			end
			if (2'b01 == tmp_valid[3:2])
				cmd_valid	<= 1'b1;
			else
				cmd_valid	<= 1'b0;
		end
	end

	always@(posedge clk or negedge rst_n)
	begin
		if (1'b0 == rst_n)
		begin
			ver_valid	<= 1'b0;
			ver_tdata	<= 32'h0000_0000;
			spi_valid	<= 1'b0;
			spi_tdata	<= 32'h0000_0000;
			capt_mode	<= 1'b0;
			capt_length	<= 16'h4000;	
			channelA_len<= 16'h4000;
			channelB_len<= 16'h4000;
			capt_start	<= 1'b0;
			read_start	<= 1'b0;
			read_channel<= 1'b0;
			div_valid	<= 1'b0;
			adc_div		<= 8'h2;
			adc_out		<= 1'b0;
			adc_rst		<= 1'b0;
		end
		else 
		begin
			if (1'b1 == cmd_valid)
			begin
				case (cmd_tdata[63:48])
					16'h0000:	
					begin
						ver_valid	<= 1'b1;
						ver_tdata	<= FPGA_ver;
					end		
					16'h0001:	
					begin
						spi_valid	<= 1'b1;
						spi_tdata	<= cmd_tdata[47:16];
					end		
					16'h0002:	
					begin
						capt_mode	<= cmd_tdata[32];
						capt_length	<= cmd_tdata[31:16];
					end		
					16'h0004:	
					begin
						channelA_len<= cmd_tdata[47:32];
						channelB_len<= cmd_tdata[31:16];
					end	
					16'h0006:	
					begin
						capt_start	<= 1'b1;
					end	
					16'h0007:	
					begin
						read_start	<= 1'b1;
						read_channel<= cmd_tdata[16];
					end	
					16'h0008:	
					begin
						div_valid	<= 1'b1;
						adc_div		<= cmd_tdata[23:16];
					end
					16'h0009:	adc_out <= cmd_tdata[16];
					16'h000A:	adc_rst <= cmd_tdata[16];
				endcase
			end
			else
			begin
				ver_valid	<= 1'b0;
				ver_tdata	<= 32'h0000_0000;
				spi_valid	<= 1'b0;
				spi_tdata	<= 32'h0000_0000;
				capt_start	<= 1'b0;
				read_start	<= 1'b0;
				div_valid	<= 1'b0;
			end			
		end
	end

endmodule
