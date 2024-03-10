//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           key_debounce
// Last modified Date:  2019/4/14 16:23:36
// Last Version:        V1.0
// Descriptions:        �������Ʒ�����
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/4/14 16:23:36
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
// Modified by:		    ����ԭ��
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

//������������ģ��
key_debounce  u_key_debounce(
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),

    .key        (key),
    .key_value  (key_value),
    .key_flag   (key_flag)
    );

//��������������ģ��
beep_control  u_beep_control(
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),

    .key_value  (key_value),
    .key_flag   (key_flag),
    .beep       (beep)
    );

endmodule
