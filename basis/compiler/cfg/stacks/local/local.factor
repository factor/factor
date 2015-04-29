! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.instructions compiler.cfg.parallel-copy
compiler.cfg.registers compiler.cfg.stacks.height
fry hash-sets kernel make math math.order namespaces sequences sets ;
FROM: namespaces => set ;
IN: compiler.cfg.stacks.local

: current-height ( state -- ds rs )
    first2 [ first ] bi@ ;

: >loc< ( loc -- n ds? )
    [ n>> ] [ ds-loc? ] bi ;

: modify-height ( state loc -- )
    >loc< 0 1 ? rot nth [ + ] with map! drop ;

: adjust ( state loc -- )
    >loc< 0 1 ? rot nth dup first swapd + 0 rot set-nth ;

: reset-emits ( state -- )
    [ 0 1 rot set-nth ] each ;

: height-state>insns ( state -- insns )
    [ second ] map { ds-loc rs-loc } [ new swap >>n ] 2map
    [ n>> 0 = not ] filter [ ##inc new swap >>loc ] map ;

: translate-local-loc ( loc state -- loc' )
    [ clone ] dip over >loc< 0 1 ? rot nth first - >>n ;

: clone-height-state ( state -- state' )
    [ clone ] map ;

: initial-height-state ( -- state )
    { { 0 0 } { 0 0 } } clone-height-state ;

: kill-locations ( saved-height height -- seq )
    dupd [-] iota [ swap - ] with map ;

: local-kill-set ( ds-height rs-height state -- set )
    current-height swapd [ kill-locations ] 2bi@
    [ [ <ds-loc> ] map ] [ [ <rs-loc> ] map ] bi*
    append >hash-set ;

SYMBOLS: height-state peek-sets replace-sets kill-sets locs>vregs ;

: inc-stack ( loc -- )
    height-state get swap modify-height ;

: loc>vreg ( loc -- vreg ) locs>vregs get [ drop next-vreg ] cache ;
: vreg>loc ( vreg -- loc/f ) locs>vregs get value-at ;

SYMBOLS: local-peek-set replaces ;

: replaces>copy-insns ( replaces -- insns )
    [ [ loc>vreg ] dip ] assoc-map parallel-copy ;

: changes>insns ( replaces height-state -- insns )
    [ replaces>copy-insns ] [ height-state>insns ] bi* append ;

: emit-changes ( replaces state -- )
    building get pop -rot changes>insns % , ;

: peek-loc ( loc -- vreg )
    height-state get translate-local-loc dup replaces get at
    [ ] [ dup local-peek-set get adjoin loc>vreg ] ?if ;

: replace-loc ( vreg loc -- )
    height-state get translate-local-loc replaces get set-at ;

: compute-local-kill-set ( basic-block -- set )
    [ ds-heights get at ] [ rs-heights get at ] bi
    height-state get local-kill-set ;

: begin-local-analysis ( basic-block -- )
    height-state get dup reset-emits
    current-height rot record-stack-heights
    HS{ } clone local-peek-set set
    H{ } clone replaces set ;

: remove-redundant-replaces ( replaces -- replaces' )
    [ [ loc>vreg ] dip = not ] assoc-filter ;

: end-local-analysis ( basic-block -- )
    [
        replaces get remove-redundant-replaces
        dup height-state get emit-changes keys
        swap replace-sets get set-at
    ]
    [ [ local-peek-set get ] dip peek-sets get set-at ]
    [ [ compute-local-kill-set ] keep kill-sets get set-at ] tri ;
