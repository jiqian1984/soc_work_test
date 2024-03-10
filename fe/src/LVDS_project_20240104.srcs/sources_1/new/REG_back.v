`timescale 1ns / 1ps

module REG_back(
	input 	clk,
	input 	rst_n,

	input 	tx_done,
	output  tx_valid,	
	output [7:0]tx_data,
	
	input ver_valid,
	input [31:0]	ver_tdata,
	input rd_valid,
	input [31:0]	rd_tdata,
	input ad_valid,
	input [31:0]	ad_tdata
	);

	wire	axis_ready;
	reg		axis_valid;
	reg [ 7:0]	axis_tdata;
	reg [ 3:0]	tmp_valid;
	reg [31:0]	tmp_tdata;
	always@(posedge clk or negedge rst_n)
	begin
		if (1'b0 == rst_n)
		begin
			tmp_valid	<= 4'h0;
			tmp_tdata	<= 32'h0;	
			axis_valid	<= 1'b0;
			axis_tdata	<= 8'h00;	
		end
		else
		begin
			case({ad_valid,rd_valid,ver_valid})
			3'b001:	begin
					tmp_valid	<= 4'hF;
					tmp_tdata	<= ver_tdata;
				end
			3'b010:	begin
					tmp_valid	<= 4'hF;
					tmp_tdata	<= rd_tdata;	
				end
			3'b100:	begin
					tmp_valid	<= 4'hF;
					tmp_tdata	<= ad_tdata;	
				end
			endcase
			if ((1'b1 == axis_ready) && (4'h0 != tmp_valid))
			begin
				axis_valid	<= tmp_valid[3];
				axis_tdata	<= tmp_tdata[31:24];
				tmp_valid	<= {tmp_valid[2:0],1'b0};
				tmp_tdata	<= {tmp_tdata[23:0],8'h00};
			end	
			else
			begin
				axis_valid	<= 1'b0;
				axis_tdata	<= 8'h00;	
			end
		end
	end

    axis_data_fifo_0 
    uut0_readback_fifo(
        .s_axis_aresetn(rst_n),
        .s_axis_aclk(clk),
        .s_axis_tvalid(axis_valid),
        .s_axis_tready(axis_ready),
        .s_axis_tdata(axis_tdata),
        .m_axis_tvalid(tx_valid),
        .m_axis_tready(tx_done),
        .m_axis_tdata(tx_data)
        );

endmodule
