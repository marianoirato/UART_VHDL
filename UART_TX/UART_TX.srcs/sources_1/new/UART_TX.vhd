----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/19/2023 10:18:10 PM
-- Design Name: 
-- Module Name: UART_TX - Behavioral
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

entity UART_TX is
  generic (
        CLK_PER_BIT  : integer := 7500        -- 72 MHz / 9600 Baudios
    );
  port (
        i_CLK       : in  std_logic;
        i_TX_RTS    : in  std_logic;            -- Señal de Validación de Transmisión (Ready To Send)
        i_TX_DATA   : in  std_logic_vector(7 downto 0);  -- Byte a transmitir
        o_TX_DS     : out std_logic;            -- Indicador de actividad de transmisión (Data Sending)
        o_TX_SERIAL : out std_logic;            -- Salida serial de transmisión
        o_TX_DONE   : out std_logic             -- Indicador de finalización de transmisión
    );
end UART_TX;


architecture RTL of UART_TX is

    -- Definición de la máquina de estados
    type StateMachine_MAIN is (     s_IDLE,         -- 1. Estado de Reposo: espera al RTS
                                    s_START_BIT,    -- 2. Envio de Start Bit
                                    s_DATA_SEND,    -- 3. Envio de Data
                                    s_STOP_BIT,     -- 4. Envio de Stop Bit
                                    s_CLEAN);       -- 5. Reinicia las banderas y vuelve al s_IDLE

        
    signal r_SM_Main : StateMachine_MAIN := s_IDLE;

    -- Contadores e índices para el control del tiempo y bits
    signal COUNT_CLK : integer range 0 to CLK_PER_BIT - 1 := 0;         -- contador de clock s/bit_rate
    signal INDEX_BIT : integer range 0 to 7 := 0;                       -- indice de 8 bits en total

    -- Almacenamiento temporal del byte de datos a transmitir
    signal r_DATA   : std_logic_vector(7 downto 0) := (others => '0');  -- Buffer de 8 Bits (paralelo)

    -- Indicador de finalización de transmisión
    signal r_DONE   : std_logic := '0';

begin

  -- Proceso principal de la UART
  p_UART_TX : process (i_CLK) 
  begin
    if rising_edge(i_CLK) then

      case r_SM_Main is
        -------------------------------------------------------------------------------------

        -- 1. Estado de Reposo: espera al RTS
        when s_IDLE => 
            -- Configuración en estado de reposo (IDLE)
            o_TX_DS <= '0';             -- Data Sending = OFF
            o_TX_SERIAL <= '1';         -- Línea en alto para estado de reposo
            r_DONE   <= '0';            -- TX_Done = NOT
            COUNT_CLK <= 0;             -- Clock Counter = OFF
            INDEX_BIT <= 0;             -- Indice de bit = 0

            if i_TX_RTS= '1' then           -- Si llega la señal RTS
                r_DATA <= i_TX_DATA;        -- Llena el Buffer de 8 Bits
                r_SM_Main <= s_START_BIT;   -- Next-State
            
            else                            -- Sino
                r_SM_Main <= s_IDLE;        -- Permanecer en estado de reposo
            
            end if;
        -------------------------------------------------------------------------------------

        -- 2. Envio de Start Bit
        when s_START_BIT =>
            -- Envio del bit de inicio (Start Bit = 0)
            o_TX_DS <= '1';             -- Data Sending = ON
            o_TX_SERIAL <= '0';         -- Start-Bit: 1 -> 0

            -- Se transmite el Start-Bit durante el CONT_PER_BIT (s/Bit-Rate)
            if COUNT_CLK < CLK_PER_BIT -1 then
                COUNT_CLK <= COUNT_CLK + 1;     --  Incrementa el Counter
                r_SM_Main   <= s_START_BIT;     --  Mantiene el estado

            else
                COUNT_CLK <= 0;                 -- Reinicia el Counter
                r_SM_Main   <= s_DATA_SEND;     -- Next-State

            end if;
        -------------------------------------------------------------------------------------

        -- 3. Envio de Data
        when s_DATA_SEND =>
          -- Transmición de los bits de datos
          o_TX_SERIAL <= r_DATA(INDEX_BIT);     -- Envia a la Output el bit n°[INDEX_BIT] del Buffer

          if COUNT_CLK < CLK_PER_BIT -1 then    -- Envia el mismo bit segun CLK_PER_BIT
            COUNT_CLK <= COUNT_CLK + 1;
            r_SM_Main   <= s_DATA_SEND;         -- Mantiene el estado

          else                                  -- Si completo el periodo CLK_PER_BIT
            COUNT_CLK <= 0;                     -- Reinica el Counter

            -- Verificar si se han enviado todos los bits
            if INDEX_BIT < 7 then               -- Si NO se enviaron todos los bits
              INDEX_BIT <= INDEX_BIT + 1;       -- Incrementa el indice (INDEX_BIT)
              r_SM_Main   <= s_DATA_SEND;       -- Mantiene el estado
            
            else                                -- Si se enviaron todos los bits
              INDEX_BIT <= 0;                   -- Se reinicia el indice (INDEX_BIT)
              r_SM_Main   <= s_STOP_BIT;        -- Next-State
            end if;

          end if;
        -------------------------------------------------------------------------------------
        
        -- 4. Envio de Stop Bit
        when s_STOP_BIT =>
          -- Enviar el bit de parada (Stop Bit = 1)
          o_TX_SERIAL <= '1';                   -- Stop-Bit: 0/1 -> 1

          -- Se transmite el Stop-Bit durante el CONT_PER_BIT (s/Bit-Rate)
          if COUNT_CLK < CLK_PER_BIT -1 then    -- if COUNT_CLK < CLK_PER_BIT + CLK_PER_BIT/2 -1 then
            COUNT_CLK <= COUNT_CLK + 1;         -- Incrementa el Counter
            r_SM_Main   <= s_STOP_BIT;          -- Mantiene el estado

          else
            r_DONE   <= '1';                    -- Transmition Tx_Done = YES
            COUNT_CLK <= 0;                     -- Reinicia el Counter
            r_SM_Main   <= s_CLEAN;             -- Next-State
          end if;
        -------------------------------------------------------------------------------------
        
        -- 5. Reinicia las banderas y vuelve al s_IDLE
        when s_CLEAN =>
          -- Permanecer aquí durante 1 ciclo de reloj y luego regresar al estado de reposo
          o_TX_DS <= '0';                       -- Data Sending = OFF
          r_DONE   <= '1';                      -- Tx_Done = YES
          r_SM_Main   <= s_IDLE;                -- Vuelve al 1er State
        
        -------------------------------------------------------------------------------------
        when others =>                          -- Para cualquier otro Case
          r_SM_Main <= s_IDLE;                  -- Vuelve al 1er State
        -------------------------------------------------------------------------------------

      end case;
    end if;
  end process p_UART_TX;

  -- Salida de la señal de finalización de transmisión
  o_TX_DONE <= r_DONE;

end RTL;
