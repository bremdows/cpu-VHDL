library ieee; 
use ieee.std_logic_1164.all; 
use IEEE.STD_LOGIC_unsigned.all;
use IEEE.numeric_std.all;

entity alu is 
	port ( 
			clk : in std_logic:='0'; 
			A, B : in std_logic_vector (3 downto 0); 
			Selector : in std_logic_vector (1 downto 0); 
			Resultado1 : inout std_logic_vector (7 downto 0)
			); 
end alu; 
architecture arq of alu is 
	signal Resultado :  std_logic_vector (7 downto 0) := "00000000";
begin 
process(clk, Selector) 
begin 
	if (clk'event and clk = '1') then 
		case Selector is 
			when "00" => 
--				Resultado(4 downto 0) <= std_logic_vector('0'& unsigned(A) + unsigned(B)); 
				Resultado <= "00000000";
			when "01" => 
--				Resultado(4 downto 0) <= std_logic_vector( to_unsigned( to_integer(unsigned(A)) - to_integer(unsigned(B)) ,5));
				Resultado <= "00000001";
			when "10" => 
				Resultado <= "00000010";
--				Resultado(7 downto 0) <= std_logic_vector(to_unsigned(to_integer(unsigned(A)) * to_integer(unsigned(B)),8)); 
			when "11" => 
				Resultado <= "00000011";
--				Resultado(3 downto 0) <= std_logic_vector(to_unsigned(to_integer(unsigned(A)) / to_integer(unsigned(B)),4));				
			when others => 
			null ; 
		end case; 
	end if; 
end process;
Resultado1 <= Resultado; 
end arq; 