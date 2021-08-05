library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;


entity UART_top is
  port (clock  : in  std_logic;
        reset  : in  std_logic;
        d_out  : out std_logic_vector(7 downto 0);
        --txStart  :  in std_logic;
        oTxOut : out std_logic;
        iRxIn  : in  std_logic
        );

end UART_top;

architecture Behavioral of UART_top is

  signal txStart  : std_logic              := '0';
  constant second : integer                := 200000000;
  signal seccntr  : integer range 0 to second := 0;
  signal d_in     : std_logic_vector(7 downto 0):="10100101";

  component uart is
    port (clk      : in  std_logic;
          rst      : in  std_logic;
          din      : in std_logic_vector(7 downto 0);
          tx_start : in  std_logic;
          tx_out   : out std_logic;
          tx_done  : out std_logic
          );
  end component;

  component uart_rcv is
    port (                              --start_clk : inout std_logic;
      clk     : in  std_logic;
      dout    : out std_logic_vector(7 downto 0);
      rx      : in  std_logic;
      rx_done : out std_logic
      );
  end component;
  attribute mark_debug : string;

  signal Dout   : std_logic_vector(7 downto 0); 
  signal txDone : std_logic := '0';
  signal rxDone : std_logic := '0';
  signal txOut  : std_logic := '0';
  signal rxIn   : std_logic := '0';

  attribute mark_debug of txOut  : signal is "true";
  attribute mark_debug of rxIn   : signal is "true";
  attribute mark_debug of txDone : signal is "true";
  attribute mark_debug of rxDone : signal is "true";
  attribute mark_debug of Dout   : signal is "true";
begin
  oTxOut <= txOut;
  rxIn   <= iRxIn;
  dout  <= Dout;
  uartt : process(clock)
  begin
    if (rising_edge(clock)) then
      if (seccntr = second - 1) then
        txStart <= not txStart;
      else
        seccntr <= seccntr +1;
      end if;
    end if;
  end process;

  TX : uart
    port map (
      clk      => clock,
      rst      => reset,
      tx_start => txStart,
      tx_out   => txOut,
      tx_done  => txDone
      );


  RX : uart_rcv
    port map (
      clk     => clock,
      dout    => d_out,
      rx      => rxIn,
      rx_done => rxDone
      );


                                                     
end Behavioral;

