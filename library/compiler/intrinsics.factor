! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-frontend
USING: assembler compiler-backend generic hashtables inference
kernel kernel-internals lists math math-internals namespaces
sequences vectors words ;

: node-peek ( node -- value ) node-in-d peek ;

: type-tag ( type -- tag )
    #! Given a type number, return the tag number.
    dup 6 > [ drop 3 ] when ;

: value-tag ( value node -- n/f )
    #! If the tag is known, output it, otherwise f.
    node-classes hash dup [
        types [ type-tag ] map dup [ = ] monotonic?
        [ first ] [ drop f ] ifte
    ] [
        drop f
    ] ifte ;

: slot@ ( node -- n/f )
    #! Compute slot offset.
    dup node-in-d reverse dup first dup literal? [
        literal-value cell * swap second
        rot value-tag dup [ - ] [ 2drop f ] ifte
    ] [
        3drop f
    ] ifte ;

\ slot [
    dup slot@ [
        -1 %inc-d ,
        in-1
        0 swap slot@ %fast-slot ,
    ] [
        drop
        in-2
        -1 %inc-d ,
        0 %untag ,
        1 0 %slot ,
    ] ifte  out-1
] "intrinsic" set-word-prop

\ set-slot [
    dup slot@ [
        -1 %inc-d ,
        in-2
        -2 %inc-d ,
        slot@ >r 0 1 r> %fast-set-slot ,
    ] [
        drop
        in-3
        -3 %inc-d ,
        1 %untag ,
        0 1 2 %set-slot ,
    ] ifte
    1 %write-barrier ,
] "intrinsic" set-word-prop

\ type [
    drop
    in-1
    0 %type ,
    0 %retag-fixnum ,
    out-1
] "intrinsic" set-word-prop

\ tag [
    drop
    in-1
    0 %tag ,
    0 %retag-fixnum ,
    out-1
] "intrinsic" set-word-prop

\ getenv [
    -1 %inc-d ,
    node-peek literal-value 0 <vreg> swap %getenv ,
    1 %inc-d ,
    out-1
] "intrinsic" set-word-prop

\ setenv [
    -1 %inc-d ,
    in-1
    node-peek literal-value 0 <vreg> swap %setenv ,
    -1 %inc-d ,
] "intrinsic" set-word-prop

: value/vreg-list ( in -- list )
    [ 0 swap length 1 - ] keep
    [ >r 2dup r> 3vector >r 1 - >r 1 + r> r> ] map 2nip ;

: values>vregs ( in -- in )
    value/vreg-list
    dup [ first3 load-value ] each
    [ first <vreg> ] map ;

: load-inputs ( node -- in )
    dup node-in-d values>vregs
    [ >r node-out-d length r> length - %inc-d , ] keep ;

: binary-op ( node op -- )
    >r load-inputs first2 swap dup r> execute , out-1 ; inline

{
    { fixnum+       %fixnum+       }
    { fixnum-       %fixnum-       }
    { fixnum*       %fixnum*       }
    { fixnum/i      %fixnum/i      }
    { fixnum-bitand %fixnum-bitand }
    { fixnum-bitor  %fixnum-bitor  }
    { fixnum-bitxor %fixnum-bitxor }
} [
    first2 [ literalize , \ binary-op , ] [ ] make
    "intrinsic" set-word-prop
] each

: binary-jump ( node label op -- )
    >r >r node-in-d values>vregs
    dup length neg %inc-d , first2 swap
    r> r> execute , ; inline

{
    { fixnum<= %jump-fixnum<= }
    { fixnum<  %jump-fixnum<  }
    { fixnum>= %jump-fixnum>= }
    { fixnum>  %jump-fixnum>  }
    { eq?      %jump-eq?      }
} [
    first2 [ literalize , \ binary-jump , ] [ ] make
    "ifte-intrinsic" set-word-prop
] each

\ fixnum-mod [
    ! This is not clever. Because of x86, %fixnum-mod is
    ! hard-coded to put its output in vreg 2, which happends to
    ! be EDX there.
    drop
    in-2
    -1 %inc-d ,
    1 <vreg> 0 <vreg> 2 <vreg> %fixnum-mod ,
    2 0 %replace-d ,
] "intrinsic" set-word-prop

\ fixnum/mod [
    ! See the remark on fixnum-mod for vreg usage
    drop
    in-2
    { << vreg f 1 >> << vreg f 0 >> }
    { << vreg f 2 >> << vreg f 0 >> }
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
    -1 %inc-d ,
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
        -1 %inc-d ,
        in-1
        0 <vreg> 0 <vreg> %fixnum<< ,
        out-1
    ] [
        drop slow-shift
    ] ifte ;

: fast-shift ( n -- )
    dup 0 = [
        -1 %inc-d ,
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
