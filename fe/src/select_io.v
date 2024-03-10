/*********************************************************************
 * SYNOPSYS CONFIDENTIAL                                             *
 *                                                                   *
 * This is an unpublished, proprietary work of Synopsys, Inc., and   *
 * is fully protected under copyright and trade secret laws. You may *
 * not view, use, disclose, copy, or distribute this file or any     *
 * information contained herein except pursuant to a valid written   *
 * license from Synopsys.                                            *
 *********************************************************************/

//-----------------------------------------------------------------------------
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1996 - 2004 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rick Kelly         2/21/97
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: 8cb3b816
// DesignWare_release: V-2004.06-DWF_0406
//
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
//
// ABSTRACT:  This is a basic FIR strauct filte.Support N-step,16bit float,and using rotate struct.
//            
//           programmable almost empty and almost full flags
//
//              Parameters:     Valid Values
//              ==========      ============
//              width           [ 1 to 256 ]
//              depth           [ 2 to 256 ]
//              ae_level        [ 1 to depth-1 ]
//              af_level        [ 1 to depth-1 ]
//              err_mode        [ 0 = sticky error flag w/ ptr check,
//                                1 = sticky error flag (no ptr chk),
//                                2 = dynamic error flag ]
//              reset_mode      [ 0 = asynchronous reset,
//                                1 = synchronous reset ]
//              
//              Input Ports:    Size    Description
//              ===========     ====    ===========
//              clk             1 bit   Input Clock
//              rst_n           1 bit   Active Low Reset
//              push_req_n      1 bit   Active Low Push Request
//              pop_req_n       1 bit   Active Low Pop Request
//              diag_n          1 bit   Active Low diagnostic control
//              data_in         W bits  Push data input
//
//              Output Ports    Size    Description
//              ============    ====    ===========
//              empty           1 bit   Empty Flag
//              almost_empty    1 bit   Almost Empty Flag
//              half_full       1 bit   Half Full Flag
//              almost_full     1 bit   Almost Full Flag
//              full            1 bit   Full Flag
//              error           1 bit   Error Flag
//              data_out        W bits  Pop data output
//
//
// MODIFIED: 
//		RJK	2/10/98
//		Added better handling of 'x' inputs and async rst
//
//-------------------------------------------------------------------------------
//
module slect_io#(
    parameter                       DW          = 4   ,
    parameter                       SP_Mult     = 4            
)
 (
   input REFCLK_200m,
   input clk_125M,
	input i_rst,
	
	input i_dclk,
   
   //input serial 
	input i_clk_p,
   input i_clk_n,
	input [DW-1 : 0] i_data_p,
	input [DW-1 : 0] i_data_n,
	
   //output serial
   output o_clk_p,
   output o_clk_n,
	output [DW-1 : 0]    o_data_p,
	output [DW-1 : 0]    o_data_n,
   
   //oout inter logic
   output               o_fclk,
   output [DW*SP_Mult-1 : 0]          o_pardata,
   //input inter logic
   input  [DW*SP_Mult-1 : 0]          i_pardata,
   
   //iserdes/oserdes  loop
   input  [DW-1 : 0] IFB,
   output [DW-1 : 0] OFB
	);

//wire [4:0]  inmode;
//wire [6:0]  opmode;
//wire [3:0]  alumode;
//wire [2:0]  carryinsel;

wire [DW-1 : 0]  data_ibuf_o;
wire [DW-1 : 0]  data_delay_o;
wire [DW-1 : 0]  o_serdesdata_buf;
 
wire dclk_f;

//inclk

   IBUFDS #(
      .DIFF_TERM("TRUE"),       // Differential Termination
      .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
   ) IBUFDS_inst (
      .O(dclk_f),  // Buffer output
      .I(i_clk_p),  // Diff_p buffer input (connect directly to top-level port)
      .IB(i_clk_n) // Diff_n buffer input (connect directly to top-level port)
   )
   BUFR #(
		.BUFR_DIVIDE("4"),
		.SIM_DEVICE("7SERIES")
		)
	uut0_BUFR(
		.O(o_fclk),
		.CE(1'b1),
		.CLR(1'b0),
		.I(dclk_f)
		);
   
//outclk

   OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("FAST")           // Specify the output slew rate
   ) OBUFDS_inst (
      .O(o_clk_p),     // Diff_p output (connect directly to top-level port)
      .OB(o_clk_n),   // Diff_n output (connect directly to top-level port)
      .I(i_dclk)      // Buffer input
   );

generate 	
   genvar Ilane_num;
   for(Ilane_num=0;Ilane_num < DW;Ilane_num <= Ilane_num + 1)	
   begin	

//   IBUFDS    : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (IBUFDS_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

   // IBUFDS: Differential Input Buffer
   //         Artix-7
   // Xilinx HDL Language Template, version 2018.3

   IBUFDS #(
      .DIFF_TERM("TRUE"),       // Differential Termination
      .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
   ) IBUFDS_inst (
      .O(data_ibuf_o[Ilane_num]),  // Buffer output
      .I(datain_p[Ilane_num]),  // Diff_p buffer input (connect directly to top-level port)
      .IB(datain_n[Ilane_num]) // Diff_n buffer input (connect directly to top-level port)
   );

   // End of IBUFDS_inst instantiation
 

// IDELAYCTRL  : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (IDELAYCTRL_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

   // IDELAYCTRL: IDELAYE2/ODELAYE2 Tap Delay Value Control
   //             Artix-7
   // Xilinx HDL Language Template, version 2018.3

   (* IODELAY_GROUP = "datain_delay" *) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL

   IDELAYCTRL IDELAYCTRL_inst (
      .RDY(RDY),       // 1-bit output: Ready output
      .REFCLK(REFCLK_200m), // 1-bit input: Reference clock input
      .RST(i_rst)        // 1-bit input: Active high reset input
   );

   // End of IDELAYCTRL_inst instantiation
//  IDELAYE2   : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (IDELAYE2_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

   // IDELAYE2: Input Fixed or Variable Delay Element
   //           Artix-7
   // Xilinx HDL Language Template, version 2018.3

   (* IODELAY_GROUP = "datain_delay" *) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL

   IDELAYE2 #(
      .CINVCTRL_SEL("FALSE"),          // Enable dynamic clock inversion (FALSE, TRUE)
      .DELAY_SRC("IDATAIN"),           // Delay input (IDATAIN, DATAIN)
      .HIGH_PERFORMANCE_MODE("FALSE"), // Reduced jitter ("TRUE"), Reduced power ("FALSE")
      .IDELAY_TYPE("VAR_LOAD"),           // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
      .IDELAY_VALUE(0),                // Input delay tap setting (0-31)
      .PIPE_SEL("FALSE"),              // Select pipelined mode, FALSE, TRUE
      .REFCLK_FREQUENCY(200.0),        // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
      .SIGNAL_PATTERN("DATA")          // DATA, CLOCK input signal
   )
   IDELAYE2_inst (
      .CNTVALUEOUT(), // 5-bit output: Counter value output
      .DATAOUT(data_delay_o)[Ilane_num],         // 1-bit output: Delayed data output
      .C(clk_125M),                     // 1-bit input: Clock input
      .CE(1'b0),                   // 1-bit input: Active high enable increment/decrement input
      .CINVCTRL(1'b0),       // 1-bit input: Dynamic clock inversion input
      .CNTVALUEIN(5'b00010),   // 5-bit input: Counter value input
      .DATAIN(1'b0),           // 1-bit input: Internal delay data input
      .IDATAIN(data_ibuf_o[Ilane_num]),         // 1-bit input: Data input from the I/O
      .INC(1'b0),                 // 1-bit input: Increment / Decrement tap delay input
      .LD(1'b1),                   // 1-bit input: Load IDELAY_VALUE input
      .LDPIPEEN(1'b0),       // 1-bit input: Enable PIPELINE register to load data input
      .REGRST(1'b0)            // 1-bit input: Active-high reset tap-delay input
   );
   // End of IDELAYE2_inst instantiation



					
					

//  ISERDESE2  : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (ISERDESE2_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

   // ISERDESE2: Input SERial/DESerializer with Bitslip
   //            Artix-7
   // Xilinx HDL Language Template, version 2018.3

   ISERDESE2 #(
      .DATA_RATE("DDR"),           // DDR, SDR
      .DATA_WIDTH(4),              // Parallel data width (2-8,10,14)
      .DYN_CLKDIV_INV_EN("FALSE"), // Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
      .DYN_CLK_INV_EN("FALSE"),    // Enable DYNCLKINVSEL inversion (FALSE, TRUE)
      // INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
      .INIT_Q1(1'b0),
      .INIT_Q2(1'b0),
      .INIT_Q3(1'b0),
      .INIT_Q4(1'b0),
      .INTERFACE_TYPE("NETWORKING"),   // MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
      .IOBDELAY("NONE"),           // NONE, BOTH, IBUF, IFD
      .NUM_CE(2),                  // Number of clock enables (1,2)
      .OFB_USED("FALSE"),          // Select OFB path (FALSE, TRUE)
      .SERDES_MODE("MASTER"),      // MASTER, SLAVE
      // SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
      .SRVAL_Q1(1'b0),
      .SRVAL_Q2(1'b0),
      .SRVAL_Q3(1'b0),
      .SRVAL_Q4(1'b0)
   )
   ISERDESE2_inst (
      .O(),                       // 1-bit output: Combinatorial output
      // Q1 - Q8: 1-bit (each) output: Registered data outputs
      //[(Ilane_num+1)*SP_Mult - 1 : Ilane_num*SP_Mult]
      .Q1(o_pardata[Ilane_num*SP_Mult]),
      .Q2(o_pardata[Ilane_num*SP_Mult + 1]),
      .Q3(o_pardata[Ilane_num*SP_Mult + 2]),
      .Q4(o_pardata[Ilane_num*SP_Mult + 3]),
      .Q5(),
      .Q6(),
      .Q7(),
      .Q8(),
      // SHIFTOUT1, SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
      .SHIFTOUT1(),
      .SHIFTOUT2(),
      .BITSLIP(BITSLIP),           // 1-bit input: The BITSLIP pin performs a Bitslip operation synchronous to
                                   // CLKDIV when asserted (active High). Subsequently, the data seen on the Q1
                                   // to Q8 output ports will shift, as in a barrel-shifter operation, one
                                   // position every time Bitslip is invoked (DDR operation is different from
                                   // SDR).

      // CE1, CE2: 1-bit (each) input: Data register clock enable inputs
      .CE1(1'b1),
      .CE2(1'b1),
      .CLKDIVP(1'b0),           // 1-bit input: TBD
      // Clocks: 1-bit (each) input: ISERDESE2 clock input ports
      .CLK(dclk_int),                   // 1-bit input: High-speed clock
      .CLKB(~dclk_int),                 // 1-bit input: High-speed secondary clock
      .CLKDIV(o_fclk),             // 1-bit input: Divided clock
      .OCLK(1'b0),                 // 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY" 
      // Dynamic Clock versions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
      .DYNCLKDIVSEL(1'b0), // 1-bit input: Dynamic CLKDIV inversion
      .DYNCLKSEL(1'b0),       // 1-bit input: Dynamic CLK/CLKB inversion
      // Input Data: 1-bit (each) input: ISERDESE2 data input ports
      .D(data_delay_o[Ilane_num]),                       // 1-bit input: Data input
      .DDLY(1'b0),                 // 1-bit input: Serial data from IDELAYE2
      .OFB(IFB[Ilane_num]),                   // 1-bit input: Data feedback from OSERDESE2
      .OCLKB(1'b0),// 1-bit input: High speed negative edge output clock
      .RST(rst),                   // 1-bit input: Active high asynchronous reset
      // SHIFTIN1, SHIFTIN2: 1-bit (each) input: Data width expansion input ports
      .SHIFTIN1(1'b0),
      .SHIFTIN2(1'b0)
   );

   // End of ISERDESE2_inst instantiation
	   End
endgenerate				
 
//generate
//    genvar II_CPRI;
//    for(II_CPRI=0;II_CPRI<6;II_CPRI=II_CPRI+1)
//    begin
//         xxxx;
//         xxxx;
//
//    end
//endgenerate
//
generate 	
   genvar Olane_num;
   for(c=0;Olane_num < DW;Olane_num <= Olane_num + 1)	
   begin			

//  OSERDESE2  : In order to incorporate this function into the design,
//   Verilog   : the following instance declaration needs to be placed
//  instance   : in the body of the design code.  The instance name
// declaration : (OSERDESE2_inst) and/or the port declarations within the
//    code     : parenthesis may be changed to properly reference and
//             : connect this function to the design.  All inputs
//             : and outputs must be connected.

//  <-----Cut code below this line---->

   // OSERDESE2: Output SERial/DESerializer with bitslip
   //            Artix-7
   // Xilinx HDL Language Template, version 2018.3

   OSERDESE2 #(
      .DATA_RATE_OQ("DDR"),   // DDR, SDR
      .DATA_RATE_TQ("DDR"),   // DDR, BUF, SDR
      .DATA_WIDTH(4),         // Parallel data width (2-8,10,14)
      .INIT_OQ(1'b0),         // Initial value of OQ output (1'b0,1'b1)
      .INIT_TQ(1'b0),         // Initial value of TQ output (1'b0,1'b1)
      .SERDES_MODE("MASTER"), // MASTER, SLAVE
      .SRVAL_OQ(1'b1),        // OQ output value when SR is used (1'b0,1'b1)
      .SRVAL_TQ(1'b0),        // TQ output value when SR is used (1'b0,1'b1)
      .TBYTE_CTL("FALSE"),    // Enable tristate byte operation (FALSE, TRUE)
      .TBYTE_SRC("FALSE"),    // Tristate byte source (FALSE, TRUE)
      .TRISTATE_WIDTH(4)      // 3-state converter width (1,4)
   )
   OSERDESE2_inst (
      .OFB(OFB[Olane_num]),             // 1-bit output: Feedback path for data
      .OQ(o_serdesdata_buf[Olane_num]),               // 1-bit output: Data path output
      // SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
      .SHIFTOUT1(),
      .SHIFTOUT2(),
      .TBYTEOUT(),   // 1-bit output: Byte group tristate
      .TFB(),             // 1-bit output: 3-state control
      .TQ(),               // 1-bit output: 3-state control
      .CLK(dclk_int),             // 1-bit input: High speed clock
      .CLKDIV(o_fclk),       // 1-bit input: Divided clock
      // D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
      .D1(i_pardata[Olane_num*SP_Mult]),
      .D2(i_pardata[Olane_num*SP_Mult+1]),
      .D3(i_pardata[Olane_num*SP_Mult+2]),
      .D4(i_pardata[Olane_num*SP_Mult+3]),
      .D5(1'b0),
      .D6(1'b0),
      .D7(1'b0),
      .D8(1'b0),
      .OCE(1'b1),             // 1-bit input: Output data clock enable
      .RST(i_rst),             // 1-bit input: Reset
      // SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
      .SHIFTIN1(1'b0),
      .SHIFTIN2(1'b0),
      // T1 - T4: 1-bit (each) input: Parallel 3-state inputs
      .T1(1'b0),
      .T2(1'b0),
      .T3(1'b0),
      .T4(1'b0),
      .TBYTEIN(1'b0),     // 1-bit input: Byte group tristate
      .TCE(1'b0)              // 1-bit input: 3-state clock enable
   );

   // End of OSERDESE2_inst instantiation
					


//     OBUFDS      : In order to incorporate this function into the design,
//     Verilog     : the following instance declaration needs to be placed
//    instance     : in the body of the design code.  The instance name
//   declaration   : (OBUFDS_inst) and/or the port declarations within the
//      code       : parenthesis may be changed to properly reference and
//                 : connect this function to the design.  Delete or comment
//                 : out inputs/outs that are not necessary.

//  <-----Cut code below this line---->

   // OBUFDS: Differential Output Buffer
   //         Artix-7
   // Xilinx HDL Language Template, version 2018.3

   OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) OBUFDS_inst (
      .O(o_data_p[Olane_num]),     // Diff_p output (connect directly to top-level port)
      .OB(o_data_n[Olane_num]),   // Diff_n output (connect directly to top-level port)
      .I(o_serdesdata_buf[Olane_num])      // Buffer input
   );

   // End of OBUFDS_inst instantiation

   End
endgenerate
 

endmodule
