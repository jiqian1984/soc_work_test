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

module CLK_system(  
    input	rst,  
    input	clk,
	input   adc_out,
	input 	div_valid,
	input [7:0]	adc_div,
	output pll_locked,
	output clk_free,
	output clk_200M,
	output adclk_p,
	output adclk_n
    );

    wire clk_250M;
	wire clk_125M;
    clk_wiz_0 
    uut0_clk_wiz_0(  
        .reset(~rst),
        .clk_in1(clk),
		.locked(pll_locked),
		.clk_out1(clk_250M),
		.clk_out2(clk_200M),
		.clk_out3(clk_125M),
		.clk_out4(clk_free)
        );

	wire tmp_valid;
	wire [7:0] tmp_tdata;
	axis_data_fifo_2 
	uut0_axis_data_fifo_2(
		.s_axis_aresetn(rst),
		.s_axis_aclk(clk_free),
		.s_axis_tvalid(div_valid),
		.s_axis_tready(),
		.s_axis_tdata(adc_div),
		.m_axis_aclk(clk_250M),
		.m_axis_tvalid(tmp_valid),
		.m_axis_tready(1'b1),
		.m_axis_tdata(tmp_tdata)
		);

	reg [7:0] adc_period1;
	reg [7:0] adc_period2;
	reg [7:0] adc_period3;
	reg [7:0] adc_period4;	
	always@(posedge clk_250M or negedge rst)
	begin
		if (1'b0 == rst)
		begin
			adc_period1	<= 8'h2;
			adc_period2	<= 8'h2;
			adc_period3	<= 8'h2;
			adc_period4	<= 8'h2;
		end
		else 
			if (1'b1 == tmp_valid)
				adc_period1	<= tmp_tdata;
			adc_period2	<= adc_period1;
			adc_period3	<= adc_period2;
			adc_period4	<= adc_period3;			
	end

	reg clk_adc;
	reg [7:0] count1;
	always@(posedge clk_250M or negedge rst)
	begin
		if (1'b0 == rst)
		begin
			count1		<= 8'h1;
			clk_adc		<= 1'b0;
		end
		else if (1'b1 == pll_locked)
		begin
			count1	<=	count1 + 1'b1;
			if (count1 == {1'b0,adc_period4[7:1]})
				clk_adc	<= 1'b1;
			else if (count1 == adc_period4)
			begin
				count1	<= 8'h01;
				clk_adc	<= 1'b0;
			end
		end
	end 

/*	wire clk_adc;
	BUFGMUX #()
   	uut0_BUFGMUX_inst (
		.O(clk_adc),   // 1-bit output: Clock output
		.I0(clk_080M), // 1-bit input: Clock input (S=0)
		.I1(clk_125M), // 1-bit input: Clock input (S=1)
		.S(adc_div[0])    // 1-bit input: Clock select
   		);
*/

  	OBUFTDS #(
      	.IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      	.SLEW("SLOW")           // Specify the output slew rate
   		) 
   	uut0_OBUFTDS(
      	.O(adclk_p),     // Diff_p output (connect directly to top-level port)
      	.OB(adclk_n),    // Diff_n output (connect directly to top-level port)
      	.I(clk_adc),     // Buffer input
//		.I(clk_125M),
		.T(~adc_out)
   		);

endmodule