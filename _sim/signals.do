onerror {resume}
#add wave -group mull -recursive sim:/testbench/*

add wave -position 0  sim:/testbench/s_clk
add wave -position end  sim:/testbench/dut/r_readStepShift(0)
add wave -position end  sim:/testbench/dut/r_readDataN
add wave -position end  sim:/testbench/dut/r_accumMultiN
add wave -position end  sim:/testbench/dut/s_readAddr
add wave -position end  sim:/testbench/dut/*
add wave -group PE11 sim:/testbench/dut/gen_outer(1)/gen_inner(1)/processingElement_i/*
add wave -group PE44 sim:/testbench/dut/gen_outer(4)/gen_inner(4)/processingElement_i/*
add wave -position end sim:/testbench/*
add wave -group PEEX end sim:/testbench/dut/gen_outer(2)/gen_inner(2)/processingElement_i/*
