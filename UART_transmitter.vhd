library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart is
    
    Generic ( clk_frq : integer := 100e6;
              baud: integer := 460800;--115200;
              stopbit: integer :=1
              --din: std_logic_vector := "10100101"
              );
              
    Port ( clk : in STD_LOGIC;
          -- rst : in STD_LOGIC;
           din: in std_logic_vector(7 downto 0);
           --uart_rxd : in STD_LOGIC;
           tx_start: in std_logic;
           tx_out : out STD_LOGIC;
           tx_done : out std_logic);


    
end uart;

architecture Behavioral of uart is
    constant c_bittimerlim 	: integer := clk_frq/(baud*10);
    constant c_stopbitlim 	: integer := (clk_frq/(baud*10))*stopbit;
    
    type states is (idle,start,data,stop);
    signal state: states := idle;
       
    signal bittimer : integer range 0 to c_stopbitlim := 0;
    signal bitcntr	: integer range 0 to 7 := 0;
    signal shreg	: std_logic_vector (7 downto 0) := (others => '0');
begin
    
P_MAIN : process (clk) begin
if (rising_edge(clk)) then

	case state is
	
		when idle =>
		
			tx_out			<= '1';
			tx_done	<= '0';
			bitcntr			<= 0;
			
			if (tx_start = '1') then
				state	<= start;
				tx_out	<= '0';    
				shreg	<= din;    
			end if;    
		    
		when start =>--process(clk,uart_rxd)
		--begin
			-- tx_o	<= '0';---- decide what the clock should be
			if (bittimer = c_bittimerlim-1) then--if (rising_edge(clk)) then
				state				<=data;--    -- check if the start bit is activated, if it is check every bit rate for 8 times
				tx_out				<= shreg(0);--    if (uart_rxd = 0) then
				shreg(7)			<= shreg(0);--        if (rising_edge(
				shreg(6 downto 0)	<= shreg(7 downto 1);--    -- start bit is not activated
				-- shreg(7 downto 1) 	<= shreg(6 downto 0);--    else
				-- shreg(0)			<= shreg(7);end Behavioral;
				bittimer			<= 0;
			else
				bittimer			<= bittimer + 1;
			end if;
			
		when data =>
		
			-- tx_o	<= shreg(0);
		
			if (bitcntr = 7) then
				if (bittimer = c_bittimerlim-1) then
					-- shreg(7 downto 1) 	<= shreg(6 downto 0);
					-- shreg(0)			<= shreg(7);
					bitcntr				<= 0;
					state				<= stop;
					tx_out				<= '1';
					bittimer			<= 0;
				else
					bittimer			<= bittimer + 1;					
				end if;			
			else
				if (bittimer = c_bittimerlim-1) then
					-- shreg(7 downto 1) 	<= shreg(6 downto 0);
					-- shreg(0)			<= shreg(7);
					shreg(7)			<= shreg(0);
					shreg(6 downto 0)	<= shreg(7 downto 1);					
					tx_out				<= shreg(0);
					bitcntr				<= bitcntr + 1;
					bittimer			<= 0;
				else
					bittimer			<= bittimer + 1;					
				end if;
			end if;
		
		when stop =>
		
			if (bittimer = c_stopbitlim-1) then
				state				<= idle;
				tx_done		<= '1';
				bittimer			<= 0;
			else
				bittimer			<= bittimer + 1;				
			end if;		
	
	end case;

end if;
end process;
end Behavioral;
