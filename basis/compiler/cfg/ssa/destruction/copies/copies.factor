! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs hashtables fry kernel make namespaces
sequences compiler.cfg.ssa.destruction.state compiler.cfg.parallel-copy ;
IN: compiler.cfg.ssa.destruction.copies

ERROR: bad-copy ;

: compute-copies ( assoc -- assoc' )
    dup assoc-size <hashtable> [
        '[
            [
                2dup eq? [ 2drop ] [
                    _ 2dup key?
                    [ bad-copy ] [ set-at ] if
                ] if
            ] with each
        ] assoc-each
    ] keep ;

: insert-copies ( -- )
    waiting get [
        [ instructions>> building ] dip '[
            building get pop
            _ compute-copies parallel-copy
            ,
        ] with-variable
    ] assoc-each ;