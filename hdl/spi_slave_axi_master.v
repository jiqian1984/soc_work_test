`timescale 1 ns / 1 ps

 module spi_slave_axi_master #
 (
  // Users to add parameters here

  // Do not modify the parameters beyond this line
    parameter integer SPI_ADDR_WIDTH = 20,
    parameter integer DUMMY_CYCLES  = 12,

  // Parameters of Axi Master Bus Interface M00_AXI
//  parameter  C_M00_AXI_START_DATA_VALUE = 32'hAA000000,
//  parameter  C_M00_AXI_TARGET_SLAVE_BASE_ADDR = 32'h40000000,
  parameter integer C_M00_AXI_ADDR_WIDTH = 32,
  parameter integer C_M00_AXI_DATA_WIDTH = 32
  // User parameters ends
//  parameter integer C_M00_AXI_TRANSACTIONS_NUM = 4
 )
 (
  // Users to add ports here
  input wire spi_clk,
  input wire spi_mosi,
  output wire spi_miso,
  input wire spi_cs_n,
  // User ports ends
  // Do not modify the ports beyond this line


  // Ports of Axi Master Bus Interface M00_AXI
//  input wire  m00_axi_init_axi_txn,
//  output wire  m00_axi_error,
//  output wire  m00_axi_txn_done,
  input wire  m00_axi_aclk,
  input wire  m00_axi_aresetn,
  output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_awaddr,
  output wire [2 : 0] m00_axi_awprot,
  output wire  m00_axi_awvalid,
  input wire  m00_axi_awready,
  output wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_wdata,
  output wire [C_M00_AXI_DATA_WIDTH/8-1 : 0] m00_axi_wstrb,
  output wire  m00_axi_wvalid,
  input wire  m00_axi_wready,
  input wire [1 : 0] m00_axi_bresp,
  input wire  m00_axi_bvalid,
  output wire  m00_axi_bready,
  output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_araddr,
  output wire [2 : 0] m00_axi_arprot,
  output wire  m00_axi_arvalid,
  input wire  m00_axi_arready,
  input wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata,
  input wire [1 : 0] m00_axi_rresp,
  input wire  m00_axi_rvalid,
  output wire  m00_axi_rready
 );
 
  wire [C_M00_AXI_ADDR_WIDTH-1 : 0] axi_wr_address;
  wire [C_M00_AXI_ADDR_WIDTH-1 : 0] axi_rd_address;
  
  assign m00_axi_awaddr = { axi_wr_address[C_M00_AXI_ADDR_WIDTH-3 : 0] , 2'b00 };
  assign m00_axi_araddr = { axi_rd_address[C_M00_AXI_ADDR_WIDTH-3 : 0] , 2'b00 };
              
  wire [31:0] core_miso_word;      
  
  wire        core_cs_n;

  wire        init_w_axi_txn; 
  wire        init_r_axi_txn; 
  wire        error_w_axi_txn;
  wire        error_r_axi_txn;
  wire        done_w_axi_txn; 
  wire        done_r_axi_txn; 
 
 wire [C_M00_AXI_ADDR_WIDTH-1:0] user_awaddr;
  wire [C_M00_AXI_ADDR_WIDTH-1:0] user_araddr;
  wire [SPI_ADDR_WIDTH-1:0]       user_awaddr_sm;
  wire [SPI_ADDR_WIDTH-1:0]       user_araddr_sm;
  wire [C_M00_AXI_ADDR_WIDTH-SPI_ADDR_WIDTH-1:0] dummy_0;
  wire [C_M00_AXI_DATA_WIDTH-1:0] user_wdata; 
  wire [C_M00_AXI_DATA_WIDTH-1:0] user_rdata;
  
 
 wire [SPI_ADDR_WIDTH-1:0]      spi_read_address  ;
 wire [SPI_ADDR_WIDTH-1:0]      spi_write_address ;
  wire [31:0]                    spi_write_data    ;
  wire [31:0]                    spi_read_data     ;
  wire                           spi_write         ;// write pulse indicate there has a write command
  wire                           spi_read          ;// read pulse 
  
  wire                           spi_miso_int      ;
  
  assign spi_miso = spi_miso_int ;
  assign dummy_0 = 0;
//assign user_awaddr = {dummy_0, user_awaddr_sm};
//assign user_araddr = {dummy_0, user_araddr_sm};


  assign user_awaddr[C_M00_AXI_ADDR_WIDTH-1:SPI_ADDR_WIDTH] = 12'h0;
  assign user_araddr[C_M00_AXI_ADDR_WIDTH-1:SPI_ADDR_WIDTH] = 12'h0;

 
// Instantiation of Axi Bus Interface M00_AXI
 spi_slave_axi_master_M00_AXI # ( 
//  .C_M_START_DATA_VALUE(C_M00_AXI_START_DATA_VALUE),
//  .C_M_TARGET_SLAVE_BASE_ADDR(C_M00_AXI_TARGET_SLAVE_BASE_ADDR),
  .C_M_AXI_ADDR_WIDTH(C_M00_AXI_ADDR_WIDTH)
//  .C_M_AXI_DATA_WIDTH(C_M00_AXI_DATA_WIDTH) -- must be 32 bit for AXI4-Lite
//  .C_M_TRANSACTIONS_NUM(C_M00_AXI_TRANSACTIONS_NUM)
 ) spi_slave_axi_master_M00_AXI_inst (
//  .INIT_AXI_TXN(m00_axi_init_axi_txn),
//  .ERROR(m00_axi_error),
//  .TXN_DONE(m00_axi_txn_done),
      .init_w_axi_txn  ( init_w_axi_txn ),
      .init_r_axi_txn  ( init_r_axi_txn ),
      .error_w_axi_txn ( error_w_axi_txn ),
      .error_r_axi_txn ( error_r_axi_txn ),
      .done_w_axi_txn  ( done_w_axi_txn ),
      .done_r_axi_txn  ( done_r_axi_txn ),
      .user_awaddr     ( user_awaddr ),
      .user_araddr     ( user_araddr ),
      .user_wdata      ( user_wdata ),
      .user_rdata      ( user_rdata ),
      
      .M_AXI_ACLK    ( m00_axi_aclk ),
      .M_AXI_ARESETN ( m00_axi_aresetn ),
      .M_AXI_AWADDR  ( axi_wr_address ),
      .M_AXI_AWPROT  ( m00_axi_awprot ),
      .M_AXI_AWVALID ( m00_axi_awvalid ),
      .M_AXI_AWREADY ( m00_axi_awready ),
      .M_AXI_WDATA   ( m00_axi_wdata ),
      .M_AXI_WSTRB   ( m00_axi_wstrb ),
      .M_AXI_WVALID  ( m00_axi_wvalid ),
      .M_AXI_WREADY  ( m00_axi_wready ),
      .M_AXI_BRESP   ( m00_axi_bresp ),
      .M_AXI_BVALID  ( m00_axi_bvalid ),
      .M_AXI_BREADY  ( m00_axi_bready ),
      .M_AXI_ARADDR  ( axi_rd_address ),
      .M_AXI_ARPROT  ( m00_axi_arprot ),
      .M_AXI_ARVALID ( m00_axi_arvalid ),
      .M_AXI_ARREADY ( m00_axi_arready ),
      .M_AXI_RDATA   ( m00_axi_rdata ),
      .M_AXI_RRESP   ( m00_axi_rresp ),
      .M_AXI_RVALID  ( m00_axi_rvalid ),
      .M_AXI_RREADY  ( m00_axi_rready )
 );

 
  spi_slave_axi_master_SPI #(
      .SPI_ADDR_WIDTH ( SPI_ADDR_WIDTH ),
      .DUMMY_CYCLES   ( DUMMY_CYCLES   )
      )
  spi_slave_if (
      .core_clk         ( m00_axi_aclk   ),            
      .core_reset_n     ( m00_axi_aresetn),        
      .spi_clk          ( spi_clk        ),
      .spi_mosi         ( spi_mosi       ),
      .spi_miso         ( spi_miso_int   ),
      .spi_cs_n         ( spi_cs_n       ),
                                         
      .spi_read_address ( user_araddr[SPI_ADDR_WIDTH-1:0]  ),  
      .spi_write_address( user_awaddr[SPI_ADDR_WIDTH-1:0]  ),
      .spi_write_data   ( user_wdata     ),  
      .spi_read_data    ( user_rdata     ), 
      .spi_write        ( init_w_axi_txn ), 
      .spi_read         ( init_r_axi_txn )  
  );


/*
  spi_slave_axi_master_SPI #(
      .SPI_ADDR_WIDTH ( SPI_ADDR_WIDTH ),
      .DUMMY_CYCLES ( DUMMY_CYCLES )
      )
  spi_slave_axi_master_SPI_inst (
      .core_clk     ( m00_axi_aclk ),            
      .core_reset_n ( m00_axi_aresetn ),        
                       
      .spi_clk  ( spi_clk  ),
      .spi_mosi ( spi_mosi ),
      .spi_miso ( spi_miso_int ),
      .spi_cs_n ( spi_cs_n ),
                       
      .core_miso_word   ( core_miso_word    ),      
      .core_cs_n        ( core_cs_n         ),
      
      .spi_read_address ( spi_read_address  ) ,  
      .spi_write_address( spi_write_address ) ,
      .spi_write_data   ( spi_write_data    ) ,  
      .spi_read_data    ( spi_read_data     ) , 
      .spi_write        ( spi_write         ) , 
      .spi_read         ( spi_read          )   
  );
    
  spi_slave_axi_master_sm #(
      .SPI_ADDR_WIDTH ( SPI_ADDR_WIDTH )
      )
  spi_slave_axi_master_sm_inst (
      .core_clk     ( m00_axi_aclk ),            
      .core_reset_n ( m00_axi_aresetn ),
      
      .core_cs_n    ( core_cs_n ),

      .core_miso_word  ( core_miso_word ),      

      .init_w_axi_txn  ( init_w_axi_txn ),
      .init_r_axi_txn  ( init_r_axi_txn ),
      .error_w_axi_txn ( error_w_axi_txn ),
      .error_r_axi_txn ( error_r_axi_txn ),
      .done_w_axi_txn  ( done_w_axi_txn ),
      .done_r_axi_txn  ( done_r_axi_txn ),
      
      .user_awaddr  ( user_awaddr_sm ),
      .user_araddr  ( user_araddr_sm ),
      .user_wdata   ( user_wdata ),
      .user_rdata   ( user_rdata ),
      
      .spi_read_address  ( spi_read_address  ) ,
      .spi_write_address ( spi_write_address ) ,
      .spi_write_data    ( spi_write_data    ) , 
      .spi_read_data     ( spi_read_data     ) ,
      .spi_write         ( spi_write         ) ,
      .spi_read          ( spi_read          )
       
  );
*/  
 endmodule