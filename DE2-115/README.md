## DE2-115 Verilog projects

Here are colleted some project for DE2-115 board.

Each project has it's own directory. Some files located out of project can be used in many projects (library.v, for example). 

To build some project just enter appropriate directory and enter.

  `quartus_sh --flow compile de2_115`

To flash compiled project on real board Windows version of Quartus should be used. It's unresolved problem for now because of drivers.

To achieve goal you should have linux system with Quartus Prime installed.

Also you can work with project using Quartus GUI in any system it's provided.

Each project should contain at least three files:
  - de2_115.qpf: Quartus Ppoject File needed for Quartus project detection
  - de2_115.qsf: Quartus Setting FIle needed for Quartus project configuration such as pin assignment
  - de2_115.v: File with top level verilog module, whose inputs and outputs are wired directly to DE2-115 board ones. It can be used as convenient entry point for project.

## Running tests in simulator

To run tests you can use following command:

  `iverilog -o testbench -I . /path/to/test.v && vvp testbench`

To achieve goal you should have Icarus Verilog installed on yout linux system.

After running tests, file `.vcd` with waveform can be generated, if appropriate lines included in test module. This file can be viewed with appropriate utility, like a GTKWave.

Tests for modules from `library.v` are located in `test/` directory, for example you can run:

  `iverilog -o testbench -I . /test/division.v  && vvp testbench`


