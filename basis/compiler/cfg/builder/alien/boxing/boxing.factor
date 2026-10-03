! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays assocs classes.struct classes.tuple
combinators compiler.cfg.builder.alien.params compiler.cfg.hats
compiler.cfg.instructions compiler.cfg.intrinsics.allot
compiler.cfg.registers cpu.architecture kernel layouts
locals math math.bitwise math.order namespaces sequences sequences.generalizations system ;
QUALIFIED-WITH: alien.c-types c
IN: compiler.cfg.builder.alien.boxing

! Scoped to argument classification; return values keep their ordinary ABI.
SYMBOL: windows-arm64-varargs?

! RISC-V applies the integer convention only to unnamed arguments.
SYMBOL: varargs-parameter?

SYMBOL: struct-return-area

SYMBOLS: int-reg-reps float-reg-reps ;

: reg-reps ( reps -- int-reps float-reps )
    [ second ] reject [ [ first int-rep? ] count ] [ length over - ] bi ;

: record-reg-reps ( reps -- reps )            
    dup reg-reps [ int-reg-reps +@ ] [ float-reg-reps +@ ] bi* ;

: unrecord-reg-reps ( reps -- reps )
    dup reg-reps [ neg int-reg-reps +@ ] [ neg float-reg-reps +@ ] bi* ;

GENERIC: flatten-c-type ( c-type -- pairs )

M: c-type flatten-c-type
    [ rep>> f f ] [ heap-size ] bi 4array 1array record-reg-reps ;

M: small-float-c-type flatten-c-type
    [ c-type-rep f f ] [ heap-size ] bi 4array 1array record-reg-reps ;

M: long-long-type flatten-c-type
    drop 2 [ int-rep long-long-on-stack? f 3array ] replicate record-reg-reps ;

HOOK: flatten-struct-type cpu ( type -- pairs )
HOOK: flatten-struct-type-return cpu ( type -- pairs )

M: object flatten-struct-type
    heap-size cell align cell /i { int-rep f f } <array> record-reg-reps ;

M: struct-c-type flatten-c-type
    flatten-struct-type ;

M: object flatten-struct-type-return
    flatten-struct-type ;

: stack-size ( c-type -- n )
    base-type flatten-c-type keys 0 [ rep-size + ] reduce ;

: component-offsets ( reps -- offsets )
    0 [ rep-size + ] accumulate nip ;

HOOK: struct-components cpu ( reps c-type -- offsets c-types )
M: object struct-components
    drop [ component-offsets ] [ length f <array> ] bi ;

GENERIC: load-struct-component ( src offset rep type -- dst )
M: object load-struct-component ^^load-memory-imm ;

GENERIC: store-struct-component ( value src offset rep type -- )
M: object store-struct-component ##store-memory-imm, ;

! Integer ABI chunks can end partway through a register. Foreign struct
! storage has exactly its declared size, so the last chunk must not read
! or write the register's remaining bytes.
TUPLE: partial-struct-cell size ;
C: <partial-struct-cell> partial-struct-cell

:: integer-struct-components ( reps c-type -- offsets types )
    reps component-offsets dup [| offset |
        c-type heap-size offset - cell min
        dup cell < [ <partial-struct-cell> ] [ drop f ] if
    ] map ;

M:: partial-struct-cell load-struct-component ( src offset rep part -- dst )
    part size>> <iota> 0 ^^load-integer [| dst index |
        src offset index + int-rep c:uchar ^^load-memory-imm
        index 8 * ^^shl-imm dst swap ^^or
    ] reduce ;

M:: partial-struct-cell store-struct-component ( value src offset rep part -- )
    part size>> <iota> [| index |
        value index 8 * ^^shr-imm
        src offset index + int-rep c:uchar ##store-memory-imm,
    ] each ;

:: copy-struct-data ( src dst c-type -- )
    c-type heap-size cell align cell /i int-rep <array>
    c-type integer-struct-components [| offset type |
        src offset int-rep type load-struct-component
        dst offset int-rep type store-struct-component
    ] 2each ;

! Load only bytes belonging to the field, including packed fields. A wider
! integer load/store could cross the end of the struct or overwrite a float.
M:: struct-bit-slot-spec load-struct-component ( src offset rep field -- dst )
    field offset>> 8 mod :> start
    field bits>> :> bits
    start bits + 8 align 8 /i <iota> 0 ^^load-integer
    [| dst index |
        src offset index + int-rep c:uchar ^^load-memory-imm :> byte
        index 8 * start - :> shift
        byte shift 0 < [ shift neg ^^shr-imm ] [ shift ^^shl-imm ] if
        dst swap ^^or
    ] reduce
    bits cell-bits < [
        cell-bits bits - ^^shl-imm
        cell-bits bits - field signed?>> [ ^^sar-imm ] [ ^^shr-imm ] if
    ] when ;

M:: struct-bit-slot-spec store-struct-component ( value src offset rep field -- )
    field offset>> 8 mod :> start
    field bits>> :> bits
    start bits + 8 align 8 /i <iota> [| index |
        start index 8 * - 0 max :> low
        start bits + index 8 * - 8 min :> high
        1 high low - shift 1 - low shift :> mask
        src offset index + int-rep c:uchar ^^load-memory-imm mask bitnot ^^and-imm :> old
        index 8 * start - :> shift
        value shift 0 < [ shift neg ^^shl-imm ] [ shift ^^shr-imm ] if
        mask ^^and-imm old swap ^^or
        src offset index + int-rep c:uchar ##store-memory-imm,
    ] each ;

:: explode-struct ( src c-type -- vregs reps )
    c-type flatten-struct-type :> reps
    reps keys dup c-type struct-components
    [| rep offset type | src offset rep type load-struct-component ] 3map
    reps ;

:: explode-struct-return ( src c-type -- vregs reps )
    c-type flatten-struct-type-return :> reps
    reps keys dup c-type struct-components
    [| rep offset type | src offset rep type load-struct-component ] 3map
    reps ;

:: implode-struct ( src vregs reps -- )
    vregs reps dup component-offsets
    [| vreg rep offset | vreg src offset rep f ##store-memory-imm, ] 3each ;

:: implode-struct-type ( src vregs reps c-type -- )
    reps c-type struct-components :> ( offsets types )
    vregs reps offsets types
    [| vreg rep offset type | vreg src offset rep type store-struct-component ] 4 neach ;

GENERIC: unbox ( src c-type -- vregs reps )

M:: c-type unbox ( src c-type -- vregs reps )
    src c-type [ rep>> ] [ unboxer>> ] bi
    [
        {
            { "to_float" [ drop ] }
            { "to_double" [ drop ] }
            { "to_signed_1" [ drop ] }
            { "to_unsigned_1" [ drop ] }
            { "to_signed_2" [ drop ] }
            { "to_unsigned_2" [ drop ] }
            { "alien_offset" [ drop ^^unbox-any-c-ptr ] }
            [
                dup { "to_signed_4" "to_unsigned_4" } member?
                [ cell 8 = not ] [ t ] if
                [ swap ^^unbox ] [ 2drop ] if
            ]
        } case 1array
    ]
    [ drop f f c-type heap-size 4array 1array ] 2bi record-reg-reps ;

! Numeric quotations convert small floats to/from raw fixnum payloads.
! Keep the ABI representation distinct from the fixnum representation.
M: small-float-c-type unbox
    [ [ unboxer>> ] [ c-type-rep ] bi ^^unbox 1array ]
    [ nip flatten-c-type ] 2bi ;

! SIMD values are byte arrays between the tree and CFG stages. The normal
! representation conversion pass loads/stores their 128-bit payloads.
M: vector-c-type unbox
    [ 1array ] [ rep>> f f 3array 1array record-reg-reps ] bi* ;

M: long-long-type unbox
    [ next-vreg next-vreg 2dup ] 2dip unboxer>> ##unbox-long-long, 2array
    int-rep long-long-on-stack? long-long-odd-register? 3array
    int-rep long-long-on-stack? f 3array 2array record-reg-reps ;

M: struct-c-type unbox
    [ ^^unbox-any-c-ptr ] dip explode-struct ;

: frob-struct ( c-type -- c-type )
    dup value-struct? [ drop void* base-type ] unless ;

GENERIC: unbox-parameter ( src c-type -- vregs reps )

HOOK: unbox-scalar-parameter cpu ( src c-type -- vregs reps )
M: object unbox-scalar-parameter unbox ;
M: c-type unbox-parameter unbox-scalar-parameter ;

M: long-long-type unbox-parameter unbox-scalar-parameter ;

HOOK: unbox-struct-parameter cpu ( src c-type -- vregs reps )
M: object unbox-struct-parameter
    dup value-struct? [ unbox ] [
        [ nip [ heap-size ] [ c-type-align cell max ] bi f ^^local-allot dup ]
        [ [ ^^unbox-any-c-ptr ] dip explode-struct keys ] 2bi
        implode-struct
        1array { { int-rep f f } }
    ] if ;
M: struct-c-type unbox-parameter unbox-struct-parameter ;

: store-return ( vregs reps -- triples )
    [ [ dup next-return-reg 3array ] 2map ] with-return-regs ;

GENERIC: unbox-return ( src c-type -- vregs reps )

HOOK: unbox-scalar-return cpu ( src c-type -- vregs reps )
M: object unbox-scalar-return unbox keys ;

M: abstract-c-type unbox-return
    ! Don't care about on-stack? flag when looking at return
    ! values.
    unbox-scalar-return ;

M: struct-c-type unbox-return
    dup return-struct-in-registers?
    [ [ ^^unbox-any-c-ptr ] dip explode-struct-return keys ]
    [
        [ struct-return-area get ] 2dip [ unbox keys ] keep implode-struct-type
        return-struct-pointer?
        [ struct-return-area get 1array { int-rep } ] [ { } { } ] if
    ] if ;

GENERIC: flatten-parameter-type ( c-type -- reps )

HOOK: flatten-scalar-parameter cpu ( c-type -- reps )
M: object flatten-scalar-parameter flatten-c-type ;
M: abstract-c-type flatten-parameter-type flatten-scalar-parameter ;

M: struct-c-type flatten-parameter-type frob-struct flatten-c-type ;

GENERIC: box ( vregs reps c-type -- dst )

M: c-type box
    [ [ first ] bi@ ] [ boxer>> ] bi*
    {
        { "from_float" [ drop ] }
        { "from_double" [ drop ] }
        { "from_signed_1" [ drop c:char ^^convert-integer ] }
        { "from_unsigned_1" [ drop c:uchar ^^convert-integer ] }
        { "from_signed_2" [ drop c:short ^^convert-integer ] }
        { "from_unsigned_2" [ drop c:ushort ^^convert-integer ] }
        { "allot_alien" [ drop ^^box-alien ] }
        [
            cell 8 = [
                {
                    { [ dup "from_signed_4" = ] [ c:int ] }
                    { [ dup "from_unsigned_4" = ] [ c:uint ] }
                    [ f ]
                } cond
            ] [ f ] if
            [ 2nip ^^convert-integer ]
            [ swap <gc-map> ^^box ] if*
        ]
    } case ;

M: small-float-c-type box
    [ [ first ] bi@ ] [ boxer>> ] bi* swap <gc-map> ^^box ;

M: vector-c-type box 2drop first ;

M: long-long-type box
    [ first2 ] [ drop ] [ boxer>> ] tri*
    <gc-map> ^^box-long-long ;

M: struct-c-type box
    [ '[ _ heap-size ^^allot-byte-array dup ^^unbox-byte-array ] 2dip ] keep
    implode-struct-type ;

GENERIC: box-parameter ( vregs reps c-type -- dst )

HOOK: box-scalar-parameter cpu ( vregs reps c-type -- dst )
M: object box-scalar-parameter box ;
M: abstract-c-type box-parameter box-scalar-parameter ;

HOOK: box-struct-parameter cpu ( vregs reps c-type -- dst )
M: object box-struct-parameter
    dup value-struct?
    [ [ [ drop first ] dip explode-struct keys ] keep ] unless
    box ;
M: struct-c-type box-parameter box-struct-parameter ;

GENERIC: load-return ( c-type -- triples )

GENERIC: flatten-return-type ( c-type -- reps )
M: abstract-c-type flatten-return-type flatten-c-type ;
M: struct-c-type flatten-return-type flatten-struct-type-return ;

M: abstract-c-type load-return
    [
        flatten-return-type keys
        [ [ next-vreg ] dip dup next-return-reg 3array ] map
    ] with-return-regs ;

M: struct-c-type load-return
    dup return-struct-in-registers?
    [ call-next-method ] [ drop { } ] if ;

GENERIC: box-return ( vregs reps c-type -- dst )

M: abstract-c-type box-return box ;

M: struct-c-type box-return
    dup return-struct-in-registers?
    [ call-next-method ]
    [
        [
            [ [ { } assert-sequence= ] bi@ struct-return-area get ] dip
            explode-struct-return keys
        ] keep box
    ] if ;

! Windows ARM64 variadic callbacks receive the same raw GP payloads as
! outgoing calls. These helpers leave the flag scoped to argument work.
: flatten-windows-vararg-type ( c-type -- reps )
    t windows-arm64-varargs? [
        flatten-parameter-type [
            dup first dup vector-rep? [
                2drop { { int-rep f f 8 } { int-rep f f 8 } }
            ] [
                reg-class-of float-regs eq? [
                    rest int-rep prefix
                ] when 1array
            ] if
        ] map concat
    ] with-variable ;

:: (box-windows-vararg-parameter) ( vregs reps c-type -- dst )
    c-type struct-c-type? [ vregs reps c-type box-parameter ] [
        c-type c-type-rep :> rep
        rep vector-rep? [
            16 16 f ^^local-allot :> buffer
            buffer vregs { int-rep int-rep } implode-struct
            buffer 0 rep f ^^load-memory-imm 1array
            rep 1array c-type box-parameter
        ] [
            rep reg-class-of float-regs eq? [
                vregs first rep ^^integer>scalar 1array
                rep 1array c-type box-parameter
            ] [ vregs reps c-type box-parameter ] if
        ] if
    ] if ;

: box-windows-vararg-parameter ( vregs reps c-type -- dst )
    t windows-arm64-varargs?
    [ (box-windows-vararg-parameter) ] with-variable ;
