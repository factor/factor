! Copyright (C) 2009, 2010 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: combinators
compiler.cfg
compiler.cfg.registers
compiler.cfg.predecessors
compiler.cfg.loop-detection
compiler.cfg.representations.rewrite
compiler.cfg.representations.peephole
compiler.cfg.representations.selection
compiler.cfg.representations.coalescing ;
IN: compiler.cfg.representations

! Virtual register representation selection. This is where
! decisions about integer tagging and float and vector boxing
! are made. The appropriate conversion operations inserted
! after a cost analysis.

: select-representations ( cfg -- cfg' )
    needs-loops
    {
        [ needs-predecessors ]
        [ compute-components ]
        [ compute-possibilities ]
        [ compute-representations ]
        [ insert-conversions ]
        [ ]
    } cleave ;
