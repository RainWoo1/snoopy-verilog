
vlib work
vlog rateDivider.v

#vsim -L altera_mf_ver part1

vsim RateDivider

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


force {ClockIn} 0 0ns, 1 {10ns} -r 20ns
force {Reset} 0
run 20ns


force {Reset} 1
run 100000ns
