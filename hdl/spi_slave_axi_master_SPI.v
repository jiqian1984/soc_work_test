module spi_slave_axi_master_SPI
 #(
    parameter integer SPI_ADDR_WIDTH = 20,
    parameter integer DUMMY_CYCLES = 12,
    parameter integer BURST_STEP = 1
    
 )
(
    input                            core_clk,
	input                            core_reset_n,
	//spi slave                      
	input                            spi_clk,
	input                            spi_mosi,
	output wire                      spi_miso,
	input                            spi_cs_n,
	
	input wire [31:0]                spi_read_data,
	output     [SPI_ADDR_WIDTH-1:0]  spi_read_address,
	output     [SPI_ADDR_WIDTH-1:0]  spi_write_address,
	output     [31:0]                spi_write_data,
	output reg                       spi_write,
	output reg                       spi_read
	
);
//==========================================================
wire spi_clk_posedge;
wire spi_clk_negedge;

reg [2:0]    spi_clk_delay;
reg [1:0]    spi_cs_n_delay;
reg [1:0]    spi_mosi_delay;
reg 		spi_writein;
reg      	spi_readin;
reg [SPI_ADDR_WIDTH-1:0] spi_rx_
end module;