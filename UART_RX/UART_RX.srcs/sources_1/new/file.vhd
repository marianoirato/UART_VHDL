library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

entity data_file is
    Generic(file_name    : string  := "C:/Users/Martin/VHDL/UART_RX/archivo_uart.dat";
            output_width : integer := 10
           );
    Port( read_new_data : in   std_logic;
          file_on       : out  std_logic;
          file_output   : out  std_logic_vector ( ( output_width - 1 ) downto 0 )
        );
end data_file;

architecture Behavioral of data_file is

    FILE   archivo   : text  open read_mode  is  file_name;
    
    signal file_open        : std_logic := '0';
    signal string_output    : std_logic_vector ( ( output_width - 1 ) downto 0 ) := ( others => '0' );
  
    -- Se utiliza para convertir la cadena a std_logic_vector
    function to_std_logic(c: character) return std_logic is 
    variable sl: std_logic;
    begin
        case c is
        when 'U' => 
            sl := 'U'; 
        when 'X' =>
            sl := 'X';
        when '0' => 
            sl := '0';
        when '1' => 
            sl := '1';
        when 'Z' => 
            sl := 'Z';
        when 'W' => 
            sl := 'W';
        when 'L' => 
            sl := 'L';
        when 'H' => 
            sl := 'H';
        when '-' => 
            sl := '-';
        when others =>
            sl := 'X'; 
        end case;
    return sl;
    end to_std_logic;
  
    -- Convierte la cadena a std_logic_vector
    function to_std_logic_vector ( s: string ) return std_logic_vector is 
        variable slv: std_logic_vector ( s'high-s'low downto 0 );
        variable k: integer;
    begin
        k := s'high-s'low;
        for i in s'range loop
            slv(k) := to_std_logic ( s ( i ) );
            k      := k - 1;
        end loop;
    return slv;
    end to_std_logic_vector;  

    begin
    
    read_process: process
    
    variable linea   : line;
    variable cadena  : string ( 1 to output_width );
    
    begin	
        while not endfile ( archivo ) loop
            file_open <= '1';
            wait until rising_edge ( read_new_data );
            readline ( archivo , linea );
            read ( linea , cadena );
            string_output <= to_std_logic_vector ( cadena );
        end loop;
        
        file_open <= '0';
        file_close ( archivo );
    end process;
    
    file_output <= string_output;
    file_on     <= file_open;
   
end Behavioral;