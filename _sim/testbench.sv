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
  integer s_countDown = 500;
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
  logic [c_datawidth - 1 : 0] dataSet[c_innergridsize * c_outergridsize - 1 : 0][c_innergridsize * c_outergridsize - 1 : 0];
  logic [c_datawidth -1 : 0] dataFromElement[c_outergridsize - 1:0][c_outergridsize - 1:0];
  genvar gx;
  genvar gy;
  for (gx=0; gx<c_outergridsize; gx++) begin : genbit
    for (gy=0; gy<c_outergridsize; gy++) begin : genbit
      assign dataFromElement[gx][gy] = dut.gen_outer[gx].gen_inner[gy].processingElement_i.o_currentOutput;
    end
  end
  always @(posedge s_clk) begin
    // if (s_reset == 0) begin
    //   if (dut.r_writeEnable != 0) begin
    //     $fwrite(file, "%h ", dut.r_result);
    //     if (dut.r_positionShift[0].x == 11 && dut.r_positionShift[0].y == 11) begin
    //       $fwrite(file, "\n");
    //     end
    //   end
    // end
    if (dut.gen_outer[0].gen_inner[0].processingElement_i.o_currentValid) begin
      // $display("point done");
      for (int x = 0; x < c_outergridsize; x++) begin
        for (int y = 0; y < c_outergridsize; y++) begin
          // $fwrite(file, "%d %d %h\n", x * c_innergridsize + dut.gen_outer[0].gen_inner[0].processingElement_i.o_currentPosition.x, y * c_innergridsize + dut.gen_outer[0].gen_inner[0].processingElement_i.o_currentPosition.y, dataFromElement[x][y]);
          dataSet[x * c_innergridsize + dut.gen_outer[0].gen_inner[0].processingElement_i.o_currentPosition.x][y * c_innergridsize + dut.gen_outer[0].gen_inner[0].processingElement_i.o_currentPosition.y] = dataFromElement[x][y];
        end
      end
      if (dut.gen_outer[0].gen_inner[0].processingElement_i.o_currentPosition.x == c_innergridsize - 1 && dut.gen_outer[0].gen_inner[0].processingElement_i.o_currentPosition.y == c_innergridsize - 1) begin
        for (int x = 0; x < c_innergridsize * c_outergridsize; x++) begin
          for (int y = 0; y < c_innergridsize * c_outergridsize; y++) begin
            $fwrite(file, "%h ", dataSet[x][y]);
          end
        end
        $fwrite(file, "\n");
      end
    end
    if (s_outputReady) begin
      $display("count: %d output: %h %f", s_counter, s_output, s_output/65536.0);
      $fflush();
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
