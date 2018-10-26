library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;


entity dualPortRam is
  generic (
    g_dataWidth : positive;
    g_depth     : positive
    );
  port(
    i_clk          : in  std_logic;
    i_writeEnableA : in  std_logic;
    i_writeDataA   : in  std_logic_vector(g_dataWidth - 1 downto 0);
    o_readDataA    : out std_logic_vector(g_dataWidth - 1 downto 0);
    i_addrA        : in  std_logic_vector(g_depth - 1 downto 0);
    i_writeEnableB : in  std_logic;
    i_writeDataB   : in  std_logic_vector(g_dataWidth - 1 downto 0);
    o_readDataB    : out std_logic_vector(g_dataWidth - 1 downto 0);
    i_addrB        : in  std_logic_vector(g_depth - 1 downto 0)
    );
end dualPortRam;

architecture Behavioral of dualPortRam is
  type ram_type is array(0 to 2**g_depth - 1) of std_logic_vector(g_dataWidth - 1 downto 0);
  function fu_getInitial (size : integer)
    return ram_type is
    variable v_temp : ram_type;
  begin
    for i in 0 to size loop
      v_temp(i) := std_logic_vector(to_unsigned(i * 65536, g_dataWidth));
    end loop;
    return v_temp;
  end;
--type and signal declaration for RAM.
  signal ram         : ram_type := fu_getInitial(2**g_depth - 1);
  signal r_readDataA : std_logic_vector(g_dataWidth - 1 downto 0);
  signal r_readDataB : std_logic_vector(g_dataWidth - 1 downto 0);
begin

  process(i_clk)
  begin
    if (rising_edge(i_clk)) then
      if i_writeEnableA then            --see if write enable is ON.
        ram(to_integer(unsigned(i_addrA))) <= i_writeDataA;
        o_readDataA                        <= i_writeDataA;
      else
        o_readDataA <= ram(to_integer(unsigned(i_addrA)));
      end if;
      if i_writeEnableB then            --see if write enable is ON.
        ram(to_integer(unsigned(i_addrB))) <= i_writeDataB;
        o_readDataB                        <= i_writeDataB;
      else
        o_readDataB <= ram(to_integer(unsigned(i_addrB)));
      end if;
    end if;
  end process;


end Behavioral;
