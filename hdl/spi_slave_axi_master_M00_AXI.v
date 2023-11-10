`timescale 1 ns /1 ps
module spi_slave_axi_master_M00_AXI #(

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