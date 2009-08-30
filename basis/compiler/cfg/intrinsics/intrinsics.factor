! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: words sequences kernel combinators cpu.architecture
compiler.cfg.hats
compiler.cfg.instructions
compiler.cfg.intrinsics.alien
compiler.cfg.intrinsics.allot
compiler.cfg.intrinsics.fixnum
compiler.cfg.intrinsics.float
compiler.cfg.intrinsics.slots
compiler.cfg.intrinsics.misc
compiler.cfg.comparisons ;
QUALIFIED: alien
QUALIFIED: alien.accessors
QUALIFIED: kernel
QUALIFIED: arrays
QUALIFIED: byte-arrays
QUALIFIED: kernel.private
QUALIFIED: slots.private
QUALIFIED: strings.private
QUALIFIED: classes.tuple.private
QUALIFIED: math.private
QUALIFIED: math.integers.private
QUALIFIED: math.floats.private
QUALIFIED: math.libm
IN: compiler.cfg.intrinsics

: enable-intrinsics ( words -- )
    [ t "intrinsic" set-word-prop ] each ;

{
    kernel.private:tag
    kernel.private:getenv
    math.private:both-fixnums?
    math.private:fixnum+
    math.private:fixnum-
    math.private:fixnum*
    math.private:fixnum+fast
    math.private:fixnum-fast
    math.private:fixnum-bitand
    math.private:fixnum-bitor 
    math.private:fixnum-bitxor
    math.private:fixnum-shift-fast
    math.private:fixnum-bitnot
    math.private:fixnum*fast
    math.private:fixnum< 
    math.private:fixnum<=
    math.private:fixnum>=
    math.private:fixnum>
    ! math.private:bignum>fixnum
    ! math.private:fixnum>bignum
    kernel:eq?
    slots.private:slot
    slots.private:set-slot
    strings.private:string-nth
    strings.private:set-string-nth-fast
    classes.tuple.private:<tuple-boa>
    arrays:<array>
    byte-arrays:<byte-array>
    byte-arrays:(byte-array)
    kernel:<wrapper>
    alien:<displaced-alien>
    alien.accessors:alien-unsigned-1
    alien.accessors:set-alien-unsigned-1
    alien.accessors:alien-signed-1
    alien.accessors:set-alien-signed-1
    alien.accessors:alien-unsigned-2
    alien.accessors:set-alien-unsigned-2
    alien.accessors:alien-signed-2
    alien.accessors:set-alien-signed-2
    alien.accessors:alien-cell
    alien.accessors:set-alien-cell
} enable-intrinsics

: enable-alien-4-intrinsics ( -- )
    {
        alien.accessors:alien-unsigned-4
        alien.accessors:set-alien-unsigned-4
        alien.accessors:alien-signed-4
        alien.accessors:set-alien-signed-4
    } enable-intrinsics ;

: enable-float-intrinsics ( -- )
    {
        math.private:float+
        math.private:float-
        math.private:float*
        math.private:float/f
        math.private:fixnum>float
        math.private:float>fixnum
        math.private:float<
        math.private:float<=
        math.private:float>
        math.private:float>=
        math.private:float=
        alien.accessors:alien-float
        alien.accessors:set-alien-float
        alien.accessors:alien-double
        alien.accessors:set-alien-double
    } enable-intrinsics ;

: enable-fsqrt ( -- )
    \ math.libm:fsqrt t "intrinsic" set-word-prop ;

: enable-float-min/max ( -- )
    {
        math.floats.private:float-min
        math.floats.private:float-max
    } enable-intrinsics ;

: enable-float-functions ( -- )
    ! Everything except for fsqrt
    {
        math.libm:facos
        math.libm:fasin
        math.libm:fatan
        math.libm:fatan2
        math.libm:fcos
        math.libm:fsin
        math.libm:ftan
        math.libm:fcosh
        math.libm:fsinh
        math.libm:ftanh
        math.libm:fexp
        math.libm:flog
        math.libm:fpow
        math.libm:facosh
        math.libm:fasinh
        math.libm:fatanh
    } enable-intrinsics ;

: enable-min/max ( -- )
    {
        math.integers.private:fixnum-min
        math.integers.private:fixnum-max
    } enable-intrinsics ;

: enable-fixnum-log2 ( -- )
    { math.integers.private:fixnum-log2 } enable-intrinsics ;

: emit-intrinsic ( node word -- )
    {
        { \ kernel.private:tag [ drop emit-tag ] }
        { \ kernel.private:getenv [ emit-getenv ] }
        { \ math.private:both-fixnums? [ drop emit-both-fixnums? ] }
        { \ math.private:fixnum+ [ drop emit-fixnum+ ] }
        { \ math.private:fixnum- [ drop emit-fixnum- ] }
        { \ math.private:fixnum* [ drop emit-fixnum* ] }
        { \ math.private:fixnum+fast [ drop [ ^^add ] emit-fixnum-op ] }
        { \ math.private:fixnum-fast [ drop [ ^^sub ] emit-fixnum-op ] }
        { \ math.private:fixnum-bitand [ drop [ ^^and ] emit-fixnum-op ] }
        { \ math.private:fixnum-bitor [ drop [ ^^or ] emit-fixnum-op ] }
        { \ math.private:fixnum-bitxor [ drop [ ^^xor ] emit-fixnum-op ] }
        { \ math.private:fixnum-shift-fast [ emit-fixnum-shift-fast ] }
        { \ math.private:fixnum-bitnot [ drop emit-fixnum-bitnot ] }
        { \ math.integers.private:fixnum-log2 [ drop emit-fixnum-log2 ] }
        { \ math.private:fixnum*fast [ drop emit-fixnum*fast ] }
        { \ math.private:fixnum< [ drop cc< emit-fixnum-comparison ] }
        { \ math.private:fixnum<= [ drop cc<= emit-fixnum-comparison ] }
        { \ math.private:fixnum>= [ drop cc>= emit-fixnum-comparison ] }
        { \ math.private:fixnum> [ drop cc> emit-fixnum-comparison ] }
        { \ kernel:eq? [ drop cc= emit-fixnum-comparison ] }
        { \ math.integers.private:fixnum-min [ drop [ ^^min ] emit-fixnum-op ] }
        { \ math.integers.private:fixnum-max [ drop [ ^^max ] emit-fixnum-op ] }
        { \ math.private:bignum>fixnum [ drop emit-bignum>fixnum ] }
        { \ math.private:fixnum>bignum [ drop emit-fixnum>bignum ] }
        { \ math.private:float+ [ drop [ ^^add-float ] emit-float-op ] }
        { \ math.private:float- [ drop [ ^^sub-float ] emit-float-op ] }
        { \ math.private:float* [ drop [ ^^mul-float ] emit-float-op ] }
        { \ math.private:float/f [ drop [ ^^div-float ] emit-float-op ] }
        { \ math.private:float< [ drop cc< emit-float-comparison ] }
        { \ math.private:float<= [ drop cc<= emit-float-comparison ] }
        { \ math.private:float>= [ drop cc>= emit-float-comparison ] }
        { \ math.private:float> [ drop cc> emit-float-comparison ] }
        { \ math.private:float= [ drop cc= emit-float-comparison ] }
        { \ math.private:float>fixnum [ drop emit-float>fixnum ] }
        { \ math.private:fixnum>float [ drop emit-fixnum>float ] }
        { \ math.floats.private:float-min [ drop [ ^^min-float ] emit-float-op ] }
        { \ math.floats.private:float-max [ drop [ ^^max-float ] emit-float-op ] }
        { \ math.libm:fsqrt [ drop emit-fsqrt ] }
        { \ math.libm:facos [ drop "acos" emit-unary-float-function ] }
        { \ math.libm:fasin [ drop "asin" emit-unary-float-function ] }
        { \ math.libm:fatan [ drop "atan" emit-unary-float-function ] }
        { \ math.libm:fatan2 [ drop "atan2" emit-binary-float-function ] }
        { \ math.libm:fcos [ drop "cos" emit-unary-float-function ] }
        { \ math.libm:fsin [ drop "sin" emit-unary-float-function ] }
        { \ math.libm:ftan [ drop "tan" emit-unary-float-function ] }
        { \ math.libm:fcosh [ drop "cosh" emit-unary-float-function ] }
        { \ math.libm:fsinh [ drop "sinh" emit-unary-float-function ] }
        { \ math.libm:ftanh [ drop "tanh" emit-unary-float-function ] }
        { \ math.libm:fexp [ drop "exp" emit-unary-float-function ] }
        { \ math.libm:flog [ drop "log" emit-unary-float-function ] }
        { \ math.libm:fpow [ drop "pow" emit-binary-float-function ] }
        { \ math.libm:facosh [ drop "acosh" emit-unary-float-function ] }
        { \ math.libm:fasinh [ drop "asinh" emit-unary-float-function ] }
        { \ math.libm:fatanh [ drop "atanh" emit-unary-float-function ] }
        { \ slots.private:slot [ emit-slot ] }
        { \ slots.private:set-slot [ emit-set-slot ] }
        { \ strings.private:string-nth [ drop emit-string-nth ] }
        { \ strings.private:set-string-nth-fast [ drop emit-set-string-nth-fast ] }
        { \ classes.tuple.private:<tuple-boa> [ emit-<tuple-boa> ] }
        { \ arrays:<array> [ emit-<array> ] }
        { \ byte-arrays:<byte-array> [ emit-<byte-array> ] }
        { \ byte-arrays:(byte-array) [ emit-(byte-array) ] }
        { \ kernel:<wrapper> [ emit-simple-allot ] }
        { \ alien:<displaced-alien> [ emit-<displaced-alien> ] }
        { \ alien.accessors:alien-unsigned-1 [ 1 emit-alien-unsigned-getter ] }
        { \ alien.accessors:set-alien-unsigned-1 [ 1 emit-alien-integer-setter ] }
        { \ alien.accessors:alien-signed-1 [ 1 emit-alien-signed-getter ] }
        { \ alien.accessors:set-alien-signed-1 [ 1 emit-alien-integer-setter ] }
        { \ alien.accessors:alien-unsigned-2 [ 2 emit-alien-unsigned-getter ] }
        { \ alien.accessors:set-alien-unsigned-2 [ 2 emit-alien-integer-setter ] }
        { \ alien.accessors:alien-signed-2 [ 2 emit-alien-signed-getter ] }
        { \ alien.accessors:set-alien-signed-2 [ 2 emit-alien-integer-setter ] }
        { \ alien.accessors:alien-unsigned-4 [ 4 emit-alien-unsigned-getter ] }
        { \ alien.accessors:set-alien-unsigned-4 [ 4 emit-alien-integer-setter ] }
        { \ alien.accessors:alien-signed-4 [ 4 emit-alien-signed-getter ] }
        { \ alien.accessors:set-alien-signed-4 [ 4 emit-alien-integer-setter ] }
        { \ alien.accessors:alien-cell [ emit-alien-cell-getter ] }
        { \ alien.accessors:set-alien-cell [ emit-alien-cell-setter ] }
        { \ alien.accessors:alien-float [ single-float-rep emit-alien-float-getter ] }
        { \ alien.accessors:set-alien-float [ single-float-rep emit-alien-float-setter ] }
        { \ alien.accessors:alien-double [ double-float-rep emit-alien-float-getter ] }
        { \ alien.accessors:set-alien-double [ double-float-rep emit-alien-float-setter ] }
    } case ;
