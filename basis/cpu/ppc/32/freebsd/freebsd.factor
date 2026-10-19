! FreeBSD PowerPC32 uses Clang SysV.
USING: cpu.architecture cpu.ppc cpu.ppc.32.abi cpu.ppc.32.clang
layouts system ;
QUALIFIED: cpu.ppc.32.clang
IN: cpu.ppc.32.freebsd

M: freebsd lr-save 1 cells ;
M: freebsd has-toc f ;
M: freebsd reserved-area-size 2 cells ;
M: freebsd allows-null-dereference f ;

! Preserve the existing helper API.
: ppc32-return-components ( size -- offsets parts )
    cpu.ppc.32.clang:ppc32-return-components ;
