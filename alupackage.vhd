library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;  
use work.aluPackage.all;

library work;

package aluPackage is
	function numberToHex (nth_input1: in integer range 0 to 9) return std_logic_vector;
	procedure doAlu(
		signal aluInstructionAddress:	in std_logic_vector(1 downto 0);
		signal aluInput1: 				in std_logic_vector(7 downto 0);
		signal aluInput2:					in std_logic_vector(7 downto 0);
		signal aluAcc:						out std_logic_vector(7 downto 0);
		signal aluC:						out bit; --PRZEPEŁNIENIE
		signal aluZ:						out bit; --ZERO
		signal aluS:						out bit; --ZNAK
		signal aluP:						out bit --PARZYSTOSC
	);
end aluPackage;

package body aluPackage is
	function numberToHex (nth_input1: in integer range 0 to 9) return std_logic_vector is 
		variable returnValue: std_logic_vector(6 downto 0);
	begin
		case nth_input1 is
			when 0 => return "1000000"; -- 0
			when 1 => return "1111001"; -- 1
			when 2 => return "0100100"; -- 2
			when 3 => return "0110000"; -- 3
			when 4 => return "0011001"; -- 4
			when 5 => return "0010010"; -- 5
			when 6 => return "0000010"; -- 6
			when 7 => return "1111000"; -- 7
			when 8 => return "0000000"; -- 8
			when 9 => return "0010000"; -- 9
	    end case;
		 
		 return returnValue;		 
	end numberToHex;
	

	procedure doAlu(
		signal aluInstructionAddress:	in std_logic_vector(1 downto 0);
		signal aluInput1: 				in std_logic_vector(7 downto 0);
		signal aluInput2:					in std_logic_vector(7 downto 0);
		signal aluAcc:						out std_logic_vector(7 downto 0);
		signal aluC:						out bit; --PRZEPEŁNIENIE
		signal aluZ:						out bit; --ZERO
		signal aluS:						out bit; --ZNAK
		signal aluP:						out bit --PARZYSTOSC
	) is 
		variable input1Value:			std_logic_vector(7 downto 0);
		variable input2Value:			std_logic_vector(7 downto 0);
		variable outputValue:		  	std_logic_vector(8 downto 0);
		variable outputValueTemp:  	std_logic_vector(8 downto 0);
	begin
		input1Value := aluInput1;
		input2Value := aluInput2;
		aluC <= '0';
		aluZ <= '0';
		aluS <= '0';
		aluP <= '0';
		
		case aluInstructionAddress is 
			when "00" => --MOV A, B
				input1Value := input2Value;
				outputValue := ("0" & input1Value);
			when "01" => --Dodawnaie
				outputValue := ("0" & input1Value) + ("0" & input2Value);
			when "10" => --Odejmowanie
				outputValueTemp := ("0" & input1Value) - ("0" & input2Value);
				
				if (input2Value > input1Value) then
					aluS <= '1';
					outputValue := (not outputValueTemp) + '1';
				else 
					outputValue := outputValueTemp;
				end if;
			
			when "11" => --Przesuniecie o 4 bity
				outputValue := ("0" & std_logic_vector(rotate_right(unsigned(input1Value), 4)));						
		end case;			
	
		--------------USTAWIENIE FLAG----------------		
		if (aluInstructionAddress /= "10" AND outputValue > "11111111") then
			aluC <= '1';
		end if;
		
		if (outputValue = "000000000") then
			aluZ <= '1';
		end if;				
		
		if (outputValue(0) = '0') then 
			aluP <= '1';
		end if;
		
		------------USTAWIENIE DLA WYJSC--------------				
		aluAcc <= outputValue(7 downto 0);		
	end doAlu;
end aluPackage;