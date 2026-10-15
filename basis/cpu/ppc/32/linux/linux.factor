! GNU Linux PowerPC32 uses the shared SysV ABI.
USING: cpu.architecture cpu.ppc cpu.ppc.32.gnu layouts system ;
IN: cpu.ppc.32.linux

M: linux lr-save 1 cells ;
M: linux has-toc f ;
M: linux reserved-area-size 2 cells ;
M: linux allows-null-dereference f ;
