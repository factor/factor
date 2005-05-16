! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic interpreter kernel lists math namespaces
sequences words ;

: literal-inputs? ( in stack -- )
    tail-slice dup >list [ safe-literal? ] all? [
        length dataflow-drop, t
    ] [
        drop f
    ] ifte ;

: literal-inputs ( out stack -- )
    tail-slice [ literal-value ] nmap ;

: literal-outputs ( out stack -- )
    tail-slice dup [ recursive-state get <literal> ] nmap
    length dataflow-push, ;

: partial-eval? ( word -- ? )
    "infer-effect" word-prop car length
    meta-d get literal-inputs? ;

: infer-eval ( word -- )
    dup partial-eval? [
        dup "infer-effect" word-prop 2unlist
        >r length meta-d get
        literal-inputs
        host-word
        r> length meta-d get literal-outputs
    ] [
        dup "infer-effect" word-prop consume/produce
    ] ifte ;

: stateless ( word -- )
    #! A stateless word can be evaluated at compile-time.
    dup unit [ car infer-eval ] cons "infer" set-word-prop ;

! Could probably add more words here
[
    car
    cdr
    cons
    <
    <=
    >
    >=
    number=
    +
    -
    *
    /
    /i
    /f
    mod
    /mod
    bitand
    bitor
    bitxor
    shift
    bitnot
    >fixnum
    >bignum
    >float
    real
    imaginary
] [
    stateless
] each

: eq-tie ( v1 v2 bool -- )
    >r swap literal-value <literal-tie> general-t swons unit r>
    set-value-class-ties ;

: eq-ties ( v1 v2 bool -- )
    #! If the boolean is true, the values are equal.
    pick literal? [
        eq-tie
    ] [
        over literal? [
            swapd eq-tie
        ] [
            3drop
        ] ifte
    ] ifte ;

\ eq? [
    peek-d peek-next-d
    \ eq? infer-eval
    peek-d eq-ties
] "infer" set-word-prop

! Partially-evaluated words need their stack effects to be
! entered by hand.
\ car [ [ general-list ] [ object ] ] "infer-effect" set-word-prop
\ cdr [ [ general-list ] [ object ] ] "infer-effect" set-word-prop
\ < [ [ real real ] [ boolean ] ] "infer-effect" set-word-prop
\ <= [ [ real real ] [ boolean ] ] "infer-effect" set-word-prop
\ > [ [ real real ] [ boolean ] ] "infer-effect" set-word-prop
\ >= [ [ real real ] [ boolean ] ] "infer-effect" set-word-prop
\ number= [ [ real real ] [ boolean ] ] "infer-effect" set-word-prop
\ + [ [ number number ] [ number ] ] "infer-effect" set-word-prop
\ - [ [ number number ] [ number ] ] "infer-effect" set-word-prop
\ * [ [ number number ] [ number ] ] "infer-effect" set-word-prop
\ / [ [ number number ] [ number ] ] "infer-effect" set-word-prop
\ /i [ [ number number ] [ number ] ] "infer-effect" set-word-prop
\ /f [ [ number number ] [ number ] ] "infer-effect" set-word-prop
\ mod [ [ integer integer ] [ integer ] ] "infer-effect" set-word-prop
\ /mod [ [ integer integer ] [ integer integer ] ] "infer-effect" set-word-prop
\ bitand [ [ integer integer ] [ integer ] ] "infer-effect" set-word-prop
\ bitor [ [ integer integer ] [ integer ] ] "infer-effect" set-word-prop
\ bitxor [ [ integer integer ] [ integer ] ] "infer-effect" set-word-prop
\ shift [ [ integer integer ] [ integer ] ] "infer-effect" set-word-prop
\ bitnot [ [ integer ] [ integer ] ] "infer-effect" set-word-prop
\ gcd [ [ integer integer ] [ integer integer ] ] "infer-effect" set-word-prop
\ real [ [ number ] [ real ] ] "infer-effect" set-word-prop
\ imaginary [ [ number ] [ real ] ] "infer-effect" set-word-prop
