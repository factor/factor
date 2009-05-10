! Copyright (C) 2008 Slava Pestov.
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
compiler.cfg.iterator ;
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

: emit-intrinsic ( node word -- node/f )
    {
        { \ kernel.private:tag [ drop emit-tag iterate-next ] }
        { \ kernel.private:getenv [ emit-getenv iterate-next ] }
        { \ math.private:both-fixnums? [ drop emit-both-fixnums? iterate-next ] }
        { \ math.private:fixnum+ [ drop [ ##fixnum-add ] [ ##fixnum-add-tail ] emit-fixnum-overflow-op ] }
        { \ math.private:fixnum- [ drop [ ##fixnum-sub ] [ ##fixnum-sub-tail ] emit-fixnum-overflow-op ] }
        { \ math.private:fixnum* [ drop [ i i ##fixnum-mul ] [ i i ##fixnum-mul-tail ] emit-fixnum-overflow-op ] }
        { \ math.private:fixnum+fast [ [ ^^add ] [ ^^add-imm ] emit-fixnum-op iterate-next ] }
        { \ math.private:fixnum-fast [ [ ^^sub ] [ ^^sub-imm ] emit-fixnum-op iterate-next ] }
        { \ math.private:fixnum-bitand [ [ ^^and ] [ ^^and-imm ] emit-fixnum-op iterate-next ] }
        { \ math.private:fixnum-bitor [ [ ^^or ] [ ^^or-imm ] emit-fixnum-op iterate-next ] }
        { \ math.private:fixnum-bitxor [ [ ^^xor ] [ ^^xor-imm ] emit-fixnum-op iterate-next ] }
        { \ math.private:fixnum-shift-fast [ emit-fixnum-shift-fast iterate-next ] }
        { \ math.private:fixnum-bitnot [ drop emit-fixnum-bitnot iterate-next ] }
        { \ math.integers.private:fixnum-log2 [ drop emit-fixnum-log2 iterate-next ] }
        { \ math.private:fixnum*fast [ emit-fixnum*fast iterate-next ] }
        { \ math.private:fixnum< [ cc< emit-fixnum-comparison iterate-next ] }
        { \ math.private:fixnum<= [ cc<= emit-fixnum-comparison iterate-next ] }
        { \ math.private:fixnum>= [ cc>= emit-fixnum-comparison iterate-next ] }
        { \ math.private:fixnum> [ cc> emit-fixnum-comparison iterate-next ] }
        { \ kernel:eq? [ cc= emit-fixnum-comparison iterate-next ] }
        { \ math.private:bignum>fixnum [ drop emit-bignum>fixnum iterate-next ] }
        { \ math.private:fixnum>bignum [ drop emit-fixnum>bignum iterate-next ] }
        { \ math.private:float+ [ drop [ ^^add-float ] emit-float-op iterate-next ] }
        { \ math.private:float- [ drop [ ^^sub-float ] emit-float-op iterate-next ] }
        { \ math.private:float* [ drop [ ^^mul-float ] emit-float-op iterate-next ] }
        { \ math.private:float/f [ drop [ ^^div-float ] emit-float-op iterate-next ] }
        { \ math.private:float< [ drop cc< emit-float-comparison iterate-next ] }
        { \ math.private:float<= [ drop cc<= emit-float-comparison iterate-next ] }
        { \ math.private:float>= [ drop cc>= emit-float-comparison iterate-next ] }
        { \ math.private:float> [ drop cc> emit-float-comparison iterate-next ] }
        { \ math.private:float= [ drop cc= emit-float-comparison iterate-next ] }
        { \ math.private:float>fixnum [ drop emit-float>fixnum iterate-next ] }
        { \ math.private:fixnum>float [ drop emit-fixnum>float iterate-next ] }
        { \ slots.private:slot [ emit-slot iterate-next ] }
        { \ slots.private:set-slot [ emit-set-slot iterate-next ] }
        { \ strings.private:string-nth [ drop emit-string-nth iterate-next ] }
        { \ strings.private:set-string-nth-fast [ drop emit-set-string-nth-fast iterate-next ] }
        { \ classes.tuple.private:<tuple-boa> [ emit-<tuple-boa> iterate-next ] }
        { \ arrays:<array> [ emit-<array> iterate-next ] }
        { \ byte-arrays:<byte-array> [ emit-<byte-array> iterate-next ] }
        { \ byte-arrays:(byte-array) [ emit-(byte-array) iterate-next ] }
        { \ kernel:<wrapper> [ emit-simple-allot iterate-next ] }
        { \ alien.accessors:alien-unsigned-1 [ 1 emit-alien-unsigned-getter iterate-next ] }
        { \ alien.accessors:set-alien-unsigned-1 [ 1 emit-alien-integer-setter iterate-next ] }
        { \ alien.accessors:alien-signed-1 [ 1 emit-alien-signed-getter iterate-next ] }
        { \ alien.accessors:set-alien-signed-1 [ 1 emit-alien-integer-setter iterate-next ] }
        { \ alien.accessors:alien-unsigned-2 [ 2 emit-alien-unsigned-getter iterate-next ] }
        { \ alien.accessors:set-alien-unsigned-2 [ 2 emit-alien-integer-setter iterate-next ] }
        { \ alien.accessors:alien-signed-2 [ 2 emit-alien-signed-getter iterate-next ] }
        { \ alien.accessors:set-alien-signed-2 [ 2 emit-alien-integer-setter iterate-next ] }
        { \ alien.accessors:alien-unsigned-4 [ 4 emit-alien-unsigned-getter iterate-next ] }
        { \ alien.accessors:set-alien-unsigned-4 [ 4 emit-alien-integer-setter iterate-next ] }
        { \ alien.accessors:alien-signed-4 [ 4 emit-alien-signed-getter iterate-next ] }
        { \ alien.accessors:set-alien-signed-4 [ 4 emit-alien-integer-setter iterate-next ] }
        { \ alien.accessors:alien-cell [ emit-alien-cell-getter iterate-next ] }
        { \ alien.accessors:set-alien-cell [ emit-alien-cell-setter iterate-next ] }
        { \ alien.accessors:alien-float [ single-float-regs emit-alien-float-getter iterate-next ] }
        { \ alien.accessors:set-alien-float [ single-float-regs emit-alien-float-setter iterate-next ] }
        { \ alien.accessors:alien-double [ double-float-regs emit-alien-float-getter iterate-next ] }
        { \ alien.accessors:set-alien-double [ double-float-regs emit-alien-float-setter iterate-next ] }
    } case ;
