
vlib work
vlog characterCounter.v

vsim characterCounter

#vsim -L altera_mf_ver part1

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


force {clk} 0 0ns, 1 {5ns} -r 10ns
force {resetn} 1
run 10ns


force {resetn} 0
run 1000ns
