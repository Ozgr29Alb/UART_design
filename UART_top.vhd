entity UART_top is
    Port (clock    :  in STD_LOGIC;
          reset    :  in STD_LOGIC;
          --txStart  :  in std_logic;  
          txOut    :  out STD_LOGIC; 
          txDone   :  out std_logic;
          --
          --startclock: inout std_logic;
          d_out     : out std_logic_vector(7 downto 0);
          r_x        : in std_logic;
          r_x_done   : out std_logic);
end UART_top;

architecture Behavioral of UART_top is

signal txStart: std_logic := '0';
constant sec: integer := 200000000;
signal seccntr: integer range 0 to sec:= 0;



component uart is
    Port ( clk     : in STD_LOGIC;
           rst     : in STD_LOGIC;
           --din: in std_logic_vector(7 downto 0);
           --uart_rxd : in STD_LOGIC;
           tx_start: in std_logic;
           tx_out  : out STD_LOGIC;
           tx_done : out std_logic);
end component;

component uart_rcv is
    Port ( --start_clk : inout std_logic;
            clk      : in STD_LOGIC;
           --rst : in STD_LOGIC;
           
           dout:  out std_logic_vector(7 downto 0);
           --uart_rxd : in STD_LOGIC;
           --rx_start: in std_logic;
           rx : in std_logic;
           --rx_out : out STD_LOGIC;
           rx_done : out std_logic);
end component;
begin
    uartt: process(clock)
    begin

if (rising_edge(clock)) then
    if (seccntr = sec - 1) then
        txStart <= not txStart;



    else 
    seccntr <= seccntr +1;

end if;
end if;
end process;

TX: uart port map (  clk     => clock,                       
                     rst     => reset,                       
                     tx_start=> txStart,                     
                     tx_out  => txOut,                       
                     tx_done => txDone);                     
                                                                                                                       
                                                             
RX: uart_rcv port map ( clk       => clock,                  
                        dout      => d_out,                  
                        rx        => r_x,                    
                        rx_done    => r_x_done);             
                                                             
                                                             
                                                                                            
end Behavioral;
