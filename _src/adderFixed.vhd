----



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_audiovhd.all;


entity adderFixed is
  port(
    i_clk   : in  std_logic;
    i_reset : in  std_logic;
    i_x     : in  std_logic_vector(c_dataWidth - 1 downto 0);
    i_y     : in  std_logic_vector(c_dataWidth - 1 downto 0);
    o_z     : out std_logic_vector(c_dataWidth - 1 downto 0)
    );
end entity;
architecture rtl of adderFixed is
  signal r_i_x  : std_logic_vector(c_dataWidth - 1 downto 0);
  signal rr_i_x : std_logic_vector(c_dataWidth - 1 downto 0);
  signal rr_i_y : std_logic_vector(c_dataWidth - 1 downto 0);
  signal r_i_y  : std_logic_vector(c_dataWidth - 1 downto 0);
begin
  p_reg : process(i_clk, i_reset)
  begin
    if i_reset then
      o_z    <= (others => '0');
      r_i_x  <= (others => '0');
      rr_i_x <= (others => '0');
      rr_i_y <= (others => '0');
      r_i_y  <= (others => '0');

    elsif rising_edge(i_clk) then
      r_i_x  <= i_x;
      rr_i_x <= r_i_x;
      r_i_y  <= i_y;
      rr_i_y <= r_i_y;
      o_z    <= std_logic_vector(resize(signed(rr_i_x) + signed(rr_i_y), o_z'length));
    end if;
  end process;  -- end p_reg
end architecture;
