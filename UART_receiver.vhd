library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_rcv is

  generic (clk_frq : integer := 100e6;
           baud    : integer := 460800; --115200;
           stopbit : integer := 1

           );

  port (--start_clk : inout std_logic;
        clk       : in    std_logic;
        dout      : out   std_logic_vector(7 downto 0);
        rx        : in    std_logic;
        rx_done   : out   std_logic
        );



end uart_rcv;

architecture Behavioral of uart_rcv is
  constant c_bittimerlim : integer := clk_frq/(baud*10);
  constant c_stopbitlim  : integer := (clk_frq/(baud*10))*stopbit;
  constant starttimerlim : integer := clk_frq/(baud*32);  -- ask what should be the freq that controls if the process is started
                                                          -- (bittime'dan 32 kat daha küçük bir zaman aralığı start state i gözlemlemek için yeterli olur
                                        -- dedim ama açıkcası bilmiyorum)

  type states is (idle, start, data, stop);
  signal state : states := idle;

  signal bittimer   : integer range 0 to c_stopbitlim  := 0;
  signal bitcntr    : integer range 0 to 7             := 0;
  signal shreg      : std_logic_vector (7 downto 0)    := (others => '0');
  signal r_begin    : std_logic                        := '0';
  signal starttimer : integer range 0 to starttimerlim := 0;
begin


  P_MAIN : process (clk)
  begin
    if (rising_edge(clk)) then
      case state is

        when idle =>

          rx_done <= '0';
          bitcntr <= 0;

          if (rx ='0') then
            --if (rx = '0') then
              state <= start;


            --end if;
         -- else
           -- starttimer <= starttimer +1;
          end if;
        when start =>
          if (bittimer = (c_bittimerlim*3 / 2)-1) then  -- start state'e ilk geçildiği andan 3/2 bittime sonrası ilk bitin(D0) ortasına denk gelir diye düşündüm)
            state    <= data;
            dout(0)  <= rx;
            bittimer <= 0;
            bitcntr <= 1;
          else
            bittimer <= bittimer + 1;
          end if;

        when data =>


          if (bitcntr = 7) then
            if (bittimer = c_bittimerlim-1) then
              dout(bitcntr) <= rx;
              bitcntr  <= 0;
              state    <= stop;
              bittimer <= 0;
            else
              bittimer <= bittimer + 1;
            end if;
          else
            if (bittimer = c_bittimerlim-1) then
              dout(bitcntr) <= rx;
              bitcntr       <= bitcntr + 1;
              bittimer      <= 0;
            else
              bittimer <= bittimer + 1;
            end if;
          end if;

        when stop =>

          if (bittimer = c_stopbitlim-1) then
            state    <= idle;
            rx_done  <= '1';
            bittimer <= 0;
          else
            bittimer <= bittimer + 1;
          end if;




      end case;
    end if;
  end process;
end Behavioral;
