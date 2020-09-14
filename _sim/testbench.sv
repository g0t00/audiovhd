// library ieee;
// use ieee.std_logic_1164.all;
// use ieee.numeric_std.all;
// use std.textio.all;                     -- Imports the standard textio package.
// use work.pkg_audiovhd.all;

`timescale 1ps/1ps
realtime delay=10ns;
import pkg_audiovhd::*;
module testbench;
  integer                              checkerErrors;

  logic                                s_clk          = 0;
  logic                                s_reset       = 1;
  logic                                s_outputReady ;
  logic signed [c_datawidth - 1 : 0]   s_output;
  logic                                s_finished     = 0;
  integer                              s_countDown = 100000;
  integer                              s_counter     = 1;
  // t_coefficients dut_i_coefficientsN = {
  //                                       32'h0,
  //                                       32'h0,
  //                                       32'h0,
  //                                       32'h0,
  //                                       32'h0,
  //                                       32'h0,
  //                                       32'h0,
  //                                       32'h3f800000,
  //                                       32'h0,
  //                                       32'h0,
  //                                       32'h0,
  //                                       32'h0,
  //                                       32'h0
  //                                       };
  // t_coefficients dut_i_coefficientsNMinus1 = {
  //                                             32'h0,
  //                                             32'h0,
  //                                             32'h0,
  //                                             32'h0,
  //                                             32'h0,
  //                                             32'h0,
  //                                             32'h0,
  //                                             32'h0,
  //                                             32'h0,
  //                                             32'h0,
  //                                             32'h0,
  //                                             32'h0,
  //                                             32'h0
  //                                             };

  logic [c_datawidth - 1 : 0]          s0 = 32'h0000045f;
  logic [c_datawidth - 1 : 0]          s1 = 32'h00007ee3;
  logic [c_datawidth - 1 : 0]          t0 = 32'hffff0015;

  t_coefficients dut_i_coefficientsN = {
                                        32'h0,
                                        32'h0,
                                        s1,
                                        32'h0,
                                        32'h0,
                                        s1,
                                        s0,
                                        s1,
                                        32'h0,
                                        32'h0,
                                        s1,
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
                                              t0,
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
  logic [c_datawidth -1 : 0]  dataFromElement[c_outergridsize - 1:0][c_outergridsize - 1:0];
  logic [c_datawidth -1 : 0]  i_borderData[c_outergridsize - 1:0][c_outergridsize - 1:0];
  logic                       i_borderValid[c_outergridsize - 1:0][c_outergridsize - 1:0];
  integer                     i_borderPositionx[c_outergridsize - 1:0][c_outergridsize - 1:0];
  integer                     i_borderPositiony[c_outergridsize - 1:0][c_outergridsize - 1:0];
  logic [63:0]                temp;
  genvar                      gx;
  genvar                      gy;
  for (gx=0; gx<c_outergridsize; gx++) begin : genbit
    for (gy=0; gy<c_outergridsize; gy++) begin : genbit
      assign dataFromElement[gx][gy] = dut.gen_outer[gx].gen_inner[gy].processingElement_i.o_currentOutput;
      assign i_borderPositionx[gx][gy] = dut.gen_outer[gx].gen_inner[gy].processingElement_i.i_borderPosition.x;
      assign i_borderPositiony[gx][gy] = dut.gen_outer[gx].gen_inner[gy].processingElement_i.i_borderPosition.y;
      assign i_borderData[gx][gy] = dut.gen_outer[gx].gen_inner[gy].processingElement_i.i_borderData;
      assign i_borderValid[gx][gy] = dut.gen_outer[gx].gen_inner[gy].processingElement_i.i_borderValid;
    end
  end
  integer macroX;
  integer macroY;
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
            // temp =  {dataSet[x][y][31], dataSet[x][y][30], {3{~dataSet[x][y][30]}}, dataSet[x][y][29:23], dataSet[x][y][22:0], {29{1'b0}}};
            // $fwrite(file, "%9.9f ", $bitstoreal(temp));
            $fwrite(file, "%h ", dataSet[x][y]);
          end
        end
        $fwrite(file, "\n");
      end
    end
    for (int x = 0; x < c_outergridsize; x++) begin
      for (int y = 0; y < c_outergridsize; y++) begin
        if (i_borderValid[x][y]) begin
          macroX = x * c_innergridsize - 2 + i_borderPositionx[x][y];
          macroY = y * c_innergridsize - 2 + i_borderPositiony[x][y];
          if (i_borderData[x][y] !== dataSet[macroX][macroY]) begin
            $display("wrong Bordercase:%d %d || %d %d is %h should be %h", x, y, macroX, macroY, i_borderData[x][y], dataSet[macroX][macroY]);
            $stop;
            checkerErrors++;
          end else begin
            // $display("Right Bordercase:%d %d || %d %d is %h should be %h", x, y, macroX, macroY, i_borderData[x][y], dataSet[macroX][macroY]);
          end
        end
      end

    end
    if (checkerErrors > 0) begin

    end


    if (s_outputReady) begin
      $display("count: %d output: %h %f", s_counter, s_output, real'(s_output));

      $fflush();
      s_counter++;
      s_countDown--;
      // $stop;
      if (s_countDown == 0) begin
        $stop;
      end
    end
  end
  integer                            offsets [12:0][1:0] = {
                                                            '{0 ,2},
                                                            '{-1, 1},
                                                            '{0 ,1},
                                                            '{1 ,1},
                                                            '{-2, 0},
                                                            '{-1, 0},
                                                            '{0 ,0},
                                                            '{1 ,0},
                                                            '{2 ,0},
                                                            '{-1, -1},
                                                            '{0 ,-1},
                                                            '{1 ,-1},
                                                            '{0 ,-2}
                                                            };
  logic signed [c_datawidth - 1 : 0] dataN [c_innergridsize * c_outergridsize -1 + 4 : 0][c_innergridsize * c_outergridsize -1 + 4 : 0];
  logic signed [c_datawidth - 1 : 0] dataNminus1 [c_innergridsize * c_outergridsize -1 + 4 : 0][c_innergridsize * c_outergridsize -1 + 4 : 0];
  logic signed [c_datawidth - 1 : 0] dataNplus1 [c_innergridsize * c_outergridsize -1 + 4 : 0][c_innergridsize * c_outergridsize -1 + 4 : 0];
  logic signed [c_datawidth - 1 : 0] accumN;
  logic signed [c_datawidth - 1 : 0] accumNminus1;
  logic signed [2*c_datawidth - 1 : 0] fixedPointConcat;
  logic signed [c_datawidth - 1 : 0]   initalValues [c_innergridsize - 1:0][c_innergridsize - 1:0];
  real                                 v_center;
  initial begin
    for (int x = 0; x < (c_innergridsize * c_outergridsize) + 4; x++) begin
      for (int y = 0; y < (c_innergridsize * c_outergridsize) + 4 ; y++) begin
        dataN[x][y] = 32'h0;
        dataNminus1[x][y] = 32'h0;
        dataNplus1[x][y] = 32'h0;
      end
    end
    v_center =  real'(c_innergridsize) / 2.0;

    for (int x = 1; x <= 9 ; x++) begin
      for (int y = 1; y <= 9 ; y++) begin
        dataN[x + 2 + 2*c_innergridsize][y + 2 + 2*c_innergridsize] =
                   $rtoi($floor(2.0 ** c_fractionlength * -0.1 * $cos(($acos(-1) / (1.0 * real'(c_innergridsize)))
                                                                      * $sqrt((real'(x) - v_center)**2.0
                                                                              + ((real'(y) - v_center) **2.0))) ** 2));

        dataNminus1[x + 2 + 2*c_innergridsize][y + 2 + 2*c_innergridsize] = dataN[x + 2 + 2*c_innergridsize][y + 2 + 2*c_innergridsize];
        dataNplus1[x + 2 + 2*c_innergridsize][y + 2 + 2*c_innergridsize] = dataN[x + 2 + 2*c_innergridsize][y + 2 + 2*c_innergridsize];
      end
    end
  end
  always @(posedge s_clk) begin
    if (s_outputReady) begin
      for (int x = 2; x < c_innergridsize * c_outergridsize + 4 - 2; x++) begin
        for (int y = 2; y < c_innergridsize * c_outergridsize + 4 - 2; y++) begin
          accumN = 0;
          accumNminus1 = 0;
          for (int i = 0; i < 13; i++) begin
            fixedPointConcat =  signed'(dut_i_coefficientsN[i]) * signed'(dataN[x + offsets[i][0]][y + offsets[i][1]]);
            accumN = accumN + fixedPointConcat[2*c_datawidth - 1 - (c_datawidth - c_fractionlength) -: c_datawidth];
            fixedPointConcat =  signed'(dut_i_coefficientsNMinus1[i]) * signed'(dataNminus1[x + offsets[i][0]][y + offsets[i][1]]);
            accumNminus1 = accumNminus1 + fixedPointConcat[2*c_datawidth - 1 - (c_datawidth - c_fractionlength) -: c_datawidth];
          end
          dataNplus1[x][y] = accumN + accumNminus1;
        end
      end
      dataNminus1 = dataN;
      dataN = dataNplus1;
      checkerErrors = 0;
      for (int x = 2; x < c_innergridsize * c_outergridsize + 4 - 2; x++) begin
        for (int y = 2; y < c_innergridsize * c_outergridsize + 4 - 2; y++) begin
          if (dataSet[x - 2][y - 2] !== dataNplus1[x][y]) begin
            $display("wrong: %d %d is %h should be %h", (x-2), (y-2), dataSet[x - 2][y - 2], dataNplus1[x][y]);
            checkerErrors++;
          end else begin
            // $display("right: %d %d is %h should be %h", (x-2), (y-2), dataSet[x - 2][y - 2], dataNplus1[x][y]);
          end
        end
      end
      if (checkerErrors > 0) begin
        $stop;
      end
      // $stop;
    end
  end

  processingGrid #(
                   .g_outputX(c_innergridsize * c_outergridsize -1),
                   .g_outputY(c_innergridsize * c_outergridsize -1)
                   )   dut (
                            .i_clk( s_clk),
                            .i_reset( s_reset),
                            .i_coefficientsN( dut_i_coefficientsN),
                            .i_coefficientsNMinus1( dut_i_coefficientsNMinus1),
                            .o_outputReady( s_outputReady),
                            .o_output( s_output)
                            );

endmodule;
