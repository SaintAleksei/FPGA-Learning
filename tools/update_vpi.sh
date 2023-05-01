#!/bin/bash

mkdir -p vpi
if [ ! -d "vpi/VGA-Verilog-Simulator" ]; then
  (cd vpi &&  git clone https://github.com/SaintAleksei/VGA-Verilog-Simulator.git)
fi
make -C vpi/VGA-Verilog-Simulator && cp vpi/VGA-Verilog-Simulator/vgasim.vpi vpi/vgasim.vpi
