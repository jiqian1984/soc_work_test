-------------------------------------------------------------------------------
-- Title    : BCN sync mux
-- Project  : Kaasu
-- Author   : $Author: jkoskela $
-- Revision : $Revision: 2177 $
-- Date     : $Date: 2015-02-05 10:42:49 +0200 (Thu, 05 Feb 2015) $
-- URL      : $URL: https://svne1.access.nsn.com/isource/svnroot/soc_ip_cpri_obsai/trunk/duran/trunk/cpri_ip/design/hdl/bcn/sync_bcn_mux.vhd $
-------------------------------------------------------------------------------
-- Copyright (C) Nokia Siemens Networks
-- All rights reserved. Reproduction in whole or part is prohibited
-- without the written permission of the copyright owner.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

--library work;
--use work.CPRI_PKG.all;

entity one_bit_sync is
  port (
    rst_i                : in  std_logic;
    clk_high_i           : in  std_logic;
    clk_low_i            : in  std_logic;
    data_high_i          : in  std_logic;

    data_low_o           : out std_logic
    );
end one_bit_sync;

architecture RTL of one_bit_sync is

  signal data_high_reg       : std_logic;
  signal data_low_reg0       : std_logic;
  signal data_low_reg1       : std_logic;
  signal data_low_reg2       : std_logic;
  signal data_lowout_reg     : std_logic;
  
 begin

  ----------------------------------------------------------------------------
  -- Synchronize OCB signals
  ----------------------------------------------------------------------------
  high_input_sync : process(rst_i,clk_high_i)
  begin
      if(rst_i = '1') then
	      data_high_reg <= '0';
	  else
	      if(clk_high_i'event and clk_high_i = '1') then
		      if(data_high_i = '1') then
			      data_high_reg <= not data_high_reg;
			  else
			      data_high_reg <= data_high_reg;
			  end if;
		  end if;
	  end if;
  
  end process high_input_sync;
  
  high_to_low_sync : process(rst_i,clk_low_i)
  begin
      if(rst_i = '1') then
	      data_low_reg0 <= '0';
	      data_low_reg1 <= '0';
	      data_low_reg2 <= '0';
	      data_lowout_reg <= '0';
	  else
	      if(clk_low_i'event and clk_low_i = '1') then
		      data_low_reg0 <= data_high_reg;
			  data_low_reg1 <= data_low_reg0;
			  data_low_reg2 <= data_low_reg1;
		      if((data_low_reg2 xor data_low_reg1) = '1')then
			      data_lowout_reg <= '1';
			  else
			      data_lowout_reg <= '0';
			  end if;
		  end if;
	  end if;
  
  end process high_to_low_sync;
  
  data_low_o <= data_lowout_reg;
  
end RTL;

