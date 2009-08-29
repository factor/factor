! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences assocs fry
cpu.architecture
compiler.cfg.rpo
compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.stacks.uninitialized ;
IN: compiler.cfg.gc-checks

! Garbage collection check insertion. This pass runs after representation
! selection, so it must keep track of representations.

: insert-gc-check? ( bb -- ? )
    instructions>> [ ##allocation? ] any? ;

: blocks-with-gc ( cfg -- bbs )
    post-order [ insert-gc-check? ] filter ;

: insert-gc-check ( bb -- )
    dup '[
        int-rep next-vreg-rep
        int-rep next-vreg-rep
        f f _ uninitialized-locs \ ##gc new-insn
        prefix
    ] change-instructions drop ;

: insert-gc-checks ( cfg -- cfg' )
    dup blocks-with-gc [
        over compute-uninitialized-sets
        [ insert-gc-check ] each
    ] unless-empty ;