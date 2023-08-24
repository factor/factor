! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.renaming.functor
compiler.cfg.representations.conversion
compiler.cfg.representations.preferred compiler.cfg.rpo kernel
make namespaces sequences ;
IN: compiler.cfg.representations.rewrite

! Insert conversions. This introduces new temporaries, so we need
! to rename opearands too.

SYMBOL: alternatives

:: (emit-def-conversion) ( dst preferred required -- new-dst' )
    ! If an instruction defines a register with representation 'required',
    ! but the register has preferred representation 'preferred', then
    ! we rename the instruction's definition to a new register, which
    ! becomes the input of a conversion instruction.
    dst required next-vreg-rep [ preferred required emit-conversion ] keep ;

:: (emit-use-conversion) ( src preferred required -- new-src' )
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
    renaming-set get delete-all ;

: no-renaming ( vreg -- )
    dup 2array renaming-set get push ;

: record-renaming ( from to -- )
    2array renaming-set get push needs-renaming? on ;

:: (compute-renaming-set) ( vreg required quot: ( vreg preferred required -- new-vreg ) -- )
    vreg rep-of :> preferred
    preferred required eq?
    [ vreg no-renaming ]
    [ vreg vreg preferred required quot call record-renaming ] if ; inline

: emit-use-conversion ( insn -- )
    [ [ (emit-use-conversion) ] (compute-renaming-set) ] each-use-rep ;

: no-use-conversion ( insn -- )
    [ drop no-renaming ] each-use-rep ;

: emit-def-conversion ( insn -- )
    [ [ (emit-def-conversion) ] (compute-renaming-set) ] each-def-rep ;

: no-def-conversion ( insn -- )
    [ drop no-renaming ] each-def-rep ;

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

M: ##copy conversions-for-insn , ;

M: insn conversions-for-insn , ;

: conversions-for-block ( insns -- insns )
    [
        alternatives get clear-assoc
        [ conversions-for-insn ] each
    ] V{ } make ;

: insert-conversions ( cfg -- )
    H{ } clone alternatives set
    V{ } clone renaming-set set
    [ conversions-for-block ] simple-optimization ;
