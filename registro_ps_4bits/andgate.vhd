library ieee;
use ieee.std_logic_1164.all;

entity andgate is
port(
	data, control : in std_logic; -- ENTRADAS
	salida : out std_logic
);
end entity;

architecture arch of andgate is
begin
	salida <= data and not control;
end architecture;