library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity tb is
--  Port ( );
end tb;

architecture Behavioral of tb is

  component uart_top is
    --generic (
    --g_CLKS_PER_BIT : integer := 115   -- Needs to be set correctly
    --);
    port (clock  : in  std_logic;
          iRxIn  : in  std_logic;
          oTxOut : out std_logic
          );
  end component;



  -- Test Bench uses a 10 MHz Clock
  -- Want to interface to 115200 baud UART
  -- 10000000 / 115200 = 87 Clocks Per Bit.
  constant c_CLKS_PER_BIT : integer := 870;

  constant c_BIT_PERIOD : time := 8680 ns;

  signal r_CLOCK     : std_logic                    := '0';
  signal r_TX_DV     : std_logic                    := '0';
  signal r_TX_BYTE   : std_logic_vector(7 downto 0) := (others => '0');
  signal w_TX_SERIAL : std_logic;
  signal w_TX_DONE   : std_logic;
  signal w_RX_DV     : std_logic;
  signal w_RX_BYTE   : std_logic_vector(7 downto 0);
  signal r_RX_SERIAL : std_logic                    := '1';

  signal i_serial  : std_logic;
  signal data_out  : std_logic_vector(7 downto 0);
  -- Low-level byte-write
  signal i_data_in : std_logic_vector(7 downto 0) := "10100101";
  signal o_serial  : std_logic;




begin
  i_serial <= o_serial;
  -- Instantiate UART transmitter
  UART : uart_top
    --generic map (
    --g_CLKS_PER_BIT => c_CLKS_PER_BIT
    --)
    port map (
      clock  => r_CLOCK,
      iRxIn  => r_RX_SERIAL,
      oTxOut => w_TX_SERIAL
      );





  -- Send a command to the UART
  uart_write : process
  begin

    -- Send Start Bit
    o_serial <= '0';
    wait for c_BIT_PERIOD;

    -- Send Data Byte
    for ii in 0 to 7 loop
      o_serial <= i_data_in(ii);
      wait for c_BIT_PERIOD;
    end loop;  -- ii

    -- Send Stop Bit
    o_serial <= '1';
    wait for c_BIT_PERIOD;
  end process;



  data_read : process
  begin
    if(i_serial = '0') then
      wait for c_BIT_PERIOD;
    end if;

    for ii in 0 to 7 loop
      data_out(ii) <= i_serial;
      wait for c_BIT_PERIOD;
    end loop;  -- ii


    if(i_serial = '1') then
      wait for c_BIT_PERIOD;
    end if;

  end process;


end Behavioral;
