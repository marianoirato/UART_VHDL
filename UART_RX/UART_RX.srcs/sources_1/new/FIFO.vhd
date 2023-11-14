library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity FIFO is
    Port (
        clk         : in  std_logic;                        
        reset       : in  std_logic;                       
        wr_en       : in  std_logic;                        
        data_in     : in  std_logic_vector ( 7 downto 0 );  
        data_out    : out std_logic_vector ( 7 downto 0 )   
    );
end entity FIFO;

architecture Behavioral of FIFO is
    type fifo_memory is array ( 0 to 15 ) of std_logic_vector ( 7 downto 0 );
    signal memory : fifo_memory := ( others => ( others => '0' ) );
    signal read_ptr, write_ptr: integer range 0 to 15 := 0;
begin
    process ( clk, reset )
    begin
        if ( reset = '1' ) then
            read_ptr <= 0;
            write_ptr <= 0;
        elsif ( rising_edge ( clk ) ) then
            if ( wr_en = '1' ) then
                if ( write_ptr < 16 ) then
                    memory ( write_ptr ) <= data_in;
                    write_ptr <= ( write_ptr + 1 );
                end if;
            else
                -- Se lee solo si se escribieron más datos de los que se quiere leer
                if ( read_ptr < write_ptr ) then
                    data_out <= memory ( read_ptr );
                    read_ptr <= ( read_ptr + 1 );
                end if;
                -- Cuando se llega al final de la memoria se reincia el puntero
                if ( read_ptr = 15 and write_ptr = 15 ) then
                    write_ptr <= 0;
                    read_ptr  <= 0;
                end if;
            end if;
        end if;
    end process;

end architecture Behavioral;

