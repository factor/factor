! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer
USING: arrays errors generic hashtables inference kernel lists
math math-internals sequences words ;

! A system for associating dataflow optimizers with words.

: optimizer-hooks ( node -- conditions )
    node-param "optimizer-hooks" word-prop ;

: optimize-hooks ( node -- node/t )
    dup optimizer-hooks cond ;

: define-optimizers ( word optimizers -- )
    { [ t ] [ drop t ] } add "optimizer-hooks" set-word-prop ;

: partial-eval? ( #call -- ? )
    dup node-param "foldable" word-prop [
        dup node-in-d [
            dup value?
            [ 2drop t ] [ swap node-literals ?hash* nip ] if
        ] all-with?
    ] [
        drop f
    ] if ;

: literal-in-d ( #call -- inputs )
    dup node-in-d [
        dup value?
        [ nip value-literal ] [ swap node-literals ?hash ] if
    ] map-with ;

: partial-eval ( #call -- node )
    dup literal-in-d over node-param
    [ with-datastack ] catch
    [ 3drop t ] [ inline-literals ] if ;

: flip-subst ( not -- )
    #! Note: cloning the vectors, since subst-values will modify
    #! them.
    [ node-in-d clone ] keep
    [ node-out-d clone ] keep
    subst-values ;

: flip-branches ( not -- #if )
    #! If a not is followed by an #if, flip branches and
    #! remove the not.
    dup flip-subst node-successor dup
    dup node-children reverse swap set-node-children ;

\ not {
    { [ dup node-successor #if? ] [ flip-branches ] }
} define-optimizers

: disjoint-eq? ( node -- ? )
    dup node-classes swap node-in-d
    [ swap ?hash ] map-with
    first2 2dup and [ classes-intersect? not ] [ 2drop f ] if ;

\ eq? {
    { [ dup disjoint-eq? ] [ [ f ] inline-literals ] }
} define-optimizers

: useless-coerce? ( node -- )
    dup node-in-d first over node-class
    swap node-param "infer-effect" word-prop second first eq? ;

: call>no-op ( node -- node )
    [ ] dataflow [ subst-node ] keep ;

{ >fixnum >bignum >float } [
    {
        { [ dup useless-coerce? ] [ call>no-op ] }
    } define-optimizers
] each

! Arithmetic identities
SYMBOL: @

: define-identities ( words identities -- )
    swap [ swap "identities" set-word-prop ] each-with ;

: literals-match? ( values template -- ? )
    [
        over value? [ >r value-literal r> ] [ nip @ ] if =
    ] 2map [ ] all? ;

: values-match? ( values template -- ? )
    [ @ = [ drop f ] unless ] 2map [ ] subset all-eq? ;

: apply-identity? ( values identity -- ? )
    first 2dup literals-match? >r values-match? r> and ;

: find-identity ( node -- values identity )
    dup node-in-d swap node-param "identities" word-prop
    [ dupd apply-identity? ] find nip ;

: apply-identities ( node -- node/f )
    dup find-identity dup [
        second swap dataflow-with [ subst-node ] keep
    ] [
        3drop f
    ] if ;

[ + fixnum+ bignum+ float+ ] {
    { { @ 0 } [ drop ] }
    { { 0 @ } [ nip ]  }
} define-identities

[ - fixnum- bignum- float- ] {
    { { @ 0 } [ drop ]    }
    { { @ @ } [ 2drop 0 ] }
} define-identities

[ * fixnum* bignum* float* ] {
    { { @ 1 }  [ drop ]          }
    { { 1 @ }  [ nip ]           }
    { { @ 0 }  [ nip ]           }
    { { 0 @ }  [ drop ]          }
    { { @ -1 } [ drop 0 swap - ] }
    { { -1 @ } [ nip 0 swap - ]  }
} define-identities

[ / /i /f fixnum/i fixnum/f bignum/i bignum/f float/f ] {
    { { @ 1 }  [ drop ]          }
    { { @ -1 } [ drop 0 swap - ] }
} define-identities

[ fixnum-mod bignum-mod ] {
    { { @ 1 }  [ 2drop 0 ] }
} define-identities

[ bitand fixnum-bitand bignum-bitand ] {
    { { @ -1 } [ drop ] }
    { { -1 @ } [ nip  ] }
    { { @ @ }  [ drop ] }
    { { @ 0 }  [ nip  ] }
    { { 0 @ }  [ drop ] }
} define-identities

[ bitor fixnum-bitor bignum-bitor ] {
    { { @ 0 }  [ drop ] }
    { { 0 @ }  [ nip  ] }
    { { @ @ }  [ drop ] }
    { { @ -1 } [ nip  ] }
    { { -1 @ } [ drop ] }
} define-identities

[ bitxor fixnum-bitxor bignum-bitxor ] {
    { { @ 0 }  [ drop ]        }
    { { 0 @ }  [ nip  ]        }
    { { @ -1 } [ drop bitnot ] }
    { { -1 @ } [ nip  bitnot ] }
    { { @ @ }  [ 2drop 0 ]     }
} define-identities

[ shift fixnum-shift bignum-shift ] {
    { { 0 @ } [ drop ] }
    { { @ 0 } [ drop ] }
} define-identities

[ < fixnum< bignum< float< ] {
    { { @ @ } [ 2drop f ] }
} define-identities

[ <= fixnum<= bignum<= float<= ] {
    { { @ @ } [ 2drop t ] }
} define-identities
    
[ > fixnum> bignum> float>= ] {
    { { @ @ } [ 2drop f ] }
} define-identities

[ >= fixnum>= bignum>= float>= ] {
    { { @ @ } [ 2drop t ] }
} define-identities

[ eq? number= = ] {
    { { @ @ } [ 2drop t ] }
} define-identities

M: #call optimize-node* ( node -- node/t )
    {
        { [ dup partial-eval? ] [ partial-eval ] }
        { [ dup find-identity nip ] [ apply-identities ] }
        { [ dup optimizer-hooks ] [ optimize-hooks ] }
        { [ dup optimize-predicate? ] [ optimize-predicate ] }
        { [ t ] [ inline-method ] }
    } cond ;
