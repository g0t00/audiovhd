library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.std_logic_textio.all;

use work.types.all;

entity coefficientsentity is
  port (coefficients_out : out coefficients);
end coefficientsentity;

architecture Behavioral of coefficientsentity is
begin
  coefficients_out <= (
        beta00 => x"0987",
        beta01 => x"1d9e",
        beta11 => x"0000",
        beta02 => x"0000",
        gamma00 => x"c001",
        gamma01 => x"0000"
       );
end Behavioral;
