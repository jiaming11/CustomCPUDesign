LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- Control logic for the Duke 550 processor
-- Author: Young-hoon Kim

ENTITY control IS
	PORT (	op	: IN STD_LOGIC_VECTOR(4 DOWNTO 0);	-- instruction opcode
				Rwe		:	OUT STD_LOGIC;
				SW			:	OUT STD_LOGIC;
				ALUinB	:	OUT STD_LOGIC;
				ALUOP		:	OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
				DMwe		:	OUT STD_LOGIC;
				Rwd		:	OUT STD_LOGIC;
				JP			:	OUT STD_LOGIC;
				BR			:	OUT STD_LOGIC;
				BR_COND	:	OUT STD_LOGIC;
				JR			:	OUT STD_LOGIC;
				JAL		:	OUT STD_LOGIC;
				KEYBOARD_ACK	:	OUT STD_LOGIC;
				READ_KEY	:	OUT STD_LOGIC;
				LCD_WRITE:	OUT STD_LOGIC
			);
END control;

ARCHITECTURE Behavior OF control IS
BEGIN
	-- TODO: implement behavior of control unit
	-- NOTE: Behavioral WHEN... ELSE statements may be used
	Rwe 	<= '1' when op = "00000" else
				'1' when op = "00001" else
				'1' when op = "00010" else
				'1' when op = "00011" else
				'1' when op = "00100" else
				'1' when op = "00101" else
				'1' when op = "00110" else
				'1' when op = "00111" else
				'1' when op = "01101" else
				'1' when op = "01110" else
				'0';
			 
	SW		<=	'1' when op = "01000" else
				'1' when op = "01001" else
				'1' when op = "01010" else
				'1' when op = "01011" else
				'1' when op = "01111" else
				'0';
				
			 
	ALUinB	<=	'1' when op = "00110" else
					'1' when op = "00111" else
					'1' when op = "01000" else
					'0';
					
	ALUOP		<= "001" when op = "00001" else
					"001" when op = "01001" else
					"001" when op = "01010" else
					"010" when op = "00010" else
					"011" when op = "00011" else
					"100" when op = "00100" else
					"101" when op = "00101" else
					"000"; 
					
	DMwe		<=	'1' when op = "01000" else
					'0';		 
					
	JP			<=	'1' when op = "01100" else
					'1' when op = "01101" else
					'0';	

	BR			<=	'1' when op = "01001" else
					'1' when op = "01010" else
					'0';				
			
	
	BR_COND 	<= '1' when op = "01001" else
					'0';
					
	JR			<= '1' when op = "01011" else
					'0';
					
	JAL		<= '1' when op = "01101" else
					'0';
					
	KEYBOARD_ACK	<= '1' when op = "01110" else
							'0';
							
	READ_KEY			<=	'1' when op = "01110" else
							'0';
				
	LCD_WRITE		<=	'1' when op = "01111" else
							'0';
				
	Rwd				<=	'1' when op = "00111" else
							'0';
	
	
	
	
	
END Behavior;