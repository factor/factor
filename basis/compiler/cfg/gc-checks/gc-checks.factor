! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences assocs fry
compiler.cfg.rpo
compiler.cfg.hats
compiler.cfg.registers
compiler.cfg.instructions
compiler.cfg.stacks.uninitialized ;
IN: compiler.cfg.gc-checks

: insert-gc-check? ( bb -- ? )
    instructions>> [ ##allocation? ] any? ;

: blocks-with-gc ( cfg -- bbs )
    post-order [ insert-gc-check? ] filter ;

: insert-gc-check ( bb -- )
    dup '[
        i i f _ uninitialized-locs \ ##gc new-insn
        prefix
    ] change-instructions drop ;

: insert-gc-checks ( cfg -- cfg' )
    dup blocks-with-gc [
        over compute-uninitialized-sets
        [ insert-gc-check ] each
    ] unless-empty ;