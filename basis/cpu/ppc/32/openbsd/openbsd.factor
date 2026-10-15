! OpenBSD macppc uses Clang SysV; aggregate classification is shared with FreeBSD.
USING: cpu.architecture cpu.ppc cpu.ppc.32.abi cpu.ppc.32.clang
layouts system ;
IN: cpu.ppc.32.openbsd

M: openbsd lr-save 1 cells ;
M: openbsd has-toc f ;
M: openbsd reserved-area-size 2 cells ;
M: openbsd allows-null-dereference f ;
