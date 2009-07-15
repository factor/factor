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
QUALIFIED: kernel
QUALIFIED: arrays
QUALIFIED: byte-arrays
QUALIFIED: kernel.private
QUALIFIED: slots.private
QUALIFIED: strings.private
QUALIFIED: classes.tuple.private
QUALIFIED: math.private
QUALIFIED: math.integers.private
QUALIFIED: alien.accessors
IN: compiler.cfg.intrinsics

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
    math.private:bignum>fixnum
    math.private:fixnum>bignum
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
} [ t "intrinsic" set-word-prop ] each

: enable-alien-4-intrinsics ( -- )
    {
        alien.accessors:alien-unsigned-4
        alien.accessors:set-alien-unsigned-4
        alien.accessors:alien-signed-4
        alien.accessors:set-alien-signed-4
    } [ t "intrinsic" set-word-prop ] each ;

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
    } [ t "intrinsic" set-word-prop ] each ;

: enable-fixnum-log2 ( -- )
    \ math.integers.private:fixnum-log2 t "intrinsic" set-word-prop ;

: emit-intrinsic ( node word -- )
    {
        { \ kernel.private:tag [ drop emit-tag ] }
        { \ kernel.private:getenv [ emit-getenv ] }
        { \ math.private:both-fixnums? [ drop emit-both-fixnums? ] }
        { \ math.private:fixnum+ [ drop [ ##fixnum-add ] emit-fixnum-overflow-op ] }
        { \ math.private:fixnum- [ drop [ ##fixnum-sub ] emit-fixnum-overflow-op ] }
        { \ math.private:fixnum* [ drop [ i i ##fixnum-mul ] emit-fixnum-overflow-op ] }
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
        { \ slots.private:slot [ emit-slot ] }
        { \ slots.private:set-slot [ emit-set-slot ] }
        { \ strings.private:string-nth [ drop emit-string-nth ] }
        { \ strings.private:set-string-nth-fast [ drop emit-set-string-nth-fast ] }
        { \ classes.tuple.private:<tuple-boa> [ emit-<tuple-boa> ] }
        { \ arrays:<array> [ emit-<array> ] }
        { \ byte-arrays:<byte-array> [ emit-<byte-array> ] }
        { \ byte-arrays:(byte-array) [ emit-(byte-array) ] }
        { \ kernel:<wrapper> [ emit-simple-allot ] }
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
        { \ alien.accessors:alien-float [ single-float-regs emit-alien-float-getter ] }
        { \ alien.accessors:set-alien-float [ single-float-regs emit-alien-float-setter ] }
        { \ alien.accessors:alien-double [ double-float-regs emit-alien-float-getter ] }
        { \ alien.accessors:set-alien-double [ double-float-regs emit-alien-float-setter ] }
    } case ;
