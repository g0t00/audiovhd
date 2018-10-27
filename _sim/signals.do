onerror {resume}
add wave -group mull -recursive sim:/testbench/*

add wave -position 0  sim:/testbench/s_clk
add wave -position end  sim:/testbench/dut/r_readStepShift(0)
add wave -position end  sim:/testbench/dut/r_readDataN
add wave -position end  sim:/testbench/dut/r_accumMultiN
add wave -position end  sim:/testbench/dut/s_readAddr
