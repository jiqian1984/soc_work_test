//----------------------------------------------------------------------------- 
// Title         : SPI Slave
// Project       : 
//----------------------------------------------------------------------------- 
// File          : spi_slave_axi_master_v1_0_SPI.v
// Author        : 
// Created       :
//----------------------------------------------------------------------------- 
// Description   : 
//
//----------------------------------------------------------------------------- 
//------------------------------------------------------------------------------

module spi_slave_axi_master_sm
 #( 
    parameter integer SPI_ADDR_WIDTH = 20
  )
  (
    input                       core_clk,
    input                       core_reset_n,
    input                       core_cs_n,

    output reg      [31:0]      core_miso_word,

    output reg                  init_w_axi_txn,
    output reg                  init_r_axi_txn,
    input                       error_w_axi_txn,
    input                       error_r_axi_txn,
    input                       done_w_axi_txn,
    input                       done_r_axi_txn,

    output reg      [SPI_ADDR_WIDTH-1:0]  user_awaddr,
    output reg      [SPI_ADDR_WIDTH-1:0]  user_araddr,
    output reg      [31:0]                user_wdata,
    input           [31:0]                user_rdata,
    
    input  wire     [SPI_ADDR_WIDTH-1:0]  spi_read_address,
    input  wire     [SPI_ADDR_WIDTH-1:0]  spi_write_address,
    input  wire     [31:0]                spi_write_data,
    output  wire    [31:0]                spi_read_data,
    input  wire                           spi_write, // write pulse indicate there has a write command
    input  wire                           spi_read   // read pulse 
  );
    
reg  [2:0]  spi_read_d;
reg  [2:0]  spi_write_d;
reg  [31:0] spi_write_data_d;
reg  [SPI_ADDR_WIDTH-1:0] spi_read_address_d;
reg  [SPI_ADDR_WIDTH-1:0] spi_write_address_d;
wire        spi_read_come ;
wire        spi_write_come ;
//******************************************************************************
//  Local Parameter Declaration
//******************************************************************************

//localparam STATE_IDLE            = 0;

typedef enum logic [3:0] {
  STATE_IDLE,
  STATE_WRITE_1,
  STATE_WRITE_2,
  STATE_WRITE_3,
  STATE_WRITE_4,
  STATE_READ_1,
  STATE_READ_2,
  STATE_READ_3,
  STATE_READ_4
} STATE_ENUM; 

reg sm_reset_n;
reg [3:0] sm_rst_cnt;

always @( posedge core_clk or negedge core_cs_n)
begin
  if ( !core_cs_n ) begin
    sm_reset_n <= 1'b1;
    sm_rst_cnt <= 4'h0;
  end else begin
    if (sm_rst_cnt != 4'hf) begin
      sm_rst_cnt <= sm_rst_cnt + 4'h1;
      sm_reset_n <= 1'b1;
    end else begin
      sm_rst_cnt <= sm_rst_cnt;
      sm_reset_n <= 1'b0;
    end
  end
end

// Cross clock domain process
always @(posedge core_clk or negedge core_reset_n)
begin
  if ( !core_reset_n ) begin
    spi_read_d         <=  3'h0 ;
    spi_write_d        <=  3'h0 ;
    spi_write_data_d   <= 32'h0 ;
    spi_read_address_d <= 'h0 ;
    spi_write_address_d<= 'h0 ;
  end
  else begin
    spi_read_d         <=  { spi_read_d[1:0], spi_read } ;
    spi_write_d        <=  { spi_write_d[1:0], spi_write } ;
    spi_write_data_d   <=  spi_write_data ;
    spi_read_address_d <=  spi_read_address ;
    spi_write_address_d<=  spi_write_address ;
  end
end

assign spi_read_come = spi_read_d[1] & !spi_read_d[2];
assign spi_write_come = spi_write_d[1] & !spi_write_d[2];
//******************************************************************************
//  Register Declaration
//******************************************************************************
STATE_ENUM   sm_state;
reg [15:0]   num_words;
reg [4:0]    timeout_cnt;
//assign    sm_reset_n = core_cs_n && core_reset_n;
// *****************************************************************************

always @( posedge core_clk or negedge sm_reset_n )
begin
  if ( !sm_reset_n ) begin
    sm_state <= STATE_IDLE;
    core_miso_word <=  'h0;
    
    init_w_axi_txn <= 1'b0;
    init_r_axi_txn <= 1'b0;
    user_awaddr <=   'h0;
    user_araddr <=   'h0;
    user_wdata  <= 32'h0;
    num_words   <= 16'h0;
    timeout_cnt <= 5'h0;
  end
  else begin
      // default values
    init_w_axi_txn <= 1'b0;
    init_r_axi_txn <= 1'b0;
    timeout_cnt    <= 5'h0;
    case ( sm_state )
      STATE_IDLE:
      begin
        if (spi_read_come) begin
          sm_state <= STATE_READ_1;
          user_araddr[SPI_ADDR_WIDTH-1:0] <= spi_read_address_d;
          init_r_axi_txn <= 1'b1;
        end 
        else if (spi_write_come) begin
          sm_state <= STATE_WRITE_1;
          user_awaddr[SPI_ADDR_WIDTH-1:0] <= spi_write_address_d;
        end
      end 
      
      // -----------------------------------------------------------------------
      STATE_WRITE_1:
      begin
          user_wdata[31:0] <= spi_write_data_d;
          init_w_axi_txn <= 1'b1;
          sm_state <= STATE_WRITE_2;
      end
      
      STATE_WRITE_2:
      begin
        // init_w_axi_txn asserted
        sm_state <= STATE_WRITE_3;
      end

      STATE_WRITE_3:
      begin
        // init_w_axi_txn deasserted
        // done_w_axi_txn takes one clock to clear from previous transaction
        sm_state <= STATE_WRITE_4;
      end
      
      STATE_WRITE_4:
      begin
        // wait for AXI write transaction to complete
        timeout_cnt <= timeout_cnt + 5'h1;
        if ( done_w_axi_txn ) begin
          sm_state <= STATE_IDLE;
        end
        else if (timeout_cnt == 5'h1f) begin
          sm_state <= STATE_IDLE;
        end
      end
      
      // -----------------------------------------------------------------------
      
      // init_r_axi_txn       0 0 1 0 0
      // done_r_axi_txn       1 1 1 1 0 
      // error_r_axi_txn      1 1 1 1 0
      STATE_READ_1:
      begin
        // wait for AXI read transaction to complete
        timeout_cnt <= timeout_cnt + 5'h1;
        if ( done_r_axi_txn ) begin
          core_miso_word <= user_rdata[31:0];
          sm_state <= STATE_READ_2;
        end
        else if (timeout_cnt == 5'h1f) begin
          sm_state <= STATE_IDLE;
        end
      end
      
        
      STATE_READ_2:
      begin
        sm_state <= STATE_READ_3;
      end
      
      
      STATE_READ_3:
      begin
        sm_state <= STATE_READ_4;
      end
      
      
      STATE_READ_4:
      begin
        sm_state <= STATE_IDLE;
      end
          
    endcase
    
  end
end
 

endmodule