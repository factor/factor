! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel math namespaces sets make sequences
compiler.cfg compiler.cfg.hats
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.stacks.height ;
IN: compiler.cfg.stacks.local

! Local stack analysis. We build local peek and replace sets for every basic
! block while constructing the CFG.

SYMBOLS: peek-sets replace-sets ;

SYMBOL: locs>vregs

: loc>vreg ( loc -- vreg ) locs>vregs get [ drop i ] cache ;

TUPLE: current-height { d initial: 0 } { r initial: 0 } { emit-d initial: 0 } { emit-r initial: 0 } ;

SYMBOLS: copies local-peek-set local-replace-set ;

: record-copy ( dst src -- ) swap copies get set-at ;
: resolve-copy ( vreg -- vreg' ) copies get ?at drop ;

GENERIC: translate-local-loc ( loc -- loc' )
M: ds-loc translate-local-loc n>> current-height get d>> - <ds-loc> ;
M: rs-loc translate-local-loc n>> current-height get r>> - <rs-loc> ;

: emit-height-changes ( -- )
    ! Insert height changes prior to the last instruction
    building get pop
    current-height get
    [ emit-d>> dup 0 = [ drop ] [ ##inc-d ] if ]
    [ emit-r>> dup 0 = [ drop ] [ ##inc-r ] if ] bi
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
    [ dup local-replace-set get key? [ drop ] [ local-peek-set get conjoin ] if ]
    [ loc>vreg [ i ] dip [ record-copy ] [ ##copy ] [ drop ] 2tri ]
    bi ;

: replace-loc ( vreg loc -- )
    translate-local-loc
    2dup [ resolve-copy ] dip loc>vreg = [ 2drop ] [
        [ local-replace-set get conjoin ]
        [ loc>vreg swap ##copy ]
        bi
    ] if ;

: begin-local-analysis ( -- )
    H{ } clone copies set
    H{ } clone local-peek-set set
    H{ } clone local-replace-set set
    current-height get 0 >>emit-d 0 >>emit-r drop
    current-height get [ d>> ] [ r>> ] bi basic-block get record-stack-heights ;

: end-local-analysis ( -- )
    emit-height-changes
    local-peek-set get basic-block get peek-sets get set-at
    local-replace-set get basic-block get replace-sets get set-at ;

: clone-current-height ( -- )
    current-height [ clone ] change ;

: peek-set ( bb -- assoc ) peek-sets get at ;
: replace-set ( bb -- assoc ) replace-sets get at ;
