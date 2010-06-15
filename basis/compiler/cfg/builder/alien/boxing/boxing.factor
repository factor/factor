! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays assocs classes.struct fry
kernel layouts locals math namespaces sequences
sequences.generalizations system
compiler.cfg.builder.alien.params compiler.cfg.hats
compiler.cfg.instructions cpu.architecture ;
IN: compiler.cfg.builder.alien.boxing

SYMBOL: struct-return-area

! pairs have shape { rep on-stack? }
GENERIC: flatten-c-type ( c-type -- pairs )

M: c-type flatten-c-type
    rep>> f 2array 1array ;

M: long-long-type flatten-c-type
    drop 2 [ int-rep long-long-on-stack? 2array ] replicate ;

HOOK: flatten-struct-type cpu ( type -- pairs )

M: object flatten-struct-type
    heap-size cell align cell /i { int-rep f } <repetition> ;

M: struct-c-type flatten-c-type
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

:: implode-struct ( src vregs reps -- )
    vregs reps dup component-offsets
    [| vreg rep offset | vreg src offset rep f ##store-memory-imm ] 3each ;

GENERIC: unbox ( src c-type -- vregs reps )

M: c-type unbox
    [ unboxer>> ] [ rep>> ] bi
    [ ^^unbox 1array ] [ nip f 2array 1array ] 2bi ;

M: long-long-type unbox
    [ 8 cell f ^^local-allot ] dip '[ _ unboxer>> ##unbox-long-long ] keep
    0 cell [ int-rep f ^^load-memory-imm ] bi-curry@ bi 2array
    int-rep long-long-on-stack? 2array dup 2array ;

M: struct-c-type unbox ( src c-type -- vregs )
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
        1array { { int-rep f } }
    ] if ;

GENERIC: unbox-return ( src c-type -- )

: store-return ( vregs reps -- )
    [
        [ [ next-return-reg ] keep ##store-reg-param ] 2each
    ] with-return-regs ;

: (unbox-return) ( src c-type -- vregs reps )
    ! Don't care about on-stack? flag when looking at return
    ! values.
    unbox keys ;

M: c-type unbox-return (unbox-return) store-return ;

M: long-long-type unbox-return (unbox-return) store-return ;

M: struct-c-type unbox-return
    dup return-struct-in-registers?
    [ (unbox-return) store-return ]
    [ [ struct-return-area get ] 2dip (unbox-return) implode-struct ] if ;

GENERIC: flatten-parameter-type ( c-type -- reps )

M: c-type flatten-parameter-type flatten-c-type ;

M: long-long-type flatten-parameter-type flatten-c-type ;

M: struct-c-type flatten-parameter-type frob-struct flatten-c-type ;

GENERIC: box ( vregs reps c-type -- dst )

M: c-type box
    [ first ] [ drop ] [ [ boxer>> ] [ rep>> ] bi ] tri* <gc-map> ^^box ;

M: long-long-type box
    [ first2 ] [ drop ] [ boxer>> ] tri* <gc-map> ^^box-long-long ;

M: struct-c-type box
    '[ _ heap-size <gc-map> ^^allot-byte-array dup ^^unbox-byte-array ] 2dip
    implode-struct ;

GENERIC: box-parameter ( vregs reps c-type -- dst )

M: c-type box-parameter box ;

M: long-long-type box-parameter box ;

M: struct-c-type box-parameter
    dup value-struct?
    [ [ [ drop first ] dip explode-struct keys ] keep ] unless
    box ;

GENERIC: box-return ( c-type -- dst )

: load-return ( c-type -- vregs reps )
    [
        flatten-c-type keys
        [ [ [ next-return-reg ] keep ^^load-reg-param ] map ] keep
    ] with-return-regs ;

M: c-type box-return [ load-return ] keep box ;

M: long-long-type box-return [ load-return ] keep box ;

M: struct-c-type box-return
    [
        dup return-struct-in-registers?
        [ load-return ]
        [ [ struct-return-area get ] dip explode-struct keys ] if
    ] keep box ;
