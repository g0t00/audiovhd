// library ieee;
// use ieee.std_logic_1164.all;
// use ieee.numeric_std.all;
// use std.textio.all;                     -- Imports the standard textio package.
// use work.pkg_audiovhd.all;

`timescale 1ns/1ns
realtime delay=10ns;
import pkg_audiovhd::*;
module testbench;

  logic s_clk          = 0;
  logic s_reset       = 1;
  logic s_outputReady ;
  logic signed [c_datawidth - 1 : 0] s_output;
  logic s_finished     = 0;
  integer s_countDown = 100;
  integer s_counter     = 1;
  t_coefficients dut_i_coefficientsN = {
    32'h0,
    32'h0,
    32'h00007ee3,
    32'h0,
    32'h0,
    32'h00007ee3,
    32'h0000045f,
    32'h00007ee3,
    32'h0,
    32'h0,
    32'h00007ee3,
    32'h0,
    32'h0
    };
  t_coefficients dut_i_coefficientsNMinus1 = {
    32'h0,
    32'h0,
    32'h0,
    32'h0,
    32'h0,
    32'h0,
    32'hffff0015,
    32'h0,
    32'h0,
    32'h0,
    32'h0,
    32'h0,
    32'h0
    };
  always begin
    #delay s_clk=~s_clk;
  end
  initial
  begin
    #20  s_reset = 0;
    end

  integer  file = $fopen("results.dat");
  always @(posedge s_clk) begin
    // if (s_reset == 0) begin
    //   if (dut.r_writeEnable != 0) begin
    //     $fwrite(file, "%h ", dut.r_result);
    //     if (dut.r_positionShift[0].x == 11 && dut.r_positionShift[0].y == 11) begin
    //       $fwrite(file, "\n");
    //     end
    //   end
    // end
    if (s_outputReady) begin
      $display("count: %d output: %h %f", s_counter, s_output, s_output/65536.0);
      s_counter++;
      s_countDown--;
      // $stop;
      if (s_countDown == 0) begin
        $stop;
      end
    end
  end

  processingGrid dut (
      .i_clk( s_clk),
      .i_reset( s_reset),
      .i_coefficientsN( dut_i_coefficientsN),
      .i_coefficientsNMinus1( dut_i_coefficientsNMinus1),
      .o_outputReady( s_outputReady),
      .o_output( s_output)
      );
  // processingElement dut (
  //     .i_clk( s_clk),
  //     .i_reset( s_reset),
  //     .i_coefficientsN( dut_i_coefficientsN),
  //     .i_coefficientsNMinus1( dut_i_coefficientsNMinus1),
  //     .o_outputReady( s_outputReady),
  //     .o_output( s_output)
  //     );

endmodule;
