! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators compiler.cfg.def-use
compiler.cfg.instructions compiler.units cpu.architecture
generic kernel namespaces sequences sequences.generalizations
sets words ;
FROM: compiler.cfg.instructions.syntax => insn-def-slots
insn-use-slots insn-temp-slots scalar-rep ;
IN: compiler.cfg.representations.preferred

GENERIC: defs-vreg-reps ( insn -- reps )
GENERIC: temp-vreg-reps ( insn -- reps )
GENERIC: uses-vreg-reps ( insn -- reps )

M: insn defs-vreg-reps drop { } ;
M: insn temp-vreg-reps drop { } ;
M: insn uses-vreg-reps drop { } ;

<PRIVATE

: rep-getter-quot ( rep -- quot )
    {
        { f [ [ rep>> ] ] }
        { scalar-rep [ [ rep>> scalar-rep-of ] ] }
        [ [ drop ] swap suffix ]
    } case ;

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

: define-vreg-reps-method ( insn slots word -- )
    [ [ drop ] ] dip '[
        [ _ create-method ]
        [ reps-getter-quot ]
        bi* define
    ] if-empty ;

: define-defs-vreg-reps-method ( insn -- )
    dup insn-def-slots \ defs-vreg-reps define-vreg-reps-method ;

: define-uses-vreg-reps-method ( insn -- )
    dup insn-use-slots \ uses-vreg-reps define-vreg-reps-method ;

: define-temp-vreg-reps-method ( insn -- )
    dup insn-temp-slots \ temp-vreg-reps define-vreg-reps-method ;

PRIVATE>

M: alien-call-insn defs-vreg-reps
    reg-outputs>> [ second ] map ;

M: ##callback-inputs defs-vreg-reps
    [ reg-outputs>> ] [ stack-outputs>> ] bi append [ second ] map ;

M: ##callback-outputs defs-vreg-reps drop { } ;

M: alien-call-insn uses-vreg-reps
    [ reg-inputs>> ] [ stack-inputs>> ] bi append [ second ] map ;

M: ##alien-indirect uses-vreg-reps
    call-next-method int-rep prefix ;

M: ##callback-inputs uses-vreg-reps
    drop { } ;

M: ##callback-outputs uses-vreg-reps
    reg-inputs>> [ second ] map ;

[
    insn-classes get
    [ special-vreg-insns diff [ define-defs-vreg-reps-method ] each ]
    [ special-vreg-insns diff [ define-uses-vreg-reps-method ] each ]
    [ [ define-temp-vreg-reps-method ] each ]
    tri
] with-compilation-unit

: each-def-rep ( insn vreg-quot: ( vreg rep -- ) -- )
    [ [ defs-vregs ] [ defs-vreg-reps ] bi ] dip 2each ; inline

: each-use-rep ( insn vreg-quot: ( vreg rep -- ) -- )
    [ [ uses-vregs ] [ uses-vreg-reps ] bi ] dip 2each ; inline

: each-temp-rep ( insn vreg-quot: ( vreg rep -- ) -- )
    [ [ temp-vregs ] [ temp-vreg-reps ] bi ] dip 2each ; inline

: each-rep ( insn vreg-quot: ( vreg rep -- ) -- )
    [ each-def-rep ] [ each-use-rep ] [ each-temp-rep ] 2tri ; inline
