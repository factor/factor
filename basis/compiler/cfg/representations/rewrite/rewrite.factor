! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.renaming.functor
compiler.cfg.representations.conversion
compiler.cfg.representations.preferred compiler.cfg.rpo
compiler.cfg.utilities cpu.architecture kernel locals make math
namespaces sequences ;
IN: compiler.cfg.representations.rewrite

! Insert conversions. This introduces new temporaries, so we need
! to rename opearands too.

! Mapping from vreg,rep pairs to vregs
SYMBOL: alternatives

:: emit-def-conversion ( dst preferred required -- new-dst' )
    ! If an instruction defines a register with representation 'required',
    ! but the register has preferred representation 'preferred', then
    ! we rename the instruction's definition to a new register, which
    ! becomes the input of a conversion instruction.
    dst required next-vreg-rep [ preferred required emit-conversion ] keep ;

:: emit-use-conversion ( src preferred required -- new-src' )
    ! If an instruction uses a register with representation 'required',
    ! but the register has preferred representation 'preferred', then
    ! we rename the instruction's input to a new register, which
    ! becomes the output of a conversion instruction.
    preferred required eq? [ src ] [
        src required alternatives get [
            required next-vreg-rep :> new-src
            [ new-src ] 2dip preferred emit-conversion
            new-src
        ] 2cache
    ] if ;

SYMBOLS: renaming-set needs-renaming? ;

: init-renaming-set ( -- )
    needs-renaming? off
    V{ } clone renaming-set set ;

: no-renaming ( vreg -- )
    dup 2array renaming-set get push ;

: record-renaming ( from to -- )
    2array renaming-set get push needs-renaming? on ;

:: (compute-renaming-set) ( vreg required quot: ( vreg preferred required -- new-vreg ) -- )
    vreg rep-of :> preferred
    preferred required eq?
    [ vreg no-renaming ]
    [ vreg vreg preferred required quot call record-renaming ] if ; inline

: compute-renaming-set ( insn -- )
    ! temp vregs don't need conversions since they're always in their
    ! preferred representation
    init-renaming-set
    [ [ [ emit-use-conversion ] (compute-renaming-set) ] each-use-rep ]
    [ , ]
    [ [ [ emit-def-conversion ] (compute-renaming-set) ] each-def-rep ]
    tri ;

: converted-value ( vreg -- vreg' )
    renaming-set get pop first2 [ assert= ] dip ;

RENAMING: convert [ converted-value ] [ converted-value ] [ ]

: perform-renaming ( insn -- )
    needs-renaming? get [
        renaming-set get reverse! drop
        [ convert-insn-uses ] [ convert-insn-defs ] bi
        renaming-set get length 0 assert=
    ] [ drop ] if ;

GENERIC: conversions-for-insn ( insn -- )

M: ##phi conversions-for-insn , ;

! When a float is unboxed, we replace the ##load-constant with a ##load-double
! if the architecture supports it
: convert-to-load-double? ( insn -- ? )
    {
        [ drop load-double? ]
        [ dst>> rep-of double-rep? ]
        [ obj>> float? ]
    } 1&& ;

! When a literal zeroes/ones vector is unboxed, we replace the ##load-reference
! with a ##zero-vector or ##fill-vector instruction since this is more efficient.
: convert-to-zero-vector? ( insn -- ? )
    {
        [ dst>> rep-of vector-rep? ]
        [ obj>> B{ 0 0 0 0  0 0 0 0  0 0 0 0  0 0 0 0 } = ]
    } 1&& ;

: convert-to-fill-vector? ( insn -- ? )
    {
        [ dst>> rep-of vector-rep? ]
        [ obj>> B{ 255 255 255 255  255 255 255 255  255 255 255 255  255 255 255 255 } = ]
    } 1&& ;

: (convert-to-load-double) ( insn -- dst val )
    [ dst>> ] [ obj>> ] bi ; inline

: (convert-to-zero/fill-vector) ( insn -- dst rep )
    dst>> dup rep-of ; inline

: conversions-for-load-insn ( insn -- ?insn )
    {
        {
            [ dup convert-to-load-double? ]
            [ (convert-to-load-double) ##load-double f ]
        }
        {
            [ dup convert-to-zero-vector? ]
            [ (convert-to-zero/fill-vector) ##zero-vector f ]
        }
        {
            [ dup convert-to-fill-vector? ]
            [ (convert-to-zero/fill-vector) ##fill-vector f ]
        }
        [ ]
    } cond ;

M: ##load-reference conversions-for-insn
    conversions-for-load-insn [ call-next-method ] when* ;

M: ##load-constant conversions-for-insn
    conversions-for-load-insn [ call-next-method ] when* ;

M: vreg-insn conversions-for-insn
    [ compute-renaming-set ] [ perform-renaming ] bi ;

M: insn conversions-for-insn , ;

: conversions-for-block ( bb -- )
    dup kill-block? [ drop ] [
        [
            [
                H{ } clone alternatives set
                [ conversions-for-insn ] each
            ] V{ } make
        ] change-instructions drop
    ] if ;

: insert-conversions ( cfg -- )
    [ conversions-for-block ] each-basic-block ;
