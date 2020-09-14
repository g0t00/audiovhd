library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_audiovhd.all;
library multiAdder;
library adder;

entity processingElement is
  generic (
    g_outputX : integer := 5;
    g_outputY : integer := 5;
    g_x       : integer;
    g_y       : integer
    );
  port (
    i_clk                 : in  std_logic;
    i_reset               : in  std_logic;
    i_coefficientsN       : in  t_coefficients;
    i_coefficientsNMinus1 : in  t_coefficients;
    o_outputReady         : out std_logic;
    o_output              : out std_logic_vector(c_dataWidth - 1 downto 0);
    o_currentOutput       : out std_logic_vector(c_dataWidth - 1 downto 0);
    o_currentPosition     : out t_position;
    o_currentValid        : out std_logic;
    i_borderPosition      : in  t_positionRam;
    i_borderValid         : in  std_logic;
    i_borderData          : in  std_logic_vector(c_dataWidth - 1 downto 0)
    );
end entity;

architecture arch of processingElement is
  signal r_n                    : integer range 0 to 2;
  signal r_nPlus1               : integer range 0 to 2;
  signal r_nMinus1              : integer range 0 to 2;
  constant c_ramReadDelay       : integer                                                             := 3;
  constant c_ramWriteDelay      : integer                                                             := 5;
  signal r_position             : t_position;
  signal r_positionShift        : t_positionArray(c_ramWriteDelay - 1 downto 0);
  signal s_readData             : t_slvArray(0 to 2);
  signal r_readDataN            : signed(c_dataWidth - 1 downto 0);
  signal r_readDataNminus1      : signed(c_dataWidth - 1 downto 0);
  signal s_resultN              : signed(c_dataWidth - 1 downto 0);
  signal s_resultNminus1        : signed(c_dataWidth - 1 downto 0);
  signal s_readAddr             : std_logic_vector(fu_getSize((c_innerGridSize + 4)**2) - 1 downto 0) := (others => '0');
  signal r_readAddr             : std_logic_vector(fu_getSize((c_innerGridSize + 4)**2) - 1 downto 0) := (others => '0');
  signal r_writeAddr            : std_logic_vector(fu_getSize((c_innerGridSize + 4)**2) - 1 downto 0) := (others => '0');
  signal r_writeEnable          : std_logic_vector(2 downto 0);
  signal r_readStep             : integer range 0 to 12;
  signal rr_readStep            : integer range 0 to 12;
  signal r_readStepShift        : t_integerArray(c_ramReadDelay - 1 downto 0)                         := (others => 0);
  signal r_nPlus1Shift          : t_integerArray(c_ramReadDelay - 1 downto 0);
  signal r_nPlus1ForBorder      : integer range 0 to 2;
  signal r_writeData            : std_logic_vector(c_dataWidth - 1 downto 0);
  signal s_result               : std_logic_vector(c_dataWidth - 1 downto 0);
  signal s_accumMultiN          : std_logic_vector(c_dataWidth - 1 downto 0);
  signal s_accumMultiNMinus1    : std_logic_vector(c_dataWidth - 1 downto 0);
  signal r_startDone            : std_logic;
  signal r_pointDone            : std_logic;
  constant c_registersDSP       : integer                                                             := 8;
  signal sr_readDataN           : t_signedArray(c_registersDSP - 1 downto 0);
  signal sr_readDataNMinus1     : t_signedArray(c_registersDSP - 1 downto 0);
  signal sr_coefficientsN       : t_signedArray(c_registersDSP - 1 downto 0);
  signal sr_coefficientsNMinus1 : t_signedArray(c_registersDSP - 1 downto 0);
  signal sr_positionShiftDsp    : t_positionArray(c_registersDSP - 1 downto 0);
  signal sr_nPlus1Shift         : t_integerArray(c_registersDSP - 1 downto 0);
  signal s_accumulate           : std_logic;
begin
  p_state : process(i_reset, i_clk)
  begin
    if i_reset then
      o_outputReady     <= '0';
      r_pointDone       <= '0';
      rr_readStep       <= 0;
      r_writeEnable     <= (others => '0');
      r_writeAddr       <= (others => '0');
      r_readAddr        <= (others => '0');
      r_readDataNminus1 <= (others => '0');
      r_readDataN       <= (others => '0');
      r_nMinus1         <= 0;
      r_n               <= 1;
      r_nPlus1          <= 2;
      r_nPlus1Shift     <= (others => 2);
      sr_nPlus1Shift    <= (others => 2);
      r_position.x      <= 0;
      r_position.y      <= 0;
      r_readStep        <= 0;
      r_readStepShift   <= (others => 0);
      r_positionShift   <= (others => (x => 0, y => 0));
      r_startDone       <= '0';
      o_currentValid    <= '0';
      o_currentPosition <= (x      => 0, y => 0);
      o_currentOutput   <= (others => '0');
      o_output          <= (others => '0');
    elsif rising_edge(i_clk) then
      r_readAddr        <= fu_convert(getPositionReadStep(fu_convert(r_position), r_readStep));
      r_writeAddr       <= fu_convert(fu_convert(sr_positionShiftDsp(0)));
      r_readDataN       <= signed(s_readData(r_n));
      r_readDataNMinus1 <= signed(s_readData(r_nMinus1));
      for i in 0 to r_readStepShift'length - 2 loop
        r_readStepShift(i) <= r_readStepShift(i+1);
      end loop;
      for i in 0 to r_readStepShift'length - 2 loop
        r_readStepShift(i) <= r_readStepShift(i+1);
      end loop;
      for i in 0 to r_positionShift'length - 2 loop
        r_positionShift(i) <= r_positionShift(i+1);
      end loop;
      for i in 0 to r_nPlus1Shift'length - 2 loop
        r_nPlus1Shift(i) <= r_nPlus1Shift(i+1);
      end loop;
      r_readStepShift(r_readStepShift'length - 1) <= r_readStep;
      r_positionShift(r_positionShift'length - 1) <= r_position;
      r_nPlus1Shift(r_nPlus1Shift'length - 1)     <= r_nPlus1;
      if r_readStep < 12 then
        r_readStep <= r_readStep + 1;
      else
        r_readStep  <= 0;
        r_startDone <= '1';
        if r_position.x < c_innerGridSize - 1 then
          r_position.x <= r_position.x + 1;
        else
          r_position.x <= 0;
          if r_position.y < c_innerGridSize - 1 then
            r_position.y <= r_position.y + 1;
          else
            r_position.y <= 0;
            r_nMinus1    <= r_n;
            r_n          <= r_nPlus1;
            if r_nPlus1 = 2 then
              r_nPlus1 <= 0;
            else
              r_nPlus1 <= r_nPlus1 + 1;
            end if;
          end if;
        end if;
      end if;
      sr_positionShiftDsp(sr_positionShiftDsp'length - 1) <= r_positionShift(0);
      sr_nPlus1Shift(sr_nPlus1Shift'length - 1)           <= r_nPlus1Shift(0);
      for i in 0 to c_registersDSP - 2 loop
        sr_positionShiftDsp(i) <= sr_positionShiftDsp(i + 1);
        sr_nPlus1Shift(i)      <= sr_nPlus1Shift(i + 1);
      end loop;
      -- if sr_accumulateReset(0) then     -- new loop
      --   r_accumMultiN       <= resize(shift_right(s_resultN, c_fractionLength), r_accumMultiN'length);
      --   r_accumMultiNminus1 <= resize(shift_right(s_resultNminus1, c_fractionLength), r_accumMultiNminus1'length);
      -- else
      --   r_accumMultiN       <= r_accumMultiN + resize(shift_right(s_resultN), c_fractionLength), r_accumMultiN'length);
      --   r_accumMultiNminus1 <= r_accumMultiNminus1 + resize(shift_right(s_resultNminus1), c_fractionLength), r_accumMultiNminus1'length);
      -- end if;
      -- r_writeData   <= resize(r_accumMultiN + r_accumMultiNminus1, r_writeData'length);
      r_writeEnable <= (others => '0');
      o_outputReady <= '0';
      r_pointDone   <= '0';
      if r_readStepShift(0) = c_registersDSP - 1 then
        r_writeData                      <= s_result;
        r_writeEnable(sr_nPlus1Shift(0)) <= r_startDone;
        r_nPlus1ForBorder                <= sr_nPlus1Shift(0);
        r_pointDone                      <= '1';
      end if;
      if r_pointDone = '1' and sr_positionShiftDsp(0).x = g_outputX and sr_positionShiftDsp(0).y = g_outputY then
        o_output      <= r_writeData;
        o_outputReady <= r_startDone;
      end if;
      o_currentValid <= '0';
      if r_pointDone then
        o_currentValid    <= r_startDone;
        o_currentPosition <= sr_positionShiftDsp(0);
        o_currentOutput   <= r_writeData;
      -- report "x: " & integer'image(r_positionShift(0).x) & " y: " & integer'image(r_positionShift(0).y)
      --   & " value: " & to_hex_string(r_writeData);
      end if;

      rr_readStep <= r_readStep;
      if i_borderValid then
        r_writeEnable(r_nPlus1ForBorder) <= r_startDone;
        r_writeData                      <= i_borderData;
        r_writeAddr                      <= fu_convert(i_borderPosition);
      end if;
    end if;
  end process;
  s_accumulate <= '1' when r_readStepShift(0) /= 0 else '0';
  inst_multiAdderN : entity work.multiAdderFixed
    port map (
      i_clk   => i_clk,
      i_reset => i_reset,
      o_z     => s_accumMultiN,
      i_accum => s_accumulate,
      i_x     => std_logic_vector(r_readDataN),
      i_y     => std_logic_vector(i_coefficientsN(r_readStepShift(0)))
      );
  inst_multiAdderNminus1 : entity work.multiAdderFixed
    port map (
      i_clk   => i_clk,
      i_reset => i_reset,
      o_z     => s_accumMultiNminus1,
      i_accum => s_accumulate,
      i_x     => std_logic_vector(r_readDataNMinus1),
      i_y     => std_logic_vector(i_coefficientsNMinus1(r_readStepShift(0)))
      );
  inst_adder : entity work.adderFixed
    port map (
      i_clk   => i_clk,
      i_reset => i_reset,
      o_z     => s_result,
      i_x     => s_accumMultiN,
      i_y     => s_accumMultiNminus1
      );
  -- inst_multiAdderN : entity multiAdder.multiAdder
  --   port map (
  --     clk0       => i_clk,
  --     ena        => '1',
  --     clr0       => i_reset,
  --     result     => s_accumMultiN,
  --     accumulate => s_accumulate,
  --     ay         => std_logic_vector(r_readDataN),
  --     az         => std_logic_vector(i_coefficientsN(r_readStepShift(0)))
  --     );
  -- inst_multiAdderNminus1 : entity multiAdder.multiAdder
  --   port map (
  --     clk0       => i_clk,
  --     ena        => '1',
  --     clr0       => i_reset,
  --     result     => s_accumMultiNminus1,
  --     accumulate => s_accumulate,
  --     ay         => std_logic_vector(r_readDataNMinus1),
  --     az         => std_logic_vector(i_coefficientsNMinus1(r_readStepShift(0)))
  --     );
  -- inst_adder : entity adder.adder
  --   port map (
  --     clk0   => i_clk,
  --     ena    => '1',
  --     clr0   => i_reset,
  --     result => s_result,
  --     ax     => s_accumMultiN,
  --     ay     => s_accumMultiNminus1
  --     );





  rams : for i in 0 to 2 generate
  begin
    dualPortRam_i : entity work.dualPortRam
      generic map (
        g_initalValue => fu_getInitial(g_x /= 2 or g_y /= 2),
        -- g_initalValue => fu_getInitial(true),
        g_dataWidth   => c_dataWidth,
        g_depth       => fu_getSize((c_innerGridSize + 4)**2)
        )
      port map (
        i_clk          => i_clk,
        i_writeEnableA => '0',
        i_writeDataA   => (others => '0'),
        o_readDataA    => s_readData(i),
        i_addrA        => r_readAddr,
        i_writeEnableB => r_writeEnable(i),
        i_writeDataB   => std_logic_vector(r_writeData),
        o_readDataB    => open,
        i_addrB        => r_writeAddr
        );

  end generate;

end architecture;
