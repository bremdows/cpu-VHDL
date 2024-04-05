library ieee;
use ieee.std_logic_1164.all;

entity registerPS4bits is
port(
	clk : in std_logic;
	datain : in std_logic_vector(3 downto 0);
	control, reset : in std_logic;
	dataout : out std_logic
);
end entity;

architecture arch of registerPS4bits is
component ffd is
port(
	clk: in std_logic;
	d: in std_logic;
	q: out std_logic
);
end component;

component andgate is
port(
	data, control : in std_logic;
	salida : out std_logic
);
end component;

component sop is 
port(
	ffq, control, data : in std_logic;
	salida : out std_logic
);
end component;

-- SEÑALES INTERMEDIAS
signal salidas : std_logic_vector(3 downto 0);
signal ffout : std_logic_vector(2 downto 0);

begin
	G1: andgate port map (datain(0), control, salidas(0));
	F1: ffd port map(clk, salidas(0), ffout(0));
	
	S1: sop port map(ffout(0), control, datain(1), salidas(1));
	F2: ffd port map(clk, salidas(1), ffout(1));
	
	S2: sop port map(ffout(1), control, datain(2), salidas(2));
	F3: ffd port map(clk, salidas(2), ffout(2));
	
	S3: sop port map(ffout(2), control, datain(3), salidas(3));
	F4: ffd port map(clk, salidas(3), dataout);
	
end architecture;





