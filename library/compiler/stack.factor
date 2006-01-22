! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-frontend
USING: compiler-backend generic inference kernel math namespaces
sequences vectors words ;

: immediate? ( obj -- ? )
    #! fixnums and f have a pointerless representation, and
    #! are compiled immediately. Everything else can be moved
    #! by GC, and is indexed through a table.
    dup fixnum? swap f eq? or ;

GENERIC: load-value ( vreg n value -- )

M: object load-value ( vreg n value -- )
    drop %peek-d , ;

: load-literal ( vreg obj -- )
    dup immediate? [ %immediate ] [ %indirect ] if , ;

M: value load-value ( vreg n value -- )
    nip value-literal load-literal ;

SYMBOL: vreg-allocator
SYMBOL: live-d
SYMBOL: live-r

: value-dropped? ( value -- ? )
    dup value?
    over live-d get member? not
    rot live-r get member? not and
    or ;

: stack>vreg ( value stack-pos loader -- )
    pick >r vreg-allocator get r> set
    pick value-dropped? [ pick get pick pick execute , ] unless
    3drop vreg-allocator inc ; inline

: (stacks>vregs) ( stack loader -- )
    swap reverse-slice dup length
    [ pick stack>vreg ] 2each drop ; inline

: stacks>vregs ( #shuffle -- )
    dup
    node-in-d \ %peek-d (stacks>vregs)
    node-in-r \ %peek-r (stacks>vregs) ;

: shuffle-height ( #shuffle -- )
    dup node-out-d length over node-in-d length - %inc-d ,
    dup node-out-r length swap node-in-r length - %inc-r , ;

: literal>stack ( stack-pos value storer -- )
    >r value-literal r> fixnum-imm? pick immediate? and [
        >r 0 swap load-literal 0 <vreg> r>
    ] unless swapd execute , ; inline

: computed>stack >r get <vreg> swap r> execute , ;

: vreg>stack ( stack-pos value storer -- )
    {
        { [ over not ] [ 3drop ] }
        { [ over value? ] [ literal>stack ] }
        { [ t ] [ computed>stack ] }
    } cond ; inline

: (vregs>stack) ( stack storer -- )
    swap reverse-slice [ length ] keep
    [ pick vreg>stack ] 2each drop ; inline

: (vregs>stacks) ( stack stack -- )
    \ %replace-r (vregs>stack) \ %replace-d (vregs>stack) ;

: literals/computed ( stack -- literals computed )
    dup [ dup value? [ drop f ] unless ] map
    swap [ dup value? [ drop f ] when ] map ;

: vregs>stacks ( -- )
    live-d get literals/computed
    live-r get literals/computed
    swapd (vregs>stacks) (vregs>stacks) ;

: live-stores ( instack outstack -- stack )
    #! Avoid storing a value into its former position.
    dup length [ pick ?nth dupd eq? [ drop f ] when ] 2map nip ;

M: #shuffle linearize* ( #shuffle -- )
    [
        0 vreg-allocator set
        dup node-in-d over node-out-d live-stores live-d set
        dup node-in-r over node-out-r live-stores live-r set
        dup stacks>vregs
        dup shuffle-height
        vregs>stacks
    ] with-scope linearize-next ;
