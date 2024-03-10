`timescale 1ns / 1ps

module SPI_interface(
	input 	clk,
	input 	rst_n,

	input	spi_valid,
	input [31:0]	spi_tdata,
	output reg rd_valid,
	output reg [31:0]	rd_tdata,

	output reg	spi_clk,
	output reg	spi_csb,
	inout  spi_sdio
	);

	reg spi_rw;
	reg	spi_dout;
	reg spi_enable;
	reg out_valid;
	reg [ 3:0]	clk_cnt;
	reg [ 5:0]	wrd_cnt;
	reg [23:0]	tmp_tdata;
	reg [31:0]	tmp_tdata1;
	always@(posedge clk or negedge rst_n)
	begin
		if (1'b0 == rst_n)
		begin
			spi_csb		<= 1'b1;
			spi_clk		<= 1'b0;
			out_valid	<= 1'b0;
			spi_dout	<= 1'b0;	
			rd_valid	<= 1'b0;
			rd_tdata	<= 32'h0;

			spi_rw		<= 1'b0;
			clk_cnt		<= 4'h0;
			wrd_cnt		<= 6'h0;	
			spi_enable	<= 1'b0;	
			tmp_tdata	<= 24'h0;
			tmp_tdata1	<= 32'h0;
		end
		else
		begin
			rd_valid	<= 	1'b0;
			if (1'b1 == spi_valid)
			begin
				spi_csb		<= 1'b1;
				spi_clk		<= 1'b0;
				out_valid	<= 1'b1;
				spi_dout	<= 1'b0;
				rd_tdata	<= 32'h0;	

				clk_cnt		<= 4'h0;
				wrd_cnt		<= 6'h0;
				spi_enable	<= 1'b1;
				spi_rw		<= spi_tdata[31];
				tmp_tdata	<= {spi_tdata[31:16],spi_tdata[7:0]};
				tmp_tdata1	<= 32'h0;
			end
			else if (1'b1 == spi_enable)
			begin
				clk_cnt		<=	clk_cnt + 1'b1;
				case (clk_cnt)
				4'h0:	begin	
						spi_clk		<= 1'b0;
						spi_csb		<= 1'b0;						
						spi_dout	<= tmp_tdata[23];
						tmp_tdata	<= {tmp_tdata[22:0],1'b0};
						wrd_cnt		<= wrd_cnt + 1'b1;				
						if ((1'b1 == spi_rw) && (6'h10 == wrd_cnt))
							out_valid	<= 1'b0;
						end
				4'h5:	begin						
						if (6'h19 == wrd_cnt)	
						begin				
							spi_csb		<= 1'b1;	
							spi_enable	<= 1'b0;
							out_valid	<= 1'b0;
							if (1'b1 == spi_rw)
							begin
								rd_valid	<= 1'b1;
								rd_tdata	<= tmp_tdata1;
							end
						end				
						else
						begin
							spi_clk		<= 1'b1;
							tmp_tdata1	<= {tmp_tdata1[30:0],spi_sdio};
						end
						end
				4'h9:	clk_cnt	<= 4'h0;
				endcase
			end
		end
	end
	
	assign spi_sdio = out_valid ? spi_dout : 1'bz;

endmodule
