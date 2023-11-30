vlib work
vlog keyboardSignal.v

#vsim -L altera_mf_ver part1

vsim keyboardFSM

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


force {clk} 0 0ns, 1 {5ns} -r 10ns
force {reset} 1
run 10ns


force {reset} 0
run 10ns

force {data_in} 8'h00;
run 10ns

#press right arrow
force {data_in} 8'hE0;
run 10ns

force {data_in} 8'h74;
run 10ns

#release right arrow
force {data_in} 8'hF0;
run 10ns

force {data_in} 8'hE0;
run 10ns

force {data_in} 8'h74;
run 10ns

#press up key
force {data_in} 8'hE0;
run 10ns

force {data_in} 8'h75;
run 10ns

#press left key
force {data_in} 8'hE0;
run 10ns

force {data_in} 8'h6B;
run 10ns

#release left arrow
force {data_in} 8'hF0;
run 10ns

force {data_in} 8'hE0;
run 10ns

force {data_in} 8'h6B;
run 10ns

#release up arrow
force {data_in} 8'hF0;
run 10ns

force {data_in} 8'hE0;
run 10ns

force {data_in} 8'h75;
run 10ns
