----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 07/31/2017 05:27:59 PM
-- Design Name:
-- Module Name: testbench - Behavioral
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

use work.types.all;

entity excitation_insert is
  port (
    clk             : in  std_ulogic;
    n_reset         : in  std_ulogic;
    data_out : out std_logic_vector(c_width -1 downto 0);
    wait_i          : in  std_logic;
    ready_out       : out std_logic;
    start_i           : in std_logic
  );
end excitation_insert;

architecture behavioral of excitation_insert is
  component processing_grid
  port (
    clk             : in  std_ulogic;
    n_reset         : in  std_ulogic;
    coefficients_in : in  coefficients;
    init_done       : out std_logic;
    init_data       : in  full_excitation_vec;
    init_data_ready : in  std_logic;
    ready_out       : out std_logic;
    wait_i          : in  std_logic;
    data_out_addr   : in  std_logic_vector(15 downto 0);
    data_out        : out std_logic_vector(c_width -1 downto 0)
  );
  end component processing_grid;
  component dataentity
  port (
    init_data : out full_excitation_vec
  );
  end component dataentity;
  
--  component coefficientsentity
--  port (
--    coefficients_out : out coefficients
--  );
--  end component coefficientsentity;
    component coeff_debug_wrapper is
      port (
        clk : in STD_LOGIC;
        probe_in0 : in STD_LOGIC_VECTOR ( 15 to 0 );
        probe_out0 : out STD_LOGIC_VECTOR ( 15 downto 0 );
        probe_out1 : out STD_LOGIC_VECTOR ( 15 downto 0 );
        probe_out2 : out STD_LOGIC_VECTOR ( 15 downto 0 );
        probe_out3 : out STD_LOGIC_VECTOR ( 15 downto 0 );
        probe_out4 : out STD_LOGIC_VECTOR ( 15 downto 0 );
        probe_out5 : out STD_LOGIC_VECTOR ( 15 downto 0 );
        probe_out6 : out STD_LOGIC_VECTOR ( 0 to 0 )
      );
    end component coeff_debug_wrapper;
    component data_debug_wrapper is
    port (
        clk : in STD_LOGIC;
        probe0 : in STD_LOGIC_VECTOR ( 15 downto 0 );
        probe1 : in STD_LOGIC_VECTOR ( 0 to 0 );
        probe2 : in STD_LOGIC_VECTOR ( 0 to 0 )
    );
    end component data_debug_wrapper;

  signal i_clk: std_logic := '0';
  signal i_coefficients: coefficients;
  signal i_data_out: dataType;
  signal i_ready_out: std_logic;
  signal i_init_data: full_excitation_vec;
  signal i_init_data_ready : std_logic;
  signal i_init_done : std_logic;
  signal i_n_reset : std_logic;
  signal i_n_reset_vio : std_logic_vector(0 downto 0);
  
  begin

    i_init_data_ready <= not i_init_done;

    i_n_reset <= n_reset and i_n_reset_vio(0);
    
    processing_grid_i : processing_grid
    port map (
     clk             => clk,
     n_reset         => i_n_reset,
     coefficients_in => i_coefficients,
     init_done       => i_init_done,
     init_data       => i_init_data,
     init_data_ready => i_init_data_ready,
     ready_out       => i_ready_out,
     wait_i          => wait_i,
     data_out_addr   => x"0A" & x"1" & x"1",
     data_out        => i_data_out
    );
    ready_out <= i_ready_out;
    data_out <= i_data_out;
    dataentity_i : dataentity
    port map (
      init_data => i_init_data
    );
--    coefficientsentity_i : coefficientsentity
--    port map (
--      coefficients_out => i_coefficients
--    );
    coeff_debug_wrapper_i : coeff_debug_wrapper
    port map(
        clk => clk,
        probe_in0 => i_data_out,
        probe_out0 => i_coefficients.beta00,
        probe_out1 => i_coefficients.beta01,
        probe_out2 => i_coefficients.beta11,
        probe_out3 => i_coefficients.beta02,
        probe_out4 => i_coefficients.gamma00,
        probe_out5 => i_coefficients.gamma01,
        probe_out6 => i_n_reset_vio
    );
    
    data_debug_wrapper_i : data_debug_wrapper
    port map(
        clk => clk,
        probe0 => i_data_out,
        probe1(0) => i_ready_out,
        probe2(0) => i_n_reset
    );
    
end behavioral;
