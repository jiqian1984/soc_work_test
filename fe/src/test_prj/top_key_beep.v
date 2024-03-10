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
// Descriptions:        按键控制蜂鸣器
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

module top_key_beep(
    input    sys_clk ,
    input    sys_rst_n ,

    input    key ,
    output   beep
);

//wire define
wire key_value ;
wire key_flag ;

//*****************************************************
//**                    main code
//*****************************************************

//例化按键消抖模块
key_debounce  u_key_debounce(
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),

    .key        (key),
    .key_value  (key_value),
    .key_flag   (key_flag)
    );

//例化蜂鸣器控制模块
beep_control  u_beep_control(
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),

    .key_value  (key_value),
    .key_flag   (key_flag),
    .beep       (beep)
    );

endmodule
