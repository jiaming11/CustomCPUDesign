LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- A basic 2-to-1 mux.

ENTITY custom_mux IS
	PORT (	A, B	: IN STD_LOGIC;
			s	: IN STD_LOGIC;	-- select (NOT A / B)
			F	: OUT STD_LOGIC);
END custom_mux;

ARCHITECTURE Structure OF custom_mux IS
BEGIN
		F <= (A AND NOT s) OR (B AND s);
END Structure;