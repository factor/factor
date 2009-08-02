! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math accessors sequences locals assocs fry
compiler.cfg compiler.cfg.rpo compiler.cfg.utilities ;
IN: compiler.cfg.critical-edges

: critical-edge? ( from to -- ? )
    [ successors>> length 1 > ] [ predecessors>> length 1 > ] bi* and ;

: new-key ( new-key old-key assoc -- )
    [ delete-at* ] keep '[ swap _ set-at ] [ 2drop ] if ;

:: update-phis ( from to bb -- )
    ! Any phi nodes in 'to' which reference 'from'
    ! should now reference 'bb'.
    to [ [ bb from ] dip inputs>> new-key ] each-phi ;

: split-critical-edge ( from to -- )
    f <simple-block> [ insert-basic-block ] [ update-phis ] 3bi ; 

: split-critical-edges ( cfg -- )
    dup [
        dup successors>> [
            2dup critical-edge?
            [ split-critical-edge ] [ 2drop ] if
        ] with each
    ] each-basic-block
    cfg-changed
    drop ;