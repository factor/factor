! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: qualified words sequences kernel combinators
cpu.architecture
compiler.cfg.hats
compiler.cfg.instructions
compiler.cfg.intrinsics.alien
compiler.cfg.intrinsics.allot
compiler.cfg.intrinsics.fixnum
compiler.cfg.intrinsics.float
compiler.cfg.intrinsics.slots ;
QUALIFIED: kernel
QUALIFIED: arrays
QUALIFIED: byte-arrays
QUALIFIED: kernel.private
QUALIFIED: slots.private
QUALIFIED: classes.tuple.private
QUALIFIED: math.private
QUALIFIED: alien.accessors
IN: compiler.cfg.intrinsics

{
    kernel.private:tag
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
    classes.tuple.private:<tuple-boa>
    arrays:<array>
    byte-arrays:<byte-array>
    math.private:<complex>
    math.private:<ratio>
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
        alien.accessors:alien-float
        alien.accessors:set-alien-float
        alien.accessors:alien-double
        alien.accessors:set-alien-double
    } [ t "intrinsic" set-word-prop ] each ;

: emit-intrinsic ( node word -- )
    {
        { \ kernel.private:tag [ drop emit-tag ] }
        { \ math.private:fixnum+fast [ [ ^^add ] [ ^^add-imm ] emit-fixnum-op ] }
        { \ math.private:fixnum-fast [ [ ^^sub ] [ ^^sub-imm ] emit-fixnum-op ] }
        { \ math.private:fixnum-bitand [ [ ^^and ] [ ^^and-imm ] emit-fixnum-op ] }
        { \ math.private:fixnum-bitor [ [ ^^or ] [ ^^or-imm ] emit-fixnum-op ] }
        { \ math.private:fixnum-bitxor [ [ ^^xor ] [ ^^xor-imm ] emit-fixnum-op ] }
        { \ math.private:fixnum-shift-fast [ emit-fixnum-shift-fast ] }
        { \ math.private:fixnum-bitnot [ drop emit-fixnum-bitnot ] }
        { \ math.private:fixnum*fast [ emit-fixnum*fast ] }
        { \ math.private:fixnum< [ cc< emit-fixnum-comparison ] }
        { \ math.private:fixnum<= [ cc<= emit-fixnum-comparison ] }
        { \ math.private:fixnum>= [ cc>= emit-fixnum-comparison ] }
        { \ math.private:fixnum> [ cc> emit-fixnum-comparison ] }
        { \ kernel:eq? [ cc= emit-fixnum-comparison ] }
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
        { \ math.private:float= [ drop cc> emit-float-comparison ] }
        { \ math.private:float>fixnum [ drop emit-float>fixnum ] }
        { \ math.private:fixnum>float [ drop emit-fixnum>float ] }
        { \ slots.private:slot [ emit-slot ] }
        { \ slots.private:set-slot [ emit-set-slot ] }
        { \ classes.tuple.private:<tuple-boa> [ emit-<tuple-boa> ] }
        { \ arrays:<array> [ emit-<array> ] }
        { \ byte-arrays:<byte-array> [ emit-<byte-array> ] }
        { \ math.private:<complex> [ emit-simple-allot ] }
        { \ math.private:<ratio> [ emit-simple-allot ] }
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
