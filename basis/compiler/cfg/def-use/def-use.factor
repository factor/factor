! Copyright (C) 2008, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs arrays classes combinators
compiler.units fry generalizations generic kernel locals
namespaces quotations sequences sets slots words
compiler.cfg.instructions compiler.cfg.instructions.syntax
compiler.cfg.rpo ;
IN: compiler.cfg.def-use

GENERIC: defs-vreg ( insn -- vreg/f )
GENERIC: temp-vregs ( insn -- seq )
GENERIC: uses-vregs ( insn -- seq )

M: insn defs-vreg drop f ;
M: insn temp-vregs drop { } ;
M: insn uses-vregs drop { } ;

M: ##phi uses-vregs inputs>> values ;

<PRIVATE

: slot-array-quot ( slots -- quot )
    [ reader-word 1quotation ] map dup length {
        { 0 [ drop [ drop f ] ] }
        { 1 [ first [ 1array ] compose ] }
        { 2 [ first2 '[ _ _ bi 2array ] ] }
        [ '[ _ cleave _ narray ] ]
    } case ;

: define-defs-vreg-method ( insn -- )
    dup insn-def-slot dup [
        [ \ defs-vreg create-method ]
        [ name>> reader-word 1quotation ] bi*
        define
    ] [ 2drop ] if ;

: define-uses-vregs-method ( insn -- )
    dup insn-use-slots [ drop ] [
        [ \ uses-vregs create-method ]
        [ [ name>> ] map slot-array-quot ] bi*
        define
    ] if-empty ;

: define-temp-vregs-method ( insn -- )
    dup insn-temp-slots [ drop ] [
        [ \ temp-vregs create-method ]
        [ [ name>> ] map slot-array-quot ] bi*
        define
    ] if-empty ;

PRIVATE>

[
    insn-classes get
    [ [ define-defs-vreg-method ] each ]
    [ { ##phi } diff [ define-uses-vregs-method ] each ]
    [ [ define-temp-vregs-method ] each ]
    tri
] with-compilation-unit

! Computing def-use chains.

SYMBOLS: defs insns uses ;

: def-of ( vreg -- node ) defs get at ;
: uses-of ( vreg -- nodes ) uses get at ;
: insn-of ( vreg -- insn ) insns get at ;

: set-def-of ( obj insn assoc -- )
    swap defs-vreg dup [ swap set-at ] [ 3drop ] if ;

: compute-defs ( cfg -- )
    H{ } clone [
        '[
            dup instructions>> [
                _ set-def-of
            ] with each
        ] each-basic-block
    ] keep
    defs set ;

: compute-insns ( cfg -- )
    H{ } clone [
        '[
            instructions>> [
                dup _ set-def-of
            ] each
        ] each-basic-block
    ] keep insns set ;

:: compute-uses ( cfg -- )
    ! Here, a phi node uses its argument in the block that it comes from.
    H{ } clone :> use
    cfg [| block |
        block instructions>> [
            dup ##phi?
            [ inputs>> [ use conjoin-at ] assoc-each ]
            [ uses-vregs [ block swap use conjoin-at ] each ]
            if
        ] each
    ] each-basic-block
    use [ keys ] assoc-map uses set ;
