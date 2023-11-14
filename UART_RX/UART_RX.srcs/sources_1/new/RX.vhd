library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity UART_RX is
  generic (
    clks_per_bit    : integer   := 7500        -- 72 MHz / 9600 Baudios
  );
  port (
    clk             : in  std_logic;
    reset           : in  std_logic;
    in_RX_Serial    : in  std_logic;
    RX_full         : out std_logic;
    out_RX_Byte     : out std_logic_vector ( 7 downto 0 )
  );
end UART_RX;
 
 
architecture rtl of UART_RX is
 
    type SM_Main is ( s_Idle, s_RX_Start_Bit, s_RX_Data_Bits,
                     s_RX_Stop_Bit, s_Cleanup, s_Error );
    signal r_SM_Main            : SM_Main := s_Idle;
 
    signal r_RX_Data_Received   : std_logic := '0';
    signal r_RX_Data            : std_logic := '0';
                          
    signal r_Clk_Count          : integer range 0 to ( clks_per_bit - 1 ) := 0;
    signal r_Bit_Index          : integer range 7 downto 0 := 0;                       -- 8 Bits Total                           
    
begin

    -- Purpose: Double-register the incoming data.
    -- This allows it to be used in the UART RX Clock Domain.
    -- (It removes problems caused by metastabiliy)
    p_SAMPLE : process ( clk, reset )
    begin
        if ( rising_edge ( clk ) ) then
            if ( reset = '1') then
                r_RX_Data_Received <= '1';
                r_RX_Data          <= r_RX_Data_Received; 
            end if;
            else
                r_RX_Data_Received <= in_RX_Serial;
                r_RX_Data          <= r_RX_Data_Received; 
        end if; 
    end process p_SAMPLE;
 
    -- Purpose: Control RX state machine
    p_UART_RX : process ( clk, reset )
    begin
        if ( reset = '1' ) then
            RX_full     <= '0';
            out_RX_Byte <= "00000000";
            r_SM_Main   <= s_Idle;
            
        elsif ( rising_edge( clk ) and reset = '0' ) then
            case r_SM_Main is
                when s_Idle =>
                    out_RX_Byte <= "00000000";
                    RX_full     <= '0';
                    r_Clk_Count <= 0;
                    r_Bit_Index <= 7;

                    if r_RX_Data = '0' then       -- Start bit detected
                        r_SM_Main <= s_RX_Start_Bit;
                    else
                        r_SM_Main <= s_Idle;
                    end if;
 
                -- Check middle of start bit to make sure it's still low
                when s_RX_Start_Bit =>
                    if r_Clk_Count = ( clks_per_bit - 1 ) / 2 then
                        if r_RX_Data = '0' then
                            r_Clk_Count <= 0;  -- reset counter since we found the middle
                            r_SM_Main   <= s_RX_Data_Bits;
                        else
                            r_SM_Main   <= s_Idle;
                    end if;
                    else
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_SM_Main   <= s_RX_Start_Bit;
                    end if;
         
                -- Wait clks_per_bit-1 clock cycles to sample serial data
                when s_RX_Data_Bits =>
                    if r_Clk_Count < clks_per_bit-1 then
                        r_Clk_Count     <= r_Clk_Count + 1;
                        r_SM_Main       <= s_RX_Data_Bits;
                    else
                        r_Clk_Count                 <= 0;
                        out_RX_Byte ( r_Bit_Index ) <= r_RX_Data;
                 
                    -- Check if wr_en have sent out all bits
                    if r_Bit_Index > 0 then
                        r_Bit_Index     <= r_Bit_Index - 1;
                        r_SM_Main       <= s_RX_Data_Bits;
                    else
                        r_Bit_Index     <= 7;
                        r_SM_Main       <= s_RX_Stop_Bit;
                    end if;
                    end if;
           
                -- Receive Stop bit. Stop bit = 1
                when s_RX_Stop_Bit =>
                    -- Wait clks_per_bit-1 clock cycles for Stop bit to finish
                    if ( r_Clk_Count < clks_per_bit - 1 ) then
                        r_Clk_Count <= r_Clk_Count + 1;
                        r_SM_Main   <= s_RX_Stop_Bit;
                    elsif ( r_RX_data = '0' ) then
                        r_SM_Main   <= s_Error;
                    else
                        RX_full     <= '1';
                        r_Clk_Count <= 0;
                        r_SM_Main   <= s_Cleanup;
                    end if;
                
                -- Stay here 1 clock
                when s_Cleanup =>
                    r_SM_Main <= s_Idle;
                    RX_full   <= '0'; 
                    
                when s_Error   =>
                    r_SM_Main <= s_Idle;
                
                when others =>
                    r_SM_Main <= s_Idle;
            
            end case;
                
        end if;
        
    end process p_UART_RX;
    

   
end rtl;