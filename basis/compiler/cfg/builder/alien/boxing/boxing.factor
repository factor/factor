! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays assocs combinators
classes.struct fry kernel layouts locals math namespaces
sequences sequences.generalizations system
compiler.cfg.builder.alien.params compiler.cfg.hats
compiler.cfg.registers compiler.cfg.instructions
compiler.cfg.intrinsics.allot cpu.architecture ;
QUALIFIED-WITH: alien.c-types c
IN: compiler.cfg.builder.alien.boxing

SYMBOL: struct-return-area

! pairs have shape { rep on-stack? }
GENERIC: flatten-c-type ( c-type -- pairs )

M: c-type flatten-c-type
    rep>> f f 3array 1array ;

M: long-long-type flatten-c-type
    drop 2 [ int-rep long-long-on-stack? f 3array ] replicate ;

HOOK: flatten-struct-type cpu ( type -- pairs )
HOOK: flatten-struct-type-return cpu ( type -- pairs )

M: object flatten-struct-type
    heap-size cell align cell /i { int-rep f f } <repetition> ;

M: struct-c-type flatten-c-type
    flatten-struct-type ;

M: object flatten-struct-type-return
    flatten-struct-type ;

: stack-size ( c-type -- n )
    base-type flatten-c-type keys 0 [ rep-size + ] reduce ;

: component-offsets ( reps -- offsets )
    0 [ rep-size + ] accumulate nip ;

:: explode-struct ( src c-type -- vregs reps )
    c-type flatten-struct-type :> reps
    reps keys dup component-offsets
    [| rep offset | src offset rep f ^^load-memory-imm ] 2map
    reps ;

:: explode-struct-return ( src c-type -- vregs reps )
    c-type flatten-struct-type-return :> reps
    reps keys dup component-offsets
    [| rep offset | src offset rep f ^^load-memory-imm ] 2map
    reps ;

:: implode-struct ( src vregs reps -- )
    vregs reps dup component-offsets
    [| vreg rep offset | vreg src offset rep f ##store-memory-imm, ] 3each ;

GENERIC: unbox ( src c-type -- vregs reps )

M: c-type unbox
    [ rep>> ] [ unboxer>> ] bi
    [
        {
            { "to_float" [ drop ] }
            { "to_double" [ drop ] }
            { "to_signed_1" [ drop ] }
            { "to_unsigned_1" [ drop ] }
            { "to_signed_2" [ drop ] }
            { "to_unsigned_2" [ drop ] }
            { "to_signed_4" [ drop ] }
            { "to_unsigned_4" [ drop ] }
            { "alien_offset" [ drop ^^unbox-any-c-ptr ] }
            [ swap ^^unbox ]
        } case 1array
    ]
    [ drop f f 3array 1array ] 2bi ;

M: long-long-type unbox
    [ next-vreg next-vreg 2dup ] 2dip unboxer>> ##unbox-long-long, 2array
    int-rep long-long-on-stack? long-long-odd-register? 3array
    int-rep long-long-on-stack? f 3array 2array ;

M: struct-c-type unbox ( src c-type -- vregs reps )
    [ ^^unbox-any-c-ptr ] dip explode-struct ;

: frob-struct ( c-type -- c-type )
    dup value-struct? [ drop void* base-type ] unless ;

GENERIC: unbox-parameter ( src c-type -- vregs reps )

M: c-type unbox-parameter unbox ;

M: long-long-type unbox-parameter unbox ;

M: struct-c-type unbox-parameter
    dup value-struct? [ unbox ] [
        [ nip heap-size cell f ^^local-allot dup ]
        [ [ ^^unbox-any-c-ptr ] dip explode-struct keys ] 2bi
        implode-struct
        1array { { int-rep f f } }
    ] if ;

: store-return ( vregs reps -- triples )
    [ [ dup next-return-reg 3array ] 2map ] with-return-regs ;

GENERIC: unbox-return ( src c-type -- vregs reps )

M: abstract-c-type unbox-return
    ! Don't care about on-stack? flag when looking at return
    ! values.
    unbox keys ;

M: struct-c-type unbox-return
    dup return-struct-in-registers?
    [ call-next-method ]
    [ [ struct-return-area get ] 2dip unbox keys implode-struct { } { } ] if ;

GENERIC: flatten-parameter-type ( c-type -- reps )

M: abstract-c-type flatten-parameter-type flatten-c-type ;

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
        { "from_signed_4" [ drop c:int ^^convert-integer ] }
        { "from_unsigned_4" [ drop c:uint ^^convert-integer ] }
        { "allot_alien" [ drop ^^box-alien ] }
        [ swap <gc-map> ^^box ]
    } case ;

M: long-long-type box
    [ first2 ] [ drop ] [ boxer>> ] tri*
    <gc-map> ^^box-long-long ;

M: struct-c-type box
    '[ _ heap-size ^^allot-byte-array dup ^^unbox-byte-array ] 2dip
    implode-struct ;

GENERIC: box-parameter ( vregs reps c-type -- dst )

M: abstract-c-type box-parameter box ;

M: struct-c-type box-parameter
    dup value-struct?
    [ [ [ drop first ] dip explode-struct keys ] keep ] unless
    box ;

GENERIC: load-return ( c-type -- triples )

M: abstract-c-type load-return
    [
        flatten-c-type keys
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
