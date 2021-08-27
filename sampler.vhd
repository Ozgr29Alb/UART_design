library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


entity sampler is
    Port ( data   : in STD_LOGIC;
           reset  : in STD_LOGIC;
           clk    : in STD_LOGIC;
           valid  : in std_logic;
           done   : in std_logic;
           o_done : out STD_LOGIC);
end sampler;

architecture Behavioral of sampler is
signal ones: integer:= 0;
signal zeros: integer:= 0;



begin
    sample: process(clk)
    begin
        if reset = '1' then
            zeros <= 0;
            ones  <= 0;    
        
        elsif (rising_edge(clk)) then
                 o_done <= '0';
        
               if valid ='1' then
                    if (done = '0') then
                        
                        if (data = '0') then
                            zeros <= zeros +1;
                        elsif (data = '1') then
                            ones <= ones +1;
                        end if;
                        
                    
                    elsif (done = '1') then 
                    
                        if (zeros < ones) then
                            o_done <= '1';
                        elsif (ones < zeros) then
                            o_done <= '0';
                        end if;
                        zeros <= 0;
                        ones  <= 0;
                        
                    end if; 
               elsif valid = '0' then
                   zeros <= 0;
                   ones <= 0;
               end if;
            
        end if;
    end process;

end Behavioral;
