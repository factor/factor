! Copyright (C) 2009 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel math namespaces sequences
compiler.cfg.linear-scan.live-intervals compiler.cfg.liveness ;
IN: compiler.cfg.linear-scan.resolve

: add-mapping ( from to -- )
    2drop
    ;

: resolve-value-data-flow ( bb to vreg -- )
    live-intervals get at
    [ [ block-to ] dip child-interval-at ]
    [ [ block-from ] dip child-interval-at ]
    bi-curry bi* 2dup = [ 2drop ] [
        add-mapping
    ] if ;

: resolve-mappings ( bb to -- )
    2drop
    ;

: resolve-edge-data-flow ( bb to -- )
    [ dup live-in [ resolve-value-data-flow ] with with each ]
    [ resolve-mappings ]
    2bi ; 

: resolve-block-data-flow ( bb -- )
    dup successors>> [
        resolve-edge-data-flow
    ] with each ;

: resolve-data-flow ( rpo -- )
    [ resolve-block-data-flow ] each ;