------------------------------------------------------------
-- Module name: Processing element
-- Project Name: Real-time physical modeling sound synthesis
-- Author: Group 8
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity processing_element is
  port(
    clk        : in  std_ulogic;
    i_reset    : in  std_ulogic;
    -- coefficients
    coefficients_in  : in  coefficients;
    -- memory control signals
    sw_memory  : in  std_logic;         --MUST only be '1' for one clk cycle to
    rd_en      : in  std_logic;
    rd_addr    : in  std_logic_vector(6 downto 0);
    wr_en      : in  std_logic;
    wr_addr    : in  std_logic_vector(6 downto 0);
    data_in    : in  std_logic_vector(15 downto 0);
    data_out   : out std_logic_vector(15 downto 0)
    );
end processing_element;

architecture RTL of processing_element is


  signal i_u_interconnect     : DEFLECTION0;
  signal i_u_n_1_interconnect : DEFLECTION1;
  signal i_data_out           : std_logic_vector(c_width-1 downto 0);
  signal i_data_in            : std_logic_vector(c_width-1 downto 0);

begin

  -- loop data internally when writing to main block!
  i_data_in <= data_in;

  INST_my_equation : entity work.my_equation
    generic map(
      c_width => c_width
    )
    port map(
      clk             => clk,
      --DATA IO
      un0_in          => i_u_interconnect,  -- DEFLECTION T;
      un1_in          => i_u_n_1_interconnect,  -- DEFLECTION T-1;
      un1_out         => i_data_out,         -- DEFLECTION T+1;
--     --EXCITATION
--     fn0_in     : in  signed(c_width-1 downto 0);
--     --KOEFFICIENTS already multiplied with eta!
      coefficients_in => coefficients_in
      );


  INST_memory_block_triplet : entity work.memory_block_triplet
    generic map(
      c_width => c_width
      )
    port map(
      -- clk and reset
      clk       => clk,
      i_reset   => i_reset,
      -- rotate memory
      sw_memory => sw_memory,
      -- read (port B)
      rd_en     => rd_en,
      rd_addr   => rd_addr,
      -- write (portA)
      wr_en     => wr_en,
      wr_addr   => wr_addr,
      -- output time step N (port B output)
      u         => i_u_interconnect,
      -- output time step N-1 (port B output)
      u_n_1     => i_u_n_1_interconnect,
      -- input time step N + 1
      i0_0      => i_data_in
      );

  data_out <= i_data_out;

end RTL;
