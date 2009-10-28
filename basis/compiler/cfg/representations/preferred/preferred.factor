! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences arrays fry namespaces generic
words sets combinators generalizations cpu.architecture compiler.units
compiler.cfg.utilities compiler.cfg compiler.cfg.rpo
compiler.cfg.instructions compiler.cfg.def-use ;
FROM: compiler.cfg.instructions.syntax => insn-def-slot insn-use-slots insn-temp-slots scalar-rep ;
IN: compiler.cfg.representations.preferred

GENERIC: defs-vreg-rep ( insn -- rep/f )
GENERIC: temp-vreg-reps ( insn -- reps )
GENERIC: uses-vreg-reps ( insn -- reps )

<PRIVATE

: rep-getter-quot ( rep -- quot )
    {
        { f [ [ rep>> ] ] }
        { scalar-rep [ [ rep>> scalar-rep-of ] ] }
        [ [ drop ] swap suffix ]
    } case ;

: define-defs-vreg-rep-method ( insn -- )
    [ \ defs-vreg-rep create-method ]
    [ insn-def-slot [ rep>> rep-getter-quot ] [ [ drop f ] ] if* ]
    bi define ;

: reps-getter-quot ( reps -- quot )
    dup [ rep>> { f scalar-rep } member-eq? not ] all? [
        [ rep>> ] map [ drop ] swap suffix
    ] [
        [ rep>> rep-getter-quot ] map dup length {
            { 0 [ drop [ drop f ] ] }
            { 1 [ first [ 1array ] compose ] }
            { 2 [ first2 '[ _ _ bi 2array ] ] }
            [ '[ _ cleave _ narray ] ]
        } case
    ] if ;

: define-uses-vreg-reps-method ( insn -- )
    [ \ uses-vreg-reps create-method ]
    [ insn-use-slots reps-getter-quot ]
    bi define ;

: define-temp-vreg-reps-method ( insn -- )
    [ \ temp-vreg-reps create-method ]
    [ insn-temp-slots reps-getter-quot ]
    bi define ;

PRIVATE>

[
    insn-classes get
    [ [ define-defs-vreg-rep-method ] each ]
    [ { ##phi } diff [ define-uses-vreg-reps-method ] each ]
    [ [ define-temp-vreg-reps-method ] each ]
    tri
] with-compilation-unit

: each-def-rep ( insn vreg-quot: ( vreg rep -- ) -- )
    [ [ defs-vreg ] [ defs-vreg-rep ] bi ] dip with when* ; inline

: each-use-rep ( insn vreg-quot: ( vreg rep -- ) -- )
    [ [ uses-vregs ] [ uses-vreg-reps ] bi ] dip 2each ; inline

: each-temp-rep ( insn vreg-quot: ( vreg rep -- ) -- )
    [ [ temp-vregs ] [ temp-vreg-reps ] bi ] dip 2each ; inline

: with-vreg-reps ( cfg vreg-quot: ( vreg rep -- ) -- )
    '[
        [ basic-block set ] [
            [
                _
                [ each-def-rep ]
                [ each-use-rep ]
                [ each-temp-rep ] 2tri
            ] each-non-phi
        ] bi
    ] each-basic-block ; inline
