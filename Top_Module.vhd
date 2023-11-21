library ieee;
use ieee.std_logic_1164.ALL;

entity top_module is
    generic(
        clk_freq    : integer := 72_000_000;        -- Frequencia del sistema
        baud_rate   : integer := 9_600;             -- Baudios
        data_width  : integer := 8
    );                    
    port(
        clk                 : in  std_logic;
        reset               : in  std_logic;
        rx                  : in  std_logic;
        output              : out std_logic;
        send_data_to_file   : out std_logic
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
    
    component UART_TX is
        generic (
            clks_per_bit    : integer := 7500        -- 72 MHz / 9600 Baudios
        );
        port (
            i_CLK           : in  std_logic;
            i_TX_RTS        : in  std_logic;            -- Señal de Validación de Transmisión (Ready To Send)
            i_TX_DATA       : in  std_logic_vector(7 downto 0);  -- Byte a transmitir
            o_TX_SERIAL     : out std_logic;            -- Salida serial de transmisión
            o_TX_DS         : out std_logic
        );
    end component UART_TX;
            
    component FIFO is
        port (
            clk         : in  std_logic;                        
            reset       : in  std_logic;                        
            wr_en       : in  std_logic;                        
            data_in     : in  std_logic_vector(7 downto 0); 
            fifo_rts    : out  std_logic;     
            data_out    : out std_logic_vector(7 downto 0)      
        );
    end component FIFO;
    
    signal register_rx_full : std_logic;
    signal fifo_data_in     : std_logic_vector(data_width-1 downto 0); 
    signal fifo_data_out    : std_logic_vector(data_width-1 downto 0); 
    
    signal TX_data_in       : std_logic_vector(data_width-1 downto 0); 
    signal TX_data_out      : std_logic;
    
    signal RTS              : std_logic;
    
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
            
        -- Instanciación del módulo TX
        UART_TX_Inst : UART_TX
            generic map(
                clks_per_bit  => clk_freq / baud_rate                         
            )
            port map(
                i_CLK         => clk,
                i_TX_RTS      => RTS,
                i_TX_DATA     => fifo_data_out,
                o_TX_SERIAL   => TX_data_out,
                o_TX_DS       => send_data_to_file
            );
            
        -- Instanciación del módulo FIFO
        FIFO_Inst    : FIFO
            port map(
                clk         => clk,
                reset       => reset,
                wr_en       => register_rx_full,
                data_in     => fifo_data_in,
                fifo_rts    => RTS,
                data_out    => fifo_data_out
            );
 
    output <= TX_data_out;

end architecture Behavioral;
        