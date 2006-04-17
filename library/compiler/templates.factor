! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays generic inference io kernel math
namespaces prettyprint sequences vectors words ;

! A data stack location.
TUPLE: ds-loc n ;

! A call stack location.
TUPLE: cs-loc n ;

! A marker for values which are already stored in this location
TUPLE: clean ;

C: clean [ set-delegate ] keep ;

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

: vreg>stack ( value loc -- )
    {
        { [ over not ] [ 2drop ] }
        { [ over clean? ] [ 2drop ] }
        { [ t ] [ %replace , ] }
    } cond ;

: vregs>stack ( phantom -- )
    dup dup phantom-locs* [ vreg>stack ] 2each
    0 swap set-length ;

: finalize-phantom ( phantom -- )
    dup finalize-height vregs>stack ;

: end-basic-block ( -- )
    phantom-d get finalize-phantom
    phantom-r get finalize-phantom ;

: stack>vreg ( vreg loc -- operand )
    over [ >r <vreg> dup r> %peek , ] [ 2drop f ] if ;

SYMBOL: any-reg

SYMBOL: free-vregs

: compute-free-vregs ( -- )
    phantom-d get phantom-r get append
    [ vreg? ] subset [ vreg-n ] map
    vregs length reverse diff
    >vector free-vregs set ;

: requested-vregs ( template -- n )
    [ any-reg eq? ] subset length ;

: sufficient-vregs? ( n -- ? ) free-vregs get length <= ;

: template-vreg# ( template template -- n )
    [ requested-vregs ] 2apply + ;

: alloc-regs ( template -- template )
    free-vregs get swap [
        dup any-reg eq? [ drop pop ] [ nip ] if
    ] map-with ;

: alloc-reg# ( n -- regs )
    free-vregs [ cut ] change ;

: ?clean ( obj -- obj )
    dup clean? [ delegate ] when ;

: %get ( obj -- value )
    get ?clean dup value? [ value-literal ] when ;

: phantom-vregs ( values template -- ) [ second set ] 2each ;

: stack>vregs ( phantom template -- values )
    [
        [ first ] map alloc-regs
        dup length rot phantom-locs
        [ stack>vreg ] 2map
    ] 2keep length neg swap adjust-phantom ;

: compatible-values? ( value template -- ? )
    >r ?clean r> {
        { [ dup not ] [ 2drop t ] }
        { [ over not ] [ 2drop f ] }
        { [ dup any-reg eq? ] [ 2drop t ] }
        { [ dup integer? ] [ swap vreg-n = ] }
    } cond ;

: template-match? ( template phantom -- ? )
    2dup [ length ] 2apply <= [
        >r dup length r> tail-slice*
        t [ swap first compatible-values? and ] 2reduce
    ] [
        2drop f
    ] if ;

: templates-match? ( template template -- ? )
    2dup template-vreg# sufficient-vregs? [
        phantom-r get template-match?
        >r phantom-d get template-match? r> and
    ] [
        2drop f
    ] if ;

: optimized-input ( template phantom -- )
    over length neg over adjust-phantom
    over length over cut-phantom
    >r dup empty? [ drop ] [ vregs>stack ] if r>
    swap phantom-vregs ;

: template-input ( template phantom -- )
    swap [ stack>vregs ] keep phantom-vregs ;

: template-inputs ( template template -- )
    2dup templates-match? [
        phantom-r get optimized-input
        phantom-d get optimized-input
        compute-free-vregs
    ] [
        phantom-r get vregs>stack
        phantom-d get vregs>stack
        compute-free-vregs
        phantom-r get template-input
        phantom-d get template-input
    ] if ;

: drop-phantom ( -- )
    end-basic-block -1 phantom-d get adjust-phantom ;

: prep-output ( value -- value )
    dup clean? [ delegate ] [ get ?clean ] if ;

: phantom-append ( seq stack -- )
    over length over adjust-phantom swap nappend ;

: template-output ( seq stack -- )
    >r [ prep-output ] map r> phantom-append ;

: trace-outputs ( stack stack -- )
    "==== Template output:" print [ . ] 2apply ;

: template-outputs ( stack stack -- )
   !  2dup trace-outputs
    phantom-r get template-output
    phantom-d get template-output ;

: with-template ( in out quot -- )
    swap >r >r { } template-inputs
    r> call r> { } template-outputs ; inline
