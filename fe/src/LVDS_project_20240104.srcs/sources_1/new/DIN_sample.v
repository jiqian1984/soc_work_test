`timescale 1ns/1ps

module DIN_sample(
	input 	rst,
	input 	dclk_int,
	input	fclk_int,
	input 	fco_ext,
	input	din0A_ext,
	input	din1A_ext,
	input	din0B_ext,
	input	din1B_ext,
	output reg valid_adc,
	output [ 5:0]   bits_fco,
	output [11:0]	data_adcA,
	output [11:0]	data_adcB
    );

	reg 		R_bit_slip;
	reg  [1:0]	R_wait;
	ISERDESE2	#(
		.DATA_RATE("DDR"),
		.DATA_WIDTH(6),
		.DYN_CLKDIV_INV_EN("FALSE"),
		.DYN_CLK_INV_EN("FALSE"),
		.INIT_Q1(1'b0),
		.INIT_Q2(1'b0),
		.INIT_Q3(1'b0),
		.INIT_Q4(1'b0),	
		.INTERFACE_TYPE("NETWORKING"),
		.IOBDELAY("NONE"),
		.NUM_CE(2),
		.OFB_USED("FALSE"),
		.SERDES_MODE("MASTER"),
		.SRVAL_Q1(1'b0),
		.SRVAL_Q2(1'b0),
		.SRVAL_Q3(1'b0),
		.SRVAL_Q4(1'b0)
		)
	uut0_fco_iserdes2(
		.O(),
		.Q1(bits_fco[0]),
		.Q2(bits_fco[1]),
		.Q3(bits_fco[2]),
		.Q4(bits_fco[3]),
		.Q5(bits_fco[4]),
		.Q6(bits_fco[5]),
		.Q7(),
		.Q8(),
		.RST(~rst),		
		.CE1(1'b1),
		.CE2(1'b1),
		.CLKDIVP(1'b0),
		.CLK(dclk_int),
		.CLKB(~dclk_int),
		.CLKDIV(fclk_int),
		.OCLK(1'b0),
		.OCLKB(1'b0),
		.D(fco_ext),	
		.DDLY(1'b0),
		.OFB(1'b0),
		.BITSLIP(R_bit_slip),
		.DYNCLKDIVSEL(1'b0),
		.DYNCLKSEL(1'b0),
		.SHIFTOUT1(),
		.SHIFTOUT2(),		
		.SHIFTIN1(1'b0),
		.SHIFTIN2(1'b0)		
		);
	
	wire [5:0] din0A_dat;
	ISERDESE2	#(
		.DATA_RATE("DDR"),
		.DATA_WIDTH(6),
		.DYN_CLKDIV_INV_EN("FALSE"),
		.DYN_CLK_INV_EN("FALSE"),
		.INIT_Q1(1'b0),
		.INIT_Q2(1'b0),
		.INIT_Q3(1'b0),
		.INIT_Q4(1'b0),	
		.INTERFACE_TYPE("NETWORKING"),
		.IOBDELAY("NONE"),
		.NUM_CE(2),
		.OFB_USED("FALSE"),
		.SERDES_MODE("MASTER"),
		.SRVAL_Q1(1'b0),
		.SRVAL_Q2(1'b0),
		.SRVAL_Q3(1'b0),
		.SRVAL_Q4(1'b0)
		)
	uut1_lsb_iserdes2(
		.O(),
		.Q1(din0A_dat[0]),
		.Q2(din0A_dat[1]),
		.Q3(din0A_dat[2]),
		.Q4(din0A_dat[3]),
		.Q5(din0A_dat[4]),
		.Q6(din0A_dat[5]),
		.Q7(),
		.Q8(),
		.RST(~rst),		
		.CE1(1'b1),
		.CE2(1'b1),
		.CLKDIVP(1'b0),
		.CLK(dclk_int),
		.CLKB(~dclk_int),
		.CLKDIV(fclk_int),
		.OCLK(1'b0),
		.OCLKB(1'b0),
		.D(din0A_ext),	
		.DDLY(1'b0),
		.OFB(1'b0),
		.BITSLIP(R_bit_slip),
		.DYNCLKDIVSEL(1'b0),
		.DYNCLKSEL(1'b0),
		.SHIFTOUT1(),
		.SHIFTOUT2(),		
		.SHIFTIN1(1'b0),
		.SHIFTIN2(1'b0)		
		);

	wire [5:0] din1A_dat;
	ISERDESE2	#(
		.DATA_RATE("DDR"),
		.DATA_WIDTH(6),
		.DYN_CLKDIV_INV_EN("FALSE"),
		.DYN_CLK_INV_EN("FALSE"),
		.INIT_Q1(1'b0),
		.INIT_Q2(1'b0),
		.INIT_Q3(1'b0),
		.INIT_Q4(1'b0),	
		.INTERFACE_TYPE("NETWORKING"),
		.IOBDELAY("NONE"),
		.NUM_CE(2),
		.OFB_USED("FALSE"),
		.SERDES_MODE("MASTER"),
		.SRVAL_Q1(1'b0),
		.SRVAL_Q2(1'b0),
		.SRVAL_Q3(1'b0),
		.SRVAL_Q4(1'b0)
		)
	uut2_msb_iserdes2(
		.O(),
		.Q1(din1A_dat[0]),
		.Q2(din1A_dat[1]),
		.Q3(din1A_dat[2]),
		.Q4(din1A_dat[3]),
		.Q5(din1A_dat[4]),
		.Q6(din1A_dat[5]),
		.Q7(),
		.Q8(),
		.RST(~rst),		
		.CE1(1'b1),
		.CE2(1'b1),
		.CLKDIVP(1'b0),
		.CLK(dclk_int),
		.CLKB(~dclk_int),
		.CLKDIV(fclk_int),
		.OCLK(1'b0),
		.OCLKB(1'b0),
		.D(din1A_ext),
		.DDLY(1'b0),
		.OFB(1'b0),
		.BITSLIP(R_bit_slip),
		.DYNCLKDIVSEL(1'b0),
		.DYNCLKSEL(1'b0),
		.SHIFTOUT1(),
		.SHIFTOUT2(),		
		.SHIFTIN1(1'b0),
		.SHIFTIN2(1'b0)		
		);
	
	wire [5:0] din0B_dat;
	ISERDESE2	#(
		.DATA_RATE("DDR"),
		.DATA_WIDTH(6),
		.DYN_CLKDIV_INV_EN("FALSE"),
		.DYN_CLK_INV_EN("FALSE"),
		.INIT_Q1(1'b0),
		.INIT_Q2(1'b0),
		.INIT_Q3(1'b0),
		.INIT_Q4(1'b0),	
		.INTERFACE_TYPE("NETWORKING"),
		.IOBDELAY("NONE"),
		.NUM_CE(2),
		.OFB_USED("FALSE"),
		.SERDES_MODE("MASTER"),
		.SRVAL_Q1(1'b0),
		.SRVAL_Q2(1'b0),
		.SRVAL_Q3(1'b0),
		.SRVAL_Q4(1'b0)
		)
	uut3_lsb_iserdes2(
		.O(),
		.Q1(din0B_dat[0]),
		.Q2(din0B_dat[1]),
		.Q3(din0B_dat[2]),
		.Q4(din0B_dat[3]),
		.Q5(din0B_dat[4]),
		.Q6(din0B_dat[5]),
		.Q7(),
		.Q8(),
		.RST(~rst),		
		.CE1(1'b1),
		.CE2(1'b1),
		.CLKDIVP(1'b0),
		.CLK(dclk_int),
		.CLKB(~dclk_int),
		.CLKDIV(fclk_int),
		.OCLK(1'b0),
		.OCLKB(1'b0),
		.D(din0B_ext),	
		.DDLY(1'b0),
		.OFB(1'b0),
		.BITSLIP(R_bit_slip),
		.DYNCLKDIVSEL(1'b0),
		.DYNCLKSEL(1'b0),
		.SHIFTOUT1(),
		.SHIFTOUT2(),		
		.SHIFTIN1(1'b0),
		.SHIFTIN2(1'b0)		
		);

	wire [5:0] din1B_dat;
	ISERDESE2	#(
		.DATA_RATE("DDR"),
		.DATA_WIDTH(6),
		.DYN_CLKDIV_INV_EN("FALSE"),
		.DYN_CLK_INV_EN("FALSE"),
		.INIT_Q1(1'b0),
		.INIT_Q2(1'b0),
		.INIT_Q3(1'b0),
		.INIT_Q4(1'b0),	
		.INTERFACE_TYPE("NETWORKING"),
		.IOBDELAY("NONE"),
		.NUM_CE(2),
		.OFB_USED("FALSE"),
		.SERDES_MODE("MASTER"),
		.SRVAL_Q1(1'b0),
		.SRVAL_Q2(1'b0),
		.SRVAL_Q3(1'b0),
		.SRVAL_Q4(1'b0)
		)
	uut4_msb_iserdes2(
		.O(),
		.Q1(din1B_dat[0]),
		.Q2(din1B_dat[1]),
		.Q3(din1B_dat[2]),
		.Q4(din1B_dat[3]),
		.Q5(din1B_dat[4]),
		.Q6(din1B_dat[5]),
		.Q7(),
		.Q8(),
		.RST(~rst),		
		.CE1(1'b1),
		.CE2(1'b1),
		.CLKDIVP(1'b0),
		.CLK(dclk_int),
		.CLKB(~dclk_int),
		.CLKDIV(fclk_int),
		.OCLK(1'b0),
		.OCLKB(1'b0),
		.D(din1B_ext),
		.DDLY(1'b0),
		.OFB(1'b0),
		.BITSLIP(R_bit_slip),
		.DYNCLKDIVSEL(1'b0),
		.DYNCLKSEL(1'b0),
		.SHIFTOUT1(),
		.SHIFTOUT2(),		
		.SHIFTIN1(1'b0),
		.SHIFTIN2(1'b0)		
		);

	always @(posedge fclk_int or negedge rst)
	begin
		if (1'b0 == rst)
		begin
			R_bit_slip	<= 1'b0;
			R_wait		<= 2'b00;
		end
		else
		begin
			if ((2'b11==R_wait) && (6'b111000!=bits_fco))	
			begin
				R_bit_slip	<= 1'b1;
				R_wait		<= 2'b00;
			end
			else
			begin
				R_bit_slip	<= 1'b0;
				R_wait		<= R_wait + 1'b1;
			end
		end
	end

	always @(posedge fclk_int or negedge rst)
	begin
		if (1'b0 == rst)
			valid_adc	<= 1'b0;
		else
		begin
			if (6'b111000 == bits_fco)
				valid_adc	<= 1'b1;
			else
				valid_adc	<= 1'b0;
		end
	end	

	assign data_adcA	= {din1A_dat,din0A_dat};
	assign data_adcB	= {din1B_dat,din0B_dat};

endmodule
