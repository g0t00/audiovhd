library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;                     -- Imports the standard textio package.
use work.pkg_audiovhd.all;


entity testbench is
end entity;

architecture behaviour of testbench is
  signal s_clk         : std_logic := '0';
  signal s_reset       : std_logic;
  signal s_outputReady : std_logic;
  signal s_output      : std_logic_vector(c_dataWidth - 1 downto 0);
  signal s_finished    : std_logic := '0';
  signal s_countDown   : integer   := 100;
  signal s_counter     : integer   := 1;
begin
  s_clk   <= not s_clk after 10 ns when s_finished /= '1' else '0';
  s_reset <= '1', '0'  after 200 ns;  -- erzeugt Resetsignal: --__
  -- process
  --   variable l : line;

  -- begin
  --   wait for 100 us;
  --   s_finished <= '1';
  --   wait;
  -- end process;
  identifier : process(s_clk)
    variable l : line;
  begin
    if rising_edge(s_clk) then
      if s_outputReady then
        write (l, string'("count: " & integer'image(s_counter) & " output:  " & to_hex_string(s_output) & "dec: " & real'image(real(to_integer(signed(s_output)))/65536.0)));
        s_counter   <= s_counter + 1;
        writeline (output, l);
        s_countDown <= s_countDown - 1;
        if s_countDown = 0 then
          s_finished <= '1';
        end if;
      end if;
    end if;
  end process;
  processingElement_i : entity work.processingElement
    port map (
      i_clk                 => s_clk,
      i_reset               => s_reset,
      i_coefficientsN       => (6 => x"0000045f", 2 => x"00007ee3", 5 => x"00007ee3", 7 => x"00007ee3", 10 => x"00007ee3", others => x"00000000"),
      i_coefficientsNMinus1 => (7 => x"ffff0015", others => x"00000000"),
      o_outputReady         => s_outputReady,
      o_output              => s_output
      );

end behaviour;
