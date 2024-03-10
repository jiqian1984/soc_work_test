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

module DCO_adjust(  
    input		rst,  
	input 		clk_200m,
    input 		dclk_ext,
	output   	dclk_int,
	output   	fclk_int,
	output [7:0]   dco_bits
    );

	wire w_delay_rdy;
	(* IODELAY_GROUP = "dco_delay" *) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL
	IDELAYCTRL IDELAYCTRL_inst (
		.RDY(w_delay_rdy),       // 1-bit output: Ready output
		.REFCLK(clk_200m), // 1-bit input: Reference clock input
		.RST(~rst)        // 1-bit input: Active high reset input
	);
	
	wire	w1_dc_clk;
	wire 	w_fc_clk;
	wire[4:0]	w_delay_cnt;		
  	(* IODELAY_GROUP = "dco_delay" *) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL
   	IDELAYE2 #(
		.CINVCTRL_SEL("FALSE"),          // Enable dynamic clock inversion (FALSE, TRUE)
		.DELAY_SRC("IDATAIN"),           // Delay input (IDATAIN, DATAIN)
		.HIGH_PERFORMANCE_MODE("FALSE"), // Reduced jitter ("TRUE"), Reduced power ("FALSE")
		.IDELAY_TYPE("VAR_LOAD"),           // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
		.IDELAY_VALUE(0),                // Input delay tap setting (0-31)
		.PIPE_SEL("FALSE"),              // Select pipelined mode, FALSE, TRUE
		.REFCLK_FREQUENCY(200.0),        // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
		.SIGNAL_PATTERN("CLOCK")          // DATA, CLOCK input signal
		)
   	IDELAYE2_inst (
		.CNTVALUEOUT(), // 5-bit output: Counter value output
		.DATAOUT(w1_dc_clk),         // 1-bit output: Delayed data output
		.C(w_fc_clk),                     // 1-bit input: Clock input
		.CE(1'b0),                   // 1-bit input: Active high enable increment/decrement input
		.CINVCTRL(1'b0),       // 1-bit input: Dynamic clock inversion input
		.CNTVALUEIN(5'b00010),   // 5-bit input: Counter value input
		.DATAIN(1'b0),           // 1-bit input: Internal delay data input
		.IDATAIN(dclk_ext),         // 1-bit input: Data input from the I/O
		.INC(1'b0),                 // 1-bit input: Increment / Decrement tap delay input
		.LD(1'b1),                   // 1-bit input: Load IDELAY_VALUE input
		.LDPIPEEN(1'b0),       // 1-bit input: Enable PIPELINE register to load data input
		.REGRST(1'b0)            // 1-bit input: Active-high reset tap-delay input
		);

	wire w_dc_clk;
	wire w2_dc_clk;
	BUFIO
	uut0_BUFIO(
		.O(w_dc_clk),
		.I(w2_dc_clk)
		);

	BUFR #(
		.BUFR_DIVIDE("3"),
		.SIM_DEVICE("7SERIES")
		)
	uut0_BUFR(
		.O(w_fc_clk),
		.CE(1'b1),
		.CLR(1'b0),
		.I(w2_dc_clk)
		);

	ISERDESE2	#(
		.DATA_RATE("SDR"),
		.DATA_WIDTH(8),
		.DYN_CLKDIV_INV_EN("FALSE"),
		.DYN_CLK_INV_EN("FALSE"),
		.INIT_Q1(1'b0),
		.INIT_Q2(1'b0),
		.INIT_Q3(1'b0),
		.INIT_Q4(1'b0),	
		.INTERFACE_TYPE("NETWORKING"),
		.IOBDELAY("IBUF"),
		.NUM_CE(2),
		.OFB_USED("FALSE"),
		.SERDES_MODE("MASTER"),
		.SRVAL_Q1(1'b0),
		.SRVAL_Q2(1'b0),
		.SRVAL_Q3(1'b0),
		.SRVAL_Q4(1'b0)
		)
	uut_dco_iserdes2(
		.OFB(1'b0),
		.D(dclk_ext),	
		.DDLY(w1_dc_clk),

		.O(w2_dc_clk),
		.Q1(dco_bits[0]),
		.Q2(dco_bits[1]),
		.Q3(dco_bits[2]),
		.Q4(dco_bits[3]),
		.Q5(dco_bits[4]),
		.Q6(dco_bits[5]),
		.Q7(dco_bits[6]),
		.Q8(dco_bits[7]),
		.SHIFTOUT1(),
		.SHIFTOUT2(),		
		.SHIFTIN1(1'b0),
		.SHIFTIN2(1'b0),		

		.RST(~rst),		
		.BITSLIP(1'b0),
		
		.CE1(1'b1),
		.CE2(1'b1),
		.DYNCLKSEL(1'b0),
		.CLK(w_dc_clk),
		.CLKB(~w_dc_clk),

		.DYNCLKDIVSEL(1'b0),
		.CLKDIV(w_fc_clk),
		.OCLK(1'b0),
		.OCLKB(1'b0),
		.CLKDIVP(1'b0)
		);

	assign	dclk_int	=	w_dc_clk;
	assign	fclk_int	=	w_fc_clk;

endmodule
