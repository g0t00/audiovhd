library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_audiovhd.all;

entity processingElement is
  port (
    i_clk                 : std_logic;
    i_reset               : std_logic;
    i_coefficientsN       : t_coefficients;
    i_coefficientsNMinus1 : t_coefficients
    );
end entity;

architecture arch of processingElement is
  signal   r_n                   : integer range 0 to 2;
  signal   r_nPlus1              : integer range 0 to 2;
  signal   r_nMinus1             : integer range 0 to 2;
  constant c_ramReadDelay        : integer                                                             := 3;
  constant c_ramWriteDelay       : integer                                                             := 5;
  signal   r_position            : t_position;
  signal   r_positionShift       : t_positionArray(c_ramWriteDelay - 1 downto 0);
  signal   S_writeEnableA        : std_logic;
  signal   s_readData            : t_slvArray(0 to 2);
  signal   r_readDataN           : signed(c_dataWidth - 1 downto 0);
  signal   r_readDataNminus1     : signed(c_dataWidth - 1 downto 0);
  signal   s_readAddr            : std_logic_vector(fu_getSize((c_innerGridSize + 4)**2) - 1 downto 0) := (others => '0');
  signal   r_readAddr            : std_logic_vector(fu_getSize((c_innerGridSize + 4)**2) - 1 downto 0) := (others => '0');
  signal   r_writeAddr           : std_logic_vector(fu_getSize((c_innerGridSize + 4)**2) - 1 downto 0) := (others => '0');
  signal   r_writeEnable         : std_logic_vector(2 downto 0);
  signal   S_writeDataB          : std_logic_vector(c_dataWidth - 1 downto 0);
  signal   S_readDataB           : std_logic_vector(c_dataWidth - 1 downto 0);
  signal   S_addrB               : std_logic_vector(fu_getSize((c_innerGridSize + 4)**2) - 1 downto 0) := (others => '0');
  signal   r_readStep            : integer range 0 to 12;
  signal   r_readStepShift       : t_integerArray(c_ramReadDelay - 1 downto 0);
  signal   s_positionRam         : t_positionRam;
  signal   s_positionRamReadStep : t_positionRam;
  signal   r_result              : signed(c_dataWidth - 1 downto 0);
  signal   r_accumMultiN         : signed(c_dataWidth - 1 downto 0);
  signal   r_accumMultiNMinus1   : signed(c_dataWidth - 1 downto 0);
  signal   r_calcDone            : std_logic;
  signal   r_startDone           : std_logic;
begin
  p_state : process(i_reset, i_clk)
  begin
    if i_reset then
      r_nMinus1       <= 0;
      r_n             <= 1;
      r_nPlus1        <= 2;
      r_position.x    <= 0;
      r_position.y    <= 0;
      r_readStep      <= 0;
      r_readStepShift <= (others => 0);
      r_positionShift <= (others => (x => 0, y => 0));
      r_calcDone      <= '0';
      r_startDone     <= '0';
    elsif rising_edge(i_clk) then
      r_readAddr        <= s_readAddr;
      r_writeAddr       <= fu_convert(fu_convert(r_positionShift(0)));
      r_readDataN       <= signed(s_readData(r_nMinus1));
      r_readDataNMinus1 <= signed(s_readData(r_n));
      for i in 0 to c_ramReadDelay - 2 loop
        r_readStepShift(i) <= r_readStepShift(i+1);
      end loop;
      for i in 0 to r_positionShift'length - 2 loop
        r_positionShift(i) <= r_positionShift(i+1);
      end loop;
      r_readStepShift(r_readStepShift'length - 1) <= r_readStep;
      r_positionShift(r_positionShift'length - 1) <= r_position;
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
      if r_readStepShift(0) = 0 then    -- new loop
        r_accumMultiN       <= resize(shift_right(r_readDataN * i_coefficientsN(0), c_dataWidth/2), r_accumMultiN'length);
        r_accumMultiNminus1 <= resize(shift_right(r_readDataN * i_coefficientsN(0), c_dataWidth/2), r_accumMultiNminus1'length);
      else
        r_accumMultiN       <= r_accumMultiN + resize(shift_right(r_readDataN * signed(i_coefficientsN(r_readStepShift(0))), c_dataWidth/2), r_accumMultiN'length);
        r_accumMultiNminus1 <= r_accumMultiNminus1 + resize(shift_right(r_readDataN * signed(i_coefficientsN(r_readStepShift(0))), c_dataWidth/2), r_accumMultiNminus1'length);
      end if;
      r_result      <= resize(r_accumMultiN + r_accumMultiNminus1, r_result'length);
      r_writeEnable <= (others => '0');
      if r_readStepShift(0) = 0 then
        r_writeEnable(r_nPlus1) <= r_startDone;
      end if;
    end if;
  end process;
  s_positionRam         <= fu_convert(r_position);
  s_positionRamReadStep <= getPositionReadStep(s_positionRam, r_readStep);
  s_readAddr            <= fu_convert(s_positionRamReadStep);
  identifier : for i in 0 to 2 generate
    dualPortRam_i : entity work.dualPortRam
      generic map (
        g_dataWidth => c_dataWidth,
        g_depth     => fu_getSize((c_innerGridSize + 4)**2)
        )
      port map (
        i_clk          => i_clk,
        i_writeEnableA => '0',
        i_writeDataA   => x"00000000",
        o_readDataA    => s_readData(i),
        i_addrA        => r_readAddr,
        i_writeEnableB => r_writeEnable(i),
        i_writeDataB   => std_logic_vector(r_result),
        o_readDataB    => open,
        i_addrB        => r_writeAddr
        );

  end generate;

end architecture;