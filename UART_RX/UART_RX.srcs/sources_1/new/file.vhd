library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

entity FileREADER is
    Generic(read_file    : string  := "C:/Users/Martin/Downloads/Archivo_de_Lectura.dat";
            output_width : integer := 10
           );
    Port( read_new_data : in   std_logic;
          file_on       : out  std_logic;
          file_output   : out  std_logic_vector ( ( output_width - 1 ) downto 0 )
        );
end FileREADER;

architecture Behavioral of FileREADER is

    FILE   variableTB : text  open read_mode  is  read_file;
    
    signal sigFileON  : std_logic := '0';
    signal sigOutput  : std_logic_vector ( ( output_width - 1 ) downto 0 ) := ( others => '0' );
  
    
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
  
    function to_std_logic_vector(s: string) return std_logic_vector is 
        variable slv: std_logic_vector(s'high-s'low downto 0);
        variable k: integer;
    begin
        k := s'high-s'low;
        for i in s'range loop
            slv(k) := to_std_logic(s(i));
            k      := k - 1;
        end loop;
    return slv;
    end to_std_logic_vector;  


    begin
    
    read_proc: process
    
    variable LineVar   : line;
    variable StringVar : string(1 to output_width);
    
    begin	
        while not endfile ( variableTB ) loop
            sigFileON <= '1';
            wait until rising_edge ( read_new_data );
            readline ( variableTB , LineVar );
            read ( LineVar , StringVar );
            sigOutput <= to_std_logic_vector ( StringVar );
        end loop;
        
        sigFileON <= '0';
        file_close(variableTB);
    end process;
    
    file_output <= sigOutput;
    file_on     <= sigFileON;
   
end Behavioral;