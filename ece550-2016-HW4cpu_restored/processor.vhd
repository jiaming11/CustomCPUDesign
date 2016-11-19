LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- The core of the Duke 550 processor
-- Author: YOUNG-HOON KIM

ENTITY processor IS
    PORT (	clock, reset	: IN STD_LOGIC;
			keyboard_in	: IN STD_LOGIC_VECTOR(31 downto 0);
			keyboard_ack, lcd_write	: OUT STD_LOGIC;
			lcd_data	: OUT STD_LOGIC_VECTOR(31 downto 0);
			
			--TESTING OUTPUTS
			test_Rwe	:	OUT	STD_LOGIC;
			test_Rwd	:	OUT	STD_LOGIC;
			test_Rd_INSTR	:	OUT	STD_LOGIC_VECTOR(4 DOWNTO 0);
			test_Rs_INSTR	:	OUT	STD_LOGIC_VECTOR(4 DOWNTO 0);
			test_Rt_INSTR	:	OUT	STD_LOGIC_VECTOR(4 DOWNTO 0);
			test_REG_VAL_D	:	OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
			test_IMM_MUX_OUT	:	OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
			test_PC	:	OUT	STD_LOGIC_VECTOR(11 DOWNTO 0);
			test_PC_PLUS_ONE	:	OUT	STD_LOGIC_VECTOR(11 DOWNTO 0);
			test_IMM_INSTR	:	OUT	STD_LOGIC_VECTOR(16 DOWNTO 0);
			test_OPCODE	:	OUT	STD_LOGIC_VECTOR(4 DOWNTO 0);
			test_REG_ALU_OUT	:	OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
			test_READ_KEY		:	OUT	STD_LOGIC;
			test_RESULT_FROM_DMEM	:	OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
			test_DMEM_OUT	:	OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
			test_VALA		:	OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
			test_VALB		:	OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
			test_PC_NEXT 	:	OUT	STD_LOGIC_VECTOR(11 DOWNTO 0);
			test_JAL			:	OUT	STD_LOGIC;
			test_REGD_MUX_OUT		:	OUT	STD_LOGIC_VECTOR(4 DOWNTO 0);
			test_TARGET_INSTR	:	OUT	STD_LOGIC_VECTOR(26 DOWNTO 0);
			test_ALUinB	:	OUT	STD_LOGIC;
			test_ALUinB_Result	:	OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
			test_isLessThan_Results	:	OUT	STD_LOGIC;
			test_isEqual_Results	:	OUT	STD_LOGIC
			);
END processor;

ARCHITECTURE Structure OF processor IS
	COMPONENT imem IS
		PORT (	address	: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
				clken	: IN STD_LOGIC ;
				clock	: IN STD_LOGIC ;
				q	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );
	END COMPONENT;
	COMPONENT dmem IS
		PORT (	address	: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
				clock	: IN STD_LOGIC ;
				data	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
				wren	: IN STD_LOGIC ;
				q	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );
	END COMPONENT;
	COMPONENT regfile IS
		PORT (	clock, wren, clear	: IN STD_LOGIC;
				regD, regA, regB	: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
				valD	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
				valA, valB	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0) );
	END COMPONENT;
	COMPONENT alu IS
		PORT (	A, B	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);	-- 32bit inputs
				op	: IN STD_LOGIC_VECTOR(2 DOWNTO 0);	-- 3bit ALU opcode
				R	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);	-- 32bit output
				isEqual : OUT STD_LOGIC; -- true if A=B
				isLessThan	: OUT STD_LOGIC ); -- true if A<B
	END COMPONENT;
	COMPONENT control IS
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
	END COMPONENT;
	-- TODO: Likely need other components here (register/adder for PC?, muxes for the data path?, etc.) 
	
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
	
	COMPONENT mux IS
		GENERIC(n: integer:=16);
		PORT (	A, B	: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
				s	: IN STD_LOGIC;	-- select (NOT A / B)
				F	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0) );
	END COMPONENT;
	
	COMPONENT custom_mux IS
	PORT (	A, B	: IN STD_LOGIC;
			s	: IN STD_LOGIC;	-- select (NOT A / B)
			F	: OUT STD_LOGIC);
	END COMPONENT;
	
	COMPONENT custom_tri_state_sel IS
		GENERIC ( n : integer := 32 );
		PORT (	Q	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
				readA, readB : IN STD_LOGIC;
				Da, Db : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0) );
	END COMPONENT;

	-- TODO: Also likely need a bunch of signals...
	SIGNAL CUR_PC	:	STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL PC_PLUS_ONE	:	STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL PC_NEXT	:	STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL PC_NEXT_TO_REG	:	STD_LOGIC_VECTOR(11 DOWNTO 0);
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
	
	--CONTROLS SIGNALS
	SIGNAL Rwe		: STD_LOGIC;
	SIGNAL SW		: STD_LOGIC;
	SIGNAL ALUinB	: STD_LOGIC;
	SIGNAL ALUOP	: STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
	SIGNAL DMwe		: STD_LOGIC;
	SIGNAL Rwd		: STD_LOGIC;
	SIGNAL JP		: STD_LOGIC;
	SIGNAL BR		: STD_LOGIC;
	SIGNAL BR_COND	: STD_LOGIC;
	SIGNAL JR		: STD_LOGIC;
	SIGNAL JAL		: STD_LOGIC;
	SIGNAL READ_KEY	: STD_LOGIC;
	
	
	--REGFILE OUTPUTS
	SIGNAL ValA_OUT	:	STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ValB_OUT	:	STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	--MUX OUTPUTS
	SIGNAL PC_ADDER_CIN		:	STD_LOGIC;
	SIGNAL KEYB_VS_DMEM_OUT	:	STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL REG_VAL_D			:	STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL REGD_MUX_OUT		:	STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL REGB_MUX_OUT		:	STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL IMM_MUX_OUT		:	STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BR_COND_RESULT	:	STD_LOGIC;
	SIGNAL isLessThan_Results	:	STD_LOGIC;
	SIGNAL isEqual_Results	:	STD_LOGIC;
	SIGNAL REG_ALU_OUT		:	STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_OUT_VAL		:	STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BR_ADDR_VAL		:	STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL JMP_ADDR_VAL		:	STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BR_ADDR_RESULT	:	STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL JP_ADDR_RESULT	:	STD_LOGIC_VECTOR(11 DOWNTO 0);
	
	--IMM SIGNEXTEND
	SIGNAL IMM_SX				:	STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	--DMEM OUTPUT
	SIGNAL DMEM_OUT			:	STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL NEXT_VALD			:	STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL RESULT_FROM_DMEM	:	STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL DMEM_OUT_VAL		:	STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	--TODO: MAKE SIGNALS HERE
	SIGNAL CLOCKN	:	STD_LOGIC;
	
	CONSTANT	REG_31	:	STD_LOGIC_VECTOR(4 DOWNTO 0) := "11111";
	CONSTANT ADD_ALU_SIG	:	STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
	CONSTANT TWENTY_ZERO	:	STD_LOGIC_VECTOR(19 DOWNTO 0) := "00000000000000000000";
	SIGNAL	internal_PC_JAL	:	STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL	internal_IMM_EXT	:	STD_LOGIC_VECTOR(31 DOWNTO 0);
	CONSTANT TWENTY_FOUR_ZERO	:	STD_LOGIC_VECTOR(23 DOWNTO 0) := "000000000000000000000000";
	
BEGIN
	--PULLING SIGNAL TO TOP FOR TESTING 
	test_PC <=	CUR_PC;
	test_Rwd	<=	Rwd;
	test_OPCODE	<= OPCODE;
	test_PC_PLUS_ONE <= PC_PLUS_ONE;
	test_IMM_INSTR	<= IMM_INSTR;
	test_Rd_INSTR	<=	Rd_INSTR;
	test_Rs_INSTR	<= Rs_INSTR;
	test_Rt_INSTR	<=	Rt_INSTR;
	test_Rwe			<=	Rwe;
	test_REG_VAL_D	<= REG_VAL_D;
	test_IMM_MUX_OUT <= IMM_MUX_OUT;
	test_REG_ALU_OUT	<= REG_ALU_OUT;
	test_VALA		<= ValA_OUT;
	test_VALB		<= ValB_OUT;
	test_READ_KEY	<= READ_KEY;
	test_RESULT_FROM_DMEM	<=	RESULT_FROM_DMEM;
	test_DMEM_OUT	<=	DMEM_OUT;
	test_PC_NEXT <=	PC_NEXT;
	test_JAL	<= JAL;
	test_REGD_MUX_OUT	<= REGD_MUX_OUT;
	test_TARGET_INSTR	<= TARGET_INSTR;
	test_isLessThan_Results	<=	isLessThan_Results;
	test_isEqual_Results	<=	isEqual_Results;
	test_ALUinB_Result	<=	IMM_MUX_OUT;
	test_ALUinB	<=	ALUinB;
	--END TESTING SIGNALS
	
	CLOCKN	<=	not clock;

	-- TODO: Connect stuff up to make a processor
	PC_REG	:	reg
		GENERIC MAP	( n => 12)
		PORT MAP		(	D	=>	PC_NEXT, --TODO: CONNECT TO PC+1 MARK: THIS NEED TO TAKE INTO ACCOUNT OTHER PC INCREMENTATIONS
						clock		=>	clock, 
						clear		=>	reset, 
						enable	=> '1',
						Q			=>	CUR_PC );
						
		-- HACKY METHOD TO DISABLE ADDER WHEN RESET
	SEL_ENABLE_PC_ADDER	: custom_mux 
		PORT MAP(A => '1',	-- WANT TO SELECT '0' WHEN RESET IS ENABLED
					B => '0',	
					s => reset,	-- select (NOT A / B)
					F => PC_ADDER_CIN );	

						
	PC_ADDER		:	adder_cs 
		GENERIC MAP (n	=> 12)
		PORT MAP(	
			A	=>	CUR_PC, 
			B 	=> "000000000000",
			cin => PC_ADDER_CIN,
			cout =>	PC_ADDER_COUT,
			sum  =>	PC_PLUS_ONE,
			signed_overflow =>	PC_ADDER_OVERFLOW);
			
	PC_NEXT_REG	:	reg
		GENERIC MAP	( n => 12)
		PORT MAP		(	D	=>	PC_NEXT_TO_REG, --TODO: CONNECT TO PC+1 MARK: THIS NEED TO TAKE INTO ACCOUNT OTHER PC INCREMENTATIONS
						clock		=>	CLOCKN, 
						clear		=>	reset, 
						enable	=> '1',
						Q			=>	PC_NEXT );
			
			
	---- FETCH Stage
			
	IMEM_STORAGE	: imem 
		PORT MAP(address => PC_NEXT,				--TODO:	NEXT PC IS NOT ALWAYS PC_PLUS_ONE
					clken	=> '1',
					clock	=> clock,
					q	=> CUR_INSTR);
		
	
	---- DECODE Stage
	
	OPCODE	<=	CUR_INSTR(31 DOWNTO 27);
	Rd_INSTR	<= CUR_INSTR(26 DOWNTO 22);
	Rs_INSTR	<= CUR_INSTR(21 DOWNTO 17);
	Rt_INSTR	<= CUR_INSTR(16 DOWNTO 12);
	IMM_INSTR	<=	CUR_INSTR(16 DOWNTO 0);
	TARGET_INSTR	<= CUR_INSTR(26 DOWNTO 0);
	
		-- MUXs FOR REGFILE
		
	SEL_Rd_OR_R31_VAL	: mux 
		GENERIC MAP(n => 5)
		PORT MAP(	A => Rd_INSTR,
					B => REG_31,	
					s => JAL,	-- select (NOT A / B)
					F => REGD_MUX_OUT);	
					
	SEL_Rt_OR_Rd_VAL	: mux 
		GENERIC MAP(n => 5)
		PORT MAP(	A => Rt_INSTR,
					B => Rd_INSTR,	
					s => SW,	-- select (NOT A / B)
					F => REGB_MUX_OUT);	
	
	REGISTERFILE	:	 regfile 
		PORT MAP(	clock => clock, 
						wren	=> Rwe, 
						clear	=> reset,
						regD	=> REGD_MUX_OUT,		
						regA	=> Rs_INSTR, 
						regB	=> REGB_MUX_OUT,
						valD	=> REG_VAL_D,	--TODO: SUPPORT JAL AND KEYBOARD IN
						valA	=> ValA_OUT, 
						valB	=> ValB_OUT);
						
		-- MUX FOR IMM SELECTOR
		
	IMM_SX	<=		std_logic_vector(resize(signed(IMM_INSTR), IMM_SX'length));
	SEL_ValA_OR_IMM_VAL	: mux 
		GENERIC MAP(n => 32)
		PORT MAP(A => ValB_OUT,
					B => IMM_SX,	
					s => ALUinB,	-- select (NOT A / B)
					F => IMM_MUX_OUT);	
	
	---- EXECUTE Stage
	
			--CONTROL LOGIC
	CONTROL_LOGIC	: control 
	PORT MAP(op			=>	OPCODE,
				Rwe		=> Rwe, 
				SW			=> SW,
				ALUinB	=> ALUinB,
				ALUOP		=> ALUOP, 
				DMwe		=> DMwe, 
				Rwd		=>	Rwd,
				JP			=> JP, 
				BR			=> BR, 
				BR_COND	=> BR_COND, 
				JR			=>	JR, 
				JAL		=> JAL, 
				KEYBOARD_ACK	=> keyboard_ack, 
				READ_KEY	=> READ_KEY,
				LCD_WRITE=> lcd_write
			);
			
			--ALU FOR REGISTER COMPUTATIONS
	REGFILE_OUT_ALU	: alu 
		PORT MAP(A	=>	ValA_OUT, 
					B	=> IMM_MUX_OUT,	-- 32bit inputs
					op	=> ALUOP,	-- 3bit ALU opcode
					R	=> REG_ALU_OUT,	-- 32bit output		--TODO: EXPAND THIS TO CHOOSE BETWEEN DMEM VALUES AND REG_ALU
					isEqual	=> isEqual_Results, -- true if A=B
					isLessThan	=> isLessThan_Results); -- true if A<B		--TODO: VALIDATE A AND B ARE IN CORRECT ORDER
					
	SEL_BR_COND	: custom_mux 
		PORT MAP(A => isLessThan_Results,	--TODO: VALIDATE CORRECT ORDER
					B => isEqual_Results,	
					s => BR_COND,	-- select (NOT A / B)
					F => BR_COND_RESULT );	


	
	---- MEMORY WRITE Stage
	DMEM_STORAGE	:	 dmem 
		PORT MAP(	address	=> REG_ALU_OUT(11 DOWNTO 0),
						clock		=>	CLOCKN,
						data	=>	ValB_OUT,
						wren	=>	DMwe,
						q	=>	DMEM_OUT );
						
	SEL_DMEM_VAL	: mux 
		GENERIC MAP(n => 32)
		PORT MAP(	A => REG_ALU_OUT,	
					B => DMEM_OUT,	
					s => Rwd,	-- select (NOT A / B)
					F => RESULT_FROM_DMEM );	

						
			
			--STORE KEYBOARD VALUES
	SEL_KEYBOARD_OR_MEM_VAL	: mux 
		GENERIC MAP(n => 32)
		PORT MAP(	A => RESULT_FROM_DMEM,	
					B => keyboard_in,	
					s => READ_KEY,	-- select (NOT A / B)
					F => KEYB_VS_DMEM_OUT );	
					
	
	---- WRITEBACK Stage
	
	internal_PC_JAL	<=	"00000000000000000000" & PC_PLUS_ONE;
	internal_IMM_EXT	<= "000000000000000" & IMM_INSTR;
	
		--DETERMINE WHAT GOES INTO REGFILE
	SEL_REG_VALD	: mux 
		GENERIC MAP(n => 32)
		PORT MAP(	A => KEYB_VS_DMEM_OUT,	--TODO: CLEAN UP THIS DUMMY VALUE 
					B => internal_PC_JAL,	
					s => JAL,	-- select (NOT A / B)
					F => REG_VAL_D);	
					
	
			--WRITE TO LCD_DATA
		lcd_data <= "000000000000000000000000" & ValB_OUT(7 DOWNTO 0);
		
		
	-- JUMP AND BRANCH CASES
	
	PC_INCR_ALU	: alu 
		PORT MAP(A	=>	internal_PC_JAL, 
					B	=> IMM_SX,	-- 32bit inputs
					op	=> "000",	-- 3bit ALU opcode
					R	=> BR_ADDR_VAL,	-- 32bit output		
					isEqual	=> open, -- true if A=B
					isLessThan	=> open); -- true if A<B		--TODO: VALIDATE A AND B ARE IN CORRECT ORDER
					
					
		-- DETERMINE IF PC=PC+1 or PC+1+TARGET
	SEL_PC_BR	: mux 
		GENERIC MAP(n => 12)
		PORT MAP(	A => PC_PLUS_ONE,	
					B => BR_ADDR_VAL(11 DOWNTO 0),	
					s => BR AND BR_COND_RESULT,	-- select (NOT A / B)
					F => BR_ADDR_RESULT);	
					
		-- DETERMINE IF JUMP OR NOT
	SEL_PC_JMP	: mux 
		GENERIC MAP(n => 12)
		PORT MAP(	A => BR_ADDR_RESULT,	
					B => TARGET_INSTR(11 DOWNTO 0),	
					s => JP,	-- select (NOT A / B)
					F => JP_ADDR_RESULT);	

		-- DETERMINE IF JUMP REG OR NOT
	SEL_PC_JR	: mux 
		GENERIC MAP(n => 12)
		PORT MAP(	A => JP_ADDR_RESULT,	
					B => ValB_OUT(11 DOWNTO 0),	
					s => JR,	-- select (NOT A / B)
					F => PC_NEXT_TO_REG);
	
	
		
END Structure;