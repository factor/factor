! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays generic hashtables inference io kernel math
namespaces prettyprint sequences vectors words ;

SYMBOL: free-vregs

! A data stack location.
TUPLE: ds-loc n ;

! A call stack location.
TUPLE: cs-loc n ;

TUPLE: phantom-stack height ;

C: phantom-stack ( -- stack )
    0 over set-phantom-stack-height
    V{ } clone over set-delegate ;

GENERIC: finalize-height ( n stack -- )

GENERIC: <loc> ( n stack -- loc )

: (loc) phantom-stack-height - ;

: (finalize-height) ( stack word -- )
    swap [
        phantom-stack-height
        dup zero? [ 2drop ] [ swap execute , ] if
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

: init-templates ( -- )
    <phantom-datastack> phantom-d set
    <phantom-callstack> phantom-r set ;

: immediate? ( obj -- ? )
    #! fixnums and f have a pointerless representation, and
    #! are compiled immediately. Everything else can be moved
    #! by GC, and is indexed through a table.
    dup fixnum? swap f eq? or ;

: load-literal ( obj dest -- )
    over immediate? [ %immediate ] [ %indirect ] if , ;

: finalize-heights ( -- )
    phantom-d get finalize-height
    phantom-r get finalize-height ;

: alloc-reg ( -- n ) free-vregs get pop ;

: loc? ( obj -- ? ) dup ds-loc? swap cs-loc? or ;

: stack>vreg ( vreg# loc -- operand )
    >r <vreg> dup r> %peek , ;

: stack>new-vreg ( loc -- vreg )
    alloc-reg swap stack>vreg ;

: vreg>stack ( value loc -- )
    over loc? [
        2drop
    ] [
        over [ %replace , ] [ 2drop ] if
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

: phantoms ( -- phantom phantom ) phantom-d get phantom-r get ;

: flush-locs ( phantom phantom -- )
    [
        2dup live-locs \ live-locs set
        [ dup phantom-locs* [ lazy-store ] 2each ] 2apply
    ] with-scope ;

: finalize-contents ( -- )
    phantoms 2dup flush-locs [ vregs>stack ] 2apply ;

: end-basic-block ( -- )
    finalize-contents finalize-heights ;

: used-vregs ( -- seq )
    phantoms append [ vreg? ] subset [ vreg-n ] map ;

: compute-free-vregs ( -- )
    used-vregs vregs length reverse diff
    >vector free-vregs set ;

: requested-vregs ( template -- n )
    0 [ [ 1+ ] unless ] reduce ;

: template-vreg# ( template template -- n )
    [ requested-vregs ] 2apply + ;

: alloc-regs ( template -- template )
    [ [ alloc-reg ] unless* ] map ;

: alloc-reg# ( n -- regs )
    free-vregs [ cut ] change ;

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
        [ first ] map alloc-regs
        dup length rot phantom-locs
        [ stack>vreg ] 2map
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

: templates-match? ( template template -- ? )
    phantom-r get template-match?
    >r phantom-d get template-match? r> and ;

: split-template ( template phantom -- slow fast )
    over length over length <=
    [ drop { } swap ] [ length swap cut* ] if ;

: split-templates ( template template -- slow slow fast fast )
    >r phantom-d get split-template r>
    phantom-r get split-template swapd ;

: match-templates ( template template -- slow slow fast fast )
    2dup templates-match? [ split-templates ] [ { } { } ] if ;

: (fast-input) ( template phantom -- )
    over length neg over adjust-phantom
    over length swap cut-phantom
    swap phantom-vregs ;

: fast-input ( template template -- )
    phantoms swapd (fast-input) (fast-input) ;

: (slow-input) ( template phantom -- )
    swap [ stack>vregs ] keep phantom-vregs ;

: phantom-append ( seq stack -- )
    over length over adjust-phantom swap nappend ;

: (template-outputs) ( seq stack -- )
    phantoms swapd phantom-append phantom-append ;

SYMBOL: +input-d
SYMBOL: +input-r
SYMBOL: +output-d
SYMBOL: +output-r
SYMBOL: +scratch
SYMBOL: +clobber

: fix-spec ( spec -- spec )
    H{
        { +input-d { } }
        { +input-r { } }
        { +output-d { } }
        { +output-r { } }
        { +scratch { } }
        { +clobber { } }
    } swap hash-union ;

: adjust-free-vregs ( -- )
    used-vregs free-vregs [ diff ] change ;

: output-vregs ( -- seq )
    { +output-d +output-r +clobber }
    [ get [ get ] map ] map concat ;

: finalize-contents? ( -- ? )
    output-vregs phantoms append
    [ swap member? ] contains-with? ;

: slow-input ( template template -- )
    2dup [ empty? not ] 2apply or finalize-contents? or
    [ finalize-contents ] when
    phantoms swapd (slow-input) (slow-input) ;

: template-inputs ( -- )
    +input-d get +input-r get
    2dup additional-vregs# ensure-vregs
    match-templates fast-input
    adjust-free-vregs
    slow-input ;

: template-outputs ( -- )
    +output-d get +output-r get [ [ get ] map ] 2apply
    (template-outputs) ;

: with-template ( spec quot -- )
    swap fix-spec [
        template-inputs call template-outputs
    ] bind ; inline
