//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           key_debounce
// Last modified Date:  2019/4/14 16:23:36
// Last Version:        V1.0
// Descriptions:        蜂鸣器控制
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/4/14 16:23:36
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
// Modified by:		    正点原子
// Modified date:
// Version:
// Descriptions:
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module beep_control(
    input        sys_clk,
    input        sys_rst_n,

    input        key_value,
    input        key_flag,
    output  reg  beep
    );

//*****************************************************
//**                    main code
//*****************************************************

//每次按键按下时，就翻转蜂鸣器的状态
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        beep <= 1'b1;
    else if(key_flag && (key_value == 1'b0))
        beep <= ~beep;
end

endmodule
