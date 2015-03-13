! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors biassocs compiler.cfg compiler.cfg.registers
compiler.cfg.stacks.finalize compiler.cfg.stacks.global
compiler.cfg.stacks.height compiler.cfg.stacks.local compiler.cfg.utilities
kernel math namespaces sequences ;
IN: compiler.cfg.stacks

: begin-stack-analysis ( -- )
    <bihash> locs>vregs set
    H{ } clone ds-heights set
    H{ } clone rs-heights set
    H{ } clone peek-sets set
    H{ } clone replace-sets set
    H{ } clone kill-sets set
    current-height new current-height set ;

: end-stack-analysis ( -- )
    cfg get
    {
        compute-anticip-sets
        compute-live-sets
        compute-pending-sets
        compute-dead-sets
        compute-avail-sets
        finalize-stack-shuffling
    } apply-passes ;

: ds-drop ( -- ) -1 inc-d ;

: ds-peek ( -- vreg ) D 0 peek-loc ;

: ds-pop ( -- vreg ) ds-peek ds-drop ;

: ds-push ( vreg -- ) 1 inc-d D 0 replace-loc ;

: ds-load ( n -- vregs )
    dup 0 =
    [ drop f ]
    [ [ iota <reversed> [ <ds-loc> peek-loc ] map ] [ neg inc-d ] bi ] if ;

: ds-store ( vregs -- )
    [
        <reversed>
        [ length inc-d ]
        [ [ <ds-loc> replace-loc ] each-index ] bi
    ] unless-empty ;

: rs-store ( vregs -- )
    [
        <reversed>
        [ length inc-r ]
        [ [ <rs-loc> replace-loc ] each-index ] bi
    ] unless-empty ;

: (2inputs) ( -- vreg1 vreg2 )
    D 1 peek-loc D 0 peek-loc ;

: 2inputs ( -- vreg1 vreg2 )
    (2inputs) -2 inc-d ;

: (3inputs) ( -- vreg1 vreg2 vreg3 )
    D 2 peek-loc D 1 peek-loc D 0 peek-loc ;

: 3inputs ( -- vreg1 vreg2 vreg3 )
    (3inputs) -3 inc-d ;

: binary-op ( quot -- )
    [ 2inputs ] dip call ds-push ; inline

: unary-op ( quot -- )
    [ ds-pop ] dip call ds-push ; inline

: adjust-d ( n -- ) current-height get [ + ] change-d drop ;
