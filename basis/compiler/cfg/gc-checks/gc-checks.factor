! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences assocs fry
cpu.architecture layouts
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

GENERIC: allocation-size* ( insn -- n )

M: ##allot allocation-size* size>> ;

M: ##box-alien allocation-size* drop 4 cells ;

M: ##box-displaced-alien allocation-size* drop 4 cells ;

: allocation-size ( bb -- n )
    instructions>> [ ##allocation? ] filter [ allocation-size* ] sigma ;

: insert-gc-check ( bb -- )
    dup dup '[
        int-rep next-vreg-rep
        int-rep next-vreg-rep
        _ allocation-size
        f
        f
        _ uninitialized-locs
        \ ##gc new-insn
        prefix
    ] change-instructions drop ;

: insert-gc-checks ( cfg -- cfg' )
    dup blocks-with-gc [
        over compute-uninitialized-sets
        [ insert-gc-check ] each
    ] unless-empty ;