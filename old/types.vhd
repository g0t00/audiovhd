----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 07/31/2017 05:45:43 PM
-- Design Name:
-- Module Name: types - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

  use IEEE.NUMERIC_STD.ALL;

package types is
  constant c_width : integer := 16;
  constant LENGTH_AFTER_SUM  : integer := C_WIDTH+3; --Q14
  constant LENGTH_AFTER_MULT : integer := LENGTH_AFTER_SUM + C_WIDTH; -- Q28

  constant g_grid : integer := 4;
  constant G_GRID_INNER : integer := 6;
  subtype dataType is std_logic_vector(c_width - 1 downto 0);
  type point_position is (PP_MAIN, PP_TOP, PP_BOTTOM, PP_LEFT, PP_RIGHT, PP_CORNER, PP_EXIT);
  type coefficients is record
      beta00 : dataType;
      beta01 : dataType;
      beta11 : dataType;
      beta02 : dataType;
      gamma00 : dataType;
      gamma01 : dataType;
    end record;
  type timePoint is (TP_LAST, TP_CURR); -- TP_LAST: 0, TP_CURR: 1,
  type grid_vec is array (G_GRID-1 downto 0, G_GRID-1 downto 0) of std_logic_vector(c_width - 1 downto 0);
  type excitation_vec is array (G_GRID_INNER * G_GRID_INNER - 1 downto 0) of grid_vec;
  type full_excitation_vec is array(timePoint) of excitation_vec;
  function intToTimepoint(i: integer range 0 to 2) return timePoint;

  -- @ Time step n
  type LOCATIONS0 is (loc00, loc10, loc01, locM10, loc0M1, loc20, loc11, loc02, locM11, locM20, locM1M1, loc0M2, loc1M1);
  type DEFLECTION0 is array (LOCATIONS0) of signed(c_width - 1 downto 0);
  -- @ Time step n-1
  type LOCATIONS1 is (loc00, loc10, loc01, locM10, loc0M1);
  type DEFLECTION1 is array (LOCATIONS1) of signed(c_width - 1 downto 0);
  function deflection0ToDeflection1(u: DEFLECTION0) return DEFLECTION1;
end package types;
package body types is
  function intToTimepoint(i: integer range 0 to 2) return timePoint is
  begin
    case i is
      when 0 =>
        return TP_LAST;
      when 1 =>
        return TP_CURR;
      when others => -- IS ERROR!
        assert false report "intToTimepoint i overflow" severity error;
        return TP_CURR;
    end case;
  end function intToTimepoint;
  function deflection0ToDeflection1(u: DEFLECTION0) return DEFLECTION1 is
  variable u_n_1 : DEFLECTION1;
  begin
    u_n_1(loc00)  := u(loc00);
    u_n_1(loc10)  := u(loc10);
    u_n_1(loc01)  := u(loc01);
    u_n_1(locM10) := u(locM10);
    u_n_1(loc0M1) := u(loc0M1);
    return u_n_1;
  end;
end package body types;
