----



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


use work.pkg_audiovhd.all;

entity multiAdderFixed is
  port(
    i_clk   : in  std_logic;
    i_reset : in  std_logic;
    i_x     : in  std_logic_vector(c_dataWidth - 1 downto 0);
    i_y     : in  std_logic_vector(c_dataWidth - 1 downto 0);
    i_accum : in  std_logic;
    o_z     : out std_logic_vector(c_dataWidth - 1 downto 0)
    );
end entity;
architecture rtl of multiAdderFixed is
  signal r_i_x        : std_logic_vector(c_dataWidth - 1 downto 0);
  signal r_i_y        : std_logic_vector(c_dataWidth - 1 downto 0);
  signal r_mult       : std_logic_vector(c_dataWidth - 1 downto 0);
  signal rr_mult      : std_logic_vector(c_dataWidth - 1 downto 0);
  signal rrr_mult     : std_logic_vector(c_dataWidth - 1 downto 0);
  signal r_i_accum    : std_logic;
  signal rr_i_accum   : std_logic;
  signal rrr_i_accum  : std_logic;
  signal rrrr_i_accum : std_logic;
begin
  p_reg : process(i_clk, i_reset)
  begin
    if i_reset then
      rrrr_i_accum <= '0';
      rrr_i_accum  <= '0';
      rr_i_accum   <= '0';
      r_i_accum    <= '0';
      rrr_mult     <= (others => '0');
      rr_mult      <= (others => '0');
      r_mult       <= (others => '0');
      o_z          <= (others => '0');
      r_i_x        <= (others => '0');
      r_i_y        <= (others => '0');

    elsif rising_edge(i_clk) then
      r_i_x        <= i_x;
      r_i_y        <= i_y;
      r_i_accum    <= i_accum;
      rr_i_accum   <= r_i_accum;
      rrr_i_accum  <= rr_i_accum;
      rrrr_i_accum <= rrr_i_accum;
      r_mult       <= std_logic_vector(resize(shift_right(signed(r_i_x) * signed(r_i_y), c_fractionLength), r_mult'length));
      rr_mult      <= r_mult;
      rrr_mult     <= rr_mult;
      if rrrr_i_accum then
        o_z <= std_logic_vector(resize(signed(o_z) + signed(rrr_mult), o_z'length));
      else
        o_z <= std_logic_vector(resize(signed(rrr_mult), o_z'length));
      end if;
    end if;
  end process;  -- end p_reg
end architecture;
