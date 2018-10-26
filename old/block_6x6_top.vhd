------------------------------------------------------------
-- Module name: Single block memory top level
-- Project Name: Real-time physical modeling sound synthesis
-- Author: Group 8
------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity memory_block_top_level is
  generic(
    c_width : integer
    );
  port(
    -- clk and reset
    clk       : in  std_logic;
    i_reset   : in  std_logic;
    -- read (port B)
    rd_en_i   : in  std_logic;
    rd_addr_i : in  std_logic_vector(6 downto 0);
    -- write (portA)
    wr_data_i : in  std_logic_vector(c_width-1 downto 0);
    wr_en_i   : in  std_logic;
    wr_addr_i : in  std_logic_vector(6 downto 0);
    -- output time step n-1 (port B output)
    u         : out DEFLECTION0
    );
end entity memory_block_top_level;

architecture Behavioral of memory_block_top_level is


  signal i_dout     : std_logic_vector(c_width-1 downto 0);
  signal i_dout_reg : std_logic_vector(c_width-1 downto 0);
  type STATE_TYPE_RD is (s_wait1, s_wait2, s_wait3, s_0, s_1, s_2, s_3, s_4, s_5, s_6, s_7, s_8, s_9, s_10, s_11, s_12);
  signal state_reg  : STATE_TYPE_RD;
  signal state   : STATE_TYPE_RD;
  signal i_u     : DEFLECTION0;
  signal i_u_reg : DEFLECTION0;

begin

  -- output read state machine process
  p1 : process(state_reg, i_dout_reg, i_u_reg, rd_en_i)
  begin

    i_u  <= i_u_reg;
    state <= state_reg;

    case state_reg is

      when s_wait1 =>
        if rd_en_i = '1' then
          state <= s_wait2;
        else
          state <= s_wait1;
        end if;

      when s_wait2 =>
        state <= s_wait3;

      when s_wait3 =>
        state <= s_0;
      when s_0  =>
        i_u(loc02) <= signed(i_dout_reg);
        state      <= s_1;

      when s_1  =>
        i_u(locM11)       <= signed(i_dout_reg);
        state      <= s_2;

      when s_2  =>
        i_u(loc01)       <= signed(i_dout_reg);
        state      <= s_3;

      when s_3  =>
        i_u(loc11)       <= signed(i_dout_reg);
        state      <= s_4;

      when s_4  =>
        i_u(locM20)       <= signed(i_dout_reg);
        state      <= s_5;

      when s_5  =>
        i_u(locM10)  <= signed(i_dout_reg);
        state <= s_6;

      when s_6  =>
        i_u(loc00)  <= signed(i_dout_reg);
        state <= s_7;

      when s_7  =>
        i_u(loc10)  <= signed(i_dout_reg);
        state <= s_8;

      when s_8  =>
        i_u(loc20)  <= signed(i_dout_reg);
        state <= s_9;

      when s_9  =>
        i_u(locM1M1)  <= signed(i_dout_reg);
        state <= s_10;

      when s_10 =>
        i_u(loc0M1) <= signed(i_dout_reg);
        state <= s_11;

      when s_11 =>
        i_u(loc1M1) <= signed(i_dout_reg);
        state <= s_12;

      when s_12 =>
        i_u(loc0M2) <= signed(i_dout_reg);
        state <= s_wait1;

    end case;
  end process p1;

  -- register process
  p2 : process (clk, i_reset) is
  begin  -- process p1
    if i_reset then               -- asynchronous reset (active low)
      i_dout_reg <= (others => '0');
      state_reg  <= s_wait1;
      i_u_reg   <= (others => (others => '0'));
    elsif clk'event and clk = '1' then  -- rising clock edge
      i_dout_reg <= i_dout;
      state_reg  <= state;
      i_u_reg   <= i_u;
    end if;
  end process p2;

  -- Single block RAM instantation
      inst_dualPortRam: entity work.dualPortRam
      port map(   i_clk => clk,
              i_writeEnable => wr_en_i,
              i_writeData => wr_data_i,
              i_writeAddr => wr_addr_i,
              i_readAddr => rd_addr_i,
              i_readEnable => rd_en_i,
              o_readData => i_dout
          );
  -- connect outputs
  u  <= i_u;

end Behavioral;
