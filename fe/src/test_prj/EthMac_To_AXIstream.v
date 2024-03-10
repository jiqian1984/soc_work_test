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
module EthMac_to_AXI
 (
    input i_sys_clk,
	input i_rst_n,
	
	input [1:0] i_key,
	
	output         o_led_core,
	output [1 : 0] o_led_buttom,
	input          i_touch_key,

	output [DW-1 : 0] o_beep,
	
	input            i_uart_rxd,
    output           o_uart_txd,
    //atk_module interface 
    input            i_uart_rx,
    output           o_uart_tx,
    input            gbc_key,
    output           gbc_led,

    output           iic_scl,
    inout            iic_sda,
	input [47:0]     i_pcin,
	
	output [47:0]    o_pcout,
	output [47:0]    o_p
	);

wire [4:0]  inmode;
wire [6:0]  opmode;
wire [3:0]  alumode;
wire [2:0]  carryinsel;

//according the DSPMODE parameter,generate the inmode,opmode,alumode,carryinsel					  
generate
    if (MODE == 4'd0) //a*b
    begin
        assign inmode = 5'b00001;//A
        assign opmode = 7'b0000001;//X=M,Y=0,Z=0
        assign alumode = 4'b0000;//Z + X + Y + CIN
        assign carryinsel = 3'b000;//3'b000  carryin
    end
    else if (MODE == 4'd1)//pcin - (a*b + carryin)
    begin
        assign inmode = 5'b00001;//A
        assign opmode = 7'b0010001;//Z:PCIN X=M,Y=0,
        assign alumode = 4'b0011;//Z -( X + Y + CIN)
        assign carryinsel = 3'b000;//3'b000  carryin
    end
    else if (MODE == 4'd2)//a*b + PCIN
    begin
        assign inmode = 5'b00001;//A
        assign opmode = 7'b0010001;//Z:PCIN XY:M 
        assign alumode = 4'b0000;//Z + X + Y + CIN
        assign carryinsel = 3'b000;//3'b000  carryin
    end  
    else if (MODE == 4'd3)//(a+d)*b
    begin
        assign inmode = 5'b00100;//A
        assign opmode = 7'b0000001;//X=M,Y=0,Z=0
        assign alumode = 4'b0000;//Z + X + Y + CIN
        assign carryinsel = 3'b000;//3'b000  carryin
    end     
    else if (MODE == 4'd4)//(d-a)*b
    begin
        assign inmode = 5'b01100;//A+D
        assign opmode = 7'b0000001;//X=M,Y=0,Z=0
        assign alumode = 4'b0000;//Z + X + Y + CIN
        assign carryinsel = 3'b000;//3'b000  carryin
    end
    else if (MODE == 4'd5)//(a+d)*b + carry_in
    begin
        assign inmode = 5'b00100;//D-A
        assign opmode = 7'b0010001;//Z:PCIN X=M,Y=0,
        assign alumode = 4'b0000;//Z + X + Y + CIN
        assign carryinsel = 3'b000;//3'b000  carryin
    end
    else if (MODE == 4'd6)//(d-a)*b + carry_in
    begin
        assign inmode = 5'b01100;//(a+d)b
        assign opmode = 7'b0010001;//Z:PCIN X=M,Y=0,
        assign alumode = 4'b0000;//Z + X + Y + CIN
        assign carryinsel = 3'b000;//3'b000  carryin
    end
	else//defaulte mode is mode0(a*b)
	begin
	    assign inmode = 5'b00001;//a*b
        assign opmode = 7'b0000001;//Z:PCIN X=M,Y=0,
        assign alumode = 4'b0000;//Z + X + Y + CIN
        assign carryinsel = 3'b000;//3'b000  carryin
	end
endgenerate
 
 
 
 
    
	DSP48E1 #(
    .A_INPUT("DIRECT"),                   //Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
    .B_INPUT("DIRECT"),                   //Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
    .USE_DPORT("FALSE"),                    //Select D port usage (TRUE or FALSE)
    .USE_MULT("MULTIPLY"),                //Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
    //Pattern Detector Attributes: Pattern Detection Configuration
    .AUTORESET_PATDET("NO_RESET"),        //"NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
    .MASK("3fffffffffff"),               // 48-bit mask value for pattern detect (1=ignore)
    .PATTERN("000000000000"),            // 48-bit pattern match for pattern detect
    .SEL_MASK("MASK"),                    // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
    .SEL_PATTERN("PATTERN"),              // Select pattern value ("PATTERN" or "C")
    .USE_PATTERN_DETECT("NO_PATDET"),     // Enable pattern detect ("PATDET" or "NO_PATDET")
    //Register Control Attributes: Pipeline Register Configuration
    .ACASCREG(1),                           //Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
    .ADREG(1),                              //Number of pipeline stages for pre-adder (0 or 1)
    .ALUMODEREG(1),                         //Number of pipeline stages for ALUMODE (0 or 1)
    .AREG(1),                               //Number of pipeline stages for A (0, 1 or 2)
    .BCASCREG(1),                           //Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
    .BREG(1),                               //Number of pipeline stages for B (0, 1 or 2)
    .CARRYINREG(1),                         //Number of pipeline stages for CARRYIN (0 or 1)
    .CARRYINSELREG(1),                      //Number of pipeline stages for CARRYINSEL (0 or 1)
    .CREG(1),                               //Number of pipeline stages for C (0 or 1)
    .DREG(1),                               //Number of pipeline stages for D (0 or 1)
    .INMODEREG(1),                          //Number of pipeline stages for INMODE (0 or 1)
    .MREG(1),                               //Number of multiplier pipeline stages (0 or 1)
    .OPMODEREG(1),                          //Number of pipeline stages for OPMODE (0 or 1)
    .PREG(1),                               //Number of pipeline stages for P (0 or 1)
    .USE_SIMD("ONE48")                      //SIMD selection ("ONE48", "TWO24", "FOUR12")
    )
	u_DSP48E1 (
    //Cascade: 30-bit (each) output: Cascade Ports
    .ACOUT(),                   //30-bit output: A port cascade output
    .BCOUT(),                   //18-bit output: B port cascade output
    .CARRYCASCOUT(),            //1-bit output: Cascade carry output
    .MULTSIGNOUT(),             //1-bit output: Multiplier sign cascade output
    .PCOUT(o_pcout),                   //48-bit output: Cascade output
    //Control: 1-bit (each) output: Control Inputs/Status Bits
    .OVERFLOW(),                //1-bit output: Overflow in add/acc output
    .PATTERNBDETECT(),          //1-bit output: Pattern bar detect output
    .PATTERNDETECT(),           //1-bit output: Pattern detect output
    .UNDERFLOW(),               //1-bit output: Underflow in add/acc output
    //Data: 4-bit (each) output: Data Ports
    .CARRYOUT(),                //4-bit output: Carry output
    .P(o_p),                    //48-bit output: Primary data output
    //Cascade: 30-bit (each) input: Cascade Ports
    .ACIN(),         //30-bit input: A cascade data input
    .BCIN(),         //18-bit input: B cascade input
    .CARRYCASCIN(1'b0),              //1-bit input: Cascade carry input
    .MULTSIGNIN(1'b0),               //1-bit input: Multiplier sign input
    .PCIN(i_pcin),         //48-bit input: P cascade input
    //Control: 4-bit (each) input: Control Inputs/Status Bits
    .ALUMODE(alumode),      //4-bit input: ALU control input 0000:Z+X+Y+CIN
    .CARRYINSEL(carryinsel),   //3-bit input: Carry select input
    .CEINMODE(1'b1),                 //1-bit input: Clock enable input for INMODEREG
    .CLK(i_clk),                   //1-bit input: Clock input
    .INMODE(inmode),               //5-bit input: INMODE control input 1_0001:REGB1 REGA1
    .OPMODE(opmode),             //7-bit input: Operation mode input 001:0 0101 M
    .RSTINMODE(1'b0),                //1-bit input: Reset input for INMODEREG
    //Data: 30-bit (each) input: Data Ports
    .A(i_data_a),             //30-bit input: A data input
    .B(i_data_b),             //18-bit input: B data input
    .C(i_data_c),             //48-bit input: C data input
    .CARRYIN(i_pre_carry),    //1-bit input: Carry input signal
    .D(i_data_d),             //25-bit input: D data input
    //Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
    .CEA1(1'b1),                      //1-bit input: Clock enable input for 1st stage AREG
    .CEA2(1'b1),                      //1-bit input: Clock enable input for 2nd stage AREG
    .CEAD(1'b1),                      //1-bit input: Clock enable input for ADREG
    .CEALUMODE(1'b1),                //1-bit input: Clock enable input for ALUMODERE
    .CEB1(1'b1),                      //1-bit input: Clock enable input for 1st stage BREG
    .CEB2(1'b1),                      //1-bit input: Clock enable input for 2nd stage BREG
    .CEC(1'b1),                       //1-bit input: Clock enable input for CREG
    .CECARRYIN(1'b1),                 //1-bit input: Clock enable input for CARRYINREG
    .CECTRL(1'b1),                    //1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
    .CED(1'b1),                       //1-bit input: Clock enable input for DREG
    .CEM(1'b1),                       //1-bit input: Clock enable input for MREG
    .CEP(1'b1),                       //1-bit input: Clock enable input for PREG
    .RSTA(1'b0),                      //1-bit input: Reset input for AREG , * changed on 150929 for timing , orignal: rst
    .RSTALLCARRYIN(1'b0),             //1-bit input: Reset input for CARRYINREG
    .RSTALUMODE(1'b0),           //1-bit input: Reset input for ALUMODEREG
    .RSTB(1'b0),                      //1-bit input: Reset input for BREG *
    .RSTC(1'b0),                      //1-bit input: Reset input for CREG *
    .RSTCTRL(1'b0),              //1-bit input: Reset input for OPMODEREG and CARRYINSELREG
    .RSTD(1'b0),                      //1-bit input: Reset input for DREG and ADREG *
    .RSTM(1'b0),                      //1-bit input: Reset input for MREG *
    .RSTP(1'b0)                  //1-bit input: Reset input for PREG 
    );

endmodule
