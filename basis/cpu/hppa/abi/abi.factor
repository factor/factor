! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays compiler.cfg.builder.alien.boxing
compiler.cfg.builder.alien.params compiler.cfg.hats compiler.cfg.instructions
cpu.architecture cpu.hppa cpu.hppa.assembler.registers kernel layouts literals locals
math math.bitwise namespaces sequences system vectors ;
IN: cpu.hppa.abi

! GNU PA32 argument words descend r26..r23. FP slots are positional:
! singles use fr4L..fr7L; aligned doubles use fr5 or fr7.
M: hppa param-regs
    drop { { int-regs ${ R26 R25 R24 R23 } }
           { float-regs ${ F4 F5 F6 F7 } } } ;
M: hppa return-regs
    { { int-regs ${ R28 R29 } } { float-regs ${ F4 } } } ;
M: hppa return-regs-for-type
    long-long-type? [
        ! Shared long-long vregs are low/high; GNU returns high in r28.
        { { int-regs ${ R29 R28 } } { float-regs ${ F4 } } }
    ] [ return-regs ] if ;
M: hppa dummy-stack-params? t ;
M: hppa dummy-int-params? t ;
M: hppa dummy-fp-params? t ;
M: hppa long-long-on-stack? f ;
M: hppa long-long-odd-register? f ;
M: hppa long-long-even-register? t ;
M: hppa float-right-align-on-stack? f ;
M: hppa struct-return-on-stack? f ;
M: hppa struct-return-register R28 ;
M: hppa return-struct-pointer? f ;
M: hppa value-struct? heap-size 8 <= ;
M: hppa return-struct-in-registers? heap-size 8 <= ;

M: hppa abi-param-slot-count double-rep eq? 2 1 ? ;
M:: hppa alloc-abi-stack-param ( rep size -- offset )
    stack-params get :> offset
    offset rep double-rep eq? 8 4 ? + stack-params set offset ;

: discard-register ( class -- ) get [ pop* ] unless-empty ;
: skip-slot ( -- ) int-regs discard-register float-regs discard-register 4 stack-params +@ ;
M: hppa prepare-long-long-registers
    dup empty? [ drop ] [
        last n>> odd? [ skip-slot ] when
    ] if ;
:: mark-scalar ( reps alignment -- reps' )
    reps [| rep i | rep first3 rep first int-rep eq? [ 4 ] [ rep param-natural-size ] if 4array 0 suffix
        i zero? alignment 1 ? suffix ] map-index ;
M:: hppa prepare-abi-parameter-group ( rep -- )
    rep length 5 > [
        ! Variadic groups append first/last flags before their alignment.
        rep length 8 = [ 5 rep nth [ 7 rep nth ] [ 1 ] if ] [ 5 rep nth ] if :> alignment
        alignment 8 >= stack-params get 7 bitand zero? not and [ skip-slot ] when
    ] when
    rep first double-rep eq? float-regs get empty? not and [
        ! The double occupies the second FP slot of its aligned pair.
        float-regs discard-register
    ] when ;
: integer-fp-argument? ( c-type -- ? )
    c-type-rep { float-rep double-rep } member? varargs-parameter? get and ;
:: integer-fp-reps ( c-type -- reps )
    c-type heap-size 4 /i { int-rep f f } <array> record-reg-reps ;
M:: hppa unbox-scalar-parameter ( src c-type -- vregs reps )
    src c-type unbox :> ( vregs reps )
    c-type integer-fp-argument? [
        reps unrecord-reg-reps drop
        c-type heap-size 8 = [
            8 8 f ^^local-allot :> buffer
            vregs first buffer 0 double-rep c-type ##store-memory-imm,
            buffer 4 int-rep f ^^load-memory-imm
            buffer 0 int-rep f ^^load-memory-imm 2array
        ] [
            4 4 f ^^local-allot :> buffer
            vregs first buffer 0 float-rep c-type ##store-memory-imm,
            buffer 0 int-rep f ^^load-memory-imm 1array
        ] if
        c-type integer-fp-reps
    ] [ vregs reps ] if
    c-type c-type-align mark-scalar ;
M:: hppa flatten-scalar-parameter ( c-type -- reps )
    c-type integer-fp-argument? [ c-type integer-fp-reps ]
    [ c-type flatten-c-type ] if c-type c-type-align mark-scalar ;
M:: hppa box-scalar-parameter ( vregs reps c-type -- dst )
    reps first int-rep eq? c-type c-type-rep { float-rep double-rep } member? and [
        c-type heap-size 8 = [
            8 8 f ^^local-allot :> buffer
            vregs first buffer 4 int-rep f ##store-memory-imm,
            vregs second buffer 0 int-rep f ##store-memory-imm,
            buffer 0 double-rep c-type ^^load-memory-imm
        ] [
            4 4 f ^^local-allot :> buffer
            vregs first buffer 0 int-rep f ##store-memory-imm,
            buffer 0 float-rep c-type ^^load-memory-imm
        ] if 1array
        c-type c-type-rep 1array c-type box
    ] [ vregs reps c-type box ] if ;

! PA32 right-aligns aggregate bytes within one or two argument words.
! Argument allocation starts with the low word; returns start with the high word.
TUPLE: hppa-struct-part size ;
C: <hppa-struct-part> hppa-struct-part
M:: hppa-struct-part load-struct-component ( src offset rep part -- dst )
    part size>> <iota> 0 ^^load-integer [| value index |
        src offset index + int-rep uchar ^^load-memory-imm
        part size>> index - 1 - 8 * ^^shl-imm value swap ^^or
    ] reduce ;
M:: hppa-struct-part store-struct-component ( value src offset rep part -- )
    part size>> <iota> [| index |
        value part size>> index - 1 - 8 * ^^shr-imm
        src offset index + int-rep uchar ##store-memory-imm,
    ] each ;
: hppa-struct-reps ( type -- reps )
    heap-size 4 > 2 1 ? { int-rep f f } <array> record-reg-reps ;
M: hppa flatten-struct-type
    dup heap-size 8 <= [
        dup heap-size 4 > 8 4 ? [ hppa-struct-reps ] dip mark-scalar
    ] [ call-next-method ] if ;
M: hppa flatten-struct-type-return
    dup heap-size 8 <= [ hppa-struct-reps ] [ call-next-method ] if ;
M:: hppa struct-components ( reps type -- offsets types )
    type heap-size :> size
    size 8 <= [
        size 4 <= [ { 0 } size 1array ] [ 0 size 4 - 2array size 4 - 4 2array ] if
        [ <hppa-struct-part> ] map
    ] [ reps type integer-struct-components ] if ;
M:: hppa unbox-struct-parameter ( src type -- vregs reps )
    type heap-size 8 <= [
        src ^^unbox-any-c-ptr type explode-struct [ reverse ] dip
    ] [ src type call-next-method ] if ;
M:: hppa box-struct-parameter ( vregs reps type -- dst )
    type heap-size 8 <= [ vregs reverse reps type box ]
    [ vregs reps type call-next-method ] if ;
