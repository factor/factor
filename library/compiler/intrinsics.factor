! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-frontend
USING: assembler compiler-backend generic hashtables inference
kernel kernel-internals lists math math-internals namespaces
sequences words ;

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
    0 0 %replace-d ,
    1 1 %replace-d ,
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

: node-peek ( node -- obj ) node-consume-d swap hash peek ;

: peek-2 dup length 2 - swap nth ;
: node-peek-2 ( node -- obj ) node-consume-d swap hash peek-2 ;

: typed? ( value -- ? ) value-types length 1 = ;

: self ( word -- )
    f swap dup "infer-effect" word-prop (consume/produce) ;

: intrinsic ( word -- )
    dup [ literal, \ self , ] make-list "infer" set-word-prop ;

\ slot intrinsic

: slot@ ( node -- n )
    #! Compute slot offset.
    node-consume-d swap hash
    dup peek literal-value cell *
    swap peek-2 value-types car type-tag - ;

: typed-literal? ( node -- ? )
    #! Output if the node's first input is well-typed, and the
    #! second is a literal.
    dup node-peek literal? swap node-peek-2 typed? and ;

\ slot [
    dup typed-literal? [
        1 %dec-d ,
        in-1
        0 swap slot@ %fast-slot ,
    ] [
        drop
        in-2
        1 %dec-d ,
        0 %untag ,
        1 0 %slot ,
    ] ifte  out-1
] "linearizer" set-word-prop

\ set-slot intrinsic

\ set-slot [
    dup typed-literal? [
        1 %dec-d ,
        in-2
        2 %dec-d ,
        slot@ >r 0 1 r> %fast-set-slot ,
    ] [
        drop
        in-3
        3 %dec-d ,
        1 %untag ,
        0 1 2 %set-slot ,
    ] ifte
] "linearizer" set-word-prop

\ type intrinsic

\ type [
    drop
    in-1
    0 %type ,
    0 %tag-fixnum ,
    out-1
] "linearizer" set-word-prop

\ arithmetic-type intrinsic

\ arithmetic-type [
    drop
    in-1
    0 %arithmetic-type ,
    0 %tag-fixnum ,
    1 %inc-d ,
    out-1
] "linearizer" set-word-prop

\ getenv intrinsic

\ getenv [
    1 %dec-d ,
    node-peek literal-value 0 <vreg> swap %getenv ,
    1 %inc-d ,
    out-1
] "linearizer" set-word-prop

\ setenv intrinsic

\ setenv [
    1 %dec-d ,
    in-1
    node-peek literal-value 0 <vreg> swap %setenv ,
    1 %dec-d ,
] "linearizer" set-word-prop

: binary-op-reg ( op out -- )
    >r in-2
    1 %dec-d ,
    1 <vreg> 0 <vreg> rot execute ,
    r> 0 %replace-d , ;

: binary-op ( node op out -- )
    #! out is a vreg where the vop stores the result.
    >r >r node-peek dup literal? [
        1 %dec-d ,
        in-1
        literal-value 0 <vreg> r> execute ,
        r> 0 %replace-d ,
    ] [
        drop
        r> r> binary-op-reg
    ] ifte ;

[
    [[ fixnum+       %fixnum+       ]]
    [[ fixnum-       %fixnum-       ]]
    [[ fixnum-bitand %fixnum-bitand ]]
    [[ fixnum-bitor  %fixnum-bitor  ]]
    [[ fixnum-bitxor %fixnum-bitxor ]]
    [[ fixnum<=      %fixnum<=      ]]
    [[ fixnum<       %fixnum<       ]]
    [[ fixnum>=      %fixnum>=      ]]
    [[ fixnum>       %fixnum>       ]]
    [[ eq?           %eq?           ]]
] [
    uncons over intrinsic
    [ literal, 0 , \ binary-op , ] make-list
    "linearizer" set-word-prop
] each

\ fixnum* intrinsic

: slow-fixnum* \ %fixnum* 0 binary-op-reg ;

\ fixnum* [
    ! Turn multiplication by a power of two into a left shift.
    node-peek dup literal? [
        literal-value dup power-of-2? [
            1 %dec-d ,
            in-1
            log2 0 <vreg> %fixnum<< ,
            0 0 %replace-d ,
        ] [
            drop slow-fixnum*
        ] ifte
    ] [
        drop slow-fixnum*
    ] ifte
] "linearizer" set-word-prop

\ fixnum-mod intrinsic

\ fixnum-mod [
    ! This is not clever. Because of x86, %fixnum-mod is
    ! hard-coded to put its output in vreg 2, which happends to
    ! be EDX there.
    drop \ %fixnum-mod 2 binary-op-reg
] "linearizer" set-word-prop

\ fixnum/i intrinsic

\ fixnum/i [
    drop \ %fixnum/i 0 binary-op-reg
] "linearizer" set-word-prop

\ fixnum/mod intrinsic

\ fixnum/mod [
    ! See the remark on fixnum-mod for vreg usage
    drop
    in-2
    0 <vreg> 1 <vreg> %fixnum/mod ,
    2 0 %replace-d ,
    0 1 %replace-d ,
] "linearizer" set-word-prop

\ fixnum-bitnot intrinsic

\ fixnum-bitnot [
    drop
    in-1
    0 %fixnum-bitnot ,
    out-1
] "linearizer" set-word-prop

: slow-shift ( -- ) \ fixnum-shift %call , ;

: negative-shift ( n -- )
    1 %dec-d ,
    in-1
    dup cell -8 * <= [
        drop 0 <vreg> 2 <vreg> %fixnum-sgn ,
        2 0 %replace-d ,
    ] [
        neg 0 <vreg> %fixnum>> ,
        out-1
    ] ifte ;

: positive-shift ( n -- )
    dup cell 8 * tag-bits - <= [
        1 %dec-d ,
        in-1
        0 <vreg> %fixnum<< ,
        out-1
    ] [
        drop slow-shift
    ] ifte ;

: fast-shift ( n -- )
    dup 0 = [
        1 %dec-d ,
        drop
    ] [
        dup 0 < [
            negative-shift
        ] [
            positive-shift
        ] ifte
    ] ifte ;

\ fixnum-shift intrinsic

\ fixnum-shift [
    node-peek dup literal? [
        literal-value fast-shift
    ] [
        drop slow-shift
    ] ifte
] "linearizer" set-word-prop
