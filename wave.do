vlib snoopy

vlog VGAmodule.v

vsim VGAmodule

#vsim -L altera_mf_ver part1

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force {iClock} 1 0ns, 0 {5ns} -r 10ns
force iResetn 1'b0
run 10ns

# reset (Active high)
force iResetn 1'b1
force iX 8'b0
force iY 7'b0
force iLoadX 1'b0
force iBlack 1'b0
run 10ns

# set and load x
force iX 8'd3
force iLoadX 1'b1
run 100ns

force iX 8'd0
force iLoadX 1'b0
run 10ns

# set y and load y/colour
force iY 7'd7
force iColour 3'b101
force iPlotBox 1'b0
run 15ns

force iY 7'd7
force iColour 3'b101
force iPlotBox 1'b1
run 100ns

force iPlotBox 1'b0
run 10000ns

# clear
force iBlack 1'b1
run 500ns

force iBlack 1'b0
run 1000ns


#force iBlack 0;
#force iColour 010
#force iResetn 1
#force iXY_Coord 000101
#force iPlotBox 0;
#force iLoadX 1;
#run 100ns
#
#force iBlack 0;
#force iColour 010
#force iResetn 1
#force iXY_Coord 000000
#force iPlotBox 0;
#force iLoadX 0;
#run 100ns
#
#force iBlack 0;
#force iColour 010
#force iResetn 1
#force iXY_Coord 000011
#force iPlotBox 1;
#force iLoadX 0;
#run 100ns
#
#force iBlack 0;
#force iColour 010
#force iResetn 1
#force iXY_Coord 000000
#force iPlotBox 0;
#force iLoadX 0;
#run 10000ns
#
#
#force {clock} 0 0ns, 1 {5ns} -r 10ns
#force {resetn} 1
#force go 0
#force iX 8'd0
#force iY 7'd0
#force iColour 3'd0
#run 10ns
#
#
#force {resetn} 0
#force go 1
#force iX 8'b00000001
#force iY 7'b0000010
#force iColour 3'b100
#
#run 100000000ns
