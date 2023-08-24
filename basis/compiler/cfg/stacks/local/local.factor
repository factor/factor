! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
compiler.cfg.instructions compiler.cfg.parallel-copy
compiler.cfg.registers hash-sets kernel make math math.order
namespaces sequences sets ;
IN: compiler.cfg.stacks.local

TUPLE: height-state ds-begin rs-begin ds-inc rs-inc ;

: >loc< ( loc -- n ds? )
    [ n>> ] [ ds-loc? ] bi ;

: ds-height ( height-state -- n )
    [ ds-begin>> ] [ ds-inc>> ] bi + ;

: rs-height ( height-state -- n )
    [ rs-begin>> ] [ rs-inc>> ] bi + ;

: global-loc>local ( loc height-state -- loc' )
    [ clone dup >loc< ] dip swap [ ds-height ] [ rs-height ] if - >>n ;

: local-loc>global ( loc height-state -- loc' )
    [ clone dup >loc< ] dip swap [ ds-begin>> ] [ rs-begin>> ] if + >>n ;

: inc-stack ( loc -- )
    >loc< height-state get swap
    [ [ + ] change-ds-inc ] [ [ + ] change-rs-inc ] if drop ;

: height-state>insns ( height-state -- insns )
    [ ds-inc>> ds-loc ] [ rs-inc>> rs-loc ] bi [ new swap >>n ] 2bi@ 2array
    [ n>> 0 = ] reject [ ##inc new swap >>loc ] map ;

: reset-incs ( height-state -- )
    dup ds-inc>> '[ _ + ] change-ds-begin
    dup rs-inc>> '[ _ + ] change-rs-begin
    0 >>ds-inc 0 >>rs-inc drop ;

SYMBOLS: locs>vregs local-peek-set replaces ;

: loc>vreg ( loc -- vreg ) locs>vregs get [ drop next-vreg ] cache ;
: vreg>loc ( vreg -- loc/f ) locs>vregs get value-at ;

: replaces>copy-insns ( replaces -- insns )
    [ [ loc>vreg ] dip ] assoc-map parallel-copy ;

: changes>insns ( replaces height-state -- insns )
    [ replaces>copy-insns ] [ height-state>insns ] bi* append ;

: emit-insns ( replaces state -- )
    building get pop -rot changes>insns % , ;

: peek-loc ( loc -- vreg )
    height-state get global-loc>local
    [ replaces get at ]
    [ dup local-peek-set get adjoin loc>vreg ] ?unless ;

: replace-loc ( vreg loc -- )
    height-state get global-loc>local replaces get set-at ;

: kill-locations ( begin inc -- seq )
    0 min neg <iota> [ swap - ] with map ;

: local-kill-set ( ds-begin ds-inc rs-begin rs-inc -- set )
    [ kill-locations ] 2bi@
    [ [ <ds-loc> ] map ] [ [ <rs-loc> ] map ] bi*
    append >hash-set ;

: compute-local-kill-set ( height-state -- set )
    { [ ds-begin>> ] [ ds-inc>> ] [ rs-begin>> ] [ rs-inc>> ] } cleave
    local-kill-set ;

: begin-local-analysis ( basic-block -- )
    height-state [ clone ] change
    height-state get [ reset-incs ] keep >>height drop
    HS{ } clone local-peek-set namespaces:set
    H{ } clone replaces namespaces:set ;

: remove-redundant-replaces ( replaces -- replaces' )
    [ [ loc>vreg ] dip = ] assoc-reject ;

: end-local-analysis ( basic-block -- )
    replaces get remove-redundant-replaces
    over kill-block?>> [
        [ height-state get emit-insns ] keep
    ] unless
    keys >hash-set >>replaces
    local-peek-set get >>peeks
    height-state get compute-local-kill-set >>kills drop ;
