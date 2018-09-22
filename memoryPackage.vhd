LIBRARY ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;  
use work.aluPackage.all;
use work.registryPackage.all;
--use work.memoryPackage.all;

library work;

entity memoryEntity is 
	port(
		dataInput: 	in std_logic_vector(7 downto 0);
		dataOutput: out std_logic_vector(7 downto 0);
		address: 	in std_logic_vector(7 downto 0);
		rw: 			in bit;
		selectBit:	in bit;
		ready:		out bit
	);
end memoryEntity;
architecture memoryArchitecture of memoryEntity is 
begin 
	memproc: process(address, selectBit, rw) 
		type memType is array(0 to 7) of std_logic_vector(7 downto 0);
		variable memoryData: 		memType; 
	begin
		if (selectBit = '1') then
			if (rw = '0') then --Zapis
				memoryData(conv_integer(address(7 downto 0))) := dataInput(7 downto 0);
				--after 1ns;
				
				ready <= '1';
			else
				dataOutput <= memoryData(conv_integer(address(7 downto 0)));
				ready <= '1';
			end if;
		end if;
	end process;
end memoryArchitecture;
