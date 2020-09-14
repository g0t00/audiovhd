# vlib work
# vlib libraries
proc external_editor {filename linenumber} {
    exec atom $filename:$linenumber
}
set PrefSource(altEditor) external_editor
mkdir -p libraries
set ipcores {multiAdder adder}
# dev_com
foreach ipcore $ipcores {
  set QSYS_SIMDIR ../_syn/$ipcore/sim/
  #
  # Source the generated IP simulation script.
  source $QSYS_SIMDIR/mentor/msim_setup.tcl
  # dev_com
  com
}
# dev_com

vcom -2008 -mixedsvvh -work work ../_src/pkg_audiovhd.vhd
vcom -2008 -mixedsvvh -work work ../_src/adderFixed.vhd
vcom -2008 -mixedsvvh -work work ../_src/multiAdderFixed.vhd
vcom -2008 -mixedsvvh -work work ../_src/dualPortRam.vhd
vcom -2008 -mixedsvvh -work work ../_src/processingElement.vhd
vcom -2008 -mixedsvvh -work work ../_src/processingGrid.vhd

vlog -sv -work work testbench.sv

vsim -t 1ps testbench -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fourteennm_ver -L fourteennm_ct1_ver -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L fourteennm -L fourteennm_ct1 -novopt
do signals.do
config wave -signalnamewidth 1

run -all
