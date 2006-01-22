! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
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
        in-1
        0 swap slot@ %fast-slot ,
    ] [
        drop
        in-2
        -1 %inc-d ,
        0 %untag ,
        1 0 %slot ,
    ] if  out-1
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
    ] if
    1 %write-barrier ,
] "intrinsic" set-word-prop

! \ char-slot [
!     drop
!     in-2
!     -1 %inc-d ,
!     0 1 %char-slot ,
!     1 <vreg> 0 %replace-d ,
! ] "intrinsic" set-word-prop
! 
! \ set-char-slot [
!     drop
!     in-3
!     -3 %inc-d ,
!     0 2 1 %set-char-slot ,
! ] "intrinsic" set-word-prop

\ type [
    drop
    in-1
    0 %type ,
    out-1
] "intrinsic" set-word-prop

\ tag [
    drop
    in-1
    0 %tag ,
    out-1
] "intrinsic" set-word-prop

\ getenv [
    -1 %inc-d ,
    node-peek value-literal 0 <vreg> swap %getenv ,
    1 %inc-d ,
    out-1
] "intrinsic" set-word-prop

\ setenv [
    -1 %inc-d ,
    in-1
    node-peek value-literal 0 <vreg> swap %setenv ,
    -1 %inc-d ,
] "intrinsic" set-word-prop

: value/vreg-list ( in -- list )
    [ 0 swap length 1- ] keep
    [ >r 2dup r> 3array >r 1- >r 1+ r> r> ] map 2nip ;

: values>vregs ( in -- in )
    value/vreg-list
    dup [ first3 load-value ] each
    [ first <vreg> ] map ;

: binary-inputs ( node -- in1 in2 )
    node-in-d values>vregs first2 swap ;

: binary-op-reg ( node op -- )
    >r binary-inputs dup -1 %inc-d , r> execute , out-1 ; inline

: binary-imm ( node -- in1 in2 )
    -1 %inc-d , in-1 node-peek value-literal 0 <vreg> ;

: binary-op-imm ( node op -- )
    >r binary-imm dup r> execute , out-1 ; inline

: literal-immediate? ( value -- ? )
    dup value? [ value-literal immediate? ] [ drop f ] if ;

: binary-op-imm? ( node -- ? )
    fixnum-imm? >r node-peek literal-immediate? r> and ;

: binary-op ( node op -- )
    #! out is a vreg where the vop stores the result.
    over binary-op-imm?
    [ binary-op-imm ] [ binary-op-reg ] if ;

{
    { fixnum+       %fixnum+       }
    { fixnum-       %fixnum-       }
    { fixnum-bitand %fixnum-bitand }
    { fixnum-bitor  %fixnum-bitor  }
    { fixnum-bitxor %fixnum-bitxor }
} [
    first2 [ binary-op ] curry "intrinsic" set-word-prop
] each

: binary-jump-reg ( node label op -- )
    >r >r binary-inputs -2 %inc-d , r> r> execute , ; inline

: binary-jump-imm ( node label op -- )
    >r >r binary-imm -1 %inc-d , r> r> execute , ; inline

: binary-jump ( node label op -- )
    pick binary-op-imm?
    [ binary-jump-imm ] [ binary-jump-reg ] if ;

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
    drop
    in-2
    -1 %inc-d ,
    1 <vreg> 0 <vreg> 2 <vreg> %fixnum-mod ,
    T{ vreg f 2 } 0 %replace-d ,
] "intrinsic" set-word-prop

\ fixnum/mod [
    ! See the remark on fixnum-mod for vreg usage
    drop
    in-2
    { T{ vreg f 1 } T{ vreg f 0 } }
    { T{ vreg f 2 } T{ vreg f 0 } }
    %fixnum/mod ,
    T{ vreg f 2 } 0 %replace-d ,
    T{ vreg f 0 } 1 %replace-d ,
] "intrinsic" set-word-prop

\ fixnum-bitnot [
    drop
    in-1
    0 <vreg> 0 <vreg> %fixnum-bitnot ,
    out-1
] "intrinsic" set-word-prop

\ fixnum* [
    \ %fixnum* binary-op-reg
] "intrinsic" set-word-prop

: slow-shift ( -- ) \ fixnum-shift %call , ;

: negative-shift ( n -- )
    -1 %inc-d ,
    in-1
    dup cell-bits neg <= [
        drop 0 <vreg> 2 <vreg> %fixnum-sgn ,
        T{ vreg f 2 } 0 %replace-d ,
    ] [
        neg 0 <vreg> 0 <vreg> %fixnum>> ,
        out-1
    ] if ;

: fast-shift ( n -- )
    dup 0 = [
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
