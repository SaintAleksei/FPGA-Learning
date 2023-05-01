#!/bin/bash

mkdir -p vpi
(cd vpi &&  git clone https://github.com/SaintAleksei/VGA-Verilog-Simulator.git)
make -C vpi/VGA-Verilog-Simulator && cp vpi/VGA-Verilog-Simulator/vgasim.vpi vpi/vgasim.vpi
