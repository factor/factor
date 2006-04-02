! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-frontend
USING: compiler-backend generic inference kernel math namespaces
sequences vectors words ;

SYMBOL: vreg-allocator
SYMBOL: live-d
SYMBOL: live-r

: value-dropped? ( value -- ? )
    dup value?
    over live-d get member? not
    rot live-r get member? not and
    or ;

: stack>vreg ( value stack-pos -- )
    vreg-allocator get <vreg> pick set
    over value-dropped? [ 2drop ] [ >r get r> %peek , ] if
    vreg-allocator inc ;

: stacks>vregs ( #shuffle -- )
    dup
    node-in-d [ <ds-loc> ] [ stack>vreg ] stacks<>vregs
    node-in-r [ <cs-loc> ] [ stack>vreg ] stacks<>vregs ;

: shuffle-height ( #shuffle -- )
    dup node-out-d length over node-in-d length - %inc-d ,
    dup node-out-r length swap node-in-r length - %inc-r , ;

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

: (vregs>stacks) ( stack stack -- )
    [ <cs-loc> ] [ vreg>stack ] stacks<>vregs
    [ <ds-loc> ] [ vreg>stack ] stacks<>vregs ;

: literals/computed ( stack -- literals computed )
    dup [ dup value? [ drop f ] unless ] map
    swap [ dup value? [ drop f ] when ] map ;

: vregs>stacks ( -- )
    #! We store literals last because storing a literal to a
    #! stack slot actually clobbers a vreg.
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
        dup stacks>vregs shuffle-height vregs>stacks
    ] with-scope iterate-next ;
