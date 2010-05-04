! Copyright (C) 2008, 2010 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: words sequences kernel combinators cpu.architecture assocs
compiler.cfg.hats
compiler.cfg.stacks
compiler.cfg.instructions
compiler.cfg.intrinsics.alien
compiler.cfg.intrinsics.allot
compiler.cfg.intrinsics.fixnum
compiler.cfg.intrinsics.float
compiler.cfg.intrinsics.slots
compiler.cfg.intrinsics.strings
compiler.cfg.intrinsics.misc
compiler.cfg.comparisons ;
QUALIFIED: alien
QUALIFIED: alien.accessors
QUALIFIED: alien.c-types
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

: enable-intrinsics ( alist -- )
    [ "intrinsic" set-word-prop ] assoc-each ;

{
    { kernel.private:tag [ drop emit-tag ] }
    { kernel.private:context-object [ emit-context-object ] }
    { kernel.private:special-object [ emit-special-object ] }
    { kernel.private:set-special-object [ emit-set-special-object ] }
    { kernel.private:(identity-hashcode) [ drop emit-identity-hashcode ] }
    { math.private:both-fixnums? [ drop emit-both-fixnums? ] }
    { math.private:fixnum+ [ drop emit-fixnum+ ] }
    { math.private:fixnum- [ drop emit-fixnum- ] }
    { math.private:fixnum* [ drop emit-fixnum* ] }
    { math.private:fixnum+fast [ drop [ ^^add ] binary-op ] }
    { math.private:fixnum-fast [ drop [ ^^sub ] binary-op ] }
    { math.private:fixnum*fast [ drop [ ^^mul ] binary-op ] }
    { math.private:fixnum-bitand [ drop [ ^^and ] binary-op ] }
    { math.private:fixnum-bitor [ drop [ ^^or ] binary-op ] }
    { math.private:fixnum-bitxor [ drop [ ^^xor ] binary-op ] }
    { math.private:fixnum-shift-fast [ emit-fixnum-shift-fast ] }
    { math.private:fixnum-bitnot [ drop [ ^^not ] unary-op ] }
    { math.private:fixnum< [ drop cc< emit-fixnum-comparison ] }
    { math.private:fixnum<= [ drop cc<= emit-fixnum-comparison ] }
    { math.private:fixnum>= [ drop cc>= emit-fixnum-comparison ] }
    { math.private:fixnum> [ drop cc> emit-fixnum-comparison ] }
    { kernel:eq? [ emit-eq ] }
    { slots.private:slot [ emit-slot ] }
    { slots.private:set-slot [ emit-set-slot ] }
    { strings.private:string-nth-fast [ drop emit-string-nth-fast ] }
    { strings.private:set-string-nth-fast [ drop emit-set-string-nth-fast ] }
    { classes.tuple.private:<tuple-boa> [ emit-<tuple-boa> ] }
    { arrays:<array> [ emit-<array> ] }
    { byte-arrays:<byte-array> [ emit-<byte-array> ] }
    { byte-arrays:(byte-array) [ emit-(byte-array) ] }
    { kernel:<wrapper> [ emit-simple-allot ] }
    { alien:<displaced-alien> [ emit-<displaced-alien> ] }
    { alien.accessors:alien-unsigned-1 [ int-rep alien.c-types:uchar emit-load-memory ] }
    { alien.accessors:set-alien-unsigned-1 [ int-rep alien.c-types:uchar emit-store-memory ] }
    { alien.accessors:alien-signed-1 [ int-rep alien.c-types:char emit-load-memory ] }
    { alien.accessors:set-alien-signed-1 [ int-rep alien.c-types:char emit-store-memory ] }
    { alien.accessors:alien-unsigned-2 [ int-rep alien.c-types:ushort emit-load-memory ] }
    { alien.accessors:set-alien-unsigned-2 [ int-rep alien.c-types:ushort emit-store-memory ] }
    { alien.accessors:alien-signed-2 [ int-rep alien.c-types:short emit-load-memory ] }
    { alien.accessors:set-alien-signed-2 [ int-rep alien.c-types:short emit-store-memory ] }
    { alien.accessors:alien-cell [ emit-alien-cell ] }
    { alien.accessors:set-alien-cell [ emit-set-alien-cell ] }
} enable-intrinsics

: enable-alien-4-intrinsics ( -- )
    {
        { alien.accessors:alien-signed-4 [ int-rep alien.c-types:int emit-load-memory ] }
        { alien.accessors:set-alien-signed-4 [ int-rep alien.c-types:int emit-store-memory ] }
        { alien.accessors:alien-unsigned-4 [ int-rep alien.c-types:uint emit-load-memory ] }
        { alien.accessors:set-alien-unsigned-4 [ int-rep alien.c-types:uint emit-store-memory ] }
    } enable-intrinsics ;

: enable-float-intrinsics ( -- )
    {
        { math.private:float+ [ drop [ ^^add-float ] binary-op ] }
        { math.private:float- [ drop [ ^^sub-float ] binary-op ] }
        { math.private:float* [ drop [ ^^mul-float ] binary-op ] }
        { math.private:float/f [ drop [ ^^div-float ] binary-op ] }
        { math.private:float< [ drop cc< emit-float-ordered-comparison ] }
        { math.private:float<= [ drop cc<= emit-float-ordered-comparison ] }
        { math.private:float>= [ drop cc>= emit-float-ordered-comparison ] }
        { math.private:float> [ drop cc> emit-float-ordered-comparison ] }
        { math.private:float-u< [ drop cc< emit-float-unordered-comparison ] }
        { math.private:float-u<= [ drop cc<= emit-float-unordered-comparison ] }
        { math.private:float-u>= [ drop cc>= emit-float-unordered-comparison ] }
        { math.private:float-u> [ drop cc> emit-float-unordered-comparison ] }
        { math.private:float= [ drop cc= emit-float-unordered-comparison ] }
        { math.private:float>fixnum [ drop [ ^^float>integer ] unary-op ] }
        { math.private:fixnum>float [ drop [ ^^integer>float ] unary-op ] }
        { math.floats.private:float-unordered? [ drop cc/<>= emit-float-unordered-comparison ] }
        { alien.accessors:alien-float [ float-rep f emit-load-memory ] }
        { alien.accessors:set-alien-float [ float-rep f emit-store-memory ] }
        { alien.accessors:alien-double [ double-rep f emit-load-memory ] }
        { alien.accessors:set-alien-double [ double-rep f emit-store-memory ] }
    } enable-intrinsics ;

: enable-fsqrt ( -- )
    {
        { math.libm:fsqrt [ drop [ ^^sqrt ] unary-op ] }
    } enable-intrinsics ;

: enable-float-min/max ( -- )
    {
        { math.floats.private:float-min [ drop [ ^^min-float ] binary-op ] }
        { math.floats.private:float-max [ drop [ ^^max-float ] binary-op ] }
    } enable-intrinsics ;

: enable-float-functions ( -- )
    {
        { math.libm:facos [ drop "acos" emit-unary-float-function ] }
        { math.libm:fasin [ drop "asin" emit-unary-float-function ] }
        { math.libm:fatan [ drop "atan" emit-unary-float-function ] }
        { math.libm:fatan2 [ drop "atan2" emit-binary-float-function ] }
        { math.libm:fcos [ drop "cos" emit-unary-float-function ] }
        { math.libm:fsin [ drop "sin" emit-unary-float-function ] }
        { math.libm:ftan [ drop "tan" emit-unary-float-function ] }
        { math.libm:fcosh [ drop "cosh" emit-unary-float-function ] }
        { math.libm:fsinh [ drop "sinh" emit-unary-float-function ] }
        { math.libm:ftanh [ drop "tanh" emit-unary-float-function ] }
        { math.libm:fexp [ drop "exp" emit-unary-float-function ] }
        { math.libm:flog [ drop "log" emit-unary-float-function ] }
        { math.libm:flog10 [ drop "log10" emit-unary-float-function ] }
        { math.libm:fpow [ drop "pow" emit-binary-float-function ] }
        { math.libm:facosh [ drop "acosh" emit-unary-float-function ] }
        { math.libm:fasinh [ drop "asinh" emit-unary-float-function ] }
        { math.libm:fatanh [ drop "atanh" emit-unary-float-function ] }
        { math.libm:fsqrt [ drop "sqrt" emit-unary-float-function ] }
        { math.floats.private:float-min [ drop "fmin" emit-binary-float-function ] }
        { math.floats.private:float-max [ drop "fmax" emit-binary-float-function ] }
        { math.private:float-mod [ drop "fmod" emit-binary-float-function ] }
    } enable-intrinsics ;

: enable-min/max ( -- )
    {
        { math.integers.private:fixnum-min [ drop [ ^^min ] binary-op ] }
        { math.integers.private:fixnum-max [ drop [ ^^max ] binary-op ] }
    } enable-intrinsics ;

: enable-log2 ( -- )
    {
        { math.integers.private:fixnum-log2 [ drop [ ^^log2 ] unary-op ] }
    } enable-intrinsics ;

: emit-intrinsic ( node word -- )
    "intrinsic" word-prop call( node -- ) ;
