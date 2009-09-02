! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences arrays fry namespaces generic
words sets cpu.architecture compiler.units
compiler.cfg.utilities compiler.cfg compiler.cfg.rpo
compiler.cfg.instructions compiler.cfg.instructions.syntax
compiler.cfg.def-use ;
IN: compiler.cfg.representations.preferred

GENERIC: defs-vreg-rep ( insn -- rep/f )
GENERIC: temp-vreg-reps ( insn -- reps )
GENERIC: uses-vreg-reps ( insn -- reps )

<PRIVATE

: define-defs-vreg-rep-method ( insn -- )
    [ \ defs-vreg-rep create-method ]
    [ insn-def-slot dup [ rep>> ] when '[ drop _ ] ] bi
    define ;

: define-uses-vreg-reps-method ( insn -- )
    [ \ uses-vreg-reps create-method ]
    [ insn-use-slots [ rep>> ] map '[ drop _ ] ] bi
    define ;

: define-temp-vreg-reps-method ( insn -- )
    [ \ temp-vreg-reps create-method ]
    [ insn-temp-slots [ rep>> ] map '[ drop _ ] ] bi
    define ;

PRIVATE>

[
    insn-classes get
    [ { ##copy } diff [ define-defs-vreg-rep-method ] each ]
    [ { ##copy ##phi } diff [ define-uses-vreg-reps-method ] each ]
    [ [ define-temp-vreg-reps-method ] each ]
    tri
] with-compilation-unit

M: ##copy defs-vreg-rep rep>> ;

M: ##copy uses-vreg-reps rep>> 1array ;

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
