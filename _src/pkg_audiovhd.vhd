library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.math_real.all;

package pkg_audiovhd is

  constant c_dataWidth     : integer := 32;
  type     t_signedArray is array (integer range <>) of signed(c_dataWidth - 1 downto 0);
  type     t_slvArray is array (integer range <>) of std_logic_vector(c_dataWidth - 1 downto 0);
  type     t_integerArray is array (integer range <>) of integer;
  subtype  t_coefficients is t_signedArray(0 to 12);
  constant c_innerGridSize : integer := 12;
  function fu_getSize (X   : integer)
    return integer;
  type t_position is record
    x : integer range 0 to c_innerGridSize - 1;
    y : integer range 0 to c_innerGridSize -1;
  end record;
  type t_positionArray is array(integer range <>) of t_position;
  type t_positionRam is record
    x : integer range 0 to c_innerGridSize -1 + 4;
    y : integer range 0 to c_innerGridSize -1 + 4;
  end record;
  function fu_convert (i : t_position)
    return t_positionRam;
  function fu_convert (i : t_positionRam)
    return std_logic_vector;
  function getPositionReadStep(pos : t_positionRam; readStep : integer range 0 to 12)
    return t_positionRam;
end package;
package body pkg_audiovhd is
  function fu_convert (i : t_position)
    return t_positionRam is
    variable v_temp : t_positionRam;
  begin
    v_temp.x := i.x + 2;
    v_temp.y := i.y + 2;
    return v_temp;
  end;
  function fu_getSize (X : integer)
    return integer is
  begin
    return integer(CEIL(LOG2(real(X))));
  end;
  function getPositionReadStep(pos : t_positionRam; readStep : integer range 0 to 12)
    return t_positionRam is
    variable v_temp : t_positionRam;
  begin
    v_temp := pos;
    case readStep is
      when 0 =>
        v_temp.y := v_temp.y + 2;
      when 1 =>
        v_temp.y := v_temp.y + 1;
        v_temp.x := v_temp.x - 1;
      when 2 =>
        v_temp.y := v_temp.y + 1;
      when 3 =>
        v_temp.y := v_temp.y + 1;
        v_temp.x := v_temp.x + 1;
      when 4 =>
        v_temp.x := v_temp.x - 2;
      when 5 =>
        v_temp.x := v_temp.x - 1;
      when 6 =>
      when 7 =>
        v_temp.x := v_temp.x + 1;
      when 8 =>
        v_temp.x := v_temp.x + 2;
      when 9 =>
        v_temp.y := v_temp.y - 1;
        v_temp.x := v_temp.x - 1;
      when 10 =>
        v_temp.y := v_temp.y - 1;
      when 11 =>
        v_temp.y := v_temp.y - 1;
        v_temp.x := v_temp.x + 1;
      when 12 =>
        v_temp.y := v_temp.y - 2;
    end case;
    return v_temp;
  end;
  function fu_convert (i : t_positionRam)
    return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(i.x + (c_innerGridSize + 4) * i.y, fu_getSize((c_innerGridSize + 4)**2)));
  end;
end;
