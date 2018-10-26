library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;                     -- Imports the standard textio package.


entity testbench is
end entity;

architecture behaviour of testbench is
  signal s_clk      : std_logic := '0';
  signal s_reset    : std_logic;
  signal s_finished : std_logic := '0';
begin
  s_clk   <= not s_clk after 10 ns when s_finished /= '1' else '0';
  s_reset <= '1', '0'  after 200 ns;  -- erzeugt Resetsignal: --__
  process
    variable l : line;

  begin
    wait for 50 us;
    s_finished <= '1';
    wait;
  end process;
  -- identifier : process(s_clk)
  --   variable l          : line;
  -- begin
  --   if rising_edge(s_clk) then
  --     -- if s_ready then
  --     --   write (l, string'("ready:  " &std_logic'image(s_ready) & to_hex_string(s_data)));
  --     --   writeline (output, l);
  --     -- end if;
  --   end if;
  -- end process;
  processingElement_i : entity work.processingElement
    port map (
      i_clk                 => s_clk,
      i_reset               => s_reset,
      i_coefficientsN       => (6 => x"00008000", others => x"00000000"),
      i_coefficientsNMinus1 => (6 => x"00008000", others => x"00000000")
      );

end behaviour;
