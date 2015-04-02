! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.instructions compiler.cfg.parallel-copy
compiler.cfg.registers compiler.cfg.stacks.height
hash-sets kernel make math math.order namespaces sequences sets ;
FROM: namespaces => set ;
IN: compiler.cfg.stacks.local

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

: translate-local-loc ( state loc -- loc' )
    >loc< [ 0 1 ? rot nth first - ] keep ds-loc rs-loc ? new swap >>n ;

: clone-height-state ( state -- state' )
    [ clone ] map ;

: initial-height-state ( -- state )
    { { 0 0 } { 0 0 } } clone-height-state ;

: kill-locations ( saved-height height -- seq )
    dupd [-] iota [ swap - ] with map ;

: local-kill-set ( ds-height rs-height state -- set )
    first2 [ first ] bi@ swapd [ kill-locations ] 2bi@
    [ [ <ds-loc> ] map ] [ [ <rs-loc> ] map ] bi*
    append >hash-set ;

SYMBOLS: height-state peek-sets replace-sets kill-sets locs>vregs ;

: inc-stack ( loc -- )
    height-state get swap modify-height ;

: loc>vreg ( loc -- vreg ) locs>vregs get [ drop next-vreg ] cache ;
: vreg>loc ( vreg -- loc/f ) locs>vregs get value-at ;

SYMBOLS: local-peek-set replace-mapping ;

: stack-changes ( replace-mapping -- insns )
    [ [ loc>vreg ] dip ] assoc-map parallel-copy ;

: emit-changes ( replace-mapping height-state -- )
    building get pop -rot [ stack-changes % ] [ height-state>insns % ] bi* , ;

: peek-loc ( loc -- vreg )
    height-state get swap translate-local-loc
    dup replace-mapping get at
    [ ] [ dup local-peek-set get adjoin loc>vreg ] ?if ;

: replace-loc ( vreg loc -- )
    height-state get swap translate-local-loc
    replace-mapping get set-at ;

: compute-local-kill-set ( -- set )
    basic-block get [ rs-heights get at ] [ ds-heights get at ] bi
    height-state get local-kill-set ;

: begin-local-analysis ( -- )
    HS{ } clone local-peek-set set
    H{ } clone replace-mapping set
    height-state get
    [ reset-emits ] [
        first2 [ first ] bi@ basic-block get record-stack-heights
    ] bi ;

: remove-redundant-replaces ( replace-mapping -- replace-mapping' )
    [ [ loc>vreg ] dip = not ] assoc-filter ;

: end-local-analysis ( basic-block -- )
    [
        replace-mapping get remove-redundant-replaces
        dup height-state get emit-changes keys
        swap replace-sets get set-at
    ]
    [ [ local-peek-set get ] dip peek-sets get set-at ]
    [ [ compute-local-kill-set ] dip kill-sets get set-at ] tri ;
