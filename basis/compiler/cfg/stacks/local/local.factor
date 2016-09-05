! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg.instructions
compiler.cfg.parallel-copy compiler.cfg.registers hash-sets kernel
make math math.order namespaces sequences sets ;
IN: compiler.cfg.stacks.local

: current-height ( state -- ds rs )
    first2 [ first ] bi@ ;

: >loc< ( loc -- n ds? )
    [ n>> ] [ ds-loc? ] bi ;

: modify-height ( state loc -- )
    >loc< 0 1 ? rot nth [ + ] with map! drop ;

: reset-emits ( state -- )
    [ 0 1 rot set-nth ] each ;

: height-state>insns ( state -- insns )
    [ second ] map { ds-loc rs-loc } [ new swap >>n ] 2map
    [ n>> 0 = ] reject [ ##inc new swap >>loc ] map ;

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

SYMBOLS: height-state locs>vregs local-peek-set replaces ;

: inc-stack ( loc -- )
    height-state get swap modify-height ;

: loc>vreg ( loc -- vreg ) locs>vregs get [ drop next-vreg ] cache ;
: vreg>loc ( vreg -- loc/f ) locs>vregs get value-at ;

: replaces>copy-insns ( replaces -- insns )
    [ [ loc>vreg ] dip ] assoc-map parallel-copy ;

: changes>insns ( replaces height-state -- insns )
    [ replaces>copy-insns ] [ height-state>insns ] bi* append ;

: emit-insns ( replaces state -- )
    building get pop -rot changes>insns % , ;

: peek-loc ( loc -- vreg )
    height-state get translate-local-loc dup replaces get at
    [ ] [ dup local-peek-set get adjoin loc>vreg ] ?if ;

: replace-loc ( vreg loc -- )
    height-state get translate-local-loc replaces get set-at ;

: record-stack-heights ( ds-height rs-height bb -- )
    [ rs-height<< ] keep ds-height<< ;

: compute-local-kill-set ( basic-block -- set )
    [ ds-height>> ] [ rs-height>> ] bi height-state get local-kill-set ;

: begin-local-analysis ( basic-block -- )
    height-state get dup reset-emits
    current-height rot record-stack-heights
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
    dup compute-local-kill-set >>kills drop ;
