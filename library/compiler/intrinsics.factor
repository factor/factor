! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays assembler generic hashtables
inference kernel kernel-internals lists math math-internals
namespaces sequences words ;

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
        { { 0 "obj" } { value "slot" } } { "obj" } [
            node get slot@ "obj" get %fast-slot ,
        ] with-template
    ] [
        { { 0 "obj" } { 1 "n" } } { "obj" } [
            "obj" get %untag ,
            "n" get "obj" get %slot ,
        ] with-template
    ] if
] "intrinsic" set-word-prop

\ set-slot [
    dup slot@ [
        { { 0 "val" } { 1 "obj" } { value "slot" } } { } [
            "val" get "obj" get node get slot@ %fast-set-slot ,
        ] with-template
    ] [
        { { 0 "val" } { 1 "obj" } { 2 "slot" } } { } [
            "obj" get %untag ,
            "val" get "obj" get "slot" get %set-slot ,
        ] with-template
    ] if
    end-basic-block
    T{ vreg f 1 } %write-barrier ,
] "intrinsic" set-word-prop

\ char-slot [
    { { 0 "n" } { 1 "str" } } { "str" } [
        "n" get "str" get %char-slot ,
    ] with-template
] "intrinsic" set-word-prop

\ set-char-slot [
    { { 0 "ch" } { 1 "n" } { 2 "str" } } { } [
        "ch" get "str" get "n" get %set-char-slot ,
    ] with-template
] "intrinsic" set-word-prop

\ type [
    { { any-reg "in" } } { "in" }
    [ end-basic-block "in" get %type , ] with-template
] "intrinsic" set-word-prop

\ tag [
    { { any-reg "in" } } { "in" } [ "in" get %tag , ] with-template
] "intrinsic" set-word-prop

\ getenv [
    { { value "env" } } { "out" } [
        T{ vreg f 0 } "out" set
        "env" get "out" get %getenv ,
    ] with-template
] "intrinsic" set-word-prop

\ setenv [
    { { any-reg "value" } { value "env" } } { } [
        "value" get "env" get %setenv ,
    ] with-template
] "intrinsic" set-word-prop

: literal-immediate? ( node -- ? )
    node-in-d peek dup value?
    [ value-literal immediate? ] [ drop f ] if ;

: binary-in ( node -- in )
    literal-immediate? fixnum-imm? and
    { { 0 "x" } { value "y" } } { { 0 "x" } { 1 "y" } } ? ;

: (binary-op) ( node in -- )
    { "x" } [
        end-basic-block >r "y" get "x" get dup r> execute ,
    ] with-template ; inline

: binary-op ( node op -- )
    swap dup binary-in (binary-op) ; inline

: binary-op-reg ( node op -- )
    swap { { 0 "x" } { 1 "y" } } (binary-op) ; inline

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
    rot { { any-reg "x" } { any-reg "y" } } { } [
        end-basic-block >r >r "y" get "x" get r> r> execute ,
    ] with-template ; inline

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
    { { 0 "x" } { 1 "y" } } { "out" } [
        end-basic-block
        T{ vreg f 2 } "out" set
        "y" get "x" get "out" get %fixnum-mod ,
    ] with-template
] "intrinsic" set-word-prop

\ fixnum/mod [
    ! See the remark on fixnum-mod for vreg usage
    { { 0 "x" } { 1 "y" } } { "quo" "rem" } [
        end-basic-block
        T{ vreg f 0 } "quo" set
        T{ vreg f 2 } "rem" set
        "y" get "x" get 2array
        "rem" get "quo" get 2array %fixnum/mod ,
    ] with-template
] "intrinsic" set-word-prop

\ fixnum-bitnot [
    { { 0 "x" } } { "x" } [
        "x" get dup %fixnum-bitnot ,
    ] with-template
] "intrinsic" set-word-prop

\ fixnum* [
    \ %fixnum* binary-op-reg
] "intrinsic" set-word-prop

: slow-shift ( -- ) \ fixnum-shift %call , ;

: negative-shift ( n node -- )
    { { 0 "x" } { value "n" } } { "out" } [
        dup cell-bits neg <= [
            drop
            T{ vreg f 2 } "out" set
            "x" get "out" get %fixnum-sgn ,
        ] [
            "x" get "out" set
            neg "x" get "out" get %fixnum>> ,
        ] if
    ] with-template ;

: fast-shift ( n node -- )
    over zero? [
        drop-phantom 2drop
    ] [
        over 0 < [
            negative-shift
        ] [
            2drop slow-shift
        ] if
    ] if ;

\ fixnum-shift [
    end-basic-block
    dup literal-immediate? [
        [ node-in-d peek value-literal ] keep fast-shift
    ] [
        drop slow-shift
    ] if
] "intrinsic" set-word-prop
