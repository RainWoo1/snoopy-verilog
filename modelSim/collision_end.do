
vlib work
vlog collision.v

#vsim -L altera_mf_ver part1

vsim collision_end

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


force {clock} 0 0ns, 1 {5ns} -r 10ns
force {resetn} 1
run 10ns


force {resetn} 0
run 10ns

force {colour} 3'b000
force {y_coord} 7'd20
run 10ns

force {colour} 3'b010
force {y_coord} 7'd119
run 10ns

force {colour} 3'b001
force {y_coord} 7'd04
run 20ns
