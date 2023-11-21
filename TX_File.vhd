library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.txt_util.all;

entity input_data_file is
    Generic(file_name    : string  := "C:/Users/Martin/VHDL/UART/Archivo_TX.dat";
            output_width : integer := 10
           );
    Port( read_new_data : in   std_logic;
          file_on       : out  std_logic;
          file_output   : out  std_logic_vector ( ( output_width - 1 ) downto 0 )
        );
end input_data_file;

architecture Behavioral of input_data_file is

    FILE   archivo   : text  open read_mode  is  file_name;
    
    signal file_open        : std_logic := '0';
    signal string_output    : std_logic_vector ( ( output_width - 1 ) downto 0 ) := ( others => '0' );

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