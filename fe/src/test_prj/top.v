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
module top
 (
    input i_sys_clk,
	input i_rst_n,
	
	input [1:0]    i_key,
	
	output         o_led_core,
	output [1 : 0] o_led_buttom,
	input          i_touch_key,

	output         o_beep,
	//uart
	input            i_uart_rxd,
    output           o_uart_txd,
    //atk_module interface 
    input            i_uart_rx,
    output           o_uart_tx,
    input            i_gbc_key,
    output           o_gbc_led,

    output           o_iic_scl,
    //inout            io_iic_sda,
    input            io_iic_sda,
	
	
	//can interface 
	output           o_can_tx,
	input            i_can_rx,
	
	//RGB TFT-LCD interface 
	output           o_lcd_hs,
	output           o_lcd_vs,
	output           o_lcd_de,
	output           o_lcd_bl,
	output           o_lcd_clk,
	output           o_lcd_rst,
	output [23:0]    o_rgb_data,
	output           o_lcd_scl,
	inout            io_lcd_sda,
	output           o_ct_rst,
	input            i_ct_int,
	
	//HDMI interface
	output [2:0]     o_tmds_data,
	output           o_tmds_clk_p,
//	output           o_tmds_scl,
//	output           o_tmds_sda,
	output           o_tmds_hpd,
	
//	//camera interface 
//	output           o_cam_sgm_ctrl,
//	output           o_cam_rst_n,
//	input            i_cam_vsync,
//	input            i_cam_href,
//	input            i_cam_pclk,
//	input [7:0]      i_cam_data,
//	input            i_cam_sck,
//	inout            io_cam_sda,
	
	//audio interface 
	input            i_aud_bclk,
	input            i_daclrc,
	input            i_adclrc,
	input            i_aud_adcdat,
	output           o_aud_dacdat,
	output           o_aud_mclk,
	
	//RGMII interface 
	output           o_eth_rst_n,
	input            i_eth_rx_clk,
	input            i_eth_rx_ctl,
	input  [3:0]     i_eth_rxd,
	output           o_eth_tx_clk,
	output           o_eth_tx_ctl,
	output [3:0]     o_eth_txd,
	output           o_eth_mdc,
	inout            io_eth_mdio
	);
	
//    assign o_uart_txd = i_uart_rxd;
    assign o_gbc_led  = i_gbc_key;
    assign o_iic_scl  = io_iic_sda;
    assign o_can_tx  = i_can_rx;


//	assign o_lcd_hs  = 1'b0;
//	assign o_lcd_vs  = 1'b0;
//	assign o_lcd_de  = 1'b0;
//	assign o_lcd_bl  = 1'b0;
//	assign o_lcd_clk   = 1'b0;
//	assign o_lcd_rst   = 1'b0;
//	assign o_rgb_data  = 24'h000000;
	assign o_lcd_scl   = 1'b0;
	assign o_ct_rst    = 1'b0;
	
	
	assign o_tmds_data   = 3'b000;
	assign o_tmds_clk_p  = 1'b0;
	assign o_tmds_scl    = 1'b0;
	assign o_tmds_sda    = 1'b0;
	assign o_tmds_hpd    = 1'b0;
	
	
	assign o_aud_dacdat    = 1'b0;
	assign o_aud_mclk      = 1'b0;
	
	assign o_eth_rst_n  = 1'b0;
	assign o_eth_tx_clk = 1'b0;
	assign o_eth_tx_ctl = 1'b0;
	assign o_eth_txd    = 4'h0;
	assign o_eth_mdc    = 1'b0;
	
	assign io_eth_mdio  = 1'b0;
	
	
   key_led #(
   .width (1)
   )
   u_key_led (
      .sys_clk  (i_sys_clk),
	  .sys_rst_n(i_rst_n),
	  .key      (i_key[0]),
	  .led      (o_led_buttom[0])
   );

   top_key_beep u_key_beep(
      .sys_clk  (i_sys_clk),
	  .sys_rst_n(i_rst_n),
	  
	  .key      (i_key[1]),
	  .beep     (o_beep)
   
   );
   
   touch_led u_touch_led(
      .sys_clk  (i_sys_clk),
	  .sys_rst_n(i_rst_n),
	  
	  .touch_key      (i_touch_key),
	  .led            (o_led_buttom[1])
   
   );
   
   breath_led u_breath_led(
      .sys_clk  (i_sys_clk),
	  .sys_rst_n(i_rst_n),
   
      .led           (o_led_core)
   );
   
   uart_loopback_top u_uart_loopback_top(
    .sys_clk  (i_sys_clk),            
    .sys_rst_n(i_rst_n),          

    .uart_rxd (i_uart_rxd),           
    .uart_txd (o_uart_txd)  
    );    

	lcd_rgb_colorbar u_lcd_rgb_colorbar(
    .sys_clk	(i_sys_clk),     //系统时钟
    .sys_rst_n	(i_rst_n),   //系统复位

    //RGB LCD接口
    .lcd_de	(o_lcd_de),      //LCD 数据使能信号
    .lcd_hs	(o_lcd_hs),      //LCD 行同步信号
    .lcd_vs	(o_lcd_vs),      //LCD 场同步信号
    .lcd_bl	(o_lcd_bl),      //LCD 背光控制信号
    .lcd_clk(o_lcd_clk),     //LCD 像素时钟
    .lcd_rst(o_lcd_rst),     //LCD 复位
    .lcd_rgb(o_rgb_data)      //LCD RGB888颜色数据
    );  
endmodule
