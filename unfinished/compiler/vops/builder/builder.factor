! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser kernel namespaces words layouts sequences classes
classes.algebra accessors math arrays byte-arrays
inference.dataflow optimizer.allot compiler.cfg compiler.vops ;
IN: compiler.vops.builder

<< : TEMP: CREATE dup [ get ] curry define-inline ; parsing >>

! Temps   Inputs    Outputs
TEMP: $1  TEMP: #1  TEMP: ^1
TEMP: $2  TEMP: #2  TEMP: ^2
TEMP: $3  TEMP: #3  TEMP: ^3
TEMP: $4  TEMP: #4  TEMP: ^4
TEMP: $5  TEMP: #5  TEMP: ^5

GENERIC: emit-literal ( vreg object -- )

M: fixnum emit-literal ( vreg object -- )
    tag-bits get shift %iconst emit ;

M: f emit-literal
    class tag-number %iconst emit ;

M: object emit-literal ( vreg object -- )
    next-vreg [ %literal-table emit ] keep
    swap %literal emit ;

: temps ( seq -- ) [ next-vreg swap set ] each ;

: init-intrinsic ( -- )
    { $1 $2 $3 $4 ^1 ^2 ^3 ^4 } temps ;

: load-iconst ( value -- vreg )
    [ next-vreg dup ] dip %iconst emit ;

: load-tag-mask ( -- vreg )
    tag-mask get load-iconst ;

: load-tag-bits ( -- vreg )
    tag-bits get load-iconst ;

: emit-tag-fixnum ( out in -- )
    load-tag-bits %shl emit ;

: emit-untag-fixnum ( out in -- )
    load-tag-bits %sar emit ;

: emit-untag ( out in -- )
    next-vreg dup tag-mask get bitnot %iconst emit
    %and emit ;

: emit-tag ( -- )
    $1 #1 load-tag-mask %and emit
    ^1 $1 emit-tag-fixnum ;

: emit-slot ( node -- )
    [ ^1 #1 #2 ] dip dup in-d>> first node-class class-tag %%slot emit ;

UNION: immediate fixnum POSTPONE: f ;

: emit-write-barrier ( node -- )
    dup in-d>> first node-class immediate class< [ #2 %write-barrier emit ] unless ;

: emit-set-slot ( node -- )
    [ emit-write-barrier ]
    [ [ #1 #2 #3 ] dip dup in-d>> second node-class class-tag %%set-slot emit ]
    bi ;

: emit-fixnum-bitnot ( -- )
    $1 #1 %not emit
    ^1 $1 load-tag-mask %xor emit ;

: emit-fixnum+fast ( -- )
    ^1 #1 #2 %iadd emit ;

: emit-fixnum-fast ( -- )
    ^1 #1 #2 %isub emit ;

: emit-fixnum-bitand ( -- )
    ^1 #1 #2 %and emit ;

: emit-fixnum-bitor ( -- )
    ^1 #1 #2 %or emit ;

: emit-fixnum-bitxor ( -- )
    ^1 #1 #2 %xor emit ;

: emit-fixnum*fast ( -- )
    $1 #1 emit-untag-fixnum
    ^1 $1 #2 %imul emit ;

: emit-fixnum-shift-left-fast ( n -- )
    [ $1 ] dip %iconst emit
    ^1 #1 $1 %shl emit ;

: emit-fixnum-shift-right-fast ( n -- )
    [ $1 ] dip %iconst emit
    $2 #1 $1 %sar emit
    ^1 $2 emit-untag ;

: emit-fixnum-shift-fast ( n -- )
    dup 0 >=
    [ emit-fixnum-shift-left-fast ]
    [ neg emit-fixnum-shift-right-fast ] if ;

: emit-fixnum-compare ( cc -- )
    $1 #1 #2 %icmp emit
    [ ^1 $1 ] dip %%iboolean emit ;

: emit-fixnum<= ( -- )
    cc<= emit-fixnum-compare ;

: emit-fixnum>= ( -- )
    cc>= emit-fixnum-compare ;

: emit-fixnum< ( -- )
    cc< emit-fixnum-compare ;

: emit-fixnum> ( -- )
    cc> emit-fixnum-compare ;

: emit-eq? ( -- )
    cc= emit-fixnum-compare ;

: emit-unbox-float ( out in -- )
    %%unbox-float emit ;

: emit-box-float ( out in -- )
    %%box-float emit ;

: emit-unbox-floats ( -- )
    $1 #1 emit-unbox-float
    $2 #2 emit-unbox-float ;

: emit-float+ ( -- )
    emit-unbox-floats
    $3 $1 $2 %fadd emit
    ^1 $3 emit-box-float ;

: emit-float- ( -- )
    emit-unbox-floats
    $3 $1 $2 %fsub emit
    ^1 $3 emit-box-float ;

: emit-float* ( -- )
    emit-unbox-floats
    $3 $1 $2 %fmul emit
    ^1 $3 emit-box-float ;

: emit-float/f ( -- )
    emit-unbox-floats
    $3 $1 $2 %fdiv emit
    ^1 $3 emit-box-float ;

: emit-float-compare ( cc -- )
    emit-unbox-floats
    $3 $1 $2 %fcmp emit
    [ ^1 $3 ] dip %%fboolean emit ;

: emit-float<= ( -- )
    cc<= emit-float-compare ;

: emit-float>= ( -- )
    cc>= emit-float-compare ;

: emit-float< ( -- )
    cc< emit-float-compare ;

: emit-float> ( -- )
    cc> emit-float-compare ;

: emit-float= ( -- )
    cc= emit-float-compare ;

: emit-allot ( vreg size class -- )
    [ tag-number ] [ type-number ] bi %%allot emit ;

: emit-(tuple) ( layout -- )
    [ [ ^1 ] dip size>> 2 + tuple emit-allot ]
    [ [ $1 ] dip emit-literal ] bi
    $2 1 emit-literal
    $1 ^1 $2 tuple tag-number %%set-slot emit ;

: emit-(array) ( n -- )
    [ [ ^1 ] dip 2 + array emit-allot ]
    [ [ $1 ] dip emit-literal ] bi
    $2 1 emit-literal
    $1 ^1 $2 array tag-number %%set-slot emit ;

: emit-(byte-array) ( n -- )
    [ [ ^1 ] dip bytes>cells 2 + byte-array emit-allot ]
    [ [ $1 ] dip emit-literal ] bi
    $2 1 emit-literal
    $1 ^1 $2 byte-array tag-number %%set-slot emit ;

! fixnum>bignum
! bignum>fixnum
! fixnum+
! fixnum-
! getenv, setenv
! alien accessors
