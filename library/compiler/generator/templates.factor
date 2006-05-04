! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays generic hashtables inference io kernel math
namespaces prettyprint sequences vectors words ;

! Register allocation

! Hash mapping reg-classes to mutable vectors
SYMBOL: free-vregs

: alloc-reg ( reg-class -- vreg )
    >r free-vregs get pop r> <vreg> ;

: requested-vregs ( template -- n )
    0 [ [ 1+ ] unless ] reduce ;

: template-vreg# ( template template -- n )
    [ requested-vregs ] 2apply + ;

: alloc-vregs ( template -- template )
    [ first [ <int-vreg> ] [ T{ int-regs } alloc-reg ] if* ] map ;

: adjust-free-vregs ( seq -- )
    free-vregs [ diff ] change ;

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
    #! Change stack heiht.
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

: stack>new-vreg ( loc -- vreg )
    T{ int-regs } alloc-reg [ swap %peek ] keep ;

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
    [ dup stack>new-vreg ] map>hash ;

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
    phantoms append [ vreg? ] subset [ vreg-n ] map ;

: compute-free-vregs ( -- )
    used-vregs T{ int-regs } vregs length reverse diff
    >vector free-vregs set ;

: additional-vregs# ( seq seq -- n )
    2array phantoms 2array [ [ length ] map ] 2apply v-
    0 [ 0 max + ] reduce ;

: free-vregs* ( -- n )
    free-vregs get length
    phantoms [ [ loc? ] subset length ] 2apply + - ;

: ensure-vregs ( n -- )
    compute-free-vregs free-vregs* <=
    [ finalize-contents compute-free-vregs ] unless ;

: lazy-load ( value loc -- value )
    over loc?
    [ dupd = [ drop f ] [ stack>new-vreg ] if ] [ drop ] if ;

: phantom-vregs ( values template -- )
    [ >r f lazy-load r> second set ] 2each ;

: stack>vregs ( phantom template -- values )
    [
        alloc-vregs dup length rot phantom-locs
        [ dupd %peek ] 2map
    ] 2keep length neg swap adjust-phantom ;

: compatible-values? ( value template -- ? )
    {
        { [ over loc? ] [ 2drop t ] }
        { [ dup not ] [ 2drop t ] }
        { [ over not ] [ 2drop f ] }
        { [ dup integer? ] [ swap vreg-n = ] }
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
    swap phantom-vregs ;

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

: slow-input ( template -- )
    ! Are we loading stuff from the stack? Then flush out
    ! remaining vregs, not slurped in by fast-input.
    dup empty? [ finalize-contents ] unless
    ! Do the outputs clash with vregs on the phantom stacks?
    ! Then we must flush them first.
    outputs-clash? [ finalize-contents ] when
    phantom-d get swap [ stack>vregs ] keep phantom-vregs ;

: input-vregs ( -- seq )
    +input +scratch [ get [ second get vreg-n ] map ] 2apply
    append ;

: guess-vregs ( -- n )
    +input get { } additional-vregs# +scratch get length + ;

: alloc-scratch ( -- )
    +scratch get [ alloc-vregs ] keep phantom-vregs ;

: template-inputs ( -- )
    ! Ensure we have enough to hold any new stack elements we
    ! will read (if any), and scratch.
    guess-vregs ensure-vregs
    ! Split the template into available (fast) parts and those
    ! that require allocating registers and reading the stack
    +input get match-template fast-input
    used-vregs adjust-free-vregs
    slow-input
    alloc-scratch
    input-vregs adjust-free-vregs ;

: template-outputs ( -- )
    +output get [ get ] map { } (template-outputs) ;

: with-template ( quot spec -- )
    fix-spec [ template-inputs call template-outputs ] bind
    compute-free-vregs ; inline

: operand ( var -- op ) get v>operand ; inline
