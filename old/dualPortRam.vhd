library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity dualPortRam is
port(   i_clk: in std_logic; --clock
        i_writeEnable : in std_logic;   --write enable for port 0
        i_writeData : in std_logic_vector(c_WIDTH - 1 downto 0);  --Input data to port 0.
        i_writeAddr : in std_logic_vector(6 downto 0);    --address for port 0
        i_readAddr : in std_logic_vector(6 downto 0);    --address for port 1
        i_readEnable : in std_logic;   --enable port 1.
        o_readData : out std_logic_vector(c_WIDTH - 1 downto 0)   --output data from port 1.
    );
end dualPortRam;

architecture Behavioral of dualPortRam is

--type and signal declaration for RAM.
type ram_type is array(0 to 2**6 - 1) of std_logic_vector(c_WIDTH - 1 downto 0);
signal ram : ram_type := (others => (others => '0'));
signal r_dataOut : std_logic_vector(c_WIDTH - 1 downto 0);
begin

process(i_clk)
begin
    if(rising_edge(i_clk)) then
        --For port 0. Writing.
        if i_writeEnable then    --see if write enable is ON.
            ram(to_integer(unsigned(i_writeAddr))) <= i_writeData;
        end if;
        --always read when port is enabled.
        if i_readEnable then
          r_dataOut <= ram(to_integer(unsigned(i_readAddr)));
          o_readData <= r_dataOut;
        end if;
    end if;
end process;


end Behavioral;
