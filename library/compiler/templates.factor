! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays generic inference kernel math
namespaces sequences vectors words ;

TUPLE: phantom-stack height elements ;

C: phantom-stack ( -- stack )
    0 over set-phantom-stack-height
    V{ } clone over set-phantom-stack-elements ;

: phantom-length ( phantom -- n )
    phantom-stack-elements length ;

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

: >phantom ( elt phantom -- ) phantom-stack-elements push ;

: phantom> ( phantom -- elt ) phantom-stack-elements pop ;

: phantom-append ( seq phantom -- )
    phantom-stack-elements swap nappend ;

: phantom-cut ( n phantom -- stuff )
    [ phantom-stack-elements cut* swap ] keep
    set-phantom-stack-elements ;

: phantom-locs ( n phantom -- locs )
    swap reverse-slice [ <loc> ] map-with ;

: phantom-locs* ( phantom -- locs )
    dup phantom-length swap phantom-locs ;

: adjust-phantom ( n phantom -- )
    [ phantom-stack-height + ] keep set-phantom-stack-height ;

: reset-phantom ( phantom -- )
    0 swap phantom-stack-elements set-length ;

SYMBOL: phantom-d
SYMBOL: phantom-r

: init-templates ( -- )
    <phantom-datastack> phantom-d set
    <phantom-callstack> phantom-r set ;

! A data stack location.
TUPLE: ds-loc n ;

! A call stack location.
TUPLE: cs-loc n ;

: adjust-stacks ( inc-d inc-r -- )
    phantom-d get adjust-phantom
    phantom-r get adjust-phantom ;

: immediate? ( obj -- ? )
    #! fixnums and f have a pointerless representation, and
    #! are compiled immediately. Everything else can be moved
    #! by GC, and is indexed through a table.
    dup fixnum? swap f eq? or ;

: load-literal ( obj vreg -- )
    over immediate? [ %immediate ] [ %indirect ] if , ;

G: vreg>stack ( value loc -- ) 1 standard-combination ;

M: f vreg>stack ( value loc -- ) 2drop ;

M: value vreg>stack ( value loc -- )
    swap value-literal fixnum-imm? over immediate? and
    [ T{ vreg f 0 } load-literal T{ vreg f 0 } ] unless
    swap %replace , ;

M: object vreg>stack ( value loc -- )
    %replace , ;

: vregs>stack ( values? phantom -- )
    [
        phantom-stack-elements
        [ dup value? rot eq? [ drop f ] unless ] map-with
    ] keep phantom-locs* [ vreg>stack ] 2each ;

: end-basic-block ( -- )
    phantom-d get finalize-height
    phantom-r get finalize-height
    f phantom-d get vregs>stack
    f phantom-r get vregs>stack
    t phantom-d get vregs>stack
    t phantom-r get vregs>stack
    phantom-d get reset-phantom
    phantom-r get reset-phantom ;

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

SYMBOL: vreg-allocator

SYMBOL: any-reg

: alloc-reg ( template -- template )
    dup any-reg eq? [
        drop vreg-allocator dup get swap inc
    ] when ;

: alloc-regs ( template -- template ) [ alloc-reg ] map ;

: (stack>vregs) ( values template locs -- inputs )
    3array flip
    [ first3 over [ stack>vreg ] [ 3drop f ] if ] map ;

: phantom-vregs ( phantom template -- )
    >r [ dup value? [ value-literal ] when ] map r>
    [ second ] map [ set ] 2each ;

: stack>vregs ( stack template -- )
    [
        [ first ] map alloc-regs
        dup length pick phantom-locs
        (stack>vregs) 
    ] keep phantom-vregs ;

: compatible-vreg? ( value vreg -- ? )
    swap dup value? [ 2drop f ] [ vreg-n = ] if ;

: compatible-values? ( value template -- ? )
    {
        { [ dup any-reg eq? ] [ drop vreg? ] }
        { [ dup integer? ] [ compatible-vreg? ] }
        { [ dup value eq? ] [ drop value? ] }
        { [ dup not ] [ 2drop t ] }
    } cond ;

: template-match? ( phantom template -- ? )
    2dup [ length ] 2apply = [
        t [ first compatible-values? and ] 2reduce
    ] [
        2drop f
    ] if ;

: optimized-input ( phantom template -- )
    over >r phantom-vregs r> reset-phantom ;

: template-input ( values template phantom -- )
    swap 2dup >r phantom-stack-elements r> template-match? [
        rot drop optimized-input
    ] [
        nip end-basic-block stack>vregs
    ] if ; inline

: template-inputs ( stack template stack template -- )
    over >r phantom-r get template-input
    over >r phantom-d get template-input
    r> r> [ phantom-length neg ] 2apply adjust-stacks ;

: (template-outputs) ( seq stack -- )
    >r [ dup value? [ get ] unless ] map r> phantom-append ;

: template-outputs ( stack stack -- )
    [ [ length ] 2apply adjust-stacks ] 2keep
    phantom-r get >phantom
    phantom-d get >phantom ;

: with-template ( node in out quot -- )
    swap >r >r >r dup node-in-d r> { } { } template-inputs
    node set r> call r> { } template-outputs ; inline
