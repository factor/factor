! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel math math.order namespaces sets make
sequences combinators fry
compiler.cfg
compiler.cfg.hats
compiler.cfg.instructions
compiler.cfg.registers
compiler.cfg.stacks.height
compiler.cfg.parallel-copy ;
IN: compiler.cfg.stacks.local

! Local stack analysis. We build local peek and replace sets for every basic
! block while constructing the CFG.

SYMBOLS: peek-sets replace-sets kill-sets ;

SYMBOL: locs>vregs

: loc>vreg ( loc -- vreg ) locs>vregs get [ drop i ] cache ;
: vreg>loc ( vreg -- loc/f ) locs>vregs get value-at ;

TUPLE: current-height
{ d initial: 0 }
{ r initial: 0 }
{ emit-d initial: 0 }
{ emit-r initial: 0 } ;

SYMBOLS: local-peek-set local-replace-set replace-mapping ;

GENERIC: translate-local-loc ( loc -- loc' )
M: ds-loc translate-local-loc n>> current-height get d>> - <ds-loc> ;
M: rs-loc translate-local-loc n>> current-height get r>> - <rs-loc> ;

: emit-stack-changes ( -- )
    replace-mapping get dup assoc-empty? [ drop ] [
        [ [ loc>vreg ] dip ] assoc-map parallel-copy
    ] if ;

: emit-height-changes ( -- )
    current-height get
    [ emit-d>> dup 0 = [ drop ] [ ##inc-d ] if ]
    [ emit-r>> dup 0 = [ drop ] [ ##inc-r ] if ] bi ;

: emit-changes ( -- )
    ! Insert height and stack changes prior to the last instruction
    building get pop
    emit-stack-changes
    emit-height-changes
    , ;

! inc-d/inc-r: these emit ##inc-d/##inc-r to change the stack height later
: inc-d ( n -- )
    current-height get
    [ [ + ] change-emit-d drop ]
    [ [ + ] change-d drop ]
    2bi ;

: inc-r ( n -- )
    current-height get
    [ [ + ] change-emit-r drop ]
    [ [ + ] change-r drop ]
    2bi ;

: peek-loc ( loc -- vreg )
    translate-local-loc
    dup local-replace-set get key? [ dup local-peek-set get conjoin ] unless
    dup replace-mapping get at [ ] [ loc>vreg ] ?if ;

: replace-loc ( vreg loc -- )
    translate-local-loc
    2dup loc>vreg =
    [ nip replace-mapping get delete-at ]
    [
        [ local-replace-set get conjoin ]
        [ replace-mapping get set-at ]
        bi
    ] if ;

: compute-local-kill-set ( -- assoc )
    basic-block get current-height get
    [ [ ds-heights get at dup ] [ d>> ] bi* [-] iota [ swap - <ds-loc> ] with map ]
    [ [ rs-heights get at dup ] [ r>> ] bi* [-] iota [ swap - <rs-loc> ] with map ]
    [ drop local-replace-set get at ] 2tri
    [ append unique dup ] dip update ;

: begin-local-analysis ( -- )
    H{ } clone local-peek-set set
    H{ } clone local-replace-set set
    H{ } clone replace-mapping set
    current-height get
    [ 0 >>emit-d 0 >>emit-r drop ]
    [ [ d>> ] [ r>> ] bi basic-block get record-stack-heights ] bi ;

: end-local-analysis ( -- )
    emit-changes
    basic-block get {
        [ [ local-peek-set get ] dip peek-sets get set-at ]
        [ [ local-replace-set get ] dip replace-sets get set-at ]
        [ [ compute-local-kill-set ] dip kill-sets get set-at ]
    } cleave ;

: clone-current-height ( -- )
    current-height [ clone ] change ;

: peek-set ( bb -- assoc ) peek-sets get at ;
: replace-set ( bb -- assoc ) replace-sets get at ;
: kill-set ( bb -- assoc ) kill-sets get at ;