! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel locals math math.order
sequences
compiler.cfg.rpo
compiler.cfg.utilities
compiler.cfg.dominance
compiler.cfg.instructions
compiler.cfg.coalescing.state
compiler.cfg.coalescing.forest
compiler.cfg.coalescing.copies
compiler.cfg.coalescing.renaming
compiler.cfg.coalescing.process-blocks ;
IN: compiler.cfg.coalescing

! Fast Copy Coalescing and Live-Range Identification
! http://www.cs.ucsd.edu/classes/sp02/cse231/kenpldi.pdf

! Dominance, liveness and def-use need to be computed

: process-blocks ( cfg -- )
    [ [ process-block ] if-has-phis ] each-basic-block ;

: break-interferences ( -- ) ;

: remove-phis-from-block ( bb -- )
    instructions>> [ ##phi? not ] filter-here ;

: remove-phis ( cfg -- )
    [ [ remove-phis-from-block ] if-has-phis ] each-basic-block ;

: coalesce ( cfg -- cfg' )
    init-coalescing
    dup compute-dfs
    dup process-blocks
    break-interferences
    dup insert-copies
    perform-renaming
    dup remove-phis ;