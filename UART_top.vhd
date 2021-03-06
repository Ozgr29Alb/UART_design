library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;


entity UART_top is
  port (clock  : in  std_logic;
        --reset  : in  std_logic;
        --d_out  : out std_logic_vector(7 downto 0);
        --txStart  :  in std_logic;
        oTxOut : out std_logic;
        iRxIn  : in  std_logic
        --forDebug: out std_logic_vector(7 downto 0)
        );

end UART_top;

architecture Behavioral of UART_top is


 

  signal txStart  : std_logic                    := '0';
  constant second : integer                      := 50000000;
  signal seccntr  : integer range 0 to second    := 0;
  signal d_in     : std_logic_vector(7 downto 0) := "10000001";

-- PHASE CLOCK SIGNALS
signal clk_30 : std_logic;
signal clk_60 : std_logic;
signal clkHigh : std_logic; 



component clk_wiz_0
port
 (-- Clock in ports
  -- Clock out ports
  clk_30d          : out    std_logic;
  clk_60d          : out    std_logic;
  clk_high          : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;



  component uart is
    port (clk      : in  std_logic;
          --rst      : in  std_logic;
          din      : in  std_logic_vector(7 downto 0);
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
      rx_done : out std_logic;
      valid   : out std_logic
      );
  end component;
  -------------------------METASTABILITY ISSUES
  signal rxIn1         : std_logic                    := '0';
  signal rxIn2         : std_logic                    := '0';
  signal rxIn3         : std_logic                    := '0';
  signal rxIn4         : std_logic                    := '0';
 ------------------------------------------------------------
 
  attribute mark_debug : string;

  --SIGNALS---------------------------------------------------------
  signal receivedData : std_logic_vector(7 downto 0);
  signal dataSend     : std_logic_vector(7 downto 0) := "10000001";
  signal txDone       : std_logic                    := '0';
  signal rxDone       : std_logic                    := '0';
  signal txOut        : std_logic                    := '0';
  signal rxIn         : std_logic                    := '0';
  signal o_valid      : std_logic                    := '0';

  attribute mark_debug of txOut        : signal is "true";
  attribute mark_debug of rxIn         : signal is "true";
  attribute mark_debug of txDone       : signal is "true";
  attribute mark_debug of rxDone       : signal is "true";
  --attribute mark_debug of Dout         : signal is "true";
  attribute mark_debug of receivedData : signal is "true";
  attribute mark_debug of dataSend     : signal is "true";
attribute mark_debug of clk_30         : signal is "true"; 
attribute mark_debug of clk_60         : signal is "true"; 
  attribute mark_debug of o_valid      : signal is "true";
--  
  attribute mark_debug of rxIn4        : signal is "true";
--
  attribute KEEP : string;
  --attribute KEEP of Dout: signal is "True";
  attribute KEEP of receivedData: signal is "True";
  attribute KEEP of dataSend: signal is "True";
begin
  oTxOut     <= txOut;
  rxIn       <= iRxIn;       -------------------------------------????????????????????????????????????

--  synchronizer: process(clk_60)                   -----------------????????????????????????????????
--    begin
--    
--    rxIn       <= iRxIn;
--    rxIn1      <= rxIn;
--    rxIn2      <= rxIn1;
--    rxIn3      <= rxIn2;
--    rxIn4      <= rxIn3;
--  end process;
    
  
  wizard : clk_wiz_0
     port map ( 
    -- Clock out ports  
     clk_30d => clk_30,
     clk_60d => clk_60,
     clk_high => clkHigh,
     -- Clock in ports
     clk_in1 => clock
   );
  
  
    
  --new_data: process(clk_30)
  --begin
  --if (rising_edge(clk_30)) then
  --    if (txDone = '1') then
  --        dataSend <= dataSend(dataSend'high-3 downto 0) & dataSend(dataSend'high downto 5);
  --    end if;
  --end if;
  --end process;
    
  new_datas: process(clk_30)
  begin
  if (rising_edge(clk_30)) then
      if (txDone = '1') then
          if (dataSend <= "10000001") then
              dataSend <= "10110101";
         
          elsif (dataSend <= "10110101") then
              dataSend <= "10000001";
          end if;
      end if;
  end if;
  end process;
    
    
  starter : process(clk_30)
  begin
    if (rising_edge(clk_30)) then
      if (seccntr = second - 1) then
        txStart <= not txStart;
        seccntr <= 0;
      else
        seccntr <= seccntr +1;
      end if;
    end if;
  end process;

  uart_1 : entity work.uart
    port map (
      clk      => clk_30,

      din      => dataSend,
      tx_start => txStart,
      tx_out   => txOut,
      tx_done  => txDone
      );

  uart_rcv_1 : entity work.uart_rcv
    port map (

      clk       => clk_60,
      dout      => receivedData,
      rx        => rxIn,--4,
      rx_done   => rxDone,
      valid     => o_valid
      );


end Behavioral;

