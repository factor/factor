! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math accessors sequences
compiler.cfg compiler.cfg.rpo compiler.cfg.utilities ;
IN: compiler.cfg.critical-edges

: critical-edge? ( from to -- ? )
    [ successors>> length 1 > ] [ predecessors>> length 1 > ] bi* and ;

: split-critical-edge ( from to -- )
    f <simple-block> insert-basic-block ;

: split-critical-edges ( cfg -- )
    dup [
        dup successors>> [
            2dup critical-edge?
            [ split-critical-edge ] [ 2drop ] if
        ] with each
    ] each-basic-block
    cfg-changed
    drop ;