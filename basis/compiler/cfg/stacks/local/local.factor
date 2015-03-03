! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.instructions compiler.cfg.parallel-copy
compiler.cfg.registers compiler.cfg.stacks.height kernel make
math math.order namespaces sequences sets ;
FROM: namespaces => set ;
IN: compiler.cfg.stacks.local

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

: stack-changes ( replace-mapping -- insns )
    [ [ loc>vreg ] dip ] assoc-map parallel-copy ;

: height-changes ( current-height -- insns )
    [ emit-d>> <ds-loc> ] [ emit-r>> <rs-loc> ] bi 2array
    [ n>> 0 = not ] filter [ ##inc new swap >>loc ] map ;

: emit-changes ( -- )
    building get pop
    replace-mapping get stack-changes %
    current-height get height-changes %
    , ;

! inc-d/inc-r: these emit ##inc to change the stack height later
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
