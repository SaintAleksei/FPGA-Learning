# DE2-115 Verilog projects

Here colleted some project for DE2-115 board

Each project has it's own directory

To build some project just enter appropriate directory and enter

  `quartus_sh --flow compile de2_115`

To flash compiled project on real board Windows version of Quartus should be used. It's unresolved problem for now because of drivers.

To achieve goal you should have linux system with Quartus Prime installed

Each project should containg at leas three files:
  - de2_115.qpf: It is Quartus Ppoject File needed for Quartus project detection
  - de2_115.qsf: It is Quartus Setting FIle needed for Quartus project configuration such as pin assignment
  - de2_115.v: It is top level verilog file. Inputs and Outputs and wired directly to DE2-115 boardones. It can be used as convenient entry point for project.
