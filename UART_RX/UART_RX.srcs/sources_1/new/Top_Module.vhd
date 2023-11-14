library ieee;
use ieee.std_logic_1164.ALL;

entity top_module is
    generic(
        clk_freq    : integer := 72_000_000;        -- Frequencia del sistema
        baud_rate   : integer := 9_600;             -- Baudios
        data_width  : integer := 8
    );                    
    port(
        clk         : in  std_logic;
        reset       : in  std_logic;
        rx          : in  std_logic;
        output      : out std_logic_vector ( data_width - 1 downto 0 )
    );
end top_module;

architecture Behavioral of top_module is

    component UART_RX is
        generic (
            clks_per_bit    : integer := clk_freq / baud_rate                       
        );
        port (
            clk             : in  std_logic;
            reset           : in  std_logic;
            in_RX_Serial    : in  std_logic;
            RX_full         : out std_logic;
            out_RX_Byte     : out std_logic_vector ( data_width - 1 downto 0 )
        );
    end component UART_RX;
        
    component FIFO is
        port (
            clk         : in  std_logic;                        
            reset       : in  std_logic;                        
            wr_en       : in  std_logic;                        
            data_in     : in  std_logic_vector(7 downto 0);     
            data_out    : out std_logic_vector(7 downto 0)      
        );
    end component FIFO;
    
    signal register_rx_full : std_logic;
    signal fifo_data_in     : std_logic_vector(data_width-1 downto 0); 
    signal fifo_data_out    : std_logic_vector(data_width-1 downto 0); 
    
    begin
        -- Instanciación del módulo RX
        UART_RX_Inst : UART_RX
            generic map(
                clks_per_bit  => clk_freq / baud_rate                         
            )
            port map(
                clk           => clk,
                reset         => reset,
                in_RX_Serial  => rx,
                RX_full       => register_rx_full,
                out_RX_Byte   => fifo_data_in
            );
        -- Instanciación del módulo FIFO
        FIFO_Inst    : FIFO
            port map(
                clk         => clk,
                reset       => reset,
                wr_en       => register_rx_full,
                data_in     => fifo_data_in,
                data_out    => fifo_data_out
            );
 
    output <= fifo_data_out;

end architecture Behavioral;
        