! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: words sequences kernel combinators cpu.architecture assocs
compiler.cfg.hats
compiler.cfg.instructions
compiler.cfg.intrinsics.alien
compiler.cfg.intrinsics.allot
compiler.cfg.intrinsics.fixnum
compiler.cfg.intrinsics.float
compiler.cfg.intrinsics.simd
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
QUALIFIED: math.vectors.simd.intrinsics
QUALIFIED: math.libm
IN: compiler.cfg.intrinsics

: enable-intrinsics ( alist -- )
    [ "intrinsic" set-word-prop ] assoc-each ;

{
    { kernel.private:tag [ drop emit-tag ] }
    { kernel.private:getenv [ emit-getenv ] }
    { math.private:both-fixnums? [ drop emit-both-fixnums? ] }
    { math.private:fixnum+ [ drop emit-fixnum+ ] }
    { math.private:fixnum- [ drop emit-fixnum- ] }
    { math.private:fixnum* [ drop emit-fixnum* ] }
    { math.private:fixnum+fast [ drop [ ^^add ] emit-fixnum-op ] }
    { math.private:fixnum-fast [ drop [ ^^sub ] emit-fixnum-op ] }
    { math.private:fixnum*fast [ drop emit-fixnum*fast ] }
    { math.private:fixnum-bitand [ drop [ ^^and ] emit-fixnum-op ] }
    { math.private:fixnum-bitor [ drop [ ^^or ] emit-fixnum-op ] }
    { math.private:fixnum-bitxor [ drop [ ^^xor ] emit-fixnum-op ] }
    { math.private:fixnum-shift-fast [ emit-fixnum-shift-fast ] }
    { math.private:fixnum-bitnot [ drop emit-fixnum-bitnot ] }
    { math.private:fixnum< [ drop cc< emit-fixnum-comparison ] }
    { math.private:fixnum<= [ drop cc<= emit-fixnum-comparison ] }
    { math.private:fixnum>= [ drop cc>= emit-fixnum-comparison ] }
    { math.private:fixnum> [ drop cc> emit-fixnum-comparison ] }
    { kernel:eq? [ drop cc= emit-fixnum-comparison ] }
    { slots.private:slot [ emit-slot ] }
    { slots.private:set-slot [ emit-set-slot ] }
    { strings.private:string-nth [ drop emit-string-nth ] }
    { strings.private:set-string-nth-fast [ drop emit-set-string-nth-fast ] }
    { classes.tuple.private:<tuple-boa> [ emit-<tuple-boa> ] }
    { arrays:<array> [ emit-<array> ] }
    { byte-arrays:<byte-array> [ emit-<byte-array> ] }
    { byte-arrays:(byte-array) [ emit-(byte-array) ] }
    { kernel:<wrapper> [ emit-simple-allot ] }
    { alien:<displaced-alien> [ emit-<displaced-alien> ] }
    { alien.accessors:alien-unsigned-1 [ 1 emit-alien-unsigned-getter ] }
    { alien.accessors:set-alien-unsigned-1 [ 1 emit-alien-integer-setter ] }
    { alien.accessors:alien-signed-1 [ 1 emit-alien-signed-getter ] }
    { alien.accessors:set-alien-signed-1 [ 1 emit-alien-integer-setter ] }
    { alien.accessors:alien-unsigned-2 [ 2 emit-alien-unsigned-getter ] }
    { alien.accessors:set-alien-unsigned-2 [ 2 emit-alien-integer-setter ] }
    { alien.accessors:alien-signed-2 [ 2 emit-alien-signed-getter ] }
    { alien.accessors:set-alien-signed-2 [ 2 emit-alien-integer-setter ] }
    { alien.accessors:alien-cell [ emit-alien-cell-getter ] }
    { alien.accessors:set-alien-cell [ emit-alien-cell-setter ] }
} enable-intrinsics

: enable-alien-4-intrinsics ( -- )
    {
        { alien.accessors:alien-unsigned-4 [ 4 emit-alien-unsigned-getter ] }
        { alien.accessors:set-alien-unsigned-4 [ 4 emit-alien-integer-setter ] }
        { alien.accessors:alien-signed-4 [ 4 emit-alien-signed-getter ] }
        { alien.accessors:set-alien-signed-4 [ 4 emit-alien-integer-setter ] }
    } enable-intrinsics ;

: enable-float-intrinsics ( -- )
    {
        { math.private:float+ [ drop [ ^^add-float ] emit-float-op ] }
        { math.private:float- [ drop [ ^^sub-float ] emit-float-op ] }
        { math.private:float* [ drop [ ^^mul-float ] emit-float-op ] }
        { math.private:float/f [ drop [ ^^div-float ] emit-float-op ] }
        { math.private:float< [ drop cc< emit-float-ordered-comparison ] }
        { math.private:float<= [ drop cc<= emit-float-ordered-comparison ] }
        { math.private:float>= [ drop cc>= emit-float-ordered-comparison ] }
        { math.private:float> [ drop cc> emit-float-ordered-comparison ] }
        { math.private:float-u< [ drop cc< emit-float-unordered-comparison ] }
        { math.private:float-u<= [ drop cc<= emit-float-unordered-comparison ] }
        { math.private:float-u>= [ drop cc>= emit-float-unordered-comparison ] }
        { math.private:float-u> [ drop cc> emit-float-unordered-comparison ] }
        { math.private:float= [ drop cc= emit-float-unordered-comparison ] }
        { math.private:float>fixnum [ drop emit-float>fixnum ] }
        { math.private:fixnum>float [ drop emit-fixnum>float ] }
        { math.floats.private:float-unordered? [ drop cc/<>= emit-float-unordered-comparison ] }
        { alien.accessors:alien-float [ float-rep emit-alien-float-getter ] }
        { alien.accessors:set-alien-float [ float-rep emit-alien-float-setter ] }
        { alien.accessors:alien-double [ double-rep emit-alien-float-getter ] }
        { alien.accessors:set-alien-double [ double-rep emit-alien-float-setter ] }
    } enable-intrinsics ;

: enable-fsqrt ( -- )
    {
        { math.libm:fsqrt [ drop emit-fsqrt ] }
    } enable-intrinsics ;

: enable-float-min/max ( -- )
    {
        { math.floats.private:float-min [ drop [ ^^min-float ] emit-float-op ] }
        { math.floats.private:float-max [ drop [ ^^max-float ] emit-float-op ] }
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
        { math.integers.private:fixnum-min [ drop [ ^^min ] emit-fixnum-op ] }
        { math.integers.private:fixnum-max [ drop [ ^^max ] emit-fixnum-op ] }
    } enable-intrinsics ;

: enable-fixnum-log2 ( -- )
    {
        { math.integers.private:fixnum-log2 [ drop emit-fixnum-log2 ] }
    } enable-intrinsics ;

: enable-simd ( -- )
    {
        { math.vectors.simd.intrinsics:assert-positive [ drop ] }
        { math.vectors.simd.intrinsics:(simd-v+) [ [ ^^add-vector ] emit-binary-vector-op ] }
        { math.vectors.simd.intrinsics:(simd-vs+) [ [ ^^saturated-add-vector ] emit-binary-vector-op ] }
        { math.vectors.simd.intrinsics:(simd-v+-) [ [ ^^add-sub-vector ] emit-binary-vector-op ] }
        { math.vectors.simd.intrinsics:(simd-v-) [ [ ^^sub-vector ] emit-binary-vector-op ] }
        { math.vectors.simd.intrinsics:(simd-vs-) [ [ ^^saturated-sub-vector ] emit-binary-vector-op ] }
        { math.vectors.simd.intrinsics:(simd-v*) [ [ ^^mul-vector ] emit-binary-vector-op ] }
        { math.vectors.simd.intrinsics:(simd-vs*) [ [ ^^saturated-mul-vector ] emit-binary-vector-op ] }
        { math.vectors.simd.intrinsics:(simd-v/) [ [ ^^div-vector ] emit-binary-vector-op ] }
        { math.vectors.simd.intrinsics:(simd-vmin) [ [ ^^min-vector ] emit-binary-vector-op ] }
        { math.vectors.simd.intrinsics:(simd-vmax) [ [ ^^max-vector ] emit-binary-vector-op ] }
        { math.vectors.simd.intrinsics:(simd-vabs) [ [ ^^abs-vector ] emit-unary-vector-op ] }
        { math.vectors.simd.intrinsics:(simd-vsqrt) [ [ ^^sqrt-vector ] emit-unary-vector-op ] }
        { math.vectors.simd.intrinsics:(simd-vbitand) [ [ ^^and-vector ] emit-binary-vector-op ] }
        { math.vectors.simd.intrinsics:(simd-vbitor) [ [ ^^or-vector ] emit-binary-vector-op ] }
        { math.vectors.simd.intrinsics:(simd-vbitxor) [ [ ^^xor-vector ] emit-binary-vector-op ] }
        { math.vectors.simd.intrinsics:(simd-v<<) [ [ ^^shl-vector ] emit-binary-vector-op ] }
        { math.vectors.simd.intrinsics:(simd-v>>) [ [ ^^shr-vector ] emit-binary-vector-op ] }
        { math.vectors.simd.intrinsics:(simd-broadcast) [ [ ^^broadcast-vector ] emit-unary-vector-op ] }
        { math.vectors.simd.intrinsics:(simd-gather-2) [ emit-gather-vector-2 ] }
        { math.vectors.simd.intrinsics:(simd-gather-4) [ emit-gather-vector-4 ] }
        { math.vectors.simd.intrinsics:(simd-sum) [ [ ^^horizontal-add-vector ] emit-unary-vector-op ] }
        { math.vectors.simd.intrinsics:alien-vector [ emit-alien-vector ] }
        { math.vectors.simd.intrinsics:set-alien-vector [ emit-set-alien-vector ] }
    } enable-intrinsics ;

: emit-intrinsic ( node word -- )
    "intrinsic" word-prop call( node -- ) ;
