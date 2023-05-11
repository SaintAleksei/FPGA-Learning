#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <name_of_test>"
    exit 1
fi

iverilog -o testbench -I . -D ICARUS_VERILOG=1 test/$1 && vvp -M vpi -m vgasim testbench
rm -f testbench
