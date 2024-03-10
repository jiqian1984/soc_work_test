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

module ADC_interface(  
    input		rst,  
    input       clk_200M,
    input 		dco_n,
    input 		dco_p,
	input 		fco_n,
	input 		fco_p,
	input		din0A_n,
	input		din0A_p,
	input 		din1A_n,
	input 		din1A_p,
	input		din0B_n,
	input		din0B_p,
	input 		din1B_n,
	input 		din1B_p,
	output		w_dc_clk,
	output		w_fc_clk,
	output [ 7:0] dco_bits,		
	output [ 5:0] fco_bits,
	output [11:0] adcA_bits,
	output [11:0] adcB_bits,
	output 		adc_valid,
	output [23:0] adc_tdata
    );
 
    wire w0_dc_clk;
	IBUFDS	#(
		.DIFF_TERM		(	"TRUE"		), 		// Differential Termination
		.IBUF_LOW_PWR	(	"TRUE"		),     	// Low power="TRUE", Highest performance="FALSE" 
		.IOSTANDARD		(	"DEFAULT"	)     	// Specify the input I/O standard
		)	
	uut0_dco_IBUFDS(
		.O	(	w0_dc_clk	),  // 1-bit output: Buffer output
		.I	(	dco_p	),   	// 1-bit input: Diff_p buffer input (connect directly to top-level port)
		.IB	(	dco_n	)  		// 1-bit input: Diff_n buffer input (connect directly to top-level port)
		); 

	wire w_fc_refclk;
	IBUFDS	#(
		.DIFF_TERM		(	"TRUE"		),     	// Differential Termination
		.IBUF_LOW_PWR	(	"TRUE"		),     	// Low power="TRUE", Highest performance="FALSE" 
		.IOSTANDARD		(	"DEFAULT"	)     	// Specify the input I/O standard
		)	
	uut1_fco_IBUFDS(
		.O	(	w_fc_refclk	),   	// 1-bit output: Buffer output
		.I	(	fco_p	),   		// 1-bit input: Diff_p buffer input (connect directly to top-level port)
		.IB	(	fco_n	)  			// 1-bit input: Diff_n buffer input (connect directly to top-level port)
		); 

	wire din0A;
	IBUFDS	#(
		.DIFF_TERM		(	"TRUE"		),      // Differential Termination
		.IBUF_LOW_PWR	(	"TRUE"		),     	// Low power="TRUE", Highest performance="FALSE" 
		.IOSTANDARD		(	"DEFAULT"	)     	// Specify the input I/O standard
		)	
	uut2_din0_IBUFDS(
		.O	(	din0A	),   	// 1-bit output: Buffer output
		.I	(	din0A_p	),   	// 1-bit input: Diff_p buffer input (connect directly to top-level port)
		.IB	(	din0A_n	)  		// 1-bit input: Diff_n buffer input (connect directly to top-level port)
		); 
	
	wire din1A;
	IBUFDS	#(
		.DIFF_TERM		(	"TRUE"		),      // Differential Termination
		.IBUF_LOW_PWR	(	"TRUE"		),     	// Low power="TRUE", Highest performance="FALSE" 
		.IOSTANDARD		(	"DEFAULT"	)     	// Specify the input I/O standard
		)	
	uut3_din1_IBUFDS(
		.O	(	din1A	),   	// 1-bit output: Buffer output
		.I	(	din1A_p	),   	// 1-bit input: Diff_p buffer input (connect directly to top-level port)
		.IB	(	din1A_n	)  		// 1-bit input: Diff_n buffer input (connect directly to top-level port)
		); 

	wire din0B;
	IBUFDS	#(
		.DIFF_TERM		(	"TRUE"		),      // Differential Termination
		.IBUF_LOW_PWR	(	"TRUE"		),     	// Low power="TRUE", Highest performance="FALSE" 
		.IOSTANDARD		(	"DEFAULT"	)     	// Specify the input I/O standard
		)	
	uut4_din0_IBUFDS(
		.O	(	din0B	),   	// 1-bit output: Buffer output
		.I	(	din0B_p	),   	// 1-bit input: Diff_p buffer input (connect directly to top-level port)
		.IB	(	din0B_n	)  		// 1-bit input: Diff_n buffer input (connect directly to top-level port)
		); 
	
	wire din1B;
	IBUFDS	#(
		.DIFF_TERM		(	"TRUE"		),      // Differential Termination
		.IBUF_LOW_PWR	(	"TRUE"		),     	// Low power="TRUE", Highest performance="FALSE" 
		.IOSTANDARD		(	"DEFAULT"	)     	// Specify the input I/O standard
		)	
	uut5_din1_IBUFDS(
		.O	(	din1B	),   	// 1-bit output: Buffer output
		.I	(	din1B_p	),   	// 1-bit input: Diff_p buffer input (connect directly to top-level port)
		.IB	(	din1B_n	)  		// 1-bit input: Diff_n buffer input (connect directly to top-level port)
		); 

	DCO_adjust
	uut0_DCO_adjust(  
		.rst(rst),  
		.clk_200m(clk_200M),
		.dclk_ext(w0_dc_clk),
		.dclk_int(w_dc_clk),
		.fclk_int(w_fc_clk),
		.dco_bits(dco_bits)
		);

	wire valid_adc;
	DIN_sample
	uut0_DIN_sample(
		.rst(rst),
		.dclk_int(w_dc_clk),
		.fclk_int(w_fc_clk),
		.fco_ext(w_fc_refclk),
		.din0A_ext(din0A),
		.din1A_ext(din1A),
		.din0B_ext(~din0B),
		.din1B_ext(~din1B),
		.bits_fco(fco_bits),
		.valid_adc(valid_adc),
		.data_adcA(adcA_bits),
		.data_adcB(adcB_bits)
    	); 

	wire axis_ready;
	axis_data_fifo_1
	uut0_axis_data_fifo (
		.s_axis_aresetn(rst),
		.s_axis_aclk(w_fc_clk),
		.s_axis_tvalid(valid_adc),
		.s_axis_tready(axis_ready),
		.s_axis_tdata({adcB_bits,adcA_bits}),
		.m_axis_aclk(clk_200M),
		.m_axis_tvalid(adc_valid),
		.m_axis_tready(1'b1),
		.m_axis_tdata(adc_tdata)
		);

endmodule

