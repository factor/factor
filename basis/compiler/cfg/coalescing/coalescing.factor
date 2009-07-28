! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel locals math math.order
sequences namespaces sets
compiler.cfg.rpo
compiler.cfg.def-use
compiler.cfg.utilities
compiler.cfg.dominance
compiler.cfg.instructions
compiler.cfg.critical-edges
compiler.cfg.coalescing.state
compiler.cfg.coalescing.forest
compiler.cfg.coalescing.copies
compiler.cfg.coalescing.renaming
compiler.cfg.coalescing.live-ranges
compiler.cfg.coalescing.process-blocks ;
IN: compiler.cfg.coalescing

! Fast Copy Coalescing and Live-Range Identification
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
            src seen get key?
            [ dst assoc src bb visit-renaming ]
            [ src seen get conjoin ]
            if
        ] assoc-each
    ] assoc-each ;

: remove-phis-from-block ( bb -- )
    instructions>> [ ##phi? not ] filter-here ;

: remove-phis ( cfg -- )
    [ [ remove-phis-from-block ] if-has-phis ] each-basic-block ;

: coalesce ( cfg -- cfg' )
    init-coalescing
    dup split-critical-edges
    dup compute-def-use
    dup compute-dominance
    dup compute-dfs
    dup compute-live-ranges
    dup process-blocks
    break-interferences
    dup perform-renaming
    insert-copies
    dup remove-phis ;