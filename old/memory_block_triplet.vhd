------------------------------------------------------------
-- Module name: Memory Block Triplet
-- Project Name: Real-time physical modeling sound synthesis
-- Author: Group 8
------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.types.all;

entity memory_block_triplet is
  generic(
    c_width : integer
    );
  port(
    -- clk and reset
    clk       : in  std_logic;
    i_reset   : in  std_logic;
    -- rotate memory
    sw_memory : in  std_logic;
    rd_en     : in  std_logic;
    rd_addr   : in  std_logic_vector(6 downto 0);
    -- wr_din            : in  std_logic_vector(15 downto 0); IS NOW i0_0
    wr_en     : in  std_logic;
    wr_addr   : in  std_logic_vector(6 downto 0);
    -- output time step N (port B output)
    u      :    out DEFLECTION0;
    -- output time step N-1 (port B output)
    u_n_1      : out DEFLECTION1;
    -- input time step N + 1
    i0_0      : in  std_logic_vector(c_width-1 downto 0)
    );
end memory_block_triplet;

architecture RTL of memory_block_triplet is




  -----------------------------------------------------------------------------
  -- SIGNALS
  -----------------------------------------------------------------------------

  -- array types for MEMORY
  type MEM_VEC is array (2 downto 0) of std_logic_vector(c_width-1 downto 0);
  type DEFLECTION_VEC is array (2 downto 0) of DEFLECTION0;
  type MEM_ADDR is array (2 downto 0) of std_logic_vector(6 downto 0);
  type MEM_TRIG_WR is array (2 downto 0) of std_logic;
  type MEM_TRIG_RD is array (2 downto 0) of std_logic;
  -- Signals for 3 Block RAMs
  signal i_rd_en       : MEM_TRIG_RD;
  signal i_rd_en_reg   : MEM_TRIG_RD;
  signal i_rd_addr     : MEM_ADDR;
  signal i_rd_addr_reg : MEM_ADDR;
  signal i_wr_din      : MEM_VEC;
  signal i_wr_din_reg  : MEM_VEC;
  signal i_wr_en       : MEM_TRIG_WR;
  signal i_wr_en_reg   : MEM_TRIG_WR;
  signal i_wr_addr     : MEM_ADDR;
  signal i_wr_addr_reg : MEM_ADDR;
  -- output time step n-1 (port B output)
  signal i_u           : DEFLECTION_VEC;
  -- output registers
  signal s_u           : DEFLECTION0; --was: s_o0_0
  -- output time step N-1 (port B output)
  signal s_u_n_1       : DEFLECTION1; --was: s_o1_0
  --
  signal s_u_reg       : DEFLECTION0; --was o0_1_reg
  -- output time step N-1 (port B output)
  signal s_u_n_1_reg : DEFLECTION1; --was o1_0_reg
  -- FSM signals
  type STATE_SEL_FSM is (S_MEM0, S_MEM1, S_MEM2);
  signal state_sel_reg : STATE_SEL_FSM;
  signal state_sel     : STATE_SEL_FSM;
  signal sw_memory_reg  : std_logic;

begin

  GEN : for I in 2 downto 0 generate
    INST_memory_block : entity work.memory_block_top_level
      generic map(
        c_width => c_width
        )
      port map(
        -- clk and reset
        clk       => clk,
        i_reset   => i_reset,
        -- read (port B)
        rd_en_i   => i_rd_en(I),
        rd_addr_i => i_rd_addr(I),
        -- write (portA)
        wr_data_i => i_wr_din(I),
        wr_en_i   => i_wr_en(I),
        wr_addr_i => i_wr_addr(I),
        -- output time step n-1 (port B output)
        u      => i_u(I)
        );
  end generate GEN;

  -----------------------------------------------------------------------------
  -- S_MEM | mem(2) | mem(1) | mem(0)
  ---------------------------------------------------------------------------
  --    0  | N+1    | N      | N-1
  --    1  | N-1    | N+1    | N
  --    2  | N      | N-1    | N+1
  -----------------------------------------------------------------------------
  ---- Anton: ICh glaube oben das ist falsch.
  -----------------------------------------------------------------------------
  -- S_MEM | mem(2) | mem(1) | mem(0)
  ---------------------------------------------------------------------------
  --    0  | N+1     | N      | N-1
  --    1  | N       | N-1    | N + 1
  --    2  | N - 1   | N+1    | N
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  mem_fsm : process (i0_0, i_u(0), i_u(1), i_u(2), i_rd_addr_reg,
                     i_rd_en_reg, i_wr_addr_reg, i_wr_din_reg, i_wr_en_reg,
                     s_u_reg, s_u_n_1_reg, rd_addr, rd_en,
                     state_sel_reg, sw_memory, wr_addr, wr_en, sw_memory_reg) is
  begin  -- process mem_fsm

    -- default
    state_sel <= state_sel_reg;
    i_rd_addr <= i_rd_addr_reg;
    i_rd_en   <= i_rd_en_reg;
    i_wr_addr <= i_wr_addr_reg;
    i_wr_din  <= i_wr_din_reg;
    i_wr_en   <= i_wr_en_reg;
    -- output data
    s_u       <= s_u_reg;
    s_u_n_1   <= s_u_n_1_reg;

    case state_sel_reg is

      when S_MEM0 =>

        --N+1 <=> mem(2)
        i_wr_din(2)  <= i0_0;
        i_wr_en(2)   <= wr_en;
        i_wr_addr(2) <= wr_addr;
        i_rd_en(2)   <= '0';
        -- leave outputs and ready ready flag open

        --N   <=> mem(1)
        s_u       <= i_u(1);
        i_wr_en(1)   <= '0';
        i_rd_en(1)   <= rd_en;
        i_rd_addr(1) <= rd_addr;

        --N-1 <=> mem(0)
        s_u_n_1       <= deflection0ToDeflection1(i_u(0));
        i_wr_en(0)   <= '0';
        i_rd_en(0)   <= rd_en;
        i_rd_addr(0) <= rd_addr;

        if sw_memory = '1' and sw_memory_reg = '0' then
          state_sel <= S_MEM1;
        end if;

      when S_MEM1 =>

        --N+1 <=> mem(0)
        i_wr_din(0)  <= i0_0;
        i_wr_en(0)   <= wr_en;
        i_wr_addr(0) <= wr_addr;
        i_rd_en(0)   <= '0';
        -- leave outputs and ready ready flag open

        --N   <=> mem(2)
        s_u       <= i_u(2);
        i_wr_en(2)   <= '0';
        i_rd_en(2)   <= rd_en;
        i_rd_addr(2) <= rd_addr;

        --N-1 <=> mem(1)
        s_u_n_1       <= deflection0ToDeflection1(i_u(1));
        i_wr_en(1)   <= '0';
        i_rd_en(1)   <= rd_en;
        i_rd_addr(1) <= rd_addr;

        if sw_memory = '1' and sw_memory_reg = '0' then
          state_sel <= S_MEM2;
        end if;

      when S_MEM2 =>
        --N+1 <=> mem(1)
        i_wr_din(1)  <= i0_0;
        i_wr_en(1)   <= wr_en;
        i_wr_addr(1) <= wr_addr;
        i_rd_en(1)   <= '0';
        -- leave outputs and ready ready flag open

        --N   <=> mem(0)
        s_u       <= i_u(0);
        i_wr_en(0)   <= '0';
        i_rd_en(0)   <= rd_en;
        i_rd_addr(0) <= rd_addr;

        --N-1 <=> mem(2)
        s_u_n_1       <= deflection0ToDeflection1(i_u(2));
        i_wr_en(2)   <= '0';
        i_rd_en(2)   <= rd_en;
        i_rd_addr(2) <= rd_addr;

        if sw_memory = '1' and sw_memory_reg = '0' then
          state_sel <= S_MEM0;
        end if;

      when others => null;
    end case;
  end process mem_fsm;



  --REG PROCESS
  register_process : process (clk, i_reset) is
  begin  -- process register_process
    if i_reset then               -- asynchronous reset (active low)
      state_sel_reg      <= S_MEM0;
      i_rd_addr_reg <= ((others => '0'), (others => '0'), (others => '0'));
      i_rd_en_reg   <= ('0', '0', '0');
      i_wr_addr_reg <= ((others => '0'), (others => '0'), (others => '0'));
      i_wr_din_reg  <= ((others => '0'), (others => '0'), (others => '0'));
      i_wr_en_reg   <= (others => '0');
      s_u_reg       <= (others => (others => '0'));
      s_u_n_1_reg   <= (others => (others => '0'));
      sw_memory_reg <= '0';
    elsif clk'event and clk ='1' then  -- rising clock edge
      state_sel_reg <= state_sel;
      i_rd_addr_reg <= i_rd_addr;
      i_rd_en_reg   <= i_rd_en;
      i_wr_addr_reg <= i_wr_addr;
      i_wr_din_reg  <= i_wr_din;
      i_wr_en_reg   <= i_wr_en;
      s_u_reg       <= s_u;
      s_u_n_1_reg   <= s_u_n_1;
      sw_memory_reg <= sw_memory;
    end if;
  end process register_process;

  -- output

  u  <= s_u;
  --
  u_n_1  <= s_u_n_1;


end RTL;
