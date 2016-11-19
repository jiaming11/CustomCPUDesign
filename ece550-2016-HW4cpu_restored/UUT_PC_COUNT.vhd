LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- The core of the Duke 550 processor
-- Author: <INSERT YOUR NAME HERE!!!!>

ENTITY UUT_PC_COUNT IS
    PORT (	clock	: IN STD_LOGIC; 
				reset	: IN STD_LOGIC; 
				PC		: OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
				);
END UUT_PC_COUNT;

ARCHITECTURE Structure OF UUT_PC_COUNT IS

	COMPONENT reg IS
		GENERIC ( n : integer := 32 );
		PORT (	D	: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
				clock, clear, enable	: IN STD_LOGIC;
				Q	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0) );
	END COMPONENT;
	
	COMPONENT adder_cs IS
		GENERIC(n: integer:=8);
		PORT (	
			A, B : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
			cin  : IN STD_LOGIC;
			cout : OUT STD_LOGIC;
			sum  : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
			signed_overflow : OUT STD_LOGIC	);
	END COMPONENT;
	
		-- TODO: Also likely need a bunch of signals...
	SIGNAL CUR_PC	:	STD_LOGIC_VECTOR(11 DOWNTO 0)	:= "000000000000";
	SIGNAL PC_PLUS_ONE	:	STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL PC_ADDER_COUT	:	STD_LOGIC;
	SIGNAL PC_ADDER_OVERFLOW	:	STD_LOGIC;
	SIGNAL CUR_INSTR	:	STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	--FIELDS FOR INSTRUCTION PARSE
	SIGNAL OPCODE	:	STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL Rd_INSTR	:	STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL Rs_INSTR	:	STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL Rt_INSTR	:	STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL IMM_INSTR	:	STD_LOGIC_VECTOR(16 DOWNTO 0);
	SIGNAL TARGET_INSTR	:	STD_LOGIC_VECTOR(26 DOWNTO 0);

BEGIN
	-- TODO: Connect stuff up to make a processor
	PC_REG	:	reg
		GENERIC MAP	( n => 12)
		PORT MAP		(	D	=>	PC_PLUS_ONE, --TODO: CONNECT TO PC+1 MARK: THIS NEED TO TAKE INTO ACCOUNT OTHER PC INCREMENTATIONS
						clock		=>	clock, 
						clear		=>	reset, 
						enable	=> '1',
						Q			=>	CUR_PC );
						
	PC_ADDER		:	adder_cs 
		GENERIC MAP (n	=> 12)
		PORT MAP(	
			A	=>	CUR_PC, 
			B 	=> "000000000000",
			cin => '1',
			cout =>	PC_ADDER_COUT,
			sum  =>	PC_PLUS_ONE,
			signed_overflow =>	PC_ADDER_OVERFLOW);
			
	PC	<=	CUR_PC;
			
			
END Structure;