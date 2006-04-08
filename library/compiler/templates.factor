! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays generic inference kernel math
namespaces sequences vectors words ;

SYMBOL: d-height
SYMBOL: r-height

! Uncomitted values
SYMBOL: phantom-d
SYMBOL: phantom-r

: init-templates
    0 d-height set 0 r-height set
    V{ } clone phantom-d set V{ } clone phantom-r set ;

! A data stack location.
TUPLE: ds-loc n ;
C: ds-loc [ >r d-height get - r> set-ds-loc-n ] keep ;

! A call stack location.
TUPLE: cs-loc n ;
C: cs-loc [ >r r-height get - r> set-cs-loc-n ] keep ;

: adjust-stacks ( inc-d inc-r -- )
    r-height [ + ] change d-height [ + ] change ;

: immediate? ( obj -- ? )
    #! fixnums and f have a pointerless representation, and
    #! are compiled immediately. Everything else can be moved
    #! by GC, and is indexed through a table.
    dup fixnum? swap f eq? or ;

: load-literal ( obj vreg -- )
    over immediate? [ %immediate ] [ %indirect ] if , ;

: literal>stack ( value loc -- )
    swap value-literal fixnum-imm? over immediate? and
    [ T{ vreg f 0 } load-literal T{ vreg f 0 } ] unless
    swap %replace , ; inline

G: vreg>stack ( value loc -- ) 1 standard-combination ;

M: f vreg>stack ( value loc -- ) 2drop ;

M: value vreg>stack ( value loc -- )
    swap value-literal fixnum-imm? over immediate? and
    [ T{ vreg f 0 } load-literal T{ vreg f 0 } ] unless
    swap %replace , ;

M: object vreg>stack ( value loc -- )
    %replace , ;

: vregs>stack ( values quot literals -- )
    -rot >r [ dup value? rot eq? [ drop f ] unless ] map-with
    dup reverse-slice swap length r> map
    [ vreg>stack ] 2each ; inline

: finalize-height ( word symbol -- )
    [ dup zero? [ 2drop ] [ swap execute , ] if 0 ] change ;
    inline

: reset-stack ( vector -- )
    0 swap set-length ;

: end-basic-block ( -- )
    \ %inc-d d-height finalize-height
    \ %inc-r r-height finalize-height
    phantom-d get [ <ds-loc> ] f vregs>stack
    phantom-r get [ <cs-loc> ] f vregs>stack
    phantom-d get [ <ds-loc> ] t vregs>stack
    phantom-r get [ <cs-loc> ] t vregs>stack
    phantom-d get reset-stack
    phantom-r get reset-stack ;

G: stack>vreg ( value vreg loc -- operand )
    2 standard-combination ;

M: f stack>vreg ( value vreg loc -- operand ) 2drop ;

M: object stack>vreg ( value vreg loc -- operand )
    >r <vreg> dup r> %peek , nip ;

M: value stack>vreg ( value vreg loc -- operand )
    drop >r value-literal r> dup value eq?
    [ drop ] [ <vreg> [ load-literal ] keep ] if ;

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
    [ second ] map [ set ] 2each ;

: stack>vregs ( stack template quot -- )
    >r dup [ first ] map swapd alloc-regs
    dup length reverse r> map
    (stack>vregs) swap phantom-vregs ; inline

: compatible-vreg?
    swap dup value? [ 2drop t ] [ vreg-n = ] if ;

: compatible-values? ( value template -- ? )
    {
        { [ dup any-reg eq? ] [ 2drop t ] }
        { [ dup integer? ] [ compatible-vreg? ] }
        { [ dup value eq? ] [ drop value? ] }
    } cond ;

: template-match? ( phantom template -- ? )
    2dup [ length ] 2apply = [
        f [ first compatible-values? and ] 2reduce
    ] [
        2drop f
    ] if ;

: template-input ( values template phantom quot -- )
    >r swap [ template-match? ] 2keep rot [
        rot r> 2drop over >r phantom-vregs r> reset-stack
    ] [
        nip end-basic-block r> stack>vregs
    ] if ; inline

: template-inputs ( stack template stack template -- )
    over >r phantom-r get [ <cs-loc> ] template-input
    over >r phantom-d get [ <ds-loc> ] template-input
    r> r> [ length neg ] 2apply adjust-stacks ;

: >phantom ( seq stack -- )
    get swap [ dup value? [ get ] unless ] map nappend ;

: template-outputs ( stack stack -- )
    2dup [ length ] 2apply adjust-stacks
    phantom-r >phantom phantom-d >phantom ;

: with-template ( node in out quot -- )
    swap >r >r >r dup node-in-d r> { } { } template-inputs
    node set r> call r> { } template-outputs ; inline
