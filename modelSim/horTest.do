
vlib work
vlog snoopyHorizintalFSM.v

vsim snoopyHorizontalFSM

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


force {clock} 0 0ns, 1 {5ns} -r 10ns
force {reset} 1
run 10ns


force {reset} 0
run 10ns


force {input_left} 0
force {input_right} 1
run 100ns

force {input_left} 1
force {input_right} 0
run 10ns


force {input_left} 1
force {input_right} 0
run 100ns
