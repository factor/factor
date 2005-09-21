! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
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
            dup literal?
            [ 2drop t ] [ swap node-literals hash* ] ifte
        ] all-with?
    ] [
        drop f
    ] ifte ;

: literal-in-d ( #call -- inputs )
    dup node-in-d [
        dup literal?
        [ nip literal-value ] [ swap node-literals hash ] ifte
    ] map-with ;

: partial-eval ( #call -- node )
    dup literal-in-d over node-param
    [ with-datastack ] catch
    [ 3drop t ] [ inline-literals ] ifte ;

: flip-subst ( not -- )
    #! Note: cloning the vectors, since subst-values will modify
    #! them.
    [ node-in-d clone ] keep
    [ node-out-d clone ] keep
    subst-values ;

: flip-branches ( not -- #ifte )
    #! If a not is followed by an #ifte, flip branches and
    #! remove the note.
    dup flip-subst node-successor dup
    dup node-children first2 swap 2array swap set-node-children ;

\ not {
    { [ dup node-successor #ifte? ] [ flip-branches ] }
} define-optimizers

: disjoint-eq? ( node -- ? )
    dup node-classes swap node-in-d
    [ swap hash ] map-with
    first2 2dup and [ classes-intersect? not ] [ 2drop f ] ifte ;

\ eq? {
    { [ dup disjoint-eq? ] [ [ f ] inline-literals ] }
} define-optimizers

! Arithmetic identities
SYMBOL: @

: define-identities ( words identities -- )
    swap [ swap "identities" set-word-prop ] each-with ;

: literals-match? ( values template -- ? )
    [
        over literal? [ >r literal-value r> ] [ nip @ ] ifte =
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
    ] ifte ;

[ + fixnum+ bignum+ float+ ] @{
    @{ @{ @ 0 }@ [ drop ] }@
    @{ @{ 0 @ }@ [ nip ]  }@
}@ define-identities

[ - fixnum- bignum- float- ] @{
    @{ @{ @ 0 }@ [ drop ]    }@
    @{ @{ @ @ }@ [ 2drop 0 ] }@
}@ define-identities

[ * fixnum* bignum* float* ] @{
    @{ @{ @ 1 }@  [ drop ]          }@
    @{ @{ 1 @ }@  [ nip ]           }@
    @{ @{ @ 0 }@  [ nip ]           }@
    @{ @{ 0 @ }@  [ drop ]          }@
    @{ @{ @ -1 }@ [ drop 0 swap - ] }@
    @{ @{ -1 @ }@ [ nip 0 swap - ]  }@
}@ define-identities

[ / /i /f fixnum/i fixnum/f bignum/i bignum/f float/f ] @{
    @{ @{ @ 1 }@  [ drop ]          }@
    @{ @{ @ -1 }@ [ drop 0 swap - ] }@
}@ define-identities

[ rem mod fixnum-mod bignum-mod ] @{
    @{ @{ @ 1 }@  [ 2drop 0 ] }@
}@ define-identities

! [ ^ ] @{
!     @{ @{ 1 @ }@  [ 2drop 1 ]             }@
!     @{ @{ @ 1 }@  [ drop ]                }@
!     @{ @{ @ 2 }@  [ drop dup * ]          }@
!     @{ @{ @ -1 }@ [ drop 1 swap / ]       }@
!     @{ @{ @ -2 }@ [ drop dup * 1 swap / ] }@
! }@ define-identities

[ bitand fixnum-bitand bignum-bitand ] @{
    @{ @{ @ -1 }@ [ drop ] }@
    @{ @{ -1 @ }@ [ nip  ] }@
    @{ @{ @ @ }@  [ drop ] }@
    @{ @{ @ 0 }@  [ nip  ] }@
    @{ @{ 0 @ }@  [ drop ] }@
}@ define-identities

[ bitor fixnum-bitor bignum-bitor ] @{
    @{ @{ @ 0 }@  [ drop ] }@
    @{ @{ 0 @ }@  [ nip  ] }@
    @{ @{ @ @ }@  [ drop ] }@
    @{ @{ @ -1 }@ [ nip  ] }@
    @{ @{ -1 @ }@ [ drop ] }@
}@ define-identities

[ bitxor fixnum-bitxor bignum-bitxor ] @{
    @{ @{ @ 0 }@  [ drop ]        }@
    @{ @{ 0 @ }@  [ nip  ]        }@
    @{ @{ @ -1 }@ [ drop bitnot ] }@
    @{ @{ -1 @ }@ [ nip  bitnot ] }@
    @{ @{ @ @ }@  [ 2drop 0 ]     }@
}@ define-identities

[ shift fixnum-shift bignum-shift ] @{
    @{ @{ 0 @ }@ [ drop ] }@
    @{ @{ @ 0 }@ [ drop ] }@
}@ define-identities

[ < fixnum< bignum< float< ] @{
    @{ @{ @ @ }@ [ 2drop f ] }@
}@ define-identities

[ <= fixnum<= bignum<= float<= ] @{
    @{ @{ @ @ }@ [ 2drop t ] }@
}@ define-identities
    
[ > fixnum> bignum> float>= ] @{
    @{ @{ @ @ }@ [ 2drop f ] }@
}@ define-identities

[ >= fixnum>= bignum>= float>= ] @{
    @{ @{ @ @ }@ [ 2drop t ] }@
}@ define-identities

[ eq? number= = ] @{
    @{ @{ @ @ }@ [ 2drop t ] }@
}@ define-identities

M: #call optimize-node* ( node -- node/t )
    @{
        @{ [ dup partial-eval? ] [ partial-eval ] }@
        @{ [ dup find-identity nip ] [ apply-identities ] }@
        @{ [ dup optimizer-hooks ] [ optimize-hooks ] }@
        @{ [ dup inlining-class ] [ inline-method ] }@
        @{ [ dup optimize-predicate? ] [ optimize-predicate ] }@
        @{ [ t ] [ drop t ] }@
    }@ cond ;
