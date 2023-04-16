#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_test>"
    exit 1
fi

iverilog -o testbench -I . $1 && vvp testbench
