library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_ARITH.ALL;
use ieee.std_logic_UNSIGNED.ALL;
use ieee.numeric_std.all;
library std;
use std.textio.all;

entity TB_UART_RX is
end TB_UART_RX;

architecture behavior of TB_UART_RX is
    component UART_RX
    port(
         clk                : IN  std_logic;
         reset              : IN  std_logic;
         in_RX_Serial       : IN  std_logic;
         RX_full            : OUT  std_logic;
         out_RX_Byte        : OUT  std_logic_vector(7 downto 0)
        );
    end component;
 
    constant clk_period     : time      := 13.888888888888888888 ns;
    constant baud_rate_hz   : time      := 104.16666666666666667 us;
    signal tb_CLK           : std_logic := '0';
    signal tb_reset         : std_logic := '0';
    
    signal tb_RX_Serial     : std_logic := '0';
    signal tb_RX_full       : std_logic;
    signal tb_RX_Byte       : std_logic_vector(7 downto 0);
    
    constant BAUD_RATE      : integer   := 9600;  
    
begin

	-- Instantiate the Unit Under Test (UUT)
   uut: UART_RX PORT MAP (
          clk           => tb_CLK,
          reset         => tb_reset,
          in_RX_Serial  => tb_RX_Serial,
          RX_full       => tb_RX_full,
          out_RX_Byte   => tb_RX_Byte
        );

   -- Clock process definitions
   clk_process :process
   begin
		tb_CLK <= '0';
		wait for clk_period/2;
		tb_CLK <= '1';
		wait for clk_period/2;
   end process;
   
  -- Main simulation loop
  tb_process: process 
  
    begin		
        -- hold reset state for 100 ns.
        wait for 100 ns;
        tb_reset <= '1';
        tb_RX_Serial  <= '1';
        wait for 100 ns;
        tb_reset <= '0';
            
        wait for clk_period*10000;
        
        -- Start
        tb_RX_Serial <= '0';   
        wait for baud_rate_hz;
              
        -- Data
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '0';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '0';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '0';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '0';   
        wait for baud_rate_hz;
        
        -- Stop
        tb_RX_Serial <= '1';     
        wait for baud_rate_hz;
        
        
        -- Start
        tb_RX_Serial <= '0';   
        wait for baud_rate_hz;     
        
        -- Data
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '0';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '0';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '0';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '0';   
        wait for baud_rate_hz;
        
        -- Stop
        tb_RX_Serial <= '1';     
        wait for baud_rate_hz;
        
        
        -- Start
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;     
        
        -- Data
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        -- Stop
        tb_RX_Serial <= '1';     
        wait for baud_rate_hz;
        
        
        -- Start
        tb_RX_Serial <= '0';   
        wait for baud_rate_hz;     
        
        -- Data
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '0';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '0';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '0';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '0';   
        wait for baud_rate_hz;
        
        -- Stop
        tb_RX_Serial <= '1';     
        wait for baud_rate_hz;
        
        
        -- Start
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;     
        
        -- Data
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        tb_RX_Serial <= '1';   
        wait for baud_rate_hz;
        
        -- Stop
        tb_RX_Serial <= '1';     
        wait for baud_rate_hz;
        
        
        -- hold reset state for 100 ns.
        wait for 100 ns;
        tb_reset <= '1';
        tb_RX_Serial  <= '1';
        wait for 100 ns;
        tb_reset <= '0';
      
        wait;
    end process;
end behavior;
