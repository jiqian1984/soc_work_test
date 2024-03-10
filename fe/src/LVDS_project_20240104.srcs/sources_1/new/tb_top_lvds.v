`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: vtf_led_test
//////////////////////////////////////////////////////////////////////////////////

module tb_top_lvds;

    reg     rst;
    reg     clk_50m; 
    reg     clk_din0;
    reg     clk_din1;

    always # 100.000    clk_50m  = ~ clk_50m;  
    always #  73.700    clk_din0 = ~ clk_din0;
    always # 117.170    clk_din1 = ~ clk_din1;
//   initial #(4)
//   forever #8.33333    clk_dco  = ~ clk_dco;
 
    initial 
    begin       
                    rst         =   1'b0;
                    clk_50m     =   1'b0;
                    clk_din0    =   1'b0;
                    clk_din1    =   1'b1;
        # 10000     rst         =   1'b1; 
    end 

	wire tx_valid;
	wire [7:0]	tx_data;
	UART_source
	uut0_UART_source(  
		.rst(rst),	
		.clk(clk_50m),
		.tx_valid(tx_valid),	
		.tx_data(tx_data)
    	);

    wire    uart_rx;
    wire    uart_tx;
	wire	tx_done;
	wire    rx_valid;
	wire [7:0]	rx_data;
	UART_interface
	uut1_UART_interface(
		.clk(clk_50m),
		.rst_n(rst),	
		.tx_valid(tx_valid),	
		.tx_data(tx_data),
		.tx_done(tx_done),
		.uart_tx(uart_tx),	
		.uart_rx(uart_rx),
		.rx_valid(rx_valid),
		.rx_data(rx_data)
		);
		
	wire 	adclk_n;
	wire 	adclk_p;
	wire	fco_n;
	wire 	fco_p;
	wire 	dco_n;
	wire  	dco_p;
	wire	din0A_n;
	wire	din0A_p;
	wire	din1A_n;
	wire	din1A_p;
	wire	din0B_n;
	wire	din0B_p;
	wire	din1B_n;
	wire	din1B_p;
	wire	adc_out;
	wire  	pll_locked;
	ADC_source
	uut0_ADC_source(  
 //   	.rst(rst), 
		.rst(adc_out),
		.clk_p(adclk_p),
		.clk_n(adclk_n),
		.din0_in(clk_din0),
		.din1_in(clk_din1),
		.fco_n(fco_n),
		.fco_p(fco_p),
		.dco_n(dco_n),
		.dco_p(dco_p),
		.din0A_n(din0A_n),
		.din0A_p(din0A_p),
		.din1A_n(din1A_n),
		.din1A_p(din1A_p),
		.din0B_n(din0B_n),
		.din0B_p(din0B_p),
		.din1B_n(din1B_n),
		.din1B_p(din1B_p),
		.pll_locked(pll_locked)
		);

	wire	spi_clk;
	wire 	spi_csb;
	wire 	spi_sdio;
	wire 	Bit_clk;
	wire [15:0]	Bit_dat;
	wire [ 9:0] test_pin;
    top_lvds    
    uut_top_lvds(
        .rst(rst),
	    .clk(clk_50m),
        .dco_n(dco_n),
        .dco_p(dco_p),
        .fco_n(fco_n),
        .fco_p(fco_p),
        .din1A_n(din1A_n),
        .din1A_p(din1A_p),
        .din0A_n(din0A_n),
        .din0A_p(din0A_p),
        .din1B_n(din1B_n),
        .din1B_p(din1B_p),
        .din0B_n(din0B_n),
        .din0B_p(din0B_p),
        .uart_tx(uart_rx),
	    .uart_rx(uart_tx),
		.spi_clk(spi_clk),
		.spi_csb(spi_csb),
		.spi_sdio(spi_sdio),
		.adclk_p(adclk_p),
		.adclk_n(adclk_n),
		.Bit_sta(1'b0),
		.Bit_cha(1'b0),
		.Bit_clr(1'b0),
		.Bit_clk(Bit_clk),
		.Bit_dat(Bit_dat),		
	    .test_pin(test_pin)
        );

	assign adc_out = test_pin[9];
	
endmodule

