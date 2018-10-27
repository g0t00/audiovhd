vlib work
vcom -2008 -mixedsvvh -work work ../_src/pkg_audiovhd.vhd
vcom -2008 -mixedsvvh -work work ../_src/dualPortRam.vhd
vcom -2008 -mixedsvvh -work work ../_src/processingElement.vhd
vcom -2008 -mixedsvvh -work work ../_src/processingGrid.vhd

vlog -sv -work work testbench.sv

vsim testbench
do signals.do
config wave -signalnamewidth 1

run -all
