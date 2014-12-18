! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.predecessors compiler.cfg.rpo
compiler.cfg.stacks.global compiler.cfg.stacks.height
compiler.cfg.stacks.local compiler.cfg.utilities fry kernel
locals make math sequences ;
IN: compiler.cfg.stacks.finalize

:: inserting-peeks ( from to -- assoc )
    to anticip-in
    from anticip-out from avail-out assoc-union
    assoc-diff ;

:: inserting-replaces ( from to -- assoc )
    from pending-out to pending-in assoc-diff
    to dead-in to live-in to anticip-in assoc-diff assoc-diff
    assoc-diff ;

: each-insertion ( ... assoc bb quot: ( ... vreg loc -- ... ) -- ... )
    '[ drop [ loc>vreg ] [ _ untranslate-loc ] bi @ ] assoc-each ; inline

ERROR: bad-peek dst loc ;

: insert-peeks ( from to -- )
    [ inserting-peeks ] keep
    [ dup n>> 0 < [ bad-peek ] [ ##peek, ] if ] each-insertion ;

: insert-replaces ( from to -- )
    [ inserting-replaces ] keep
    [ dup n>> 0 < [ 2drop ] [ ##replace, ] if ] each-insertion ;

: visit-edge ( from to -- )
    ! If both blocks are subroutine calls, don't bother
    ! computing anything.
    2dup [ kill-block?>> ] both? [ 2drop ] [
        2dup [ [ insert-replaces ] [ insert-peeks ] 2bi ##branch, ] V{ } make
        [ 2drop ] [ insert-basic-block ] if-empty
    ] if ;

: visit-block ( bb -- )
    [ predecessors>> ] keep '[ _ visit-edge ] each ;

: finalize-stack-shuffling ( cfg -- )
    [ needs-predecessors ]
    [ [ visit-block ] each-basic-block ]
    [ cfg-changed ] tri ;
