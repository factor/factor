! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays generic inference io kernel math
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

: lazy-load ( value loc -- value )
    over ds-loc? pick cs-loc? or [
        dupd = [
            drop f
        ] [
            >r alloc-reg <vreg> dup r> %peek ,
        ] if
    ] [
        drop
    ] if ;

: vregs>stack ( values locs -- )
    [ over [ %replace , ] [ 2drop ] if ] 2each ;

: finalize-contents ( -- )
    phantom-d get phantom-r get 2dup
    [ dup phantom-locs* [ [ lazy-load ] 2map ] keep ] 2apply
    vregs>stack vregs>stack
    [ 0 swap set-length ] 2apply ;

: end-basic-block ( -- )
    finalize-contents finalize-heights ;

: stack>vreg ( vreg loc -- operand )
    >r <vreg> dup r> %peek , ;

SYMBOL: any-reg

: used-vregs ( -- seq )
    phantom-d get phantom-r get append
    [ vreg? ] subset [ vreg-n ] map ;

: compute-free-vregs ( -- )
    used-vregs vregs length reverse diff
    >vector free-vregs set ;

: requested-vregs ( template -- n )
    [ any-reg eq? ] subset length ;

: sufficient-vregs? ( n -- ? ) free-vregs get length <= ;

: template-vreg# ( template template -- n )
    [ requested-vregs ] 2apply + ;

: alloc-regs ( template -- template )
    [ dup any-reg eq? [ drop alloc-reg ] when ] map ;

: alloc-reg# ( n -- regs )
    free-vregs [ cut ] change ;

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
        { [ over ds-loc? ] [ 2drop t ] }
        { [ over cs-loc? ] [ 2drop t ] }
        { [ dup not ] [ 2drop t ] }
        { [ over not ] [ 2drop f ] }
        { [ dup any-reg eq? ] [ 2drop t ] }
        { [ dup integer? ] [ swap vreg-n = ] }
    } cond ;

: template-match? ( template phantom -- ? )
    [ reverse-slice ] 2apply
    t [ swap first compatible-values? and ] 2reduce ;

: templates-match? ( template template -- ? )
    phantom-r get template-match?
    >r phantom-d get template-match? r> and ;

: split-template ( template phantom -- slow fast )
    over length over length <= [
        drop { } swap
    ] [
        length swap cut*
    ] if ;

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
    phantom-r get (fast-input)
    phantom-d get (fast-input) ;

: (slow-input) ( template phantom -- )
    swap [ stack>vregs ] keep phantom-vregs ;

: slow-input ( template template -- )
    phantom-r get (slow-input)
    phantom-d get (slow-input) ;

: adjust-free-vregs ( -- )
    used-vregs free-vregs [ diff ] change ;

: template-inputs ( template template -- )
    compute-free-vregs
    match-templates fast-input
    adjust-free-vregs
    finalize-contents
    slow-input ;

: drop-phantom ( -- )
    end-basic-block -1 phantom-d get adjust-phantom ;

: phantom-append ( seq stack -- )
    over length over adjust-phantom swap nappend ;

: (template-outputs) ( seq stack -- )
    phantom-r get phantom-append phantom-d get phantom-append ;

: template-outputs ( stack stack -- )
    [ [ get ] map ] 2apply (template-outputs) ;

: with-template ( in out quot -- )
    swap >r >r { } template-inputs
    r> call r> { } template-outputs ; inline
