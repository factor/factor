! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs kernel fry accessors sequences make math locals
combinators compiler.cfg compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.utilities compiler.cfg.rpo compiler.cfg.stacks.local
compiler.cfg.stacks.global compiler.cfg.stacks.height
compiler.cfg.predecessors ;
IN: compiler.cfg.stacks.finalize

! This pass inserts peeks and replaces.

:: inserting-peeks ( from to -- assoc )
    ! A peek is inserted on an edge if the destination anticipates
    ! the stack location, the source does not anticipate it and
    ! it is not available from the source in a register.
    to anticip-in
    from anticip-out from avail-out assoc-union
    assoc-diff ;

:: inserting-replaces ( from to -- assoc )
    ! A replace is inserted on an edge if two conditions hold:
    ! - the location is not dead at the destination, OR
    !   the location is live at the destination but not available
    !   at the destination
    ! - the location is pending in the source but not the destination
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

: finalize-stack-shuffling ( cfg -- cfg' )
    needs-predecessors

    dup [ visit-block ] each-basic-block

    dup cfg-changed ;
