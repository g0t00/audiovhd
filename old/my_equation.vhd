------------------------------------------------------------
-- Module name: My Equation
-- Project Name: Real-time physical modeling sound synthesis
-- Author: Group 8
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity my_equation is
  generic (
    c_width         : integer);
  port (
    clk             : in  std_ulogic;
    --DATA IO
    un0_in          : in  DEFLECTION0;  -- DEFLECTION T;
    un1_in          : in  DEFLECTION1;   -- DEFLECTION T-1;
    un1_out         : out std_logic_vector(c_width - 1 downto 0);      -- DEFLECTION T+1;
    coefficients_in : in  coefficients
  );
end entity my_equation;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
architecture rtl of my_equation is

  -- Top part

  constant Q               : integer := 14;

  signal i_sum_for_beta02  : signed(LENGTH_AFTER_SUM - 1 downto 0);
  signal i_sum_for_beta01  : signed(LENGTH_AFTER_SUM - 1 downto 0);
  signal i_sum_for_beta11  : signed(LENGTH_AFTER_SUM - 1 downto 0);
  signal i_sum_for_gamma01 : signed(LENGTH_AFTER_SUM - 1 downto 0);

  signal i_mult_beta02     : signed(LENGTH_AFTER_MULT - 1 downto 0);-- Multiplication of WIDTH c_width+3 and WIDTH c_width
  signal i_mult_beta01     : signed(LENGTH_AFTER_MULT - 1 downto 0);
  signal i_mult_beta11     : signed(LENGTH_AFTER_MULT - 1 downto 0);
  signal i_mult_beta00     : signed(LENGTH_AFTER_MULT - 1 downto 0);

  signal i_mult_gamma01    : signed(LENGTH_AFTER_MULT - 1 downto 0);
  signal i_mult_gamma00    : signed(LENGTH_AFTER_MULT - 1 downto 0);

  constant LENGTH_FINAL_SUM  : integer := LENGTH_AFTER_MULT + 5; --Q28
  signal i_out_pre_trunc   : signed(LENGTH_FINAL_SUM - 1 downto 0);-- Sum of 6 of the previos
  signal i_out             : signed(c_width-1 downto 0);
  --


  --
  --TEMP


  signal i_un0 : DEFLECTION0 := ((others => '1'), (others => '0'), (others => '0'),
                                 (others => '0'), (others => '0'), (others => '0'),
                                 (others => '0'), (others => '0'), (others => '0'),
                                 (others => '0'), (others => '0'), (others => '0'),
                                 (others => '0'));

  signal i_un1 : DEFLECTION1 := ((others => '1'), (others => '0'), (others => '0'),
                                 (others => '0'), (others => '0'));  --(to_signed(1,c_width),to_signed(2,c_width),to_signed(3,c_width),to_signed(4,c_width),to_signed(5,c_width));
  --signal FELDB : signed(12 downto 0);
  --signal FELDC : signed(12 downto 0);






begin  -- architecture rtl
  i_un0 <= un0_in;
  i_un1 <= un1_in;

  -- DATA FROM TIME: N

  i_sum_for_beta02  <= resize(i_un0(loc02), LENGTH_AFTER_SUM) + resize(i_un0(loc0M2), LENGTH_AFTER_SUM) + resize(i_un0(locM20), LENGTH_AFTER_SUM) + resize(i_un0(loc20), LENGTH_AFTER_SUM);
  i_sum_for_beta01  <= resize(i_un0(loc01), LENGTH_AFTER_SUM) + resize(i_un0(loc0M1), LENGTH_AFTER_SUM) + resize(i_un0(locM10), LENGTH_AFTER_SUM) + resize(i_un0(loc10), LENGTH_AFTER_SUM);
  i_sum_for_beta11  <= resize(i_un0(loc11), LENGTH_AFTER_SUM) + resize(i_un0(loc1M1), LENGTH_AFTER_SUM) + resize(i_un0(locM1M1), LENGTH_AFTER_SUM) + resize(i_un0(locM11), LENGTH_AFTER_SUM);
  i_sum_for_gamma01 <= resize(i_un1(loc10), LENGTH_AFTER_SUM) + resize(i_un1(locM10), LENGTH_AFTER_SUM) + resize(i_un1(loc0M1), LENGTH_AFTER_SUM) + resize(i_un1(loc01), LENGTH_AFTER_SUM);
  i_out_pre_trunc   <= resize(signed(i_mult_beta02), LENGTH_FINAL_SUM) + resize(signed(i_mult_beta01), LENGTH_FINAL_SUM) + resize(signed(i_mult_beta11), LENGTH_FINAL_SUM) +
                       resize(signed(i_mult_beta00), LENGTH_FINAL_SUM) + resize(signed(i_mult_gamma01), LENGTH_FINAL_SUM) + resize(signed(i_mult_gamma00), LENGTH_FINAL_SUM);
  i_out             <= signed(i_out_pre_trunc(Q+c_width-1 downto Q));
  -- DATA FROM TIME: N-1

  mult : process (CLK)
  begin
    if rising_edge(CLK) then
      i_mult_beta02 <= i_sum_for_beta02 * signed(coefficients_in.beta02);
      i_mult_beta01 <= i_sum_for_beta01 * signed(coefficients_in.beta01);
      i_mult_beta11 <= i_sum_for_beta11 * signed(coefficients_in.beta11);
      i_mult_beta00 <= resize(i_un0(loc00), LENGTH_AFTER_SUM) * signed(coefficients_in.beta00);
      i_mult_gamma01 <= i_sum_for_gamma01 * signed(coefficients_in.gamma01);
      i_mult_gamma00 <=  resize(i_un1(loc00), LENGTH_AFTER_SUM) * signed(coefficients_in.gamma00);
    end if;
  end process;

  un1_out <= std_logic_vector(i_out);

end architecture rtl;
