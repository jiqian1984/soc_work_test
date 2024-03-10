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

module UART_source(  
    input	rst, 
	input 	clk,
	output reg tx_valid,
	output reg [7:0] tx_data
    );
 
 	localparam	wlen	= 288;
	localparam 	gap		= 32'h0400;

	reg [31:0]	Gate;
	reg [31:0]	count1;
	reg [wlen*8-1:0]UART_word;
	always @(posedge clk or negedge rst)
	begin
		if (1'b0 == rst)
		begin
			tx_valid	<= 1'b0;
			tx_data		<= 8'h00;	
			Gate		<= gap;
			count1		<= 32'h00;	
			UART_word	<= { 
						32'h0000_0000,32'h0000_AAAA,	//read FPGA version
						32'h0001_1234,32'h5678_AAAA,	//write SPI register
						32'h0002_0000,32'h0080_AAAA,	//cofigure samlpe length
						32'h0004_0008,32'h0010_AAAA,	//cofigure read AB length 

						32'h0008_0000,32'h0004_AAAA,	//select 80Msps sample rate						
						32'h0009_0000,32'h0001_AAAA,	//enable ADC sample clock output
						32'h000A_0000,32'h0000_AAAA,	//reset ADC sample module in FPGA
						32'h000A_0000,32'h0001_AAAA,	//reset finished
						32'h0006_0000,32'h0000_AAAA,	//write sample data to RAM
						32'h0007_0000,32'h0001_AAAA,	//read chanel B sample data
						32'h0000_0000,32'h0000_0000,	//null
						32'h0000_0000,32'h0000_0000,	//null
						32'h0000_0000,32'h0000_0000,	//null
						32'h0000_0000,32'h0000_0000,	//null
						32'h0009_0000,32'h0000_AAAA,	//disable ADC sample clock output

						32'h0000_0000,32'h0000_AAAA,	//read FPGA version
						32'h0001_8234,32'h5678_AAAA,	//read SPI register

						32'h0008_0000,32'h0008_AAAA,	//select 125Msps sample rate
						32'h0009_0000,32'h0001_AAAA,	//enable ADC sample clock output
						32'h000A_0000,32'h0000_AAAA,	//reset ADC sample module in FPGA
						32'h000A_0000,32'h0001_AAAA,	//reset finished
						32'h0006_0000,32'h0000_AAAA,	//write sample data to RAM
						32'h0007_0000,32'h0000_AAAA,	//read chanel A sample data
						32'h0000_0000,32'h0000_0000,	//null
						32'h0000_0000,32'h0000_0000,	//null
						32'h0009_0000,32'h0000_AAAA,	//disable ADC sample clock output

						32'h0009_0000,32'h0001_AAAA,	//enable ADC sample clock output
						32'h0000_0000,32'h0000_0000,	//null
						32'h0009_0000,32'h0000_AAAA,	//disable ADC sample clock output
						32'h0009_0000,32'h0001_AAAA,	//enable ADC sample clock output
						32'h0000_0000,32'h0000_0000,	//null
						32'h0009_0000,32'h0000_AAAA,	//disable ADC sample clock output
						32'h0009_0000,32'h0001_AAAA,	//enable ADC sample clock output
						32'h0000_0000,32'h0000_0000,	//null

						32'h000A_0000,32'h0000_AAAA,
						32'h0000_0000,32'h0000_AAAA
						};	
		end
		else
		begin	
			count1		<= count1 + 1'b1;
			if (count1 == Gate)
			begin
				Gate 		<= Gate + gap;
				tx_valid	<= 1'b1;
				tx_data		<= UART_word[wlen*8-1:wlen*8-8];
				UART_word	<= {UART_word[wlen*8-9:0],8'h0};
			end	
			else
				tx_valid	<= 1'b0;
		end
	end

endmodule
