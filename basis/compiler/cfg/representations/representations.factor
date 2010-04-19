! Copyright (C) 2009, 2010 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators compiler.cfg
compiler.cfg.loop-detection compiler.cfg.registers
compiler.cfg.representations.rewrite
compiler.cfg.representations.selection namespaces ;
IN: compiler.cfg.representations

! Virtual register representation selection.

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
