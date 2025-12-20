! Copyright (C) 2008, 2010 Slava Pestov, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs compiler.cfg.comparisons compiler.cfg.hats
compiler.cfg.intrinsics.alien compiler.cfg.intrinsics.allot
compiler.cfg.intrinsics.fixnum compiler.cfg.intrinsics.float
compiler.cfg.intrinsics.misc compiler.cfg.intrinsics.slots
compiler.cfg.intrinsics.strings compiler.cfg.stacks
cpu.architecture kernel system words ;
QUALIFIED: alien
QUALIFIED: alien.accessors
QUALIFIED: alien.c-types
QUALIFIED: alien.data.private
QUALIFIED: arrays
QUALIFIED: byte-arrays
QUALIFIED: classes.tuple.private
QUALIFIED: kernel.private
QUALIFIED: math.bitwise.private
QUALIFIED: math.floats.private
QUALIFIED: math.integers.private
QUALIFIED: math.libm
QUALIFIED: math.private
QUALIFIED: slots.private
QUALIFIED: strings.private
IN: compiler.cfg.intrinsics

ERROR: inline-intrinsics-not-supported word quot ;

: enable-intrinsics ( alist -- )
    [
        over inline? [ inline-intrinsics-not-supported ] when
        "intrinsic" set-word-prop
    ] assoc-each ;

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
    { byte-arrays:<byte-array> [ emit-<byte-array> ] }
    { byte-arrays:(byte-array) [ emit-(byte-array) ] }
    { kernel:<wrapper> [ emit-simple-allot ] }
    { alien.data.private:local-allot [ emit-local-allot ] }
    { alien.data.private:cleanup-allot [ emit-cleanup-allot ] }
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

cpu arm.64? [ {
    { classes.tuple.private:<tuple-boa> [ emit-<tuple-boa> ] }
    { arrays:<array> [ emit-<array> ] }
} enable-intrinsics ] unless

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

: enable-min/max ( -- )
    {
        { math.integers.private:fixnum-min [ drop [ ^^min ] binary-op ] }
        { math.integers.private:fixnum-max [ drop [ ^^max ] binary-op ] }
    } enable-intrinsics ;

: enable-log2 ( -- )
    {
        { math.integers.private:fixnum-log2 [ drop [ ^^log2 ] unary-op ] }
    } enable-intrinsics ;

: enable-bit-count ( -- )
    {
        { math.bitwise.private:fixnum-bit-count [ drop [ ^^bit-count ] unary-op ] }
    } enable-intrinsics ;

: enable-bit-test ( -- )
    {
        { math.integers.private:fixnum-bit? [ drop [ ^^bit-test ] binary-op ] }
    } enable-intrinsics ;
