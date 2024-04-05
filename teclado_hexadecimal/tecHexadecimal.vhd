----------------------------------------------------------------------------------
--
--
--							LIBRERÍA PARA TECLADO MATRICIAL
--
-- Descripción: Con ésta librería puedes controlar un teclado matricial 4x4
--
-- Características:
--  
-- La librería se encarga de hacer el control (incluyendo el efecto rebote de las teclas)y devuelve 
-- un vector de 4 bits indicando la tecla que se presionó.
--	Se requieren de 8 pines para controlar el teclado matricial.
-- 
-- CONECTAR EL TECLADO COMO SE MUESTRA EN LA DOCUMENTACIÓN
--
--    TABLA DE FUNCIONAMIENTO
--	 ___________________________
-- | 	  TECLA 		|				 |
-- |	PRESIONADA  | TECLA_PRES |
--	|---------------------------|		 
--	|		 0			|	  x"0"	 |
--	|		 1			|	  x"1"	 |
--	|		 2			|	  x"2"	 |
--	|		 3			|	  x"3"	 |
--	|		 4			|	  x"4"	 |
--	|		 5			|	  x"5"	 |
--	|		 6			|	  x"6"	 |
--	|		 7			|	  x"7"	 |
--	|		 8			|	  x"8"	 |
--	|		 9			|	  x"9"	 |
--	|		 A			|	  x"A"	 |
--	|		 B			|	  x"B"	 |
--	|		 C			|	  x"C"	 |
--	|		 D			|	  x"D"	 |
--	|		 *			|	  x"E"	 |
--	|		 #			|	  x"F"	 |
--  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tecHexadecimal is


--El generic es útil cuando LIB_TEC_MATRICIAL_4x4_INTESC_RevA es parte de un TOP. Si no es parte de un TOP
--entonces se deben poner la frecuencia del FPGA como valores contantes en el generic
GENERIC(
			FREQ_CLK : INTEGER := 1000         --FRECUENCIA DE LA TARJETA
);


PORT(
	CLK 		  : IN  STD_LOGIC; 						  --RELOJ FPGA
	COLUMNAS   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0); --PUERTO CONECTADO A LAS COLUMNAS DEL TECLADO
	FILAS 	  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); --PUERTO CONECTADO A LA FILAS DEL TECLADO
	BOTON_PRES : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); --PUERTO QUE INDICA LA TECLA QUE SE PRESIONÓ
	IND		  : OUT STD_LOGIC;						  --BANDERA QUE INDICA CUANDO SE PRESIONÓ UNA TECLA (SÓLO DURA UN CICLO DE RELOJ)
	SEVENDISPLAY : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
);

end entity;

architecture Behavioral of tecHexadecimal is

CONSTANT DELAY_1MS  : INTEGER := (FREQ_CLK/1000)-1;
CONSTANT DELAY_10MS : INTEGER := (FREQ_CLK/100)-1;

SIGNAL CONTA_1MS 	: INTEGER RANGE 0 TO DELAY_1MS := 0;
SIGNAL BANDERA 	: STD_LOGIC := '0';
SIGNAL CONTA_10MS : INTEGER RANGE 0 TO DELAY_10MS := 0;
SIGNAL BANDERA2 	: STD_LOGIC := '0';

SIGNAL REG_B1  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS=>'0');
SIGNAL REG_B2  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS=>'0');
SIGNAL REG_B3  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS=>'0');
SIGNAL REG_B4  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS=>'0');
SIGNAL REG_B5  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS=>'0');
SIGNAL REG_B6  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS=>'0');
SIGNAL REG_B7  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS=>'0');
SIGNAL REG_B8  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS=>'0');
SIGNAL REG_B9  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS=>'0');
SIGNAL REG_BA  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS=>'0');
SIGNAL REG_BB  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS=>'0');
SIGNAL REG_BC  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS=>'0');
SIGNAL REG_BD  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS=>'0');
SIGNAL REG_B0  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS=>'0');
SIGNAL REG_BAS : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS=>'0');
SIGNAL REG_BGA : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS=>'0');

SIGNAL FILA_REG_S : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS=>'0');
SIGNAL FILA : INTEGER RANGE 0 TO 3 := 0;

SIGNAL IND_S : STD_LOGIC := '0';
SIGNAL EDO : INTEGER RANGE 0 TO 1 := 0;

-- 7 SEGMENTS DISPLAY
SIGNAL segmentsout : STD_LOGIC_VECTOR(3 downto 0) := (OTHERS=>'0');

begin

FILAS <= FILA_REG_S;

--RETARDO 1 MS--
PROCESS(CLK)
BEGIN
IF RISING_EDGE(CLK) THEN
	CONTA_1MS <= CONTA_1MS+1;
	BANDERA <= '0';
	IF CONTA_1MS = DELAY_1MS THEN
		CONTA_1MS <= 0;
		BANDERA <= '1';
	END IF;
END IF;
END PROCESS;
----------------

--RETARDO 10 MS--
PROCESS(CLK)
BEGIN
IF RISING_EDGE(CLK) THEN
	CONTA_10MS <= CONTA_10MS+1;
	BANDERA2 <= '0';
	IF CONTA_10MS = DELAY_10MS THEN
		CONTA_10MS <= 0;
		BANDERA2 <= '1';
	END IF;
END IF;
END PROCESS;
----------------

--PROCESO QUE ACTIVA CADA FILA CADA 10ms--
PROCESS(CLK, BANDERA2)
BEGIN
	IF RISING_EDGE(CLK) AND BANDERA2 = '1' THEN
		FILA <= FILA+1;
		IF FILA = 3 THEN
			FILA <= 0;
		END IF;
	END IF;
END PROCESS;

WITH FILA SELECT
	FILA_REG_S <= "1000" WHEN 0,
					  "0100" WHEN 1,
					  "0010" WHEN 2,
					  "0001" WHEN OTHERS;
-------------------------------				

----------PROCESO QUE EVITA EL EFECTO REBOTE DE LAS TECLAS----------------
--LLENA LOS REGISTROS CON '1' DEPENDIENDO EL BOTÓN QUE SE HAYA PRESIONADO--
PROCESS(CLK,BANDERA)
BEGIN
	IF RISING_EDGE(CLK) AND BANDERA = '1' THEN
		IF FILA_REG_S = "1000" THEN --PRIMERA FILA DE BOTONES
			REG_B1 <= REG_B1(6 DOWNTO 0)&COLUMNAS(3);
			REG_B2 <= REG_B2(6 DOWNTO 0)&COLUMNAS(2);
			REG_B3 <= REG_B3(6 DOWNTO 0)&COLUMNAS(1);
			REG_BA <= REG_BA(6 DOWNTO 0)&COLUMNAS(0);
		ELSIF FILA_REG_S = "0100" THEN --SEGUNDA FILA DE BOTONES
			REG_B4 <= REG_B4(6 DOWNTO 0)&COLUMNAS(3);
			REG_B5 <= REG_B5(6 DOWNTO 0)&COLUMNAS(2);
			REG_B6 <= REG_B6(6 DOWNTO 0)&COLUMNAS(1);
			REG_BB <= REG_BB(6 DOWNTO 0)&COLUMNAS(0);
		ELSIF FILA_REG_S = "0010" THEN --TERCERA FILA DE BOTONES
			REG_B7 <= REG_B7(6 DOWNTO 0)&COLUMNAS(3);
			REG_B8 <= REG_B8(6 DOWNTO 0)&COLUMNAS(2);
			REG_B9 <= REG_B9(6 DOWNTO 0)&COLUMNAS(1);
			REG_BC <= REG_BC(6 DOWNTO 0)&COLUMNAS(0);
		ELSIF FILA_REG_S = "0001" THEN --CUARTA FILA DE BOTONES
			REG_BAS <= REG_BAS(6 DOWNTO 0)&COLUMNAS(3);
			REG_B0  <= REG_B0(6 DOWNTO 0)&COLUMNAS(2);
			REG_BGA <= REG_BGA(6 DOWNTO 0)&COLUMNAS(1);
			REG_BD  <= REG_BD(6 DOWNTO 0)&COLUMNAS(0);
		END IF;
	END IF;
END PROCESS;
----------------------------------------------------------------------------

--MANDA EL DATO A LA SALIDA--
PROCESS(CLK)
BEGIN
	IF RISING_EDGE(CLK) THEN
		IF 	REG_B0  	= "11111111" THEN segmentsout <= X"0"; IND_S <= '1'; BOTON_PRES <= X"0";
		ELSIF REG_B1 	= "11111111" THEN segmentsout <= X"1"; IND_S <= '1'; BOTON_PRES <= X"1";
		ELSIF	REG_B2 	= "11111111" THEN segmentsout <= X"2"; IND_S <= '1'; BOTON_PRES <= X"2";
		ELSIF	REG_B3 	= "11111111" THEN segmentsout <= X"3"; IND_S <= '1'; BOTON_PRES <= X"3";
		ELSIF	REG_B4 	= "11111111" THEN segmentsout <= X"4"; IND_S <= '1'; BOTON_PRES <= X"4";
		ELSIF	REG_B5 	= "11111111" THEN segmentsout <= X"5"; IND_S <= '1'; BOTON_PRES <= X"5";
		ELSIF	REG_B6 	= "11111111" THEN segmentsout <= X"6"; IND_S <= '1'; BOTON_PRES <= X"6";
		ELSIF	REG_B7 	= "11111111" THEN segmentsout <= X"7"; IND_S <= '1'; BOTON_PRES <= X"7";
		ELSIF	REG_B8 	= "11111111" THEN segmentsout <= X"8"; IND_S <= '1'; BOTON_PRES <= X"8";
		ELSIF	REG_B9 	= "11111111" THEN segmentsout <= X"9"; IND_S <= '1'; BOTON_PRES <= X"9";
		ELSIF	REG_BA 	= "11111111" THEN segmentsout <= X"A"; IND_S <= '1'; BOTON_PRES <= X"A";
		ELSIF	REG_BB 	= "11111111" THEN segmentsout <= X"B"; IND_S <= '1'; BOTON_PRES <= X"B";
		ELSIF	REG_BC 	= "11111111" THEN segmentsout <= X"C"; IND_S <= '1'; BOTON_PRES <= X"C";
		ELSIF	REG_BD  	= "11111111" THEN segmentsout <= X"D"; IND_S <= '1'; BOTON_PRES <= X"D";
		ELSIF	REG_BAS 	= "11111111" THEN segmentsout <= X"E"; IND_S <= '1'; BOTON_PRES <= X"E";
		ELSIF	REG_BGA 	= "11111111" THEN segmentsout <= X"F"; IND_S <= '1'; BOTON_PRES <= X"F";
		ELSE IND_S <= '0';
		END IF;
	END IF;
END PROCESS;
-----------------------------
--MÁQUINA DE ESTADOS PARA LA BANDERA--
PROCESS(CLK)
BEGIN
	IF RISING_EDGE(CLK) THEN
		IF EDO = 0 THEN
			IF IND_S = '1' THEN
				IND <= '1';
				EDO <= 1;
			ELSE
				EDO <= 0;
				IND <= '0';
			END IF;
		ELSE
			IF IND_S = '1' THEN
				EDO <= 1;
				IND <= '0';
			ELSE
				EDO <= 0;
			END IF;
		END IF;
	END IF;
END PROCESS;
-------------------------------------

process (segmentsout)
begin
	case segmentsout is
		when "0000" => 
		SEVENDISPLAY <= "0000001"; -- 0
		when "0001" => 
		SEVENDISPLAY <= "1001111"; -- 1
		
		when "0010" => 
		SEVENDISPLAY <= "0010010"; -- 2
		
		when "0011" => 
		SEVENDISPLAY <= "0000110"; -- 3
		
		when "0100" => 
		SEVENDISPLAY <= "1001100"; -- 4
		
		when "0101" => 
		SEVENDISPLAY <= "0100100"; -- 5
		
		when "0110" => 
		SEVENDISPLAY <= "0100000"; -- 6
		
		when "0111" => 
		SEVENDISPLAY <= "0001111"; -- 7
		
		when "1000" => 
		SEVENDISPLAY <= "0000000"; -- 8
		
		when "1001" => 
		SEVENDISPLAY <= "0001100"; -- 9
		
		when "1010" => 
		SEVENDISPLAY <= "0001000"; -- A
		
		when "1011" => 
		SEVENDISPLAY <= "1100000"; -- B
		
		when "1100" => 
		SEVENDISPLAY <= "0110001"; -- C
		
		when "1101" => 
		SEVENDISPLAY <= "1000010"; -- D
		
		when "1110" => 
		SEVENDISPLAY <= "0110000"; -- E
		
		when "1111" => 
		SEVENDISPLAY <= "0111000"; -- F
		
		when others => 
		SEVENDISPLAY <= "1111111";
		
	end case;
end process;
end architecture;

