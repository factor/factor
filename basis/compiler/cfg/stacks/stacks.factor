! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors biassocs compiler.cfg compiler.cfg.registers
compiler.cfg.stacks.finalize compiler.cfg.stacks.global
compiler.cfg.stacks.height compiler.cfg.stacks.local compiler.cfg.utilities
fry kernel math namespaces sequences ;
IN: compiler.cfg.stacks

: begin-stack-analysis ( -- )
    <bihash> locs>vregs set
    H{ } clone ds-heights set
    H{ } clone rs-heights set
    H{ } clone peek-sets set
    H{ } clone replace-sets set
    H{ } clone kill-sets set
    initial-height-state height-state set ;

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

: ds-drop ( -- ) -1 <ds-loc> inc-stack ;

: ds-peek ( -- vreg ) D 0 peek-loc ;

: ds-pop ( -- vreg ) ds-peek ds-drop ;

: ds-push ( vreg -- )
    1 <ds-loc> inc-stack D 0 replace-loc ;

: stack-locs ( loc-class n -- locs )
    iota [ swap new swap >>n ] with map <reversed> ;

: vregs>stack-locs ( loc-class vregs -- locs )
    length stack-locs ;

: ds-load ( n -- vregs )
    [ iota <reversed> [ <ds-loc> peek-loc ] map ]
    [ neg <ds-loc> inc-stack ] bi ;

: store-vregs ( vregs loc-class -- )
    over vregs>stack-locs [ replace-loc ] 2each ;

: (2inputs) ( -- vreg1 vreg2 )
    D 1 peek-loc D 0 peek-loc ;

: 2inputs ( -- vreg1 vreg2 )
    (2inputs) -2 <ds-loc> inc-stack ;

: (3inputs) ( -- vreg1 vreg2 vreg3 )
    D 2 peek-loc D 1 peek-loc D 0 peek-loc ;

: 3inputs ( -- vreg1 vreg2 vreg3 )
    (3inputs) -3 <ds-loc> inc-stack ;

: binary-op ( quot -- )
    [ 2inputs ] dip call ds-push ; inline

: unary-op ( quot -- )
    [ ds-pop ] dip call ds-push ; inline

: adjust-d ( n -- )
    <ds-loc> height-state get swap adjust ;
