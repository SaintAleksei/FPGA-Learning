#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <path/to/test>"
    exit 1
fi

iverilog -o testbench -I . -D ICARUS_VERILOG=1 $1 && vvp testbench
rm -f testbench
