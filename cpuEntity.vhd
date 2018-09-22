LIBRARY ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;  
use work.aluPackage.all;
use work.registryPackage.all;
--use work.memoryPackage.all;

library work;

ENTITY cpuEntity IS 
	PORT(input1:		in std_logic_vector(7 downto 0);
		input2:			in std_logic_vector(7 downto 0);
		output:			inout std_logic_vector(7 downto 0);
		outputLastBit: out bit;
		oC:				out bit; --PRZEPEŁNIENIE
		oZ:				out bit; --ZERO
		oS:				out bit; --ZNAK
		oP:				out bit; --PARZYSTOSC
		clk: 				in bit;
		command:			in std_logic_vector(1 downto 0);
		commandDiode:	out std_logic_vector(1 downto 0);
		inputKey:		in bit;
		oHex0:			out std_logic_vector(6 downto 0) := "1111111";
		oHex1:			out std_logic_vector(6 downto 0) := "1111111";
		oHex2:			out std_logic_vector(6 downto 0) := "1111111"
		);
END cpuEntity;
ARCHITECTURE cpuArchitecture OF cpuEntity IS
	signal outputValue:		std_logic_vector(7 downto 0);	
	component memoryEntity is port(
			dataInput: 	in std_logic_vector(7 downto 0);
			dataOutput: out std_logic_vector(7 downto 0);
			address: 	in std_logic_vector(7 downto 0);
			rw: 			in bit;
			selectBit:	in bit;
			ready:		out bit
		);
	end component;
	signal dataInputSignal:		std_logic_vector(7 downto 0);
	signal dataOutputSignal: 	std_logic_vector(7 downto 0);
	signal memoryReady:	bit;
	
	------------------REJESTRY--------------------
	signal IR: 		std_logic_vector(1 downto 0) := "00";
	signal MEM:		std_logic_vector(7 downto 0) := "00000000";
	signal PC:		std_logic_vector(7 downto 0) := "00000000";
	signal AX:		std_logic_vector(7 downto 0);
	signal CX:		std_logic_vector(7 downto 0);
	signal R0:		std_logic_vector(7 downto 0);
	signal R1:		std_logic_vector(7 downto 0);
	signal R2:		std_logic_vector(7 downto 0);
	signal R3:		std_logic_vector(7 downto 0);
	signal FLAGS:	std_logic_vector(7 downto 0);
	signal CS:		std_logic_vector(7 downto 0);
	signal DS:		std_logic_vector(7 downto 0);
	signal SS:		std_logic_vector(7 downto 0);
	signal MAR:		std_logic_vector(7 downto 0) := "00000000";
	signal MBR:		std_logic_vector(7 downto 0) := "00000000";
	-------------KONIEC--REJESTRY-----------------
	
	signal cmdSignal: std_logic_vector(1 downto 0);
	signal AXFSignal: bit;
	signal addressSignal: std_logic_vector(7 downto 0);
	signal memSelectSignal: bit;
	signal memRWSignal: bit;
	signal memSaveFlag: bit;
	
	signal ACC: std_logic_vector(7 downto 0);
	signal tempOutput: std_logic_vector(7 downto 0);
	
	signal aluLock: std_logic_vector(1 downto 0);
	
BEGIN
	G1: memoryEntity port map (
		dataInput		=> dataInputSignal,
		dataOutput		=> dataOutputSignal,
		address			=> addressSignal,
		rw					=> memRWSignal,
		selectBit		=>	memSelectSignal,
		ready				=>	memoryReady
	); 
	
	process (clk)
		variable tempInteger1:          	integer range 0 to 511;
		variable tempInteger2:          	integer range 0 to 511;
		variable sUnitsInteger:         	integer range 0 to 9;
		variable sDozersInteger:        	integer range 0 to 9;
		variable sHundredsInteger:      	integer range 0 to 9;
		variable outputValueTemp:       	std_logic_vector(7 downto 0);		
		variable rwFlag:						bit;
		variable selectFlag:					bit;
	begin      
		--if (clk'EVENT AND clk='0') then 		
			cmdSignal <= command;
			
			memSaveFlag <= to_bit(input1(4));
			
			AXFSignal <= to_bit(input1(5));
		--end if;
		
	end process;
	
	process (inputKey)
		variable memIsRdy: bit;
		variable outputValueVariable: std_logic_vector(7 downto 0);
		variable integerPC:					integer range 0 to 500;
		variable tempInteger1:          	integer range 0 to 511;
		variable tempInteger2:          	integer range 0 to 511;
		variable sUnitsInteger:         	integer range 0 to 9;
		variable sDozersInteger:        	integer range 0 to 9;
		variable sHundredsInteger:      	integer range 0 to 9;
	begin
		if (inputKey'event AND inputKey = '0') then
			memIsRdy := '0';			
			memRWSignal <= '1';
			
			IR <= command;
			
			if (IR = "00") then
				PC <= PC + '1';
				if (AXFSignal = '1') then --Zapis do AX
					if (to_bit(input1(2)) = '1') then 
						case input2(1 downto 0) is 
							when "00" => AX <= R0;
							when "01" => AX <= R1;
							when "10" => AX <= R2;
							when "11" => AX <= R3;
						end case;
					else
						if (memSaveFlag = '1') then	--Z PAMIECI
							memSelectSignal <= '1';
							memRWSignal <= '1';
							addressSignal <= input2;
							
							AX <= dataOutputSignal;
							
						else 									--LICZBA
							AX <= input2;
						end if;
					end if;
				else --Zapis z AX do pamięci
					
					if (memSaveFlag = '1') then
						memSelectSignal <= '1';
						memRWSignal <= '0';
						addressSignal <= input2;
			
						dataInputSignal <= AX;
					else
						case input2(1 downto 0) is 
							when "00" => R0 <= AX;
							when "01" => R1 <= AX;
							when "10" => R2 <= AX;
							when "11" => R3 <= AX;
						end case;
					end if;
				end if;
				
				output <= AX;
			else
				PC <= PC + '1';
				--ACC <= AX;
					doAlu(IR, AX, input2, AX, oC, oZ, oS, oP);
					--output <= tempOutput;
					--AX <= tempOutput;
					output <= AX after 5 ns;
			end if;

										  
		  
			------------USTAWIENIE DLA WYJSC--------------   
			tempInteger1              := to_integer(unsigned(PC));
			sHundredsInteger        := tempInteger1 / 100;
			tempInteger2            := tempInteger1 - (sHundredsInteger * 100);
			sDozersInteger  			:= tempInteger2 / 10;
			sUnitsInteger           := tempInteger2 - (sDozersInteger * 10);
			                       
		  
			oHex0 <= numberToHex(sUnitsInteger);
			oHex1 <= numberToHex(sDozersInteger);
			oHex2 <= numberToHex(sHundredsInteger); 
			
			--Oc <= memIsRdy;
			
		end if;
	end process;
END cpuArchitecture;
					
				
			