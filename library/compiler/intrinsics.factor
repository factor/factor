! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler-frontend
USING: arrays assembler compiler-backend generic hashtables
inference kernel kernel-internals lists math math-internals
namespaces sequences words ;

: node-peek ( node -- value ) node-in-d peek ;

: type-tag ( type -- tag )
    #! Given a type number, return the tag number.
    dup 6 > [ drop 3 ] when ;

: value-tag ( value node -- n/f )
    #! If the tag is known, output it, otherwise f.
    node-classes ?hash dup [
        types [ type-tag ] map dup all-equal?
        [ first ] [ drop f ] if
    ] [
        drop f
    ] if ;

: slot@ ( node -- n/f )
    #! Compute slot offset.
    dup node-in-d reverse-slice dup first dup value? [
        value-literal cells swap second
        rot value-tag dup [ - ] [ 2drop f ] if
    ] [
        3drop f
    ] if ;

\ slot [
    dup slot@ [
        -1 %inc-d ,
        dup in-1 >r slot@ r> %fast-slot ,
    ] [
        in-2 swap
        -1 %inc-d ,
        dup %untag ,
        %slot ,
    ] if  T{ vreg f 0 } out-1
] "intrinsic" set-word-prop

\ set-slot [
    dup slot@ [
        -1 %inc-d ,
        dup in-2
        -2 %inc-d ,
        rot slot@ %fast-set-slot ,
    ] [
        in-3
        -3 %inc-d ,
        over %untag ,
        %set-slot ,
    ] if
    T{ vreg f 1 } %write-barrier ,
] "intrinsic" set-word-prop

\ char-slot [
    in-2
    -1 %inc-d ,
    [ %char-slot , ] keep
    out-1
] "intrinsic" set-word-prop

\ set-char-slot [
    in-3
    -3 %inc-d ,
    swap %set-char-slot ,
] "intrinsic" set-word-prop

\ type [
    in-1 [ %type , ] keep out-1
] "intrinsic" set-word-prop

\ tag [
    in-1 [ %tag , ] keep out-1
] "intrinsic" set-word-prop

\ getenv [
    T{ vreg f 0 } [
        -1 %inc-d ,
        swap node-peek value-literal %getenv ,
        1 %inc-d ,
    ] keep out-1
] "intrinsic" set-word-prop

: binary-imm ( node -- in1 in2 )
    node-in-d { T{ vreg f 0 } f } intrinsic-inputs first2 swap
    -2 %inc-d , ;

\ setenv [
    binary-imm
    %setenv ,
] "intrinsic" set-word-prop

: binary-reg ( node -- in1 in2 )
    node-in-d { T{ vreg f 0 } T{ vreg f 1 } } intrinsic-inputs
    first2 swap -2 %inc-d , ;

: literal-immediate? ( value -- ? )
    dup value? [ value-literal immediate? ] [ drop f ] if ;

: (binary-op) ( node -- in1 in2 )
    fixnum-imm? [
        dup node-peek literal-immediate?
        [ binary-imm ] [ binary-reg ] if
    ] [
        binary-reg
    ] if ;

: binary-op ( node op -- )
    >r (binary-op) dup r> execute ,
    1 %inc-d ,
    T{ vreg f 0 } out-1 ; inline

: binary-op-reg ( node op -- )
    >r binary-reg dup r> execute ,
    1 %inc-d ,
    T{ vreg f 0 } out-1 ; inline

{
    { fixnum+       %fixnum+       }
    { fixnum-       %fixnum-       }
    { fixnum-bitand %fixnum-bitand }
    { fixnum-bitor  %fixnum-bitor  }
    { fixnum-bitxor %fixnum-bitxor }
} [
    first2 [ binary-op ] curry "intrinsic" set-word-prop
] each

: binary-jump ( node label op -- )
    >r >r (binary-op) r> r> execute , ; inline

{
    { fixnum<= %jump-fixnum<= }
    { fixnum<  %jump-fixnum<  }
    { fixnum>= %jump-fixnum>= }
    { fixnum>  %jump-fixnum>  }
    { eq?      %jump-eq?      }
} [
    first2 [ binary-jump ] curry "if-intrinsic" set-word-prop
] each

\ fixnum/i [
    \ %fixnum/i binary-op-reg
] "intrinsic" set-word-prop

\ fixnum-mod [
    ! This is not clever. Because of x86, %fixnum-mod is
    ! hard-coded to put its output in vreg 2, which happends to
    ! be EDX there.
    in-2 swap
    -1 %inc-d ,
    [ dup %fixnum-mod , ] keep out-1
] "intrinsic" set-word-prop

\ fixnum/mod [
    ! See the remark on fixnum-mod for vreg usage
    in-2 swap 2array
    { T{ vreg f 2 } T{ vreg f 0 } }
    %fixnum/mod ,
    { T{ vreg f 0 } T{ vreg f 2 } } out-n
] "intrinsic" set-word-prop

\ fixnum-bitnot [
    in-1 [ dup %fixnum-bitnot , ] keep out-1
] "intrinsic" set-word-prop

\ fixnum* [
    \ %fixnum* binary-op-reg
] "intrinsic" set-word-prop

: slow-shift ( -- ) \ fixnum-shift %call , ;

: negative-shift ( n -- )
    -1 %inc-d ,
    { f } { T{ vreg f 0 } } intrinsic-inputs drop
    dup cell-bits neg <= [
        drop T{ vreg f 0 } T{ vreg f 2 } %fixnum-sgn ,
        T{ vreg f 2 } out-1
    ] [
        neg T{ vreg f 0 } T{ vreg f 0 } %fixnum>> ,
        T{ vreg f 0 } out-1
    ] if ;

: fast-shift ( n -- )
    dup zero? [
        -1 %inc-d ,
        drop
    ] [
        dup 0 < [
            negative-shift
        ] [
            drop slow-shift
        ] if
    ] if ;

\ fixnum-shift [
    node-peek dup value? [
        value-literal fast-shift
    ] [
        drop slow-shift
    ] if
] "intrinsic" set-word-prop
