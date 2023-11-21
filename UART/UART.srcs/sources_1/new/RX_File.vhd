library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.all;
use work.txt_util.all;

entity output_data_file is
    Generic(WriteFile  : string  := "C:/Users/Martin/VHDL/UART_RX/archivo_RX.dat";
            InputWidth : integer := 10
           );
    Port( NewData : in  STD_LOGIC;
          Input   : in  STD_LOGIC_VECTOR ((InputWidth-1) downto 0);
          FileON  : in  STD_LOGIC);
end output_data_file;

architecture Behavioral of output_data_file is

  FILE variableTB  : text  open write_mode  is  WriteFile;
  
  signal sigFileON : STD_LOGIC := '0';
  signal sigInput  : STD_LOGIC_VECTOR ((InputWidth-1) downto 0) := (others => '0');

  begin
    write_proc: process
    
    variable LineVar   : line;
    variable StringVar : string(1 to InputWidth);
    
    begin	
      wait until rising_edge(sigFileON);
      StringVar := str( sigInput );
      write(LineVar , StringVar) ;
      writeline(variableTB , LineVar);
    end process;
    
    sigInput  <= Input;
    sigFileON <= FileON AND NewData;

end Behavioral;

