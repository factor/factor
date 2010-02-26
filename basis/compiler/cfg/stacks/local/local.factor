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
FROM: namespaces => set ;
IN: compiler.cfg.stacks.local

! Local stack analysis. We build three sets for every basic block
! in the CFG:
! - peek-set: all stack locations that the block reads before writing
! - replace-set: all stack locations that the block writes
! - kill-set: all stack locations which become unavailable after the
!   block ends because of the stack height being decremented
! This is done while constructing the CFG.

SYMBOLS: peek-sets replace-sets kill-sets ;

SYMBOL: locs>vregs

: loc>vreg ( loc -- vreg ) locs>vregs get [ drop next-vreg ] cache ;
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
    dup replace-mapping get at
    [ ] [ dup local-peek-set get conjoin loc>vreg ] ?if ;

: replace-loc ( vreg loc -- )
    translate-local-loc replace-mapping get set-at ;

: compute-local-kill-set ( -- assoc )
    basic-block get current-height get
    [ [ ds-heights get at dup ] [ d>> ] bi* [-] iota [ swap - <ds-loc> ] with map ]
    [ [ rs-heights get at dup ] [ r>> ] bi* [-] iota [ swap - <rs-loc> ] with map ] 2bi
    append unique ;

: begin-local-analysis ( -- )
    H{ } clone local-peek-set set
    H{ } clone replace-mapping set
    current-height get
    [ 0 >>emit-d 0 >>emit-r drop ]
    [ [ d>> ] [ r>> ] bi basic-block get record-stack-heights ] bi ;

: remove-redundant-replaces ( -- )
    replace-mapping get [ [ loc>vreg ] dip = not ] assoc-filter
    [ replace-mapping set ] [ keys unique local-replace-set set ] bi ;

: end-local-analysis ( -- )
    remove-redundant-replaces
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
