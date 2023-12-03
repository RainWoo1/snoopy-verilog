
vlib work
vlog collision.v
vsim gameFSM

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


force {clock} 0 0ns, 1 {5ns} -r 10ns
force {reset} 0
run 10ns


force {reset} 1


force {collided} 1
force {reached_screen_end} 0
force {user_input} 1
run 10ns


force {collided} 1
force {reached_screen_end} 0
force {user_input} 1
run 10ns


force {collided} 0
force {reached_screen_end} 1
force {user_input} 1
run 10ns


force {collided} 0
force {reached_screen_end} 1
force {user_input} 1
run 30ns

