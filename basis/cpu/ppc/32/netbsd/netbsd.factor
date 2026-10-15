! GNU NetBSD PowerPC32 uses GNU SysV arguments and final SVR4 struct returns.
USING: alien.c-types alien.complex cpu.architecture cpu.ppc
cpu.ppc.32.gnu cpu.ppc.32.svr4 kernel layouts math system ;
IN: cpu.ppc.32.netbsd

M: netbsd lr-save 1 cells ;
M: netbsd has-toc f ;
M: netbsd reserved-area-size 2 cells ;
M: netbsd allows-null-dereference f ;

! GNU complex-double is a scalar complex return in r3..r6, even though
! ordinary aggregates larger than eight bytes use a hidden result pointer.
M: ppc.32 return-struct-in-registers?
    dup lookup-c-type complex-double lookup-c-type =
    [ drop t ] [ heap-size 8 <= ] if ;
