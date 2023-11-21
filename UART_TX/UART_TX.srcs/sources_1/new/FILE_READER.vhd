----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/20/2023 02:21:18 PM
-- Design Name: 
-- Module Name: FILE_READER - Behavioral
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
use std.textio.all;

entity FILE_READER is
  generic (
    FILE_NAME    : string := "/home/luciano/Desktop/FILE.dat";
    OUTPUT_WIDTH : integer := 8
  );
  port (
    i_CLK         : in  std_logic;
    i_TX_DONE     : in  std_logic;
    o_TX_DATA     : out std_logic_vector(7 downto 0);
    o_TX_RTS      : out std_logic;
    o_FILE_END    : out std_logic
  );
end FILE_READER;

architecture RTL of FILE_READER is
  type StateMachine_FILE_READER is (
    s_IDLE,    -- Espera a que TX_DONE sea 1
    s_LOAD,    -- Carga el buffer con 8 bits de datos
    s_CLEAR    -- Limpia el buffer y vuelve a s_IDLE
  );

  signal r_SM_FILE_READER : StateMachine_FILE_READER := s_IDLE;
  file FILE_DATA : TEXT open READ_MODE is FILE_NAME; --text  open read_mode  is  file_name;
  signal r_FILE_OPEN : std_logic := '0';
  signal r_BUFFER : std_logic_vector(7 downto 0) := (others => '0');
  signal r_INDEX : integer := 0;  -- Contador para los 8 bits
  signal r_INDEX_TOP : integer := 0;  -- Contador para el final del archivo

  function to_std_logic(c: character) return std_logic is
    variable sl: std_logic;
  begin
    case c is
      when 'U' => sl := 'U'; 
      when 'X' => sl := 'X';
      when '0' => sl := '0';
      when '1' => sl := '1';
      when 'Z' => sl := 'Z';
      when 'W' => sl := 'W';
      when 'L' => sl := 'L';
      when 'H' => sl := 'H';
      when '-' => sl := '-';
      when others => sl := 'X'; 
    end case;
    return sl;
  end to_std_logic;

  function to_std_logic_vector(s: string) return std_logic_vector is
    variable slv: std_logic_vector ( s'range );
  begin
    for i in s'range loop
      slv(i) := to_std_logic(s(i));
    end loop;
    return slv;
  end to_std_logic_vector;

begin
  read_process : process
    variable LINEA   : line;
    variable CADENA  : string ( 1 to output_width );
  begin
    while not endfile(FILE_DATA) loop
      r_FILE_OPEN <= '1';
      wait until rising_edge(i_CLK);

      case r_SM_FILE_READER is
        when s_IDLE =>
          if i_TX_DONE = '1' then
            r_SM_FILE_READER <= s_LOAD;
          end if;

        when s_LOAD =>
          if r_INDEX < OUTPUT_WIDTH then
            readline(FILE_DATA, LINEA);
            read(LINEA, CADENA);
            r_BUFFER(r_INDEX) <= to_std_logic(CADENA(1));
            r_INDEX <= r_INDEX + 1;
            r_INDEX_TOP <= r_INDEX_TOP + 1;
          end if;

          if r_INDEX = OUTPUT_WIDTH then
            o_TX_RTS <= '1';
            o_TX_DATA <= r_BUFFER;
            r_SM_FILE_READER <= s_CLEAR;
          end if;

        when s_CLEAR =>
          o_TX_RTS <= '0';
          r_BUFFER <= (others => '0');
          r_INDEX <= 0;
          r_SM_FILE_READER <= s_IDLE;
          
          if r_INDEX_TOP >= (1024 * 1024) then
            o_FILE_END <= '1';
          else
            o_FILE_END <= '0';
          end if;

        when others =>
          r_SM_FILE_READER <= s_IDLE;
      end case;
    end loop;

    r_FILE_OPEN <= '0';
    file_close(FILE_DATA);
  end process;
end RTL;
