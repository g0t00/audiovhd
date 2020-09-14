library IEEE;
use ieee.STD_LOGIC_1164.all;
use ieee.NUMERIC_STD.all;
use ieee.float_pkg.all;
use ieee.math_real.all;
use std.textio.all;                     -- Imports the standard textio package.

package pkg_audiovhd is

  constant c_dataWidth      : integer := 32;
  constant c_fractionLength : integer := 16;
  type t_signedArray is array (integer range <>) of signed(c_dataWidth - 1 downto 0);
  type t_signed2DArray is array (integer range <>, integer range <>) of signed(c_dataWidth - 1 downto 0);
  type t_slvArray is array (integer range <>) of std_logic_vector(c_dataWidth - 1 downto 0);
  type t_sl2DArray is array (integer range <>, integer range <>) of std_logic;
  type t_slv2DArray is array (integer range <>, integer range <>) of std_logic_vector(c_dataWidth - 1 downto 0);
  type t_integerArray is array (integer range <>) of integer;
  subtype t_coefficients is t_signedArray(0 to 12);
  type t_coefficientsArray is array (integer range <>) of t_coefficients;
  constant c_innerGridSize  : integer := 12;
  constant c_outerGridSize  : integer := 5;
  function fu_getSize (X    : integer)
    return integer;
  type t_position is record
    x : integer range 0 to c_innerGridSize - 1;
    y : integer range 0 to c_innerGridSize -1;
  end record;
  type t_positionArray is array(integer range <>) of t_position;
  type t_position2DArray is array(integer range <>, integer range <>) of t_position;
  type t_positionRam is record
    x : integer range 0 to c_innerGridSize -1 + 4;
    y : integer range 0 to c_innerGridSize -1 + 4;
  end record;
  type t_positionOffset is record
    x : integer range -1*c_innerGridSize to c_innerGridSize;
    y : integer range -1*c_innerGridSize to c_innerGridSize;
  end record;
  function "+" (L        : t_positionRam; R : t_positionOffset) return t_positionRam;
  -- Result subtype: UNSIGNED(L'LENGTH-1 downto 0).
  -- Result: Adds an UNSIGNED vector, L, with a non-negative INTEGER, R.
  type t_positionRam2DArray is array(integer range <>, integer range <>) of t_positionRam;
  function fu_convert (i : t_position)
    return t_positionRam;
  function fu_convert (i : t_positionRam)
    return std_logic_vector;
  function getPositionReadStep(pos : t_positionRam; readStep : integer range 0 to 12)
    return t_positionRam;
  function fu_getInitial (zeros : boolean)
    return t_slvArray;
  function fu_getInitialNumbers (zeros : boolean)
    return t_slvArray;
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
  -- function fu_getInitial (zeros : boolean)
  --   return t_slvArray is
  --   variable v_temp   : t_slvArray(0 to 2**fu_getSize((c_innerGridSize + 4)**2) - 1) := (others => (others => '0'));
  --   variable v_center : real;
  -- begin
  --   v_center := 2.0 + real(c_innerGridSize) / 2.0;
  --   if not zeros then
  --     for x in 3 to 11 loop
  --       for y in 3 to 11 loop
  --
  --         v_temp(x + 16 * y) := to_slv(to_float(
  --           0.1 * cos((MATH_PI / (1.0 * real(c_innerGridSize)))
  --                     * sqrt((real(x) - v_center)*(real(x) - v_center)
  --                            + ((real(y) - v_center) * (real(y) - v_center)))) ** 2));
  --       --sll (c_fractionLength - 30)
  --       -- report to_hex_string(v_temp(x + 16*y));
  --       end loop;
  --     end loop;
  --   end if;
  --   return v_temp;
  -- end;
  function fu_getInitial (zeros : boolean)
    return t_slvArray is
    variable v_temp   : t_slvArray(0 to 2**fu_getSize((c_innerGridSize + 4)**2) - 1) := (others => (others => '0'));
    variable v_center : real;
  begin
    v_center := 2.0 + real(c_innerGridSize) / 2.0;
    if not zeros then
      for x in 3 to 11 loop
        for y in 3 to 11 loop

          v_temp(x + 16 * y) := std_logic_vector(to_signed(integer(floor(
            real(2.0 ** c_fractionLength) * (-0.1) * cos((MATH_PI / (1.0 * real(c_innerGridSize)))
                                                         * sqrt((real(x) - v_center)*(real(x) - v_center)
                                                                + ((real(y) - v_center) * (real(y) - v_center)))) ** 2
            )), c_dataWidth));          --sll (c_fractionLength - 30)
        -- report to_hex_string(v_temp(x + 16*y));
        end loop;
      end loop;
    end if;
    return v_temp;
  end;
  function fu_getInitialNumbers (zeros : boolean)
    return t_slvArray is
    variable v_temp   : t_slvArray(0 to 2**fu_getSize((c_innerGridSize + 4)**2) - 1) := (others => (others => '0'));
    variable v_center : real;
    variable s_float  : float32;
  begin
    if not zeros then
      for i in 0 to (c_innerGridSize + 4)**2 - 1 loop
        v_temp(i) := to_stdlogicvector(to_float(real(i), s_float));
      end loop;
    end if;
    return v_temp;
  end;
  -- function fu_getInitialNumbers (zeros : boolean)
  --   return t_slvArray is
  --   variable v_temp   : t_slvArray(0 to 2**fu_getSize((c_innerGridSize + 4)**2) - 1) := (others => (others => '0'));
  --   variable v_center : real;
  -- begin
  --   if not zeros then
  --     for i in 0 to (c_innerGridSize + 4)**2 - 1 loop
  --       v_temp(i) := std_logic_vector(to_signed(2**c_fractionLength * i, c_dataWidth));
  --     end loop;
  --   end if;
  --   return v_temp;
  -- end;
  function "+" (L : t_positionRam; R : t_positionOffset) return t_positionRam is
    variable v_temp : t_positionRam;
  begin
    v_temp.x := L.x + R.x;
    v_temp.y := L.y + R.y;
    return v_temp;
  end;


end;
