`timescale 1 ns /1 ps
module spi_slave_axi_master_M00_AXI #(
	parameter integer C_M_AXI_ADDR_WIDTH = 32,
	parameter integer C_M_AXI_DATA_WIDTH = 32,
	parameter integer C_M_TRANSACTIONS_NUM = 1
)

(
//user ports ends
//inintiate AXI transactions
input wire init_w_axi_txn,
input wire init_r_axi_txn,

//asserts whe error is deteced
output wire error_w_axi_txn,
output wire error_r_axi_txn,

//asserts when transactions is complete
output wire done_w_axi_txn,
output wire done_r_axi_txn,

input wire [C_M_AXI_ADDR_WIDTH-1 : 0] user_awaddr,
input wire [C_M_AXI_ADDR_WIDTH-1 : 0] user_araddr,
input wire [C_M_AXI_ADDR_WIDTH-1 : 0] user_wdata,
output reg [C_M_AXI_ADDR_WIDTH-1 : 0] user_rdata,

//axi clock signal 
input wire M_AXI_ACLK,
//axi active low reset signal
input wire M_AXI_ARESETN,
//Master interface wirete address channel ports.write address(issued by master)
output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
//write channel protection type
//this signal indicates the privilege and security level of the transaction,and thweter the transaction is a data access or an instruction access
output wire [2:0] M_AXI_AWPORT,
output wire M_AXI_AWVALID,
input  wire M_AXI_AWREADY,
output wire [C_M_AXI_DATA_WIDTH-1:0] M_AXI_WDATA,
output wire [C_M_AXI_DATA_WIDTH/8-1:0] M_AXI_WSTRB,
output wire M_AXI_WVALID,
input wire M_AXI_WREADY,
input wire [1:0] M_AXI_BRESP,
input wire M_AXI_BVALID,
output wire M_AXI_BREADY,
output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
output wire [2:0] M_AXI_ARPPORT,

output wire M_AXI_ARVALID,
input wire M_AXI_ARREADY,
input wire [C_M_AXI_ADDR_WIDTH-1:0] M_AXI_RDATA,
input wire [1:0] M_AXI_RRESP,
input wire M_AXI_RVALID,
output wire M_AXI_RREADY
);




reg [1:0] mst_exec_state;
//axi4lite signal;
reg axi_awvalid;
reg axi_wvalid;
reg axi_arvalid;
reg axi_rready;
reg axi_bready;
reg [C_M_AXI_ADDR_WIDTH-1 : 0] axi_awaddr;
reg [C_M_AXI_ADDR_WIDTH-1 : 0] axi_wdata;
reg [C_M_AXI_ADDR_WIDTH-1 : 0] axi_araddr;

wire write_resp_error;
wire read_resp_error;
reg  start_signal_read;
reg  start_signal_write;
reg  write_issued;
reg  read_issued;
reg  writes_done;
reg  reads_done,reads_done_d;

reg w_error_reg;
reg r_error_reg;

reg [TRANS_NUM_BITS : 0] write_index;
reg [TRANS_NUM_BITS : 0] read_index;
reg [C_M_AXI_DATA_WIDTH-1 :0] expected_rdata;


reg last_write;
reg last_read;

reg inint_w_txn_ff;
reg inint_w_txn_ff2;
reg inint_r_txn_ff;
reg inint_r_txn_ff2;

wire init_w_txn_pulse;
wire init_r_txn_pulse;

reg m_axi_rvalid_d;
	//adding the offset address to the base addr of the slave 
	assign M_AXI_AWADDR = axi_awaddr;
	assign M_AXI_WDATA  = axi_wdata;
	assign M_AX_AWPROT  = 3'b000;
	assign M_AX_WVALID  = axi_awvalid;
	assign M_AXI_WSTRB  = 4'b1111;
	assign M_AXI_BREADY = axi_bready;
	
	assign M_AXI_ARADDR = axi_araddr;
	assign M_AXI_ARVALID = axi_arvalid;
	assign M_AXI_ARPROT = 3'b001;
	assign M_AXI_RREADY = axi_rready;
	
	//example deasign I/O
	assign init_w_txn_pulse = (!init_w_txn_ff2) && init_w_txn_ff;
//	assign init_r_txn_pulse = (!init_w_txn_ff2) && init_w_txn_ff;
	assign init_r_txn_pulse = init_r_axi_txn;
	
	//generate a pulse to initiate axi write transactiona;
	always @(posedge M_AXI_ACLK)
	begin
		if(M_AXI_ARESETN == 0)
			begin
				inint_w_txn_ff <= 1'b0;
				inint_w_txn_ff2 <= 1'b0;
			end 
		else
			begin
				init_w_txn_ff <= init_w_axi_txn;
				init_w_txn_ff2 <= init_w_txn_ff;
			end 
	end 
		//generate a pulse to initiate axi read transactiona;
	always @(posedge M_AXI_ACLK)
	begin
		if(M_AXI_ARESETN == 0)
			begin
				inint_r_txn_ff <= 1'b0;
				inint_r_txn_ff2 <= 1'b0;
			end 
		else
			begin
				init_r_txn_ff <= init_r_axi_txn;
				init_r_txn_ff2 <= init_r_txn_ff;
			end 
	end

    //---------------------
    //write address channel 
    //---------------------
	always @(posedge M_AXI_ACLK)
	begin
		if(M_AXI_ARESETN == 0 || init_w_txn_pulse == 1'b1)
			begin
				axi_awvalid <= 1'b0;
			end 
		//signal a new address/data command is available by user logic
		else 
			begin
				if(start_single_write)
					begin
						axi_awvalid <= 1'b1;
					end
				else if(M_AXI_AWREADY && axi_awvalid)
					begin
						axi_awvalid <= 1'b0;
					end
			end 
	end 
	
	always @(posedge M_AXI_ACLK)
	begin
		if(M_AXI_ARESETN == 0 || init_w_txn_pulse == 1'b1)
			begin
				write_index <= 1'b0;
			end 
		//signal a new address/data command is available by user logic
		else if(start_single_write)
			begin
				write_index <= write_index + 1;
			end
	end 
	
	

    //---------------------
    //write data channel 
    //---------------------
	always @(posedge M_AXI_ACLK)
	begin
		if(M_AXI_ARESETN == 0 || init_w_txn_pulse == 1'b1)
			begin
				axi_wvalid <= 1'b0;
			end 
		//signal a new address/data command is available by user logic
		else if(start_single_write)
			begin
				axi_wvalid <= 1'b1;
			end
		else if (M_AXI_WREADY && axi_wvalid)
			begin
			    axi_wvalid <= 1'b0;
			end
	end 
    //---------------------
	//write reaponse channel
	//---------------------
	always @(posedge M_AXI_ACLK)
	begin
		if(M_AXI_ARESETN == 0 || init_w_txn_pulse == 1'b1)
			begin
				axi_bready <= 1'b0;
			end 
		//accep/acknoledge bresp with axi_bready by the master
		else if(M_AXI_BVALID && ~axi_bready)
			begin
				axi_bready <= 1'b1;
			end 
		//deassert after one clock cycle
		else if (axi_brady)
			begin
				axi_bready <= 1'b0;
			end 
		else
			axi_bready <= axi_bready;
	end 
    
	//flag write errors
	assign write_resp_error = (axi_bready & M_AXI_BVALID & M_AXI_BRESP[1]);
	
	//------------------------//
	//read address channel
	//------------------------
	always @(posedge M_AXI_ACLK)
	begin
		if(M_AXI_ARESETN == 0 || inir_r_txn_pulse == 1'b1)
			begin
				read_index <= 0;
			end 
		else if (start_single_read)
			begin
				read_index <= read_index + 1;
			end 
	end 
	
	//a new axi_arvalid is asserted when there is a valid read address available by the master.start_single_read triggers a new read transaction
	always @(posedge M_AXI_ACLK)
	begin
		if(M_AXI_ARESETN == 0 || init_r_txn_pulse == 1'b1)
		begin
			axi_arvalid <= 1'b0;
		end 
		else if(start_single_read)
			begin
				axi_arvalid <= 1'b1;
			end 
		else if(M_AXI_ARREADY && axi_arvalid)
			begin
				axi_arvalid <= 1'b0;
			end
	end 
	
	//------------------------//
	//read data (and response) channel
	//------------------------
	always @(posedge M_AXI_ACLK)
	begin
		if(M_AXI_ARESETN == 0 || init_r_txn_pulse == 1'b1)
			begin
				axi_rready <= 1'b0;
			end 
		else if(M_AXI_RVALID && ~axi_rready)
			begin
				axi_rready <= 1'b1;
				user_rdata <= M_AXI_RDATA;
			end 
		else if(axi_rready)
			begin
				axi_rready <= 1'b0;
			end
	end 
	
	//flag write errors
	assign read_resp_error = (axi_rready & M_AXI_RVALID & M_AXI_RRESP[1]);
	
	
	
endmodule;
