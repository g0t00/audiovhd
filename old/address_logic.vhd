------------------------------------------------------------
-- Module name: Address logic
-- Project Name: Real-time physical modeling sound synthesis
-- Author: Group 8
------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity address_logic is
  port(
    clk                 : in  std_logic;
    n_reset             : in  std_logic;
    rd_addr_i           : in  std_logic_vector(6 downto 0);
    wr_en_i             : in  std_logic;
    rd_en_i             : in  std_logic;
    wr_addr_i           : in  std_logic_vector(6 downto 0);
    wr_point_position_i : in point_position;
    wr_en_o             : out std_logic_vector(0 downto 0);
    wr_addr_o           : out std_logic_vector(6 downto 0);
    rd_addr_o           : out std_logic_vector(6 downto 0);
    rd_data_ready_o     : out std_logic
    );
end entity address_logic;

architecture Behavioral of address_logic is

  type STATE_TYPE_RD is (s_wait1, s_wait2, s_wait3, s_0, s_1, s_2, s_3, s_4, s_5, s_6, s_7, s_8, s_9, s_10, s_11, s_12);
  type STATE_TYPE_WR is (s_check_position, s_wr_main, s_wr_top, s_wr_bottom, s_wr_left, s_wr_right, s_wr_corner);
  signal i_rd_data_ready  : std_logic;
  signal i_wr_en          : std_logic_vector(0 downto 0);
  signal i_wr_addr        : unsigned(6 downto 0);
  signal i_rd_addr        : unsigned(6 downto 0);
  signal i_rd_addr0        : unsigned(6 downto 0);
  signal int_rd_addr      : unsigned(6 downto 0);
  signal int_rd_addr1     : unsigned(6 downto 0);
  signal int_rd_addr1_reg : unsigned(6 downto 0);
  signal int_wr_addr      : unsigned(6 downto 0);
  signal int_wr_addr_main : unsigned(6 downto 0);
  signal current_state_rd : STATE_TYPE_RD;
  signal next_state_rd    : STATE_TYPE_RD;
  signal current_state_wr : STATE_TYPE_WR;
  signal next_state_wr    : STATE_TYPE_WR;

begin

  -- connect input
  i_rd_addr <= unsigned(rd_addr_i);
  i_rd_addr0 <= unsigned(rd_addr_i);
  i_wr_addr <= unsigned(wr_addr_i);

  -- register process
  p1 : process (clk, n_reset) is
  begin  -- process p1
    if n_reset = '0' then               -- asynchronous reset (active low)
      current_state_rd <= s_wait1;
      current_state_wr <= s_check_position;
      int_rd_addr1_reg <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      current_state_rd <= next_state_rd;
      current_state_wr <= next_state_wr;
      int_rd_addr1_reg <= int_rd_addr1;
    end if;
  end process p1;

  ----------
  -- READ --
  ----------

  -- internal read address
  int_rd_addr <=
    i_rd_addr0+22 when to_integer(i_rd_addr) < 6 else
    i_rd_addr0+26 when to_integer(i_rd_addr) > 5 and to_integer(i_rd_addr) < 12 else
    i_rd_addr0+30 when to_integer(i_rd_addr) > 11 and to_integer(i_rd_addr) < 18 else
    i_rd_addr0+34 when to_integer(i_rd_addr) > 17 and to_integer(i_rd_addr) < 24 else
    i_rd_addr0+38 when to_integer(i_rd_addr) > 23 and to_integer(i_rd_addr) < 30 else
    i_rd_addr0+42;

  -- read state machine process
  p2 : process(current_state_rd, int_rd_addr, int_rd_addr1_reg, rd_en_i)
  begin

    -- default values
    i_rd_data_ready <= '0';
    int_rd_addr1    <= int_rd_addr1_reg;
    next_state_rd   <= current_state_rd;

    case current_state_rd is

      when s_wait1 =>

        if rd_en_i = '1' then
          next_state_rd <= s_wait2;
          int_rd_addr1  <= int_rd_addr-20; --loc02
        else
          next_state_rd <= s_wait1;
        end if;
      when s_wait2 =>
        int_rd_addr1  <= int_rd_addr-11; --locM11
        next_state_rd <= s_wait3;
      when s_wait3 =>
        int_rd_addr1  <= int_rd_addr-10; --loc01
        next_state_rd <= s_0;
      when s_0 =>
        int_rd_addr1  <= int_rd_addr-9; --loc11
        next_state_rd <= s_1;
      when s_1 =>
        int_rd_addr1  <= int_rd_addr-2; --locM20
        next_state_rd <= s_2;
      when s_2 =>
        int_rd_addr1  <= int_rd_addr-1; --locM10
        next_state_rd <= s_3;
      when s_3 =>
        int_rd_addr1  <= int_rd_addr; --loc00
        next_state_rd <= s_4;
      when s_4 =>
        int_rd_addr1  <= int_rd_addr+1; --loc10
        next_state_rd <= s_5;
      when s_5 =>
        int_rd_addr1  <= int_rd_addr+2; --loc20
        next_state_rd <= s_6;
      when s_6 =>
        int_rd_addr1  <= int_rd_addr+9; --locM1M1
        next_state_rd <= s_7;
      when s_7 =>
        int_rd_addr1  <= int_rd_addr+10; --loc0M1
        next_state_rd <= s_8;
      when s_8 =>
        int_rd_addr1  <= int_rd_addr+11; --loc1M1
        next_state_rd <= s_9;
      when s_9 =>
        int_rd_addr1  <= int_rd_addr+20; --loc0M2
        next_state_rd <= s_10;
      when s_10 =>
        next_state_rd <= s_11;
      when s_11 =>
        next_state_rd <= s_12;
      when s_12 =>
        i_rd_data_ready <= '1';
        next_state_rd   <= s_wait1;
    end case;
  end process p2;

  -- rd data ready
  rd_data_ready_o <= i_rd_data_ready;

  -----------
  -- WRITE --
  -----------

  -- address calculation
  int_wr_addr_main <=
    i_wr_addr+22 when to_integer(i_wr_addr) < 6 else
    i_wr_addr+26 when to_integer(i_wr_addr) > 5 and to_integer(i_wr_addr) < 12 else
    i_wr_addr+30 when to_integer(i_wr_addr) > 11 and to_integer(i_wr_addr) < 18 else
    i_wr_addr+34 when to_integer(i_wr_addr) > 17 and to_integer(i_wr_addr) < 24 else
    i_wr_addr+38 when to_integer(i_wr_addr) > 23 and to_integer(i_wr_addr) < 30 else
    i_wr_addr+42;

  -- write state machine process
  p3 : process(current_state_wr, int_wr_addr_main, wr_en_i, wr_point_position_i)
  begin

    -- default
    int_wr_addr   <= (others => '0');
    i_wr_en       <= "0";
    next_state_wr <= s_check_position;

    case current_state_wr is

      -- S_CHECK_POSIITON
      when s_check_position =>
        if wr_point_position_i = PP_TOP then --"000"
          next_state_wr <= s_wr_top;
        elsif wr_point_position_i = PP_BOTTOM then --"001"
          next_state_wr <= s_wr_bottom;
        elsif wr_point_position_i = PP_LEFT then -- 010
          next_state_wr <= s_wr_left;
        elsif wr_point_position_i = PP_RIGHT then -- "011"
          next_state_wr <= s_wr_right;
        elsif wr_point_position_i = PP_MAIN then -- 100
          next_state_wr <= s_wr_main;
        elsif wr_point_position_i = PP_CORNER then -- "101"
          next_state_wr <= s_wr_corner;
        else
          next_state_wr <= s_check_position;
        end if;

        if wr_en_i = '0' then
          next_state_wr <= s_check_position;
        end if;

      -- S_WR_MAIN
      when s_wr_main =>
        i_wr_en     <= "1";
        int_wr_addr <= int_wr_addr_main;

      -- S_WR_TOP
      when s_wr_top =>
        i_wr_en     <= "1";
        int_wr_addr <= int_wr_addr_main-60;

      -- S_WR_BOTTOM
      when s_wr_bottom =>
        i_wr_en     <= "1";
        int_wr_addr <= int_wr_addr_main+60;

      -- S_WR_CORNER
      when s_wr_corner =>
        i_wr_en <= "1";
        if to_integer(int_wr_addr_main) = 22 then     -- topleft
          int_wr_addr <= to_unsigned(88, int_wr_addr'length);
        elsif to_integer(int_wr_addr_main) = 27 then  -- topright
          int_wr_addr <= to_unsigned(81, int_wr_addr'length);
        elsif to_integer(int_wr_addr_main) = 72 then  -- bottomleft
          int_wr_addr <= to_unsigned(18, int_wr_addr'length);
        elsif to_integer(int_wr_addr_main) = 77 then  -- bottomright
          int_wr_addr <= to_unsigned(11, int_wr_addr'length);
        end if;

      -- S_WR_LEFT
      when s_wr_left =>
        i_wr_en     <= "1";
        int_wr_addr <= int_wr_addr_main-6;

      -- S_WR_RIGHT
      when s_wr_right =>
        i_wr_en     <= "1";
        int_wr_addr <= int_wr_addr_main+6;

    end case;
  end process p3;

  -- connect output
  rd_addr_o <= std_logic_vector(int_rd_addr1);
  wr_addr_o <= std_logic_vector(int_wr_addr);
  wr_en_o   <= i_wr_en;

end Behavioral;
