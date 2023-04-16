DE2-115 Verilog Projects
------------------------

This document presents a collection of projects for the DE2-115 board, each with its own directory. Some files located outside of the project can be used in multiple projects, such as `library.v`.

To build a project, navigate to the appropriate directory and run the following command:

`quartus_sh --flow compile de2_115`

To flash the compiled project onto a real board, use the Windows version of Quartus. However, this is currently an unresolved issue due to drivers. As an alternative, you can use a Linux system with Quartus Prime installed. Alternatively, you can work with the project using the Quartus GUI on any system where it is available.

Each project should contain at least three files:

*   `de2_115.qpf`: Quartus Project File needed for Quartus project detection
*   `de2_115.qsf`: Quartus Setting File needed for Quartus project configuration, such as pin assignment
*   `de2_115.v`: File with a top-level Verilog module whose inputs and outputs are wired directly to the DE2-115 board. It can be used as a convenient entry point for the project.

Running Tests in Simulator
--------------------------

To run tests, use the following command:

`iverilog -o testbench -I . /path/to/test.v && vvp testbench`

This requires Icarus Verilog to be installed on your Linux system. After running the tests, you can generate a `.vcd` file with a waveform if appropriate lines are included in the test module. This file can be viewed with an appropriate utility, such as GTKWave.

Tests for modules from `library.v` are located in the `test/` directory. For example, you can run:

`iverilog -o testbench -I . /test/division.v  && vvp testbench`

This document provides a brief overview of the DE2-115 Verilog projects and how to run tests in the simulator. Please refer to the project directories for more details on each project.

