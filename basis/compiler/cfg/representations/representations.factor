! Copyright (C) 2009, 2010 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING:
compiler.cfg
compiler.cfg.loop-detection
compiler.cfg.predecessors
compiler.cfg.registers
compiler.cfg.representations.coalescing
compiler.cfg.representations.peephole
compiler.cfg.representations.rewrite
compiler.cfg.representations.selection
compiler.cfg.utilities ;
IN: compiler.cfg.representations

: select-representations ( cfg -- )
    {
        needs-loops
        needs-predecessors
        compute-components
        compute-possibilities
        compute-representations
        insert-conversions
    } apply-passes ;
