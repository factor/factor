! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-frontend
USING: assembler compiler-backend generic hashtables inference
kernel kernel-internals lists math math-internals namespaces
sequences words ;

! Architecture description
: fixnum-imm?
    #! Can fixnum operations take immediate operands?
    cpu "x86" = ;

\ dup [
    drop
    in-1
    1 %inc-d ,
    out-1
] "intrinsic" set-word-prop

\ swap [
    drop
    in-2
    0 0 %replace-d ,
    1 1 %replace-d ,
] "intrinsic" set-word-prop

\ over [
    drop
    0 1 %peek-d ,
    1 %inc-d ,
    out-1
] "intrinsic" set-word-prop

\ pick [
    drop
    0 2 %peek-d ,
    1 %inc-d ,
    out-1
] "intrinsic" set-word-prop

\ >r [
    drop
    in-1
    1 %inc-r ,
    1 %dec-d ,
    0 0 %replace-r ,
] "intrinsic" set-word-prop

\ r> [
    drop
    0 0 %peek-r ,
    1 %inc-d ,
    1 %dec-r ,
    out-1
] "intrinsic" set-word-prop

: node-peek ( node -- obj ) node-in-d peek ;

: peek-2 dup length 2 - swap nth ;
: node-peek-2 ( node -- obj ) node-in-d peek-2 ;

: typed? ( value -- ? ) value-types length 1 = ;

: slot@ ( node -- n )
    #! Compute slot offset.
    node-in-d
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
] "intrinsic" set-word-prop

\ set-slot [
    dup typed-literal? [
        1 %dec-d ,
        in-2
        2 %dec-d ,
        slot@ >r 0 1 r> %fast-set-slot ,
        0 %write-barrier ,
    ] [
        drop
        in-3
        3 %dec-d ,
        1 %untag ,
        0 1 2 %set-slot ,
        1 %write-barrier ,
    ] ifte
] "intrinsic" set-word-prop

\ type [
    drop
    in-1
    0 %type ,
    0 %tag-fixnum ,
    out-1
] "intrinsic" set-word-prop

\ arithmetic-type [
    drop
    in-1
    0 %arithmetic-type ,
    0 %tag-fixnum ,
    1 %inc-d ,
    out-1
] "intrinsic" set-word-prop

\ getenv [
    1 %dec-d ,
    node-peek literal-value 0 <vreg> swap %getenv ,
    1 %inc-d ,
    out-1
] "intrinsic" set-word-prop

\ setenv [
    1 %dec-d ,
    in-1
    node-peek literal-value 0 <vreg> swap %setenv ,
    1 %dec-d ,
] "intrinsic" set-word-prop

: value/vreg-list ( in -- list )
    [ 0 swap length 1 - ] keep
    [ >r 2dup r> 3list >r 1 - >r 1 + r> r> ] map 2nip ;

: values>vregs ( in -- in )
    value/vreg-list
    dup [ 3unlist load-value ] each
    [ car <vreg> ] map ;

: load-inputs ( node -- in )
    dup node-in-d values>vregs
    [ length swap node-out-d length - %dec-d , ] keep ;

: binary-op-reg ( node op -- )
    >r load-inputs 2unlist swap dup r> execute ,
    0 0 %replace-d , ; inline

: literal-fixnum? ( value -- ? )
    dup literal? [ literal-value fixnum? ] [ drop f ] ifte ;

: binary-op-imm ( imm op -- )
    1 %dec-d , in-1
    >r 0 <vreg> dup r> execute ,
    0 0 %replace-d , ; inline

: binary-op ( node op -- )
    #! out is a vreg where the vop stores the result.
    fixnum-imm? [
        >r dup node-peek dup literal-fixnum? [
            literal-value r> binary-op-imm drop
        ] [
            drop r> binary-op-reg
        ] ifte
    ] [
        binary-op-reg
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
    uncons [ literal, \ binary-op , ] make-list
    "intrinsic" set-word-prop
] each

: fast-fixnum* ( n -- )
    1 %dec-d ,
    in-1
    log2 0 <vreg> 0 <vreg> %fixnum<< ,
    0 0 %replace-d , ;

: slow-fixnum* ( node -- ) \ %fixnum* binary-op-reg ;

\ fixnum* [
    ! Turn multiplication by a power of two into a left shift.
    dup node-peek dup literal-fixnum? [
        literal-value dup power-of-2? [
            nip fast-fixnum*
        ] [
            drop slow-fixnum*
        ] ifte
    ] [
        drop slow-fixnum*
    ] ifte
] "intrinsic" set-word-prop

\ fixnum-mod [
    ! This is not clever. Because of x86, %fixnum-mod is
    ! hard-coded to put its output in vreg 2, which happends to
    ! be EDX there.
    drop
    in-2
    1 %dec-d ,
    1 <vreg> 0 <vreg> 2 <vreg> %fixnum-mod ,
    2 0 %replace-d ,
] "intrinsic" set-word-prop

\ fixnum/i t "intrinsic" set-word-prop

\ fixnum/i [
    \ %fixnum/i binary-op-reg
] "intrinsic" set-word-prop

\ fixnum/mod [
    ! See the remark on fixnum-mod for vreg usage
    drop
    in-2
    [ << vreg f 1 >> << vreg f 0 >> ]
    [ << vreg f 2 >> << vreg f 0 >> ]
    %fixnum/mod ,
    2 0 %replace-d ,
    0 1 %replace-d ,
] "intrinsic" set-word-prop

\ fixnum-bitnot [
    drop
    in-1
    0 <vreg> 0 <vreg> %fixnum-bitnot ,
    out-1
] "intrinsic" set-word-prop

: slow-shift ( -- ) \ fixnum-shift %call , ;

: negative-shift ( n -- )
    1 %dec-d ,
    in-1
    dup cell -8 * <= [
        drop 0 <vreg> 2 <vreg> %fixnum-sgn ,
        2 0 %replace-d ,
    ] [
        neg 0 <vreg> 0 <vreg> %fixnum>> ,
        out-1
    ] ifte ;

: positive-shift ( n -- )
    dup cell 8 * tag-bits - <= [
        1 %dec-d ,
        in-1
        0 <vreg> 0 <vreg> %fixnum<< ,
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

\ fixnum-shift [
    node-peek dup literal? [
        literal-value fast-shift
    ] [
        drop slow-shift
    ] ifte
] "intrinsic" set-word-prop
