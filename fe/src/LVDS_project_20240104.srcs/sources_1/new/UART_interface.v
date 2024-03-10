`timescale 1ns / 1ps

module UART_interface(
	input 	clk,
	input 	rst_n,
	
	input 	tx_valid,	
	input  [7:0]tx_data,
	output reg	tx_done,
	output reg	uart_tx,
	
	input 	uart_rx,
	output reg 	rx_valid,
	output reg [7:0]rx_data
	);

	localparam	Tx_IDLE	= 1'd0;
	localparam	Tx_SEND	= 1'd1;
	localparam 	Rx_IDLE	= 1'd0;
	localparam 	Rx_CAPT	= 1'd1;

	localparam	Baud_Rate = 1000000;		
	localparam	Send_Cnt  = 32'd85899346;		
	localparam	Capt_Cnt  = 32'd1374389535; 

/*	localparam	Baud_Rate = 115200;		
	localparam	Send_Cnt  = 32'd9895605;		
	localparam	Capt_Cnt  = 32'd158329674; 
*/
//	Send_Cnt =	Baud_Rate*2^32/CLK = 115200*2^32/50e6 = 9895604.64
//	Capt_Cnt =	Baud_Rate*2^36/CLK = 115200*2^32/50e6 = 158329674.39 

	reg clk_bps;
	reg	clk_bps_r0;
	reg clk_bps_r1;	
	reg [31:0]	bps_cnt1;
	always@(posedge clk or negedge rst_n)
	begin
		if (1'b0 == rst_n)
		begin
			bps_cnt1	<= 32'h0;
			clk_bps		<= 1'b0;
			clk_bps_r0	<= 1'b0;
			clk_bps_r1	<= 1'b0;		
		end
		else
		begin
			clk_bps_r1	<= clk_bps_r0;
			bps_cnt1	<= bps_cnt1 + Send_Cnt;
			if(bps_cnt1 < 32'h7FFF_FFFF)
				clk_bps_r0 <= 0;
			else
				clk_bps_r0 <= 1;
			if (2'b01 == {clk_bps_r1,clk_bps_r0})
				clk_bps	<= 1'b1;
			else
				clk_bps	<= 1'b0;
		end
	end

	reg clk_capt;
	reg	clk_capt_r0;
	reg clk_capt_r1;	
	reg [31:0]	capt_cnt1;
	always@(posedge clk or negedge rst_n)
	begin
		if (1'b0 == rst_n)
		begin
			capt_cnt1	<= 32'h0;
			clk_capt	<= 1'b0;
			clk_capt_r0	<= 1'b0;
			clk_capt_r1	<= 1'b0;		
		end
		else
		begin
			clk_capt_r1	<= clk_capt_r0;
			capt_cnt1	<= capt_cnt1 + Capt_Cnt;
			if(capt_cnt1 < 32'h7FFF_FFFF)
				clk_capt_r0 <= 0;
			else
				clk_capt_r0 <= 1;
			if (2'b01 == {clk_capt_r1,clk_capt_r0})
				clk_capt	<= 1'b1;
			else
				clk_capt	<= 1'b0;
		end
	end

	reg tx_state;
	reg [3:0] tx_count;
	reg [7:0] tx_data1;
	always@(posedge clk or negedge rst_n)
	begin
		if (1'b0 == rst_n)
		begin
			uart_tx		<= 1'b1;
			tx_count	<= 4'h0;
			tx_done		<= 1'b0;
			tx_data1	<= 8'h00;
			tx_state 	<= Tx_IDLE;
		end	
		else
		begin
			case(tx_state)
			Tx_IDLE:
			begin
				if (1'b1 == tx_valid)
				begin
					uart_tx		<= 1'b1;
					tx_count	<= 4'h0;
					tx_done		<= 1'b1;
					tx_data1	<= tx_data;
					tx_state 	<= Tx_SEND;
				end
			end
			Tx_SEND:
			begin
				if (1'b1 == clk_bps)
				begin
					if (tx_count < 4'hA)
						tx_count	<= tx_count + 1'b1;
					else
					begin
						uart_tx		<= 1'b1;
						tx_count	<= 4'h0;
						tx_done		<= 1'b0;
						tx_data1	<= 8'h00;
						tx_state 	<= Tx_IDLE;
					end
					case(tx_count)
						4'h0:	uart_tx	<= 1'b0;
						4'h1:	uart_tx	<= tx_data1[0];
						4'h2:	uart_tx	<= tx_data1[1];
						4'h3:	uart_tx	<= tx_data1[2];
						4'h4:	uart_tx	<= tx_data1[3];
						4'h5:	uart_tx	<= tx_data1[4];
						4'h6:	uart_tx	<= tx_data1[5];
						4'h7:	uart_tx	<= tx_data1[6];
						4'h8:	uart_tx	<= tx_data1[7];
						4'h9:	uart_tx	<= 1'b1;
						default:uart_tx	<= 1'b1;
					endcase
					end
				end
			endcase
		end
	end

	reg rx_state;
	reg [3:0] rx_count;
	reg [3:0] rx_word;
	reg [8:0] rx_data1;
	always@(posedge clk or negedge rst_n)
	begin
		if (1'b0 == rst_n)
		begin
			rx_valid	<= 1'b0;
			rx_data		<= 8'h0;
			rx_word		<= 4'h0;
			rx_count	<= 4'h0;
			rx_data1	<= 9'h0;
			rx_state 	<= Rx_IDLE;
		end	
		else
		begin
			rx_valid<= 1'b0; 
			if(1'b1 == clk_capt) 
			begin
				case(rx_state)
				Rx_IDLE:
				begin
					rx_word	<= 4'h0;
					rx_data1<= 9'h0;
					if (1'b0 == uart_rx)
					begin
						rx_count <= rx_count + 1'b1;
						if (4'h7 == rx_count)
							rx_state	<= Rx_CAPT;
					end
				end
				Rx_CAPT:
				begin
					rx_count <= rx_count + 1'b1; 
					if (4'h7 == rx_count)
					begin
						rx_word	<= rx_word + 1'b1;
						if (4'h8 == rx_word)
						begin	
							rx_state	<= Rx_IDLE;
							if (1'b1 == uart_rx)
							begin
								rx_count	<= 4'h0;
								rx_valid	<= 1'b1;
								rx_data		<= rx_data1[7:0];
							end
						end
						case(rx_word)
							4'h0:	rx_data1[0]	<= uart_rx;
							4'h1:	rx_data1[1]	<= uart_rx;
							4'h2:	rx_data1[2]	<= uart_rx;
							4'h3:	rx_data1[3]	<= uart_rx;
							4'h4:	rx_data1[4]	<= uart_rx;
							4'h5:	rx_data1[5]	<= uart_rx;
							4'h6:	rx_data1[6]	<= uart_rx;
							4'h7:	rx_data1[7]	<= uart_rx;
//							default:rx_data1[8]	<= 1'b0;
						endcase
					end
				end
				endcase
			end
		end
	end

endmodule
