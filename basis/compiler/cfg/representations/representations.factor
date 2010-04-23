! Copyright (C) 2009, 2010 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators namespaces
compiler.cfg
compiler.cfg.registers
compiler.cfg.loop-detection
compiler.cfg.representations.rewrite
compiler.cfg.representations.peephole
compiler.cfg.representations.selection ;
IN: compiler.cfg.representations

! Virtual register representation selection. This is where
! decisions about integer tagging and float and vector boxing
! are made. The appropriate conversion operations inserted
! after a cost analysis.

: select-representations ( cfg -- cfg' )
    needs-loops

    {
        [ compute-possibilities ]
        [ compute-representations ]
        [ compute-phi-representations ]
        [ insert-conversions ]
        [ ]
    } cleave
    representations get cfg get (>>reps) ;
