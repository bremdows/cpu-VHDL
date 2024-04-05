library ieee;
use ieee.std_logic_1164.all;

entity sop is
port(
	ffq, control, data : in std_logic; -- ENTRADAS
	salida : out std_logic
);
end entity;

architecture arch of sop is
begin
	salida <= ((ffq and control) or (not control and data));	
end architecture;