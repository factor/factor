! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: assembler generic hashtables inference kernel
kernel-internals lists math math-internals namespaces sequences
words ;

: immediate? ( obj -- ? )
    #! fixnums and f have a pointerless representation, and
    #! are compiled immediately. Everything else can be moved
    #! by GC, and is indexed through a table.
    dup fixnum? swap f eq? or ;

#push [
    1 %inc-d ,
    [ node-param get ] bind dup immediate? [
        %immediate-d ,
    ] [
        0 swap %indirect ,  out-1
    ] ifte
] "linearizer" set-word-prop

\ drop [
    drop
    1 %dec-d ,
] "linearizer" set-word-prop

\ dup [
    drop
    in-1
    1 %inc-d ,
    out-1
] "linearizer" set-word-prop

\ swap [
    drop
    in-2
    1 0 %replace-d ,
    0 1 %replace-d ,
] "linearizer" set-word-prop

\ over [
    drop
    0 1 %peek-d ,
    1 %inc-d ,
    out-1
] "linearizer" set-word-prop

\ pick [
    drop
    0 2 %peek-d ,
    1 %inc-d ,
    out-1
] "linearizer" set-word-prop

\ >r [
    drop
    in-1
    1 %inc-r ,
    1 %dec-d ,
    0 0 %replace-r ,
] "linearizer" set-word-prop

\ r> [
    drop
    0 0 %peek-r ,
    1 %inc-d ,
    1 %dec-r ,
    out-1
] "linearizer" set-word-prop

: top-literal? ( seq -- ? ) peek literal? ;
: peek-2 dup length 2 - swap nth ;
: next-typed? ( seq -- ? )
    peek-2 value-types length 1 = ;

: self ( word -- )
    f swap dup "infer-effect" word-prop (consume/produce) ;

: intrinsic ( word -- )
    dup [ literal, \ self , ] make-list "infer" set-word-prop ;

\ slot intrinsic

: slot@ ( seq -- n )
    #! Compute slot offset.
    dup peek literal-value cell *
    swap peek-2 value-types car type-tag - ;

\ slot [
    node-consume-d swap hash
    dup top-literal? over next-typed? and [
        1 %dec-d ,
        in-1
        0 swap slot@ %fast-slot ,
    ] [
        drop
        in-2
        1 %dec-d ,
        1 %untag ,
        1 0 %slot ,
    ] ifte  out-1
] "linearizer" set-word-prop

\ set-slot intrinsic

\ set-slot [
    node-consume-d swap hash
    dup top-literal? over next-typed? and [
        1 %dec-d ,
        in-2
        2 %dec-d ,
        slot@ >r 1 0 r> %fast-set-slot ,
    ] [
        drop
        in-3
        3 %dec-d ,
        1 %untag ,
        2 1 0 %set-slot ,
    ] ifte
] "linearizer" set-word-prop

\ type intrinsic

\ type [
    drop
    in-1
    0 %type ,
    out-1
] "linearizer" set-word-prop

: binary-op-reg ( op -- )
    in-2
    << vreg f 1 >> << vreg f 0 >> rot execute ,
    1 %dec-d ,
    out-1 ;


: binary-op ( node op -- )
    node-consume-d rot hash
    dup top-literal? [
        1 %dec-d ,
        in-1
        peek literal-value << vreg f 0 >> rot execute ,
        out-1
    ] [
        drop
        binary-op-reg
    ] ifte ;

[
    [[ fixnum+       %fixnum+       ]]
    [[ fixnum-       %fixnum-       ]]
    [[ fixnum*       %fixnum*       ]]
    [[ fixnum-mod    %fixnum-mod    ]]
    [[ fixnum-bitand %fixnum-bitand ]]
    [[ fixnum-bitor  %fixnum-bitor  ]]
    [[ fixnum-bitxor %fixnum-bitxor ]]
    [[ fixnum/i      %fixnum/i      ]]
    [[ fixnum<=      %fixnum<=      ]]
    [[ fixnum<       %fixnum<       ]]
    [[ fixnum>=      %fixnum>=      ]]
    [[ fixnum>       %fixnum>       ]]
] [
    uncons over intrinsic
    [ literal, \ binary-op , ] make-list
    "linearizer" set-word-prop
] each
