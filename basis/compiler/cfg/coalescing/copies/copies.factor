! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs hashtables fry kernel make namespaces
sequences compiler.cfg.coalescing.state compiler.cfg.parallel-copy ;
IN: compiler.cfg.coalescing.copies

: compute-copies ( assoc -- assoc' )
    dup assoc-size <hashtable> [
        '[
            [ 2dup eq? [ 2drop ] [ _ 2dup key? [ "OOPS" throw ] [ set-at ] if ] if ] with each
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