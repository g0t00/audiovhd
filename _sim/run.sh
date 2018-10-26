PATH=$PATH:/Users/anton/Downloads/ghdl-0.35-llvm-macosx/bin


mkdir -p work
ghdl  -i --workdir=work --std=08 ../_src/*.vhd &&
ghdl  -i --workdir=work --std=08 *.vhd &&
ghdl  -m --workdir=work --std=08 testbench &&
ghdl  -e --workdir=work --std=08 testbench &&
ghdl -r --workdir=work  testbench --vcd=result.vcd --wave=result.ghw
