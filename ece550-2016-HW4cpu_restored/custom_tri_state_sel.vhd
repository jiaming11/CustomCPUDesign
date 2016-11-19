LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY altera;
USE altera.altera_primitives_components.all;

-- Tri-State buffers select between two n-bit inputs

ENTITY custom_tri_state_sel IS
	GENERIC ( n : integer := 32 );
	PORT (	Q	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
			readA, readB : IN STD_LOGIC;
			Da, Db : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0) );
END custom_tri_state_sel;

ARCHITECTURE Structure OF custom_tri_state_sel IS
	COMPONENT TRI
    PORT (
        a_in  :  in    std_logic;
        oe    :  in    std_logic;
        a_out :  out   std_logic);
	END COMPONENT;
BEGIN
	bits : FOR i IN 0 TO n-1 GENERATE
		ta: TRI PORT MAP (a_in=>Da(i), oe=>readA, a_out=>Q(i));
		tb: TRI PORT MAP (a_in=>Db(i), oe=>readB, a_out=>Q(i));
	END GENERATE bits;
END;