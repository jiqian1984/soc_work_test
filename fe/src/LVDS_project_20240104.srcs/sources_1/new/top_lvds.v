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

module top_lvds(  
    input		rst,  
    input       clk,
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
	output		uart_tx,
	input		uart_rx,
	output 		spi_clk,
	output		spi_csb,
	inout 		spi_sdio,
	output		adclk_p,
	output		adclk_n,
	input 		Bit_sta,
	input		Bit_cha,
	input		Bit_clr,
	output 		Bit_clk,
	output[15:0]Bit_dat,
	output[9:0]	test_pin
    );
    
	wire pll_locked;
	wire clk_050m;
	wire clk_200m;
	wire adc_out;
	wire div_valid;
	wire [7:0] adc_div;
	CLK_system
	uut0_CLK_system(  
    	.rst(rst),  
    	.clk(clk),
		.adc_out(adc_out),
		.div_valid(div_valid),
		.adc_div(adc_div),
		.pll_locked(pll_locked),
		.clk_free(clk_050m),
		.clk_200M(clk_200m),	
		.adclk_p(adclk_p),
		.adclk_n(adclk_n)
    	);
	
	wire	w_dc_clk;
	wire	w_fc_clk;
	wire [ 5:0] fco_bits;
	wire [ 7:0] dco_bits;
	wire [11:0] adcA_bits;
	wire [11:0] adcB_bits;
	wire  	adc_rst;
	wire 	adc_valid;
	wire [23:0] adc_tdata;
	ADC_interface
	uut0_ADC_interface(  
		.rst(adc_rst),
    	.clk_200M(clk_200m),
    	.dco_n(dco_n),
   		.dco_p(dco_p),
		.fco_n(fco_n),
		.fco_p(fco_p),
		.din0A_n(din0A_n),
		.din0A_p(din0A_p),
		.din1A_n(din1A_n),
		.din1A_p(din1A_p),
		.din0B_n(din0B_n),
		.din0B_p(din0B_p),
		.din1B_n(din1B_n),
		.din1B_p(din1B_p),
		.w_dc_clk(w_dc_clk),
		.w_fc_clk(w_fc_clk),
		.dco_bits(dco_bits),
		.fco_bits(fco_bits),
		.adcA_bits(adcA_bits),
		.adcB_bits(adcB_bits),
		.adc_valid(adc_valid),
		.adc_tdata(adc_tdata)
    	);

	wire	tx_done;
	wire 	tx_valid;
	wire [7:0]	tx_data;
	wire	rx_valid;
	wire [7:0]	rx_data;
	UART_interface
	uut0_UART_interface(
		.clk(clk_050m),
		.rst_n(rst),	
		.tx_valid(tx_valid),	
		.tx_data(tx_data),
		.tx_done(tx_done),
		.uart_tx(uart_tx),	
		.uart_rx(uart_rx),
		.rx_valid(rx_valid),
		.rx_data(rx_data)
		);

	wire ver_valid;
	wire [31:0] ver_tdata;
	wire spi_valid;
	wire [31:0] spi_tdata;
	wire capt_valid;
	wire capt_mode;
	wire capt_start;
	wire read_channel;
	wire read_start;
	wire [15:0]	capt_length;	
	wire [15:0] channelA_len;
	wire [15:0]	channelB_len;
	REG_mapper
	uut0_REG_mapper(
		.rst_n(rst),
		.clk(clk_050m),	
		.rx_valid(rx_valid),
		.rx_data(rx_data),
		.ver_valid(ver_valid),
		.ver_tdata(ver_tdata),
		.spi_valid(spi_valid),
		.spi_tdata(spi_tdata),
		.capt_mode(capt_mode),
		.capt_length(capt_length),	
		.channelA_len(channelA_len),
		.channelB_len(channelB_len),
		.capt_start(capt_start),
		.read_start(read_start),
		.read_channel(read_channel),
		.div_valid(div_valid),
		.adc_div(adc_div),
		.adc_out(adc_out),
		.adc_rst(adc_rst)
		);

	wire rd_valid;
	wire [31:0] rd_tdata;
	wire ad_valid;
	wire [31:0] ad_tdata;
	REG_back
	uut0_REG_back(
		.rst_n(rst),
		.clk(clk_050m),	
		.tx_done(~tx_done),
		.tx_valid(tx_valid),	
		.tx_data(tx_data),
		.rd_valid(rd_valid),
		.rd_tdata(rd_tdata),
		.ver_valid(ver_valid),
		.ver_tdata(ver_tdata),
		.ad_valid(ad_valid),
		.ad_tdata(ad_tdata)
		);

	SPI_interface
	uut0_SPI_interface(	
		.rst_n(rst),
		.clk(clk_200m),
		.spi_valid(spi_valid),
		.spi_tdata(spi_tdata),
	 	.rd_valid(rd_valid),
		.rd_tdata(rd_tdata),
		.spi_clk(spi_clk),
		.spi_csb(spi_csb),
		.spi_sdio(spi_sdio)
		);

	wire  	wea;
	wire [15:0] addra;
	wire [23:0] dina;
	ADC_write
	uut0_ADC_write(  
    	.rst(rst), 
		.clk(clk_050m), 
    	.clk_200M(clk_200m),	
		.capt_start(capt_start),
		.Bit_start(Bit_sta),
		.adc_valid(adc_valid),
		.adc_tdata(adc_tdata),
		.capt_length(capt_length),	
		.wea(wea),
		.addra(addra),
		.dina(dina)
		);

	wire [15:0] addrb;
	wire [23:0] doutb;
	ADC_uart_read
	uut0_ADC_uart_read(  
    	.rst(rst), 
		.clk(clk_050m), 
		.read_start(read_start),
		.read_channel(read_channel),
		.channelA_len(channelA_len),
		.channelB_len(channelB_len),
		.read_data(doutb),
		.ad_valid(ad_valid),
		.addrb(addrb),
		.ad_tdata(ad_tdata)
		);

	blk_mem_gen_0 
	uut0_blk_mem_gen_0(
		.clka(clk_200m),
		.ena(1'b1),
		.wea(wea),
		.addra(addra),
		.dina(dina),
		.clkb(clk_050m),
		.enb(1'b1),
		.addrb(addrb),
		.doutb(doutb)
		);

    reg [ 7:0]  ila_dco;
	reg [ 5:0]  ila_fco;
	reg [11:0]	ila_adcA;
	reg [11:0]	ila_adcB;
	reg [ 7:0] 	timer_cnt;
	always @(posedge clk_200m or negedge rst)
	begin
		if (1'b0 == rst)
		begin
			timer_cnt	<= 8'h00;
			ila_fco		<= 6'h00;
			ila_dco     <= 8'h00;
			ila_adcA	<= 12'h000;
			ila_adcB	<= 12'h000;
		end
		else
		begin	
			timer_cnt	<= timer_cnt + 1'b1;
			ila_fco		<= fco_bits;
			ila_dco     <= dco_bits;
			ila_adcA	<= adcA_bits;
			ila_adcB	<= adcB_bits;
		end
	end

	assign	test_pin[8:0]	= adcA_bits[8:0];
	assign 	test_pin[9]		= adc_out;
       
endmodule
