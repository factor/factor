! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.rpo cpu.architecture kernel sequences vectors ;
IN: compiler.cfg.save-contexts

! Insert context saves.

: needs-save-context? ( insns -- ? )
    [
        {
            [ ##unary-float-function? ]
            [ ##binary-float-function? ]
            [ ##alien-invoke? ]
            [ ##alien-indirect? ]
        } 1||
    ] any? ;

: needs-callback-context? ( insns -- ? )
    [
        {
            [ ##alien-invoke? ]
            [ ##alien-indirect? ]
        } 1||
    ] any? ;

: insert-save-context ( bb -- )
    dup instructions>> dup needs-save-context? [
        int-rep next-vreg-rep
        int-rep next-vreg-rep
        pick needs-callback-context?
        \ ##save-context new-insn prefix
        >>instructions drop
    ] [ 2drop ] if ;

: insert-save-contexts ( cfg -- cfg' )
    dup [ insert-save-context ] each-basic-block ;
