! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays generic hashtables inference io kernel math
namespaces prettyprint sequences vectors words ;

! Register allocation

! Hash mapping reg-classes to mutable vectors
: free-vregs ( reg-class -- seq ) \ free-vregs get hash ;

: alloc-reg ( reg-class -- vreg ) free-vregs pop ;

: take-reg ( vreg -- ) dup delegate free-vregs delete ;

: reg-spec>class ( spec -- class )
    float eq? T{ float-regs f 8 } T{ int-regs } ? ;

: alloc-vregs ( template -- template )
    [
        dup integer? [
            <int-vreg> dup take-reg
        ] [
            reg-spec>class alloc-reg
        ] if
    ] map ;

! A data stack location.
TUPLE: ds-loc n ;

! A call stack location.
TUPLE: cs-loc n ;

UNION: loc ds-loc cs-loc ;

TUPLE: phantom-stack height ;

C: phantom-stack ( -- stack )
    0 over set-phantom-stack-height
    V{ } clone over set-delegate ;

GENERIC: finalize-height ( n stack -- )

GENERIC: <loc> ( n stack -- loc )

: (loc)
    #! Utility for methods on <loc>
    phantom-stack-height - ;

: (finalize-height) ( stack word -- )
    #! We consolidate multiple stack height changes until the
    #! last moment, and we emit the final height changing
    #! instruction here.
    swap [
        phantom-stack-height
        dup zero? [ 2drop ] [ swap execute ] if
        0
    ] keep set-phantom-stack-height ; inline

TUPLE: phantom-datastack ;

C: phantom-datastack
    [ >r <phantom-stack> r> set-delegate ] keep ;

M: phantom-datastack <loc> (loc) <ds-loc> ;

M: phantom-datastack finalize-height
    \ %inc-d (finalize-height) ;

TUPLE: phantom-callstack ;

C: phantom-callstack
    [ >r <phantom-stack> r> set-delegate ] keep ;

M: phantom-callstack <loc> (loc) <cs-loc> ;

M: phantom-callstack finalize-height
    \ %inc-r (finalize-height) ;

: phantom-locs ( n phantom -- locs )
    #! A sequence of n ds-locs or cs-locs indexing the stack.
    swap reverse-slice [ swap <loc> ] map-with ;

: phantom-locs* ( phantom -- locs )
    dup length swap phantom-locs ;

: adjust-phantom ( n phantom -- )
    [ phantom-stack-height + ] keep set-phantom-stack-height ;

GENERIC: cut-phantom ( n phantom -- seq )

M: phantom-stack cut-phantom ( n phantom -- seq )
    [ delegate cut* swap ] keep set-delegate ;

SYMBOL: phantom-d
SYMBOL: phantom-r

: phantoms ( -- phantom phantom ) phantom-d get phantom-r get ;

: init-templates ( -- )
    <phantom-datastack> phantom-d set
    <phantom-callstack> phantom-r set ;

: finalize-heights ( -- )
    phantoms [ finalize-height ] 2apply ;

: stack>new-vreg ( loc spec -- vreg )
    reg-spec>class alloc-reg [ swap %peek ] keep ;

: vreg>stack ( value loc -- )
    over loc? [
        2drop
    ] [
        over [ %replace ] [ 2drop ] if
    ] if ;

: vregs>stack ( phantom -- )
    [
        dup phantom-locs* [ vreg>stack ] 2each 0
    ] keep set-length ;

: (live-locs) ( seq -- seq )
    dup phantom-locs* [ 2array ] 2map
    [ first2 over loc? >r = not r> and ] subset
    [ first ] map ;

: live-locs ( phantom phantom -- hash )
    [ (live-locs) ] 2apply append prune
    [ dup f stack>new-vreg ] map>hash ;

: lazy-store ( value loc -- )
    over loc? [
        2dup = [
            2drop
        ] [
            >r \ live-locs get hash r> vreg>stack 
        ] if
    ] [
        2drop
    ] if ;

: flush-locs ( phantom phantom -- )
    2dup live-locs \ live-locs set
    [ dup phantom-locs* [ lazy-store ] 2each ] 2apply ;

: finalize-contents ( -- )
    phantoms 2dup flush-locs [ vregs>stack ] 2apply ;

: end-basic-block ( -- )
    finalize-contents finalize-heights ;

: used-vregs ( -- seq )
    phantoms append [ vreg? ] subset ;

: (compute-free-vregs) ( used class -- vector )
    dup vregs length reverse [ swap <vreg> ] map-with diff
    >vector ;

: compute-free-vregs ( -- )
    used-vregs
    { T{ int-regs } T{ float-regs f 8 } }
    [ 2dup (compute-free-vregs) ] map>hash \ free-vregs set
    drop ;

: additional-vregs# ( seq seq -- n )
    2array phantoms 2array [ [ length ] map ] 2apply v-
    0 [ 0 max + ] reduce ;

: free-vregs* ( -- int# float# )
    T{ int-regs } free-vregs length
    phantoms [ [ loc? ] subset length ] 2apply + -
    T{ float-regs f 8 } free-vregs length ;

: ensure-vregs ( int# float# -- )
    compute-free-vregs free-vregs* swapd <= >r <= r> and
    [ finalize-contents compute-free-vregs ] unless ;

: spec>vreg ( spec -- vreg )
    dup integer? [ <int-vreg> ] [ reg-spec>class alloc-reg ] if ;

: (lazy-load) ( value spec -- value )
    spec>vreg [
        swap {
            { [ dup loc? ] [ %peek ] }
            { [ dup vreg? ] [ %move ] }
            { [ t ] [ 2drop ] }
        } cond
    ] keep ;

: lazy-load ( values template -- template )
    [ first2 >r (lazy-load) r> 2array ] 2map ;

: stack>vregs ( phantom template -- values )
    [
        [ first ] map alloc-vregs dup length rot phantom-locs
        [ dupd %peek ] 2map
    ] 2keep length neg swap adjust-phantom ;

: compatible-vreg? ( n vreg -- ? )
    dup [ int-regs? ] is? [ vreg-n = ] [ 2drop f ] if ;

: compatible-values? ( value template -- ? )
    {
        { [ over loc? ] [ 2drop t ] }
        { [ dup { f float } memq? ] [ 2drop t ] }
        { [ dup integer? ] [ swap compatible-vreg? ] }
    } cond ;

: template-match? ( template phantom -- ? )
    [ reverse-slice ] 2apply
    t [ swap first compatible-values? and ] 2reduce ;

: split-template ( template phantom -- slow fast )
    over length over length <=
    [ drop { } swap ] [ length swap cut* ] if ;

: match-template ( template -- slow fast )
    phantom-d get 2dup template-match?
    [ split-template ] [ drop { } ] if ;

: fast-input ( template -- )
    phantom-d get
    over length neg over adjust-phantom
    over length swap cut-phantom
    swap lazy-load [ first2 set ] each ;

: phantom-push ( obj stack -- )
    1 over adjust-phantom push ;

: phantom-append ( seq stack -- )
    over length over adjust-phantom swap nappend ;

: (template-outputs) ( seq stack -- )
    phantoms swapd phantom-append phantom-append ;

SYMBOL: +input
SYMBOL: +output
SYMBOL: +scratch
SYMBOL: +clobber

: fix-spec ( spec -- spec )
    H{
        { +input { } }
        { +output { } }
        { +scratch { } }
        { +clobber { } }
    } swap hash-union ;

: output-vregs ( -- seq seq )
    +output +clobber [ get [ get ] map ] 2apply ;

: outputs-clash? ( -- ? )
    output-vregs append phantoms append
    [ swap member? ] contains-with? ;

: phantom-vregs ( values template -- ) [ second set ] 2each ;

: slow-input ( template -- )
    ! Are we loading stuff from the stack? Then flush out
    ! remaining vregs, not slurped in by fast-input.
    dup empty? [ finalize-contents ] unless
    ! Do the outputs clash with vregs on the phantom stacks?
    ! Then we must flush them first.
    outputs-clash? [ finalize-contents ] when
    phantom-d get swap [ stack>vregs ] keep phantom-vregs ;

: requested-vregs ( template -- int# float# )
    dup length swap [ float eq? ] subset length [ - ] keep ;

: guess-vregs ( -- int# float# )
    +input get { } additional-vregs#
    +scratch get [ first ] map requested-vregs >r + r> ;

: alloc-scratch ( -- )
    +scratch get
    [ [ first ] map alloc-vregs ] keep phantom-vregs ;

: template-inputs ( -- )
    ! Ensure we have enough to hold any new stack elements we
    ! will read (if any), and scratch.
    guess-vregs ensure-vregs
    ! Split the template into available (fast) parts and those
    ! that require allocating registers and reading the stack
    +input get match-template fast-input slow-input
    ! Finally allocate scratch registers
    alloc-scratch ;

: template-outputs ( -- )
    +output get [ get ] map { } (template-outputs) ;

: with-template ( quot spec -- )
    fix-spec [ template-inputs call template-outputs ] bind
    compute-free-vregs ; inline

: operand ( var -- op ) get v>operand ; inline
