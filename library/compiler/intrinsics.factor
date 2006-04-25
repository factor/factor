! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays assembler generic hashtables
inference kernel kernel-internals lists math math-internals
namespaces sequences words ;

\ slot [
    [
        "obj" get %untag ,
        "n" get "obj" get %slot ,
    ] H{
        { +input { { f "obj" } { f "n" } } }
        { +output { "obj" } }
    } with-template
] "intrinsic" set-word-prop

\ set-slot [
    [
        "obj" get %untag ,
        "val" get "obj" get "slot" get %set-slot ,
        finalize-contents
        "obj" get %write-barrier ,
    ] H{
        { +input { { f "val" } { f "obj" } { f "slot" } } }
        { +clobber { "obj" } }
    } with-template
] "intrinsic" set-word-prop

\ char-slot [
    [
        "n" get "str" get %char-slot ,
    ] H{
        { +input { { f "n" } { f "str" } } }
        { +output { "str" } }
    } with-template
] "intrinsic" set-word-prop

\ set-char-slot [
    [
        "ch" get "str" get "n" get %set-char-slot ,
    ] H{
        { +input { { f "ch" } { f "n" } { f "str" } } }
    } with-template
] "intrinsic" set-word-prop

\ type [
    [ finalize-contents "in" get %type , ] H{
        { +input { { f "in" } } }
        { +output { "in" } }
    } with-template
] "intrinsic" set-word-prop

\ tag [
    [ "in" get %tag , ] H{
        { +input { { f "in" } } }
        { +output { "in" } }
    } with-template
] "intrinsic" set-word-prop

: binary-op ( op -- )
    [
        finalize-contents >r "y" get "x" get dup r> execute ,
    ] H{
        { +input { { 0 "x" } { 1 "y" } } }
        { +output { "x" } }
    } with-template ; inline

{
    { fixnum+       %fixnum+       }
    { fixnum-       %fixnum-       }
    { fixnum/i      %fixnum/i      }
    { fixnum*       %fixnum*       }
} [
    first2 [ binary-op ] curry
    "intrinsic" set-word-prop
] each

: binary-op-fast ( op -- )
    [
        >r "y" get "x" get dup r> execute ,
    ] H{
        { +input { { f "x" } { f "y" } } }
        { +output { "x" } }
    } with-template ; inline

{
    { fixnum-bitand %fixnum-bitand }
    { fixnum-bitor  %fixnum-bitor  }
    { fixnum-bitxor %fixnum-bitxor }
    { fixnum+fast   %fixnum+fast   }
    { fixnum-fast   %fixnum-fast   }
} [
    first2 [ binary-op-fast ] curry
    "intrinsic" set-word-prop
] each

: binary-jump ( label op -- )
    [
        end-basic-block >r >r "y" get "x" get r> r> execute ,
    ] H{
        { +input { { f "x" } { f "y" } } }
    } with-template ; inline

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
    [
        finalize-contents
        T{ vreg f 2 } "out" set
        "y" get "x" get "out" get %fixnum-mod ,
    ] H{
        { +input { { 0 "x" } { 1 "y" } } }
        { +output { "out" } }
    } with-template
] "intrinsic" set-word-prop

\ fixnum/mod [
    ! See the remark on fixnum-mod for vreg usage
    [
        finalize-contents
        T{ vreg f 0 } "quo" set
        T{ vreg f 2 } "rem" set
        "y" get "x" get 2array
        "rem" get "quo" get 2array %fixnum/mod ,
    ] H{
        { +input { { 0 "x" } { 1 "y" } } }
        { +output { "quo" "rem" } }
    } with-template
] "intrinsic" set-word-prop

\ fixnum-bitnot [
    [ "x" get dup %fixnum-bitnot , ] H{
        { +input { { f "x" } } }
        { +output { "x" } }
    } with-template
] "intrinsic" set-word-prop
