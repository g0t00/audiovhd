------------------------------------------------------------
-- Module name: Processing grid
-- Project Name: Real-time physical modeling sound synthesis
-- Author: Group 8
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity processing_grid is
  generic(
    c_width : integer := 16;
    G_GRID  : integer := 4
    );
  port(
    clk             : in  std_ulogic;
    i_reset         : in  std_ulogic;
    i_coefficients : in  coefficients;
    o_initDone       : out  std_logic;
    i_initData       : in  full_excitation_vec;
    i_initDataReady : in  std_logic;
    o_ready       : out std_logic;
    i_wait          : in std_logic;
    i_dataAddr   : in  std_logic_vector(15 downto 0);
    o_data        : out std_logic_vector(c_width -1 downto 0)
    );
end processing_grid;


architecture Behavioral of processing_grid is


  signal s_cntInit     : integer range 0 to 2;
  signal r_cntInit : integer range 0 to 2;

  signal s_addr              : integer range 0 to G_GRID_INNER * G_GRID_INNER - 1;
  signal r_addr              : integer range 0 to G_GRID_INNER * G_GRID_INNER - 1;
  type position is (t_main, t_top, t_left, t_bottom, t_right, t_topleft, t_bottomleft, t_bottomright, t_topright, t_empty);
  type positions is array (0 to 2) of position;
  signal position_order      : positions;
  signal actual_position     : position;
  signal actual_position_reg : position;
  type grid_trig is array (G_GRID-1 downto 0, G_GRID-1 downto 0) of std_logic;

  -----------------------------------------------------------------------------
  -- processing element output signals
  -----------------------------------------------------------------------------
  signal i_out_reg             : std_logic_vector(c_width-1 downto 0);
  signal i_out                 : std_logic_vector(c_width-1 downto 0);
  -- data_out_addr
  signal i_out_x_addr          : integer ;
  signal i_out_y_addr          : integer ;
  signal i_out_addr            : integer ;
  signal i_data_out_addr       : std_logic_vector(15 downto 0);
  -- memory control signals
  signal i_sw_memory           : std_logic;
  signal i_rd_en               : std_logic;
  signal i_rd_addr             : std_logic_vector(6 downto 0);
  signal i_rd_addr_o           : std_logic_vector(6 downto 0);
  signal i_wr_en               : std_logic;
  signal i_wr_en_o             : std_logic;
  signal i_wr_addr             : std_logic_vector(6 downto 0);
  signal i_wr_addr_o           : std_logic_vector(6 downto 0);
  signal i_wr_point_position   : point_position;
  signal i_wr_point_position_0 : point_position;
  signal i_rd_data_ready_o     : std_logic;
  signal i_rd_data_ready       : std_logic;
  -- init signals
  signal s_dataIn             : grid_vec;
  signal s_dataOut            : grid_vec;
  signal i_data_out1           : grid_vec;
  signal i_ready_out : std_logic;

  -- FSM
  type STATE_FSM is (S_IDLE, S_NEXT_ADDR, S_READ, S_SW_MEMORY, S_MAIN, S_OTHERS);
  signal present_state : STATE_FSM;
  signal next_state    : STATE_FSM;
  signal i_cnt         : integer range 0 to 2;
  signal r_cnt     : integer range 0 to 2;
  signal i_clkdiv      : unsigned(1 downto 0);
  signal i_clkdiv_reg  : unsigned(1 downto 0);


begin
  GEN_X : for x in 0 to G_GRID-1 generate
    GEN_Y : for y in 0 to G_GRID-1 generate
      INST_P_E : entity work.processing_element
        port map(
          clk        => clk,
          i_reset    => i_reset,
          coefficients_in  => i_coefficients,
          sw_memory  => i_sw_memory,
          rd_en      => i_rd_en,
          rd_addr    => i_rd_addr_o,
          wr_en      => i_wr_en,
          wr_addr    => i_wr_addr_o,
          data_in    => s_dataIn(X, Y),
          data_out   => i_data_out1(X, Y)
          );
    end generate GEN_Y;
  end generate GEN_X;



  -----------------------------------------------------------------------------
  -- CONTROL FSM
  -----------------------------------------------------------------------------
  CTRL_FSM : process (all) is
  begin  -- process CTRL_FSM

    -- default values
    next_state          <= present_state;
    s_addr              <= r_addr;
    i_rd_en             <= '0';
    i_wr_en             <= '0';
    i_wr_point_position <= PP_MAIN;       --main
    i_cnt               <= 0;
    i_clkdiv            <= (others => '0');
    i_sw_memory         <= '0';
    i_ready_out           <= '0';
    actual_position     <= actual_position_reg;


    case present_state is
      when S_IDLE =>
      if i_wait = '0' then
        if o_initDone = '1' then
          next_state <= S_READ;
        elsif i_initDataReady = '1' then
          next_state <= S_MAIN;
        else
          i_ready_out <= '1';
        end if;
      end if;

      when S_NEXT_ADDR =>
        i_ready_out <= '1';
        if i_initDataReady = '1' or o_initDone = '1' then
          if r_addr = 35 then
            s_addr     <= 0;
            next_state <= S_SW_MEMORY;
          else
            s_addr <= r_addr + 1;
            if o_initDone = '1' then
              next_state <= S_READ;
            else
              next_state <= S_MAIN;
            end if;
          end if;
        end if;

      when S_READ =>
        i_rd_en <= '1';

        if i_rd_data_ready = '1' then
          next_state <= S_MAIN;
        end if;

      when S_MAIN =>

        actual_position     <= t_main;
        i_wr_point_position <= PP_MAIN;   --main
        i_wr_en             <= '1';

        if i_clkdiv_reg = 1 then
          next_state <= S_OTHERS;
          i_clkdiv   <= (others => '0');
        else
          i_clkdiv <= i_clkdiv_reg + 1;
        end if;


      when S_OTHERS =>

        if r_cnt < 2 and i_clkdiv_reg = 0 then
          i_clkdiv <= i_clkdiv_reg + 1;  --clock divider;
        elsif r_cnt = 2 then
          i_clkdiv <= i_clkdiv_reg + 1;
        else
          i_clkdiv <= (others => '0');
        end if;

        actual_position <= position_order(r_cnt);
        i_wr_en         <= '1';

        if i_clkdiv_reg = 1 and r_cnt < 2 then
          i_cnt <= r_cnt + 1;
        else
          i_cnt <= r_cnt;
        end if;

        if i_clkdiv_reg = 2 and r_cnt = 2 then
          i_wr_point_position <= PP_EXIT;  --or whatever the exit code is
          next_state          <= S_NEXT_ADDR;
        else
          i_wr_point_position <= i_wr_point_position_0;
        end if;


      when S_SW_MEMORY =>
        i_sw_memory <= '1';
        next_state  <= S_IDLE;

    end case;
  end process CTRL_FSM;

  -----------------------------------------------------------------------------
  -- init data flow
  -----------------------------------------------------------------------------

  s_dataOut <= i_initData(intToTimepoint(r_cntInit))(r_addr) when o_initDone = '0' else
                i_data_out1;

  -----------------------------------------------------------------------------
  -- interconnect the processing elements
  -- (t_main, t_top, t_left, t_bottom, t_right, t_topleft,
  -- t_bottomleft, t_bottomright, t_topright, t_empty);
  -----------------------------------------------------------------------------

  grid_communication : process (actual_position, s_dataOut) is
  begin  -- process grid_communication
    case actual_position is

      when t_main =>
        for x in 0 to G_GRID-1 loop
          for y in 0 to G_GRID-1 loop
            s_dataIn(x, y) <= s_dataOut(x, y);
          end loop;
        end loop;
        i_wr_point_position_0 <= PP_MAIN;

      when t_top =>
        for x in 0 to G_GRID-1 loop
          for y in 0 to G_GRID-1 loop
            if y + 1 <= G_GRID - 1 then
              s_dataIn(x, y) <= s_dataOut(x, y + 1);
            else
              s_dataIn(x, y) <= (others => '0');
            end if;
          end loop;
        end loop ;
        i_wr_point_position_0 <= PP_TOP;


      when t_left =>
        for x in 0 to G_GRID-1 loop
          for y in 0 to G_GRID-1 loop
            if x - 1 >= 0 then
              s_dataIn(x, y) <= s_dataOut(x - 1, y);
            else
              s_dataIn(x, y) <= (others => '0');
            end if;
          end loop;
        end loop;
        i_wr_point_position_0 <= PP_LEFT;

      when t_bottom =>
        for x in 0 to G_GRID-1 loop
          for y in 0 to G_GRID-1 loop
            if y - 1 >= 0 then
              s_dataIn(x, y) <= s_dataOut(x, y - 1);
            else
              s_dataIn(x, y) <= (others => '0');
            end if;
          end loop;
        end loop;
        i_wr_point_position_0 <= PP_BOTTOM;

      when t_right =>
        for x in 0 to G_GRID-1 loop
          for y in 0 to G_GRID-1 loop
            if x + 1 <= G_GRID - 1 then
              s_dataIn(x, y) <= s_dataOut(x + 1, y);
            else
              s_dataIn(x, y) <= (others => '0');
            end if;
          end loop;
        end loop;
        i_wr_point_position_0 <= PP_RIGHT;

      when t_topleft =>
        for x in 0 to G_GRID-1 loop
          for y in 0 to G_GRID-1 loop
            if (y + 1 <= G_GRID - 1) and (x - 1 >= 0) then
              s_dataIn(x, y) <= s_dataOut(x - 1, y + 1);
            else
              s_dataIn(x, y) <= (others => '0');
            end if;
          end loop;
        end loop;
        i_wr_point_position_0 <= PP_CORNER;

      when t_bottomleft =>
        for x in 0 to G_GRID-1 loop
          for y in 0 to G_GRID-1 loop
            if (x - 1 >= 0) and (y - 1 >= 0) then
              s_dataIn(x, y) <= s_dataOut(x - 1, y - 1);
            else
              s_dataIn(x, y) <= (others => '0');
            end if;
          end loop;
        end loop;
        i_wr_point_position_0 <= PP_CORNER;

      when t_bottomright =>
        L1_bottomright : for x in 0 to G_GRID-1 loop
          L2_bottomright : for y in 0 to G_GRID-1 loop
            if (x + 1 <= G_GRID - 1) and (y - 1 >= 0) then
              s_dataIn(x, y) <= s_dataOut(x + 1, y - 1);
            else
              s_dataIn(x, y) <= (others => '0');
            end if;
          end loop L2_bottomright;
        end loop L1_bottomright;
        i_wr_point_position_0 <= PP_CORNER;

      when t_topright =>
        for x in 0 to G_GRID-1 loop
          for y in 0 to G_GRID-1 loop
            if (y + 1 <= G_GRID - 1) and (x + 1 <= G_GRID - 1) then
              s_dataIn(x, y) <= s_dataOut(x + 1, y + 1);
            else
              s_dataIn(x, y) <= (others => '0');
            end if;
          end loop;
        end loop;
        i_wr_point_position_0 <= PP_CORNER;

      when t_empty =>
        for x in 0 to G_GRID-1 loop
          for y in 0 to G_GRID-1 loop
            s_dataIn(x, y) <= (others => '0');
          end loop;
        end loop;
        i_wr_point_position_0 <= PP_EXIT;


    end case;

  end process grid_communication;



  -----------------------------------------------------------------------------
  -- define write order depending on the given address
  -- except the write operation for the main block, that is anyways
  -----------------------------------------------------------------------------

  write_order : process (r_addr) is
  begin  -- process write_order
    case r_addr is
      when 0 =>
        position_order <= (t_bottom, t_bottomright, t_right);

      when 5 =>
        position_order <= (t_left, t_bottomleft, t_bottom);

      when 30 =>
        position_order <= (t_right, t_topright, t_top);

      when 35 =>
        position_order <= (t_top, t_topleft, t_left);

      when 1 | 6 | 7 =>
        position_order <= (t_bottom, t_right, t_empty);

      when 4 | 10 | 11 =>
        position_order <= (t_left, t_bottom, t_empty);

      when 28 | 29 | 34 =>
        position_order <= (t_top, t_left, t_empty);

      when 24 | 25 | 31 =>
        position_order <= (t_top, t_right, t_empty);

      when 2 | 3 | 8 | 9 =>
        position_order <= (t_bottom, t_empty, t_empty);

      when 12 | 13 | 18 | 19 =>
        position_order <= (t_right, t_empty, t_empty);

      when 16 | 17 | 22 | 23 =>
        position_order <= (t_left, t_empty, t_empty);

      when 26 | 27 | 32 | 33 =>
        position_order <= (t_top, t_empty, t_empty);

      when others =>
        position_order <= (t_empty, t_empty, t_empty);
    end case;
  end process write_order;


  -----------------------------------------------------------------------------
  -- data_out_address and data
  -----------------------------------------------------------------------------

  i_data_out_addr <= i_dataAddr;
  i_out_x_addr    <= to_integer(unsigned(i_data_out_addr(7 downto 4)));
  i_out_y_addr    <= to_integer(unsigned(i_data_out_addr(3 downto 0)));
  i_out_addr      <= to_integer(unsigned(i_data_out_addr(15 downto 8)));
  o_ready <=
  '1' when i_ready_out = '1' and r_addr = i_out_addr else
  '0';

  i_out <=
    s_dataOut(i_out_x_addr, i_out_y_addr) when r_addr = i_out_addr and i_ready_out = '1' else
    i_out_reg;

  -----------------------------------------------------------------------------
  -- signal connections
  -----------------------------------------------------------------------------

  o_initDone <=
   '1' when s_cntInit > 1 else
   '0';

  i_wr_addr       <= std_logic_vector(to_unsigned(r_addr, i_wr_addr'length));
  i_rd_addr       <= std_logic_vector(to_unsigned(r_addr, i_rd_addr'length));
  i_rd_data_ready <= i_rd_data_ready_o;
  o_data        <= i_out_reg;

  s_cntInit <=
    r_cntInit + 1 when s_addr = 0 and r_addr = 35 and r_cntInit < 2 else
    r_cntInit;

  -----------------------------------------------------------------------------
  -- purpose: register process
  -----------------------------------------------------------------------------

  process (clk, i_reset) is
  begin  -- process
    if i_reset then               -- asynchronous reset (active low)
      present_state       <= S_IDLE;
      r_addr          <= 0;
      r_cnt           <= 0;
      i_clkdiv_reg        <= (others => '0');
      i_out_reg           <= (others => '0');
      actual_position_reg <= t_main;
      r_cntInit      <= 0;
    elsif rising_edge(clk) then  -- rising clock edge
      present_state       <= next_state;
      r_addr          <= s_addr;
      r_cnt           <= i_cnt;
      i_clkdiv_reg        <= i_clkdiv;
      i_out_reg           <= i_out;
      actual_position_reg <= actual_position;
      r_cntInit      <= s_cntInit;
    end if;
  end process;


end Behavioral;
