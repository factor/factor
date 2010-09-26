! Copyright (C) 2008, 2010 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs arrays classes combinators
compiler.units fry generalizations sequences.generalizations
generic kernel locals namespaces quotations sequences sets slots
words compiler.cfg.instructions compiler.cfg.instructions.syntax
compiler.cfg.rpo compiler.cfg ;
FROM: namespaces => set ;
FROM: sets => members ;
IN: compiler.cfg.def-use

GENERIC: defs-vregs ( insn -- seq )
GENERIC: temp-vregs ( insn -- seq )
GENERIC: uses-vregs ( insn -- seq )

M: insn defs-vregs drop { } ;
M: insn temp-vregs drop { } ;
M: insn uses-vregs drop { } ;

<PRIVATE

: slot-array-quot ( slots -- quot )
    [ reader-word 1quotation ] map dup length {
        { 0 [ drop [ drop f ] ] }
        { 1 [ first [ 1array ] compose ] }
        { 2 [ first2 '[ _ _ bi 2array ] ] }
        [ '[ _ cleave _ narray ] ]
    } case ;

: define-vregs-method ( insn slots word -- )
    [ [ drop ] ] dip '[
        [ _ create-method ]
        [ [ name>> ] map slot-array-quot ] bi*
        define
    ] if-empty ; inline

: define-defs-vregs-method ( insn -- )
    dup insn-def-slots \ defs-vregs define-vregs-method ;

: define-uses-vregs-method ( insn -- )
    dup insn-use-slots \ uses-vregs define-vregs-method ;

: define-temp-vregs-method ( insn -- )
    dup insn-temp-slots \ temp-vregs define-vregs-method ;

PRIVATE>

CONSTANT: special-vreg-insns
{ ##phi ##alien-invoke ##alien-indirect ##alien-assembly ##callback-inputs ##callback-outputs }

M: ##phi defs-vregs dst>> 1array ;

M: alien-call-insn defs-vregs
    reg-outputs>> [ first ] map ;

M: ##callback-inputs defs-vregs
    [ reg-outputs>> ] [ stack-outputs>> ] bi append [ first ] map ;

M: ##callback-outputs defs-vregs drop { } ;

M: ##phi uses-vregs inputs>> values ;

M: alien-call-insn uses-vregs
    [ reg-inputs>> ] [ stack-inputs>> ] bi append [ first ] map ;

M: ##alien-indirect uses-vregs
    [ call-next-method ] [ src>> ] bi prefix ;

M: ##callback-inputs uses-vregs
    drop { } ;

M: ##callback-outputs uses-vregs
    reg-inputs>> [ first ] map ;

[
    insn-classes get
    [ special-vreg-insns diff [ define-defs-vregs-method ] each ]
    [ special-vreg-insns diff [ define-uses-vregs-method ] each ]
    [ [ define-temp-vregs-method ] each ]
    tri
] with-compilation-unit

SYMBOLS: defs insns ;

: def-of ( vreg -- node ) defs get at ;
: insn-of ( vreg -- insn ) insns get at ;

: set-def-of ( obj insn assoc -- )
    swap defs-vregs [ swap set-at ] with with each ;

: compute-defs ( cfg -- )
    H{ } clone [
        '[
            [ basic-block get ] dip [
                _ set-def-of
            ] with each
        ] simple-analysis
    ] keep defs set ;

: compute-insns ( cfg -- )
    H{ } clone [
        '[
            [
                dup _ set-def-of
            ] each
        ] simple-analysis
    ] keep insns set ;
