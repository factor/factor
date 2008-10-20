! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes classes.private classes.algebra
combinators hashtables kernel layouts math fry namespaces
quotations sequences system vectors words effects alien
byte-arrays accessors sets math.order
combinators.short-circuit cpu.architecture
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.builder.hats ;
IN: compiler.cfg.builder.stacks

! Converting stack operations into register operations, while
! doing a bit of optimization along the way.
PREDICATE: small-slot < integer cells small-enough? ;

PREDICATE: small-tagged < integer tag-fixnum small-enough? ;

! Operands holding pointers to freshly-allocated objects which
! are guaranteed to be in the nursery
SYMBOL: fresh-objects

: fresh-object ( vreg/t -- ) fresh-objects get push ;

: fresh-object? ( vreg -- ? ) fresh-objects get memq? ;

! A compile-time stack
TUPLE: phantom-stack height stack ;

M: phantom-stack clone
    call-next-method [ clone ] change-stack ;

GENERIC: finalize-height ( stack -- )

: new-phantom-stack ( class -- stack )
    >r 0 V{ } clone r> boa ; inline

: (loc) ( m stack -- n )
    #! Utility for methods on <loc>
    height>> - ;

: (finalize-height) ( stack word -- )
    #! We consolidate multiple stack height changes until the
    #! last moment, and we emit the final height changing
    #! instruction here.
    '[ dup zero? [ drop ] [ _ execute ] if 0 ] change-height drop ; inline

GENERIC: <loc> ( n stack -- loc )

TUPLE: phantom-datastack < phantom-stack ;

: <phantom-datastack> ( -- stack )
    phantom-datastack new-phantom-stack ;

M: phantom-datastack <loc> (loc) <ds-loc> ;

M: phantom-datastack finalize-height
    \ ##inc-d (finalize-height) ;

TUPLE: phantom-retainstack < phantom-stack ;

: <phantom-retainstack> ( -- stack )
    phantom-retainstack new-phantom-stack ;

M: phantom-retainstack <loc> (loc) <rs-loc> ;

M: phantom-retainstack finalize-height
    \ ##inc-r (finalize-height) ;

: phantom-locs ( n phantom -- locs )
    #! A sequence of n ds-locs or rs-locs indexing the stack.
    [ <reversed> ] dip '[ _ <loc> ] map ;

: phantom-locs* ( phantom -- locs )
    [ stack>> length ] keep phantom-locs ;

: phantoms ( -- phantom phantom )
    phantom-datastack get phantom-retainstack get ;

: (each-loc) ( phantom quot -- )
    >r [ phantom-locs* ] [ stack>> ] bi r> 2each ; inline

: each-loc ( quot -- )
    phantoms 2array swap '[ _ (each-loc) ] each ; inline

: adjust-phantom ( n phantom -- )
    swap '[ _ + ] change-height drop ;

: cut-phantom ( n phantom -- seq )
    swap '[ _ cut* swap ] change-stack drop ;

: phantom-append ( seq stack -- )
    over length over adjust-phantom stack>> push-all ;

: add-locs ( n phantom -- )
    2dup stack>> length <= [
        2drop
    ] [
        [ phantom-locs ] keep
        [ stack>> length head-slice* ] keep
        [ append >vector ] change-stack drop
    ] if ;

: phantom-input ( n phantom -- seq )
    2dup add-locs
    2dup cut-phantom
    >r >r neg r> adjust-phantom r> ;

: each-phantom ( quot -- ) phantoms rot bi@ ; inline

: finalize-heights ( -- ) [ finalize-height ] each-phantom ;

GENERIC: lazy-load ( loc/vreg -- vreg )
M: loc lazy-load ^^peek ;
M: vreg lazy-load ;

GENERIC: live-loc? ( actual current -- ? )
M: vreg live-loc? 2drop f ;
M: loc live-loc? { [ [ class ] bi@ = ] [ [ n>> ] bi@ = not ] } 2&& ;

: (live-locs) ( phantom -- seq )
    #! Discard locs which haven't moved
    [ phantom-locs* ] [ stack>> ] bi zip
    [ live-loc? ] assoc-filter
    values ;

: live-locs ( -- seq )
    [ (live-locs) ] each-phantom append prune ;

GENERIC: lazy-store ( dst src -- )

M: vreg lazy-store 2drop ;

M: loc lazy-store
    2dup live-loc? [
        \ live-locs get at swap ##replace
    ] [ 2drop ] if ;

: finalize-locs ( -- )
    #! Perform any deferred stack shuffling.
    live-locs [ dup lazy-load ] H{ } map>assoc
    dup assoc-empty? [ drop ] [
        \ live-locs set
        [ lazy-store ] each-loc
    ] if ;

: finalize-vregs ( -- )
    #! Store any vregs to their final stack locations.
    [ dup loc? [ 2drop ] [ swap ##replace ] if ] each-loc ;

: clear-phantoms ( -- )
    [ stack>> delete-all ] each-phantom ;

: finalize-contents ( -- )
    finalize-locs finalize-vregs clear-phantoms ;

! Loading stacks to vregs
: finalize-phantoms ( -- )
    #! Commit all deferred stacking shuffling, and ensure the
    #! in-memory data and retain stacks are up to date with
    #! respect to the compiler's current picture.
    finalize-contents
    finalize-heights
    fresh-objects get [
        empty? [ ##simple-stack-frame ##gc ] unless
    ] [ delete-all ] bi ;

: init-phantoms ( -- )
    V{ } clone fresh-objects set
    <phantom-datastack> phantom-datastack set
    <phantom-retainstack> phantom-retainstack set ;

: copy-phantoms ( -- )
    fresh-objects [ clone ] change
    phantom-datastack [ clone ] change
    phantom-retainstack [ clone ] change ;

: phantom-push ( obj -- )
    1 phantom-datastack get adjust-phantom
    phantom-datastack get stack>> push ;

: phantom-shuffle ( shuffle -- )
    [ in>> length phantom-datastack get phantom-input ] keep
    shuffle phantom-datastack get phantom-append ;

: phantom->r ( n -- )
    phantom-datastack get phantom-input
    phantom-retainstack get phantom-append ;

: phantom-r> ( n -- )
    phantom-retainstack get phantom-input
    phantom-datastack get phantom-append ;

: phantom-drop ( n -- )
    phantom-datastack get phantom-input drop ;

: phantom-rdrop ( n -- )
    phantom-retainstack get phantom-input drop ;

: phantom-load ( n -- vreg )
    phantom-datastack get phantom-input [ lazy-load ] map ;

: phantom-pop ( -- vreg )
    1 phantom-load first ;

: 2phantom-pop ( -- vreg1 vreg2 )
    2 phantom-load first2 ;

: 3phantom-pop ( -- vreg1 vreg2 vreg3 )
    3 phantom-load first3 ;
