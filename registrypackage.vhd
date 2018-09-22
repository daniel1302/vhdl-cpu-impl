library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;  
use work.registryPackage.all;

library work;

package registryPackage is
	procedure setToRegistry(
		signal address:		in integer range 0 to 63;
		signal data: 			in std_logic_vector(7 downto 0);
		signal returnStatus:	out bit
	);
end registryPackage;

package body registryPackage is
	procedure setToRegistry(
		signal address:		in integer range 0 to 63;
		signal data: 			in std_logic_vector(7 downto 0);
		signal returnStatus:	out bit
	) is
		variable returnSatusTemp:	bit;
	begin
		returnSatusTemp := '1';
		
		if (address < 4) then 
			returnSatusTemp := '0';
		end if;
		
		
		if (returnSatusTemp = '1') then 
			
		end if;		
	end setToRegistry;
		
end registryPackage;