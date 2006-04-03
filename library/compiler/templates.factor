! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays generic inference kernel math
namespaces sequences vectors words ;

SYMBOL: d-height
SYMBOL: r-height

! A data stack location.
TUPLE: ds-loc n ;

C: ds-loc ( n -- ds-loc ) 
    [ >r d-height get - r> set-ds-loc-n ] keep ;

! A call stack location.
TUPLE: cs-loc n ;

C: cs-loc ( n -- ds-loc ) 
    [ >r r-height get - r> set-cs-loc-n ] keep ;

: adjust-stacks ( inc-d inc-r -- )
    r-height [ + ] change d-height [ + ] change ;

: finalize-stack ( quot symbol -- )
    [
        get dup zero? [ 2drop ] [ swap execute , ] if 0
    ] keep set ; inline

: end-basic-block ( -- )
    \ %inc-r r-height finalize-stack
    \ %inc-d d-height finalize-stack ;

: immediate? ( obj -- ? )
    #! fixnums and f have a pointerless representation, and
    #! are compiled immediately. Everything else can be moved
    #! by GC, and is indexed through a table.
    dup fixnum? swap f eq? or ;

: load-literal ( obj vreg -- )
    over immediate? [ %immediate ] [ %indirect ] if , ;

GENERIC: stack>vreg* ( vreg loc value -- operand )

M: object stack>vreg* ( vreg loc value -- operand )
    drop >r <vreg> dup r> %peek , ;

M: value stack>vreg* ( vreg loc value -- operand )
    nip value-literal swap <vreg> [ load-literal ] keep ;

SYMBOL: vreg-allocator

SYMBOL: any-reg

: alloc-value ( loc value -- operand )
    vreg-allocator [ inc ] keep get -rot stack>vreg* ;

: stack>vreg ( vreg loc value -- operand )
    {
        { [ dup not ] [ 3drop f ] }
        { [ pick any-reg eq? ] [ alloc-value nip ] }
        { [ pick not ] [ 2nip value-literal ] }
        { [ t ] [ stack>vreg* ] }
    } cond ;

: (stack>vregs) ( names values template quot -- inputs )
    >r dup length reverse r> map 3array flip
    [ first3 rot stack>vreg ] map swap [ set ] 2each ; inline

: stack>vregs ( stack template quot -- )
    >r unpair -rot r> (stack>vregs) ; inline

: template-inputs ( stack template stack template -- )
    [ <cs-loc> ] stack>vregs [ <ds-loc> ] stack>vregs ;

: literal>stack ( value stack-pos -- )
    swap value-literal fixnum-imm? over immediate? and
    [ T{ vreg f 0 } load-literal T{ vreg f 0 } ] unless
    swap %replace , ; inline

: vreg>stack ( value stack-pos -- )
    {
        { [ over not ] [ 2drop ] }
        { [ over value? ] [ literal>stack ] }
        { [ t ] [ >r get r> %replace , ] }
    } cond ;

: vregs>stack ( values quot -- )
    >r dup reverse-slice swap length r> map
    [ vreg>stack ] 2each ; inline

: template-outputs ( stack stack -- )
    [ <cs-loc> ] vregs>stack [ <ds-loc> ] vregs>stack ;

SYMBOL: template-height

: with-template ( node in out quot -- )
    pick length pick length swap - template-height set
    swap >r >r
    >r dup node-in-d r> { } { } template-inputs
    template-height get 0 adjust-stacks
    node set r> call r> { } template-outputs ; inline

: literals/computed ( stack -- literals computed )
    dup [ dup value? [ drop f ] unless ] map
    swap [ dup value? [ drop f ] when ] map ;

: vregs>stacks ( ds cs -- )
    #! We store literals last because storing a literal to a
    #! stack slot actually clobbers a vreg.
    >r literals/computed r> literals/computed swapd
    template-outputs template-outputs ;
