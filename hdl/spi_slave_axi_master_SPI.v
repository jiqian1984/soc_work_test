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

reg [2:0]    				spi_clk_delay;
reg [1:0]    				spi_cs_n_delay;
reg [1:0]    				spi_mosi_delay;
reg 						spi_writein;
reg      					spi_readin;
reg [SPI_ADDR_WIDTH-1:0] 	spi_rx_addressin , spi_rx_adress;
reg [31:0]        			spi_rx_datain , spi_rx_data  ;
reg [31:0]        			spi_tx_datain , spi_tx_data  ;
reg [2:0]        			spi_state     , spi_statein  ;
reg [4:0]        			rx_cnt        , rx_cntin     ;
reg              			cmd_type      , cmd_typein   ;

//===========================================================

	assign spi_clk_posedge 	= spi_clk_delay[1]    && (~spi_clk_delay[2]);
	assign spi_clk_negedge 	= (~spi_clk_delay[1]) && spi_clk_delay[2];

	assign spi_read_address 	= {1'h0,spi_rx_address};
	assign spi_write_address 	= {1'h0,spi_rx_address};
	assign spi_write_data       = spi_rx_data;

	assign spi_miso        		= spi_tx_data[31];

	always @(*)
	begin
		spi_rx_addressin	= spi_rx_address;
		spi_rx_datain		= spi_rx_data;
		spi_tx_datain		= spi_tx_data;
		spi_writein			= 'h0;
		spi_readin			= 'h0;
		spi_statein			= spi_state;
		rx_cntin			= rx_cnt;
		cmd_typein			= cmd_type;
		if(spi_cs_n_delay[1])
		begin	
			spi_statein = h'0;
			spi_readin  = h'0;
			rx_cntin    = h'0;
		end
		else begin
			case(spi_state)
				3'h0://IDLE
				begin
					spi_statein = h'0;
			        spi_readin  = h'0;
			        rx_cntin    = h'0;
			        if(spi_clk_negedge) // the 1th data, command 1 for read,0 for write
			        begin
			        	cmd_typein = spi_mosi_delay[1];
			        	spi_statein = 3'h1;
			        end
				end
				3'h1://receive addr
				begin
					if(spi_clk_negedge) // the 1th data, command 1 for read,0 for write
			        begin
			        	spi_rx_addressin = {spi_rx_address[SPI_ADDR_WIDTH-3:0], spi_mosi_delay[1]};
			        	rx_cntin         = rx_cnt + 1'h1;
			        end
				end
				3'h2://idle cycle
          begin
              spi_tx_datain = spi_read_data;
              if(spi_clk_negedge)//
              begin
                  rx_cntin = rx_cnt + 1'h1;
              end 
              else if(rx_cnt >= 5'd12)// count >= 12, means recieved 12 idle cck
              begin
                  rx_cntin = 'h0;
                  if(~cmd_type)//this is write data
                  begin
                      spi_statein = 3'h3;//recieved write data
                  end
                  else//this is read data
                  begin
                      spi_statein = 3'h5;//send out read data               
                  end
              end          
          end
          3'h3://receive write data
          begin
              if(spi_clk_negedge)//
              begin
                  spi_rx_datain = {spi_rx_datain[30:0], spi_mosi_delay[1]};
                  rx_cntin      = rx_cnt + 1'h1;
              end 
              else if(rx_cnt >= 5'd31)// count >= 31, means recieved 31-bit
              begin
                  spi_statein = 3'h4;//recieve last data bit
                  rx_cntin    = 'h0;
              end          
          end
          3'h4://receive last bit
          begin
              if(spi_clk_negedge)//
              begin
                  spi_rx_datain = {spi_rx_datain[30:0], spi_mosi_delay[1]};
                  spi_statein   = 3'h0;//recieve last data bit
                  spi_writein   = 'h1;
              end       
          end

          3'h5://send out read data
          begin
       if(spi_clk_negedge)//
              begin
                  spi_tx_datain = spi_tx_data << 1;
                  rx_cntin      = rx_cnt + 1'h1;
              end 
              else if(rx_cnt >= 5'd31)// count >= 31, means send out 31-bit
              begin
                  spi_statein = 3'h6;//send out last data bit
                  rx_cntin    = 'h0;
              end               
          end
          3'h6://send out last bit
          begin
              if(spi_clk_negedge)//
              begin
                  spi_statein = 3'h0;//return idle
              end       
          end
          default://re
          begin
              spi_statein = 'h0;
          end
          endcase 
      end     
  end
  
  
//==============================================================================
//==============================================================================
  
  always @( posedge core_clk or negedge core_reset_n )
  begin
      if ( !core_reset_n ) 
      begin
          spi_clk_delay  <= 'h0;
          spi_cs_n_delay <= 'h7;
          spi_mosi_delay <= 'h0;
          spi_write      <= 'h0;
          spi_read       <= 'h0;
          spi_rx_address <= 'h0;
          spi_rx_data    <= 'h0;
          spi_tx_data    <= 'h0;
          spi_state      <= 'h0;
          rx_cnt         <= 'h0;
          cmd_type       <= 'h1;
      end
      else
      begin
          spi_clk_delay  <= {spi_clk_delay [1:0], spi_clk };
          spi_cs_n_delay <= {spi_cs_n_delay[0]  , spi_cs_n};
          spi_mosi_delay <= {spi_mosi_delay[0]  , spi_mosi}; 
          spi_write      <= spi_writein     ;// write pulse indicate there has a write command
          spi_read       <= spi_readin      ;// read pulse   
          spi_rx_address <= spi_rx_addressin;
          spi_rx_data    <= spi_rx_datain   ;
          spi_tx_data    <= spi_tx_datain   ;
          spi_state      <= spi_statein     ;
          rx_cnt         <= rx_cntin        ;  
          cmd_type       <= cmd_typein      ;   
      end
  end   


end module;