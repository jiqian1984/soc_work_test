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

module ADC_source(  
    input	rst, 
	input 	clk_p,
	input 	clk_n,

	input 	din0_in,
	input 	din1_in,

	output	din0A_n,
	output	din0A_p,
	output	din1A_n,
	output	din1A_p,
	output	din0B_n,
	output	din0B_p,
	output	din1B_n,
	output	din1B_p,

	output	fco_n,
	output 	fco_p,
	output 	dco_n,
	output  dco_p,
	output 	pll_locked
    );
 
  	wire sample_clk;
	IBUFDS	#(
		.DIFF_TERM		(	"TRUE"		),      // Differential Termination
		.IBUF_LOW_PWR	(	"TRUE"		),		// Low power="TRUE", Highest performance="FALSE" 
		.IOSTANDARD		(	"DEFAULT"	)     	// Specify the input I/O standard
		)	
	uut0_sample_clk_IBUFDS(
		.O	(	sample_clk	),  // 1-bit output: Buffer output
		.I	(	clk_p	),   	// 1-bit input: Diff_p buffer input (connect directly to top-level port)
		.IB	(	clk_n	)  		// 1-bit input: Diff_n buffer input (connect directly to top-level port)
		); 

	wire dco_clk;
    wire fco_clk;
    clk_wiz_1 
    uut0_clk_wiz_1(  
        .reset(~rst),
        .clk_in1(sample_clk),
		.locked(pll_locked),
		.clk_out1(dco_clk),
		.clk_out2(fco_clk)
        );

 	OBUFDS #(
      	.IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      	.SLEW("SLOW")           // Specify the output slew rate
   		) 
   	uut0_dco_clk_OBUFDS(
      	.O(dco_p),     	// Diff_p output (connect directly to top-level port)
      	.OB(dco_n),    	// Diff_n output (connect directly to top-level port)
      	.I(dco_clk)     // Buffer input
   		);
	
	OBUFDS #(
      	.IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      	.SLEW("SLOW")           // Specify the output slew rate
   		) 
   	uut1_fco_clk_OBUFDS(
      	.O(fco_p),     // Diff_p output (connect directly to top-level port)
      	.OB(fco_n),    // Diff_n output (connect directly to top-level port)
      	.I(fco_clk)    // Buffer input
   		);

	OBUFDS #(
      	.IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      	.SLEW("SLOW")           // Specify the output slew rate
   		) 
   	uut2_A_din0_OBUFDS(
      	.O(din0A_p),     // Diff_p output (connect directly to top-level port)
      	.OB(din0A_n),    // Diff_n output (connect directly to top-level port)
      	.I(din0_in)    // Buffer input
   		);

	OBUFDS #(
      	.IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      	.SLEW("SLOW")           // Specify the output slew rate
   		) 
   	uut3_A_din1_OBUFDS(
      	.O(din1A_p),     // Diff_p output (connect directly to top-level port)
      	.OB(din1A_n),    // Diff_n output (connect directly to top-level port)
      	.I(din1_in)    // Buffer input
   		);

	OBUFDS #(
      	.IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      	.SLEW("SLOW")           // Specify the output slew rate
   		) 
   	uut4_B_din0_OBUFDS(
      	.O(din0B_p),     // Diff_p output (connect directly to top-level port)
      	.OB(din0B_n),    // Diff_n output (connect directly to top-level port)
      	.I(din1_in)    // Buffer input
   		);

	OBUFDS #(
      	.IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      	.SLEW("SLOW")           // Specify the output slew rate
   		) 
   	uut5_B_din1_OBUFDS(
      	.O(din1B_p),     // Diff_p output (connect directly to top-level port)
      	.OB(din1B_n),    // Diff_n output (connect directly to top-level port)
      	.I(din0_in)    // Buffer input
   		);

endmodule
