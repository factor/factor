! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays generic inference kernel math
namespaces sequences vectors words ;

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

G: vreg>stack ( value loc -- ) 1 standard-combination ;

M: f vreg>stack ( value loc -- ) 2drop ;

M: value vreg>stack ( value loc -- )
    >r value-literal r> load-literal ;

M: object vreg>stack ( value loc -- )
    %replace , ;

: vregs>stack ( phantom -- )
    dup dup phantom-locs* [ vreg>stack ] 2each
    0 swap set-length ;

: finalize-phantom ( phantom -- )
    dup finalize-height vregs>stack ;

: end-basic-block ( -- )
    phantom-d get finalize-phantom
    phantom-r get finalize-phantom ;

: end-basic-block* ( -- )
    phantom-d get vregs>stack
    phantom-r get vregs>stack ;

G: stack>vreg ( value vreg loc -- operand )
    2 standard-combination ;

M: f stack>vreg ( value vreg loc -- operand ) 2drop ;

M: object stack>vreg ( value vreg loc -- operand )
    >r <vreg> dup r> %peek , nip ;

M: value stack>vreg ( value vreg loc -- operand )
    drop dup value eq? [
        drop
    ] [
        >r value-literal r> <vreg> [ load-literal ] keep
    ] if ;

SYMBOL: any-reg

SYMBOL: free-vregs

: compute-free-vregs ( -- )
    phantom-d get [ vreg? ] subset
    phantom-r get [ vreg? ] subset append
    [ vreg-n ] map vregs length reverse diff
    >vector free-vregs set ;

: requested-vregs ( template -- n )
    [ any-reg eq? ] subset length ;

: sufficient-vregs? ( template template -- ? )
    [ requested-vregs ] 2apply + free-vregs get length <= ;

: alloc-regs ( template -- template )
    free-vregs get swap [
        dup any-reg eq? [ drop pop ] [ nip ] if
    ] map-with ;

: (stack>vregs) ( values template locs -- inputs )
    3array flip
    [ first3 over [ stack>vreg ] [ 3drop f ] if ] map ;

: phantom-vregs ( values template -- )
    >r [ dup value? [ value-literal ] when ] map
    r> [ second set ] 2each ;

: stack>vregs ( values phantom template -- values )
    [
        [ first ] map alloc-regs
        pick length rot phantom-locs
        (stack>vregs)
    ] 2keep length neg swap adjust-phantom ;

: compatible-vreg? ( value vreg -- ? )
    swap dup value? [ 2drop f ] [ vreg-n = ] if ;

: compatible-values? ( value template -- ? )
    {
        { [ dup not ] [ 2drop t ] }
        { [ over not ] [ 2drop f ] }
        { [ dup any-reg eq? ] [ drop vreg? ] }
        { [ dup integer? ] [ compatible-vreg? ] }
        { [ dup value eq? ] [ drop value? ] }
    } cond ;

: template-match? ( template phantom -- ? )
    2dup [ length ] 2apply <= [
        >r dup length r> tail-slice*
        t [ swap first compatible-values? and ] 2reduce
    ] [
        2drop f
    ] if ;

: templates-match? ( template template -- ? )
    2dup sufficient-vregs? [
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

: template-input ( values template phantom -- )
    dup vregs>stack swap [ stack>vregs ] keep phantom-vregs ;

: template-inputs ( values template values template -- )
    pick over templates-match? [
        phantom-r get optimized-input drop
        phantom-d get optimized-input drop
    ] [
        phantom-r get template-input
        phantom-d get template-input
    ] if ;

: drop-phantom ( -- )
    end-basic-block -1 phantom-d get adjust-phantom ;

: template-output ( seq stack -- )
    over length over adjust-phantom
    swap [ dup value? [ get ] unless ] map nappend ;

: template-outputs ( stack stack -- )
    phantom-r get template-output
    phantom-d get template-output ;

: with-template ( node in out quot -- )
    compute-free-vregs
    swap >r >r >r dup node-in-d r> { } { } template-inputs
    node set r> call r> { } template-outputs ; inline
