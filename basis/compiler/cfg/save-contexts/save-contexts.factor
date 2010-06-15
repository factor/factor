! Copyright (C) 2009, 2010 Slava Pestov.
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
            [ ##alien-assembly? ]
        } 1||
    ] any? ;

: insert-save-context ( bb -- )
    dup instructions>> dup needs-save-context? [
        tagged-rep next-vreg-rep
        tagged-rep next-vreg-rep
        \ ##save-context new-insn prefix
        >>instructions drop
    ] [ 2drop ] if ;

: insert-save-contexts ( cfg -- cfg' )
    dup [ insert-save-context ] each-basic-block ;
