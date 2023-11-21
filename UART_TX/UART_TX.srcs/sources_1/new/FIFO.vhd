----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/20/2023 04:58:27 AM
-- Design Name: 
-- Module Name: FIFO - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_module is
  generic (
    clk_freq    : integer := 72_000_000;   -- Frecuencia del sistema
    baud_rate   : integer := 9_600;        -- Baudios
    data_width  : integer := 8             -- Tamaño de la cadena de bits
  );
  port (
    clk         : in  std_logic;           -- Señal de Clock
    reset       : in  std_logic;           -- Señal de Reset
    tx          : out std_logic;           -- Salida serial del sistema
    output      : out std_logic_vector(data_width - 1 downto 0)  -- Tamaño de la cadena de salida en 8[bits]
  );
end top_module;

architecture RTL of top_module is
  -- Declaración de instancias de los módulos
  component FILE_READER
    generic (
      FILE_NAME    : string := "home/luciano/Desktop/FILE.dat";
      OUTPUT_WIDTH : integer := 8
    );
    port (
      i_CLK         : in  std_logic;
      i_TX_DONE     : in  std_logic;
      o_TX_DATA     : out std_logic_vector(7 downto 0);
      o_TX_RTS      : out std_logic;
      o_FILE_END    : out std_logic
    );
  end component;

  component UART_TX
    generic (
      CLK_PER_BIT  : integer := 7500   -- 72 MHz / 9600 Baudios
    );
    port (
      i_CLK       : in  std_logic;
      i_TX_RTS    : in  std_logic;
      i_TX_DATA   : in  std_logic_vector(7 downto 0);
      o_TX_DS     : out std_logic;
      o_TX_SERIAL : out std_logic;
      o_TX_DONE   : out std_logic
    );
  end component;

  component UART_FIFO
    generic (
      FIFO_DEPTH     : integer := 1024;
      BITS_PER_BYTE  : integer := 8
    );
    port (
      i_CLK          : in  std_logic;
      i_RESET        : in  std_logic;
      i_TX_SERIAL    : in  std_logic;
      i_TX_DS        : in  std_logic;
      i_TX_DONE      : in  std_logic;
      o_FULL_FILE    : out std_logic
    );
  end component;

  -- Señales internas para interconectar los módulos
  signal r_TX_RTS      : std_logic;
  signal r_TX_DS       : std_logic;
  signal r_TX_DATA     : std_logic_vector(7 downto 0);
  signal r_TX_DONE     : std_logic;
  signal r_FULL_FILE   : std_logic;
  
  -- Variable intermedia de tipo Buffer para la salida tx
  signal r_TX_BUFFER   : std_logic;

begin
  -- Instancias de los módulos
  FILE_READER_inst : FILE_READER
    generic map (
      FILE_NAME    => "home/luciano/Desktop/FILE.dat",
      OUTPUT_WIDTH => 8
    )
    port map (
      i_CLK         => clk,
      i_TX_DONE     => r_TX_DONE,
      o_TX_DATA     => r_TX_DATA,
      o_TX_RTS      => r_TX_RTS,
      o_FILE_END    => r_FULL_FILE
    );

  UART_TX_inst : UART_TX
    generic map (
      CLK_PER_BIT  => clk_freq / baud_rate
    )
    port map (
      i_CLK       => clk,
      i_TX_RTS    => r_TX_RTS,
      i_TX_DATA   => r_TX_DATA,
      o_TX_DS     => r_TX_DS,
      o_TX_SERIAL => r_TX_BUFFER,
      o_TX_DONE   => r_TX_DONE
    );

  UART_FIFO_inst : UART_FIFO
    generic map (
      FIFO_DEPTH     => 1024,
      BITS_PER_BYTE  => 8
    )
    port map (
      i_CLK          => clk,
      i_RESET        => reset,
      i_TX_SERIAL    => r_TX_BUFFER,  -- Conectar la variable intermedia
      i_TX_DS        => r_TX_DS,
      i_TX_DONE      => r_TX_DONE,
      o_FULL_FILE    => r_FULL_FILE
    );

  -- Salida del top_module
  tx <= r_TX_BUFFER;  -- Conectar la variable intermedia
  output <= r_TX_DATA;

end RTL;
