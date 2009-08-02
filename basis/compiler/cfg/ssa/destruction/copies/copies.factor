! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs hashtables fry kernel make namespaces
sets sequences compiler.cfg.ssa.destruction.state
compiler.cfg.parallel-copy compiler.cfg.utilities ;
IN: compiler.cfg.ssa.destruction.copies

ERROR: bad-copy ;

: compute-copies ( assoc -- assoc' )
    dup assoc-size <hashtable> [
        '[
            prune [
                2dup eq? [ 2drop ] [
                    _ 2dup key?
                    [ bad-copy ] [ set-at ] if
                ] if
            ] with each
        ] assoc-each
    ] keep ;

: insert-copies ( -- )
    waiting get [
        '[ _ compute-copies parallel-copy ] add-instructions
    ] assoc-each ;