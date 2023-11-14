
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY FIFO_tb IS
END FIFO_tb;
 
ARCHITECTURE behavior OF FIFO_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT FIFO
    PORT(
         clk        : IN  std_logic;
         reset      : IN  std_logic;
         wreg_en      : IN  std_logic;
         data_in    : IN  std_logic_vector(7 downto 0);
         data_out   : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    
   --Inputs
   signal clk       : std_logic := '0';
   signal reset     : std_logic := '0';
   signal wreg_en     : std_logic := '0';
   signal data_in   : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal s_data_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 13.88888888888888888888888888888888888 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: FIFO PORT MAP (
          clk => clk,
          reset => reset,
          wreg_en => wreg_en,
          data_in => data_in,
          data_out => s_data_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      reset <= '1';
      data_in <= "00000000";
      wreg_en <= '0';
      wait for 100 ns;	
      reset <= '0';
      data_in <= "00000001";
      wait for clk_period*100;

      -- insert stimulus here 
      wreg_en <= '1';
      wait for clk_period;
      wreg_en <= '0';
      wait for 10416.66667 ns;
      
      data_in <= "00000010";
      wreg_en <= '1';
      wait for clk_period;
      wreg_en <= '0';
      wait for 10416.66667 ns;
      
      data_in <= "00000011";
      wreg_en <= '1';
      wait for clk_period;
      wreg_en <= '0';
      wait for 10416.66667 ns;

      data_in <= "00000100";
      wreg_en <= '1';
      wait for clk_period;
      wreg_en <= '0';
      wait for 10416.66667 ns;

      data_in <= "00000101";
      wreg_en <= '1';
      wait for clk_period;
      wreg_en <= '0';
      wait for 10416.66667 ns;

      data_in <= "00000111";
      wreg_en <= '1';
      wait for clk_period;
      wreg_en <= '0';
      wait for 10416.66667 ns;

      data_in <= "00001000";
      wreg_en <= '1';
      wait for clk_period;
      wreg_en <= '0';
      wait for 10416.66667 ns;

      data_in <= "00001001";
      wreg_en <= '1';
      wait for clk_period;
      wreg_en <= '0';
      wait for 10416.66667 ns;

      data_in <= "00001010";
      wreg_en <= '1';
      wait for clk_period;
      wreg_en <= '0';
      wait for 10416.66667 ns;

      data_in <= "00001011";
      wreg_en <= '1';
      wait for clk_period;
      wreg_en <= '0';
      wait for 10416.66667 ns;

      data_in <= "00001100";
      wreg_en <= '1';
      wait for clk_period;
      wreg_en <= '0';
      wait for 10416.66667 ns;

      data_in <= "00001101";
      wreg_en <= '1';
      wait for clk_period;
      wreg_en <= '0';
      wait for 10416.66667 ns;

      data_in <= "00001111";
      wreg_en <= '1';
      wait for clk_period;
      wreg_en <= '0';
      wait for 10416.66667 ns;

      data_in <= "00010000";
      wreg_en <= '1';
      wait for clk_period;
      wreg_en <= '0';
      wait for 10416.66667 ns;

      data_in <= "00010001";
      wreg_en <= '1';
      wait for clk_period;
      wreg_en <= '0';
      wait for 10416.66667 ns;

      data_in <= "11111111";
      wreg_en <= '1';
      wait for clk_period;
      wreg_en <= '0';
      wait for 10416.66667 ns;

      data_in <= "00001111";
      wreg_en <= '1';
      wait for clk_period;
      wreg_en <= '0';
      wait for 10416.66667 ns;

      data_in <= "11110000";
      wreg_en <= '1';
      wait for clk_period;
      wreg_en <= '0';
      wait for 10416.66667 ns;



      wait;
   end process;

END;
