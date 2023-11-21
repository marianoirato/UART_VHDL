library ieee;
use ieee.std_logic_1164.ALL;
 
entity FULL_RX_TB is
end FULL_RX_TB;
 
architecture behavior of FULL_RX_TB is 
 
    -- Component Declaration for the Unit Under Test (UUT)
    component top_module
    generic(
        clk_freq    : integer := 72_000_000;                  -- frequency of the system clock in Hertz
        baud_rate   : integer := 9_600;                      -- data link baud rate in bits/secondsignal
        data_width  : integer := 8
    );
    port(
        clk     : in  std_logic;
        reset   : in  std_logic;
        rx      : in  std_logic;
        output  : out std_logic_vector ( ( data_width - 1 ) downto 0 )
    );
    end component;

    --agrega el reader
    component input_data_file
    generic( file_name      : string	   := "C:/Users/Martin/VHDL/UART_RX/archivo_uart.dat";
             output_width   : integer      := 10);
    port( read_new_data     : in  std_logic;          
          file_on           : out std_logic;
          file_output       : out std_logic_vector ( ( output_width - 1 ) downto 0 ) 
    );
    end component;   

    component output_data_file
    generic( WriteFile      : string	   := "C:/Users/Martin/VHDL/UART_RX/archivo_uart.dat";
             InputWidth     : integer      := 10);
    port( NewData           : in  std_logic;          
          FileON            : out std_logic;
          Input             : out std_logic_vector ( ( InputWidth - 1 ) downto 0 ) 
    );
    end component;  

   --Inputs
   signal tb_clk    : std_logic := '0';
   signal reset     : std_logic := '0';
   signal rx_tb     : std_logic := '0';

   signal enable_lectura    : std_logic := '0';
   signal fileon_lectura    : std_logic := '0';
   signal enable_escritura  : std_logic := '0';
   signal fileon_escritura  : std_logic := '0';
   signal arrRx             : std_logic_vector ( 9 downto 0 );


   --Outputs
   signal data_out_from_tx : std_logic_vector ( 7 downto 0 );

   -- Clock period definitions
   constant clk_period      : time      := 13.888888888888888888 ns;
   constant baud_rate_hz    : time      := 104.16666666666666667 us; -- 1 / 9600 baudios
   constant BAUD_RATE       : integer   := 9600;

 
begin
 
	-- Instantiate the Unit Under Test (UUT)
    uut: top_module 
    generic map(
        clk_freq    =>  72_000_000,
        baud_rate   =>  9_600,
        data_width  =>  8
    )
    port map (
        clk         => tb_CLK,
        reset       => reset,
        rx          => rx_tb,
        output      => data_out_from_tx
    );

    --Instanciacion del reader
    Inst_TX_File: input_data_file 
    generic map(file_name       => "C:/Users/Martin/VHDL/UART_RX/archivo_TX.dat",	
                output_width      => 10)      
    port map(
        read_new_data       => enable_escritura,
        file_on             => fileon_escritura,
        file_output	        => arrRx
    );
    
    --Instanciacion del reader
    Inst_RX_File: output_data_file 
    generic map(WriteFile       => "C:/Users/Martin/VHDL/UART_RX/archivo_RX.dat",	
                InputWidth      => 10)      
    port map(
        NewData	    => enable_lectura,
        FileON	    => fileon_lectura,
        Input	    => data_out_from_tx
    );
      

   -- Clock process definitions
   clock_process :process
   begin
      tb_clk <= '0';
      wait for clk_period/2;
      tb_clk <= '1';
      wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin	
      reset <= '1';
      rx_tb <= '1';
      wait for 100 ns;	
      reset <= '0';

      --wait for clk_period*1000;

      for i in 0 to 45 loop    -- Errores en luego del dato 16 y luego del dato 28 del archivo de texto.
          enable_lectura <= '1';
          wait for baud_rate_hz;
          rx_tb <= arrRx(9);
          wait for baud_rate_hz;
          rx_tb <= arrRx(8);
          wait for baud_rate_hz;
          rx_tb <= arrRx(7);
          wait for baud_rate_hz;
          rx_tb <= arrRx(6);
          wait for baud_rate_hz;
          rx_tb <= arrRx(5);
          wait for baud_rate_hz;
          rx_tb <= arrRx(4);
          wait for baud_rate_hz;
          rx_tb <= arrRx(3);
          wait for baud_rate_hz;
          rx_tb <= arrRx(2);
          wait for baud_rate_hz;
          rx_tb <= arrRx(1);
          wait for baud_rate_hz;
          rx_tb <= arrRx(0);
          enable_lectura <= '0';
          wait for baud_rate_hz;
      end loop;	

      
      wait;
   end process;

end;
