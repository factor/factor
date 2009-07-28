! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel locals math math.order
sequences namespaces sets
compiler.cfg.rpo
compiler.cfg.def-use
compiler.cfg.utilities
compiler.cfg.dominance
compiler.cfg.instructions
compiler.cfg.liveness.ssa
compiler.cfg.critical-edges
compiler.cfg.ssa.destruction.state
compiler.cfg.ssa.destruction.forest
compiler.cfg.ssa.destruction.copies
compiler.cfg.ssa.destruction.renaming
compiler.cfg.ssa.destruction.live-ranges
compiler.cfg.ssa.destruction.process-blocks ;
IN: compiler.cfg.ssa.destruction

! Based on "Fast Copy Coalescing and Live-Range Identification"
! http://www.cs.ucsd.edu/classes/sp02/cse231/kenpldi.pdf

! Dominance, liveness and def-use need to be computed

: process-blocks ( cfg -- )
    [ [ process-block ] if-has-phis ] each-basic-block ;

SYMBOL: seen

:: visit-renaming ( dst assoc src bb -- )
    src seen get key? [
        src dst bb waiting-for push-at
        src assoc delete-at
    ] [ src seen get conjoin ] if ;

:: break-interferences ( -- )
    V{ } clone seen set
    renaming-sets get [| dst assoc |
        assoc [| src bb |
            dst assoc src bb visit-renaming
        ] assoc-each
    ] assoc-each ;

: remove-phis-from-block ( bb -- )
    instructions>> [ ##phi? not ] filter-here ;

: remove-phis ( cfg -- )
    [ [ remove-phis-from-block ] if-has-phis ] each-basic-block ;

: destruct-ssa ( cfg -- cfg' )
    dup cfg-has-phis? [
        init-coalescing
        compute-ssa-live-sets
        dup split-critical-edges
        dup compute-def-use
        dup compute-dominance
        dup compute-live-ranges
        dup process-blocks
        break-interferences
        dup perform-renaming
        insert-copies
        dup remove-phis
    ] when ;