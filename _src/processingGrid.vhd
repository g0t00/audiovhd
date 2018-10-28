library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.pkg_audiovhd.all;

entity processingGrid is
  generic (
    g_outputX : integer := 5;
    g_outputY : integer := 5
    );
  port (
  i_clk                 : in  std_logic;
  i_reset               : in  std_logic;
  i_coefficientsN       : in  t_coefficients;
  i_coefficientsNMinus1 : in  t_coefficients;
  o_outputReady         : out std_logic;
  o_output              : out std_logic_vector(c_dataWidth - 1 downto 0)
  );
end entity;

architecture arch of processingGrid is
  type t_move is (s_copyLeft, s_copyRight, s_copyUp, s_copyDown, s_copyDownLeft, s_copyDownRight, s_copyUpLeft, s_copyUpRight, s_copyNone);
  type     t_moves is array (integer range <>) of t_move;
  signal r_moves : t_moves(0 to 3);
  signal s_currentOutput       :  t_signed2DArray(0 to c_outerGridSize - 1, 0 to c_outerGridSize - 1);
  signal s_currentPosition     :  t_position2DArray(0 to c_outerGridSize - 1, 0 to c_outerGridSize - 1);
  signal s_currentValid        :  t_sl2DArray(0 to c_outerGridSize - 1, 0 to c_outerGridSize - 1);
  signal s_currentValid00        :  std_logic;
  signal r_borderPosition        :  t_positionRam2DArray(0 to c_outerGridSize - 1, 0 to c_outerGridSize - 1);
  signal r_borderValid        :  t_sl2DArray(0 to c_outerGridSize - 1, 0 to c_outerGridSize - 1);
  signal r_borderData       :  t_signed2DArray(0 to c_outerGridSize - 1, 0 to c_outerGridSize - 1);
begin
  gen_outer : for x in 0 to c_outerGridSize - 1 generate
begin
    gen_inner : for y in 0 to c_outerGridSize - 1 generate
      begin
      processingElement_i : entity work.processingElement
      generic map (
        g_x => x,
        g_y => y,
        g_outputX => g_outputX,
        g_outputY => g_outputY
      )
      port map (
        i_clk                 => i_clk,
        i_reset               => i_reset,
        i_coefficientsN       => i_coefficientsN,
        i_coefficientsNMinus1 => i_coefficientsNMinus1,
        o_outputReady         => o_outputReady,
        o_output              => o_output,
        o_currentOutput       => s_currentOutput(x, y),
        o_currentPosition     => s_currentPosition(x, y),
        o_currentValid        => s_currentValid(x, y),
        i_borderPosition      => r_borderPosition(x, y),
        i_borderValid         => r_borderValid(x, y),
        i_borderData         => r_borderData(x, y)
      );
    end generate;
  end generate;
  glue_logic : process(i_reset, i_clk)
  variable v_temp : t_positionRam;
  begin
    if i_reset then
      r_moves <= (others => s_copyNone);
      r_borderValid <= (others => (others => '0'));
      r_borderData <= (others => (others => (others => '0')));
    elsif rising_edge(i_clk) then
      r_borderValid <= (others => (others => '0'));
      if s_currentValid(0, 0) then
        r_moves <= (others => s_copyNone);
        if s_currentPosition(0, 0).y < 2 then
          r_moves(0) <= s_copyDown;
        elsif s_currentPosition(0, 0).y > c_innerGridSize - 2 then
          r_moves(0) <= s_copyUp;
        end if;
        if s_currentPosition(0, 0).x < 2 then
          r_moves(1) <= s_copyLeft;
        elsif s_currentPosition(0, 0).x > c_innerGridSize - 2 then
          r_moves(1) <= s_copyRight;
        end if;
        if s_currentPosition(0, 0).x < 2 and s_currentPosition(0, 0).y < 2 then
          r_moves(2) <= s_copyDownLeft;
        elsif s_currentPosition(0, 0).x > c_innerGridSize - 2 and s_currentPosition(0, 0).y < 2 then
          r_moves(2) <= s_copyDownRight;
        elsif s_currentPosition(0, 0).x < 2 and  s_currentPosition(0, 0).y > c_innerGridSize - 2 then
          r_moves(2) <= s_copyUpLeft;
        elsif s_currentPosition(0, 0).x > c_innerGridSize - 2 and s_currentPosition(0, 0).y > c_innerGridSize - 2 then
          r_moves(2) <= s_copyUpRight;
        end if;
      else
        r_moves(0) <= r_moves(1);
        r_moves(1) <= r_moves(2);
        r_moves(2) <= r_moves(3);
      end if;
      case r_moves(0) is
        when s_copyLeft =>
          for x in 0 to c_outerGridSize - 2 loop
            for y in 0 to c_outerGridSize - 1 loop
              r_borderValid(x, y) <= '1';
              r_borderData(x, y) <= s_currentOutput(x + 1, y);
              v_temp := fu_convert(s_currentPosition(0, 0));
              r_borderPosition(x, y) <= v_temp + (x => c_innerGridSize, y => 0);
            end loop;
          end loop;
        when s_copyRight =>
          for x in 1 to c_outerGridSize - 1 loop
            for y in 0 to c_outerGridSize - 1 loop
              r_borderValid(x, y) <= '1';
              r_borderData(x, y) <= s_currentOutput(x - 1, y);
              v_temp := fu_convert(s_currentPosition(0, 0));
              r_borderPosition(x, y) <= v_temp + (x => - 1 * c_innerGridSize, y => 0);
            end loop;
          end loop;
        when s_copyDown =>
          for x in 0 to c_outerGridSize - 1 loop
            for y in 0 to c_outerGridSize - 2 loop
              r_borderValid(x, y) <= '1';
              r_borderData(x, y) <= s_currentOutput(x, y + 1);
              v_temp := fu_convert(s_currentPosition(0, 0));
              r_borderPosition(x, y) <= v_temp + (x => 0, y => c_innerGridSize);
            end loop;
          end loop;
        when s_copyUp =>
          for x in 0 to c_outerGridSize - 1 loop
            for y in 1 to c_outerGridSize - 1 loop
              r_borderValid(x, y) <= '1';
              r_borderData(x, y) <= s_currentOutput(x, y - 1);
              v_temp := fu_convert(s_currentPosition(0, 0));
              r_borderPosition(x, y) <= v_temp + (x => 0, y => -1 * c_innerGridSize);
            end loop;
          end loop;
        when s_copyDownLeft =>
          for x in 0 to c_outerGridSize - 2 loop
            for y in 0 to c_outerGridSize - 2 loop
              r_borderValid(x, y) <= '1';
              r_borderData(x, y) <= s_currentOutput(x + 1, y + 1);
              v_temp := fu_convert(s_currentPosition(0, 0));
              r_borderPosition(x, y) <= v_temp + (x => c_innerGridSize, y => c_innerGridSize);
            end loop;
          end loop;
        when s_copyDownRight =>
          for x in 1 to c_outerGridSize - 1 loop
            for y in 0 to c_outerGridSize - 2 loop
              r_borderValid(x, y) <= '1';
              r_borderData(x, y) <= s_currentOutput(x - 1, y + 1);
              v_temp := fu_convert(s_currentPosition(0, 0));
              r_borderPosition(x, y) <= v_temp + (x => - 1 * c_innerGridSize, y => c_innerGridSize);
            end loop;
          end loop;
        when s_copyUpLeft =>
          for x in 0 to c_outerGridSize - 2 loop
            for y in 1 to c_outerGridSize - 1 loop
              r_borderValid(x, y) <= '1';
              r_borderData(x, y) <= s_currentOutput(x + 1, y - 1);
              v_temp := fu_convert(s_currentPosition(0, 0));
              r_borderPosition(x, y) <= v_temp + (x => c_innerGridSize, y => - 1 * c_innerGridSize);
            end loop;
          end loop;
        when s_copyUpRight =>
          for x in 1 to c_outerGridSize - 1 loop
            for y in 1 to c_outerGridSize - 1 loop
              r_borderValid(x, y) <= '1';
              r_borderData(x, y) <= s_currentOutput(x - 1, y - 1);
              v_temp := fu_convert(s_currentPosition(0, 0));
              r_borderPosition(x, y) <= v_temp + (x => -1 * c_innerGridSize, y => -1 * c_innerGridSize);
            end loop;
          end loop;


        when others =>

      end case;


    end if;
  end process;

end architecture;
