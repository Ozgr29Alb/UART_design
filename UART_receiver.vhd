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
           baud    : integer := 115200*100;  --115200;
           stopbit : integer := 1

           );

  port (
        clk       : in    std_logic;
        dout      : out   std_logic_vector(7 downto 0) := "11111111";
        rx        : in    std_logic;
        rx_done   : out   std_logic;
        valid     : out   std_logic
        );



end uart_rcv;

architecture Behavioral of uart_rcv is
  constant c_bittimerlim : integer := clk_frq/(baud);
  constant c_stopbitlim  : integer :=(clk_frq/(baud))*stopbit;
  constant c_startbitlim : integer := c_bittimerlim*3/2;
  
  type states is (idle, start, data, stop);
  signal state : states := idle;

  signal bittimer   : integer range 0 to c_bittimerlim  := 0;
  signal bitcntr    : integer range 0 to 7             := 0;
  signal r_begin    : std_logic                        := '0';
  signal start_bittimer: integer range 0 to c_startbitlim;

--------------------- SAMPLER
signal  reset        : std_logic:= '0';
signal  s_valid        : std_logic:= '0';
signal  done         : std_logic:= '0';
signal o_done        : std_logic;

component sampler
port
 (-- Clock in ports
  -- Clock out ports
  data             : in    std_logic;
  reset            : in    std_logic;
  clk              : in    std_logic;
  valid            : in    std_logic;
  done             : in    std_logic;
  o_done           : out   std_logic
 );
end component;



begin
sample1: entity work.sampler         
port map( data    =>  rx,        
          reset   =>  reset,          
          clk     =>  clk,       
          valid   =>  s_valid,           
          done    =>  done,           
          o_done  =>  o_done    
);                           

  
  P_MAIN : process (clk)
  begin
    if (rising_edge(clk)) then
      case state is

        when idle =>
          dout    <=    "00000000";
          rx_done <= '0';
          bitcntr <= 0;
            
          if (rx ='0') then
            
              state <= start;
              
          end if;
        when start =>
          
          if (bittimer = c_bittimerlim-1) then  -- start state'e ilk geçildiği andan 3/2 bittime sonrası ilk bitin(D0) ortasına denk gelir diye düşündüm)
            state    <= data;
            
            
            bittimer <= 0;
            bitcntr <= 0;
          else
            bittimer <= bittimer + 1;
          end if;

        when data =>

--------------------- for D(7)
          if (bitcntr = 7) then
            if (bittimer = c_bittimerlim/3 - 2-1) then
                          s_valid <= '1';
                          bittimer <= bittimer +1;
            elsif (bittimer = c_bittimerlim/3-1) then
               done <= '0';
 
               bittimer <= bittimer+1;
            
    
            elsif (bittimer = c_bittimerlim*2/3-1) then
                done       <= '1';
                bittimer   <= bittimer + 1;
                
            elsif (bittimer = c_bittimerlim*2/3 +2-1) then
              
              dout(bitcntr) <= o_done;
              bittimer      <= bittimer + 1;
              s_valid      <= '0';
            
            elsif (bittimer = c_bittimerlim -1) then
              bitcntr       <= 0;
              state         <= stop;
              bittimer      <= 0;
              valid         <= '1';                  --check if the received data is valid
              
            else
              bittimer <= bittimer + 1;
            end if;
          
------------------------- for D(0 to 6)      
          
          else
            if (bittimer = c_bittimerlim/3 - 2-1) then
             s_valid <= '1';
             bittimer <= bittimer + 1;       
            elsif (bittimer = c_bittimerlim/3-1) then
               done <= '0';         
               bittimer <= bittimer+1;
               
            
           
            elsif (bittimer = c_bittimerlim*2/3-1) then
               done       <= '1';
               
               bittimer   <= bittimer + 1;
               
            
            
            elsif (bittimer = c_bittimerlim*2/3 + 2-1) then
              
              dout(bitcntr) <= o_done;
              bittimer      <= bittimer + 1;
              s_valid       <= '0';
            elsif (bittimer = c_bittimerlim -1) then  
              bitcntr       <= bitcntr + 1;
              bittimer      <= 0;
              
            else
              bittimer <= bittimer + 1;
            end if;
          end if;

        when stop =>
          
          if bittimer = 0 then
            valid <= '0';                          --valid is 1 for 1 clk cycle
            bittimer <= bittimer + 1;
          
          elsif (bittimer = c_stopbitlim-1) then
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
