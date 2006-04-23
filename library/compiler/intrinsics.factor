! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays assembler generic hashtables
inference kernel kernel-internals lists math math-internals
namespaces sequences words ;

\ slot [
    H{
        { +input-d { { f "obj" } { f "n" } } }
        { +output-d { "obj" } }
    } [
        "obj" get %untag ,
        "n" get "obj" get %slot ,
    ] with-template
] "intrinsic" set-word-prop

\ set-slot [
    H{
        { +input-d { { f "val" } { f "obj" } { f "slot" } } }
        { +clobber { "obj" } }
    } [
        "obj" get %untag ,
        "val" get "obj" get "slot" get %set-slot ,
        finalize-contents
        "obj" get %write-barrier ,
    ] with-template
] "intrinsic" set-word-prop

\ char-slot [
    H{
        { +input-d { { f "n" } { f "str" } } }
        { +output-d { "str" } }
    } [
        "n" get "str" get %char-slot ,
    ] with-template
] "intrinsic" set-word-prop

\ set-char-slot [
    H{
        { +input-d { { f "ch" } { f "n" } { f "str" } } }
    } [
        "ch" get "str" get "n" get %set-char-slot ,
    ] with-template
] "intrinsic" set-word-prop

\ type [
    H{
        { +input-d { { f "in" } } }
        { +output-d { "in" } }
    } [ finalize-contents "in" get %type , ] with-template
] "intrinsic" set-word-prop

\ tag [
    H{
        { +input-d { { f "in" } } }
        { +output-d { "in" } }
    } [ "in" get %tag , ] with-template
] "intrinsic" set-word-prop

: binary-op ( op -- )
    H{
        { +input-d { { 0 "x" } { 1 "y" } } }
        { +output-d { "x" } }
    } [
        finalize-contents >r "y" get "x" get dup r> execute ,
    ] with-template ; inline

{
    { fixnum+       %fixnum+       }
    { fixnum-       %fixnum-       }
    { fixnum-bitand %fixnum-bitand }
    { fixnum-bitor  %fixnum-bitor  }
    { fixnum-bitxor %fixnum-bitxor }
    { fixnum/i      %fixnum/i      }
    { fixnum*       %fixnum*       }
} [
    first2 [ binary-op ] curry
    "intrinsic" set-word-prop
] each

: binary-jump ( label op -- )
    H{
        { +input-d { { f "x" } { f "y" } } }
    } [
        end-basic-block >r >r "y" get "x" get r> r> execute ,
    ] with-template ; inline

{
    { fixnum<= %jump-fixnum<= }
    { fixnum<  %jump-fixnum<  }
    { fixnum>= %jump-fixnum>= }
    { fixnum>  %jump-fixnum>  }
    { eq?      %jump-eq?      }
} [
    first2 [ binary-jump ] curry
    "if-intrinsic" set-word-prop
] each

\ fixnum-mod [
    ! This is not clever. Because of x86, %fixnum-mod is
    ! hard-coded to put its output in vreg 2, which happends to
    ! be EDX there.
    H{
        { +input-d { { 0 "x" } { 1 "y" } } }
        { +output-d { "out" } }
    } [
        finalize-contents
        T{ vreg f 2 } "out" set
        "y" get "x" get "out" get %fixnum-mod ,
    ] with-template
] "intrinsic" set-word-prop

\ fixnum/mod [
    ! See the remark on fixnum-mod for vreg usage
    H{
        { +input-d { { 0 "x" } { 1 "y" } } }
        { +output-d { "quo" "rem" } }
    } [
        finalize-contents
        T{ vreg f 0 } "quo" set
        T{ vreg f 2 } "rem" set
        "y" get "x" get 2array
        "rem" get "quo" get 2array %fixnum/mod ,
    ] with-template
] "intrinsic" set-word-prop

\ fixnum-bitnot [
    H{
        { +input-d { { f "x" } } }
        { +output-d { "x" } }
    } [ "x" get dup %fixnum-bitnot , ] with-template
] "intrinsic" set-word-prop
