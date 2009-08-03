! Copyright (C) 2008, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel assocs sequences namespaces fry
sets compiler.cfg.rpo compiler.cfg.instructions locals ;
IN: compiler.cfg.def-use

GENERIC: defs-vreg ( insn -- vreg/f )
GENERIC: temp-vregs ( insn -- seq )
GENERIC: uses-vregs ( insn -- seq )

M: ##flushable defs-vreg dst>> ;
M: ##fixnum-overflow defs-vreg dst>> ;
M: _fixnum-overflow defs-vreg dst>> ;
M: insn defs-vreg drop f ;

M: ##write-barrier temp-vregs [ card#>> ] [ table>> ] bi 2array ;
M: ##unary/temp temp-vregs temp>> 1array ;
M: ##allot temp-vregs temp>> 1array ;
M: ##dispatch temp-vregs temp>> 1array ;
M: ##slot temp-vregs temp>> 1array ;
M: ##set-slot temp-vregs temp>> 1array ;
M: ##string-nth temp-vregs temp>> 1array ;
M: ##set-string-nth-fast temp-vregs temp>> 1array ;
M: ##compare temp-vregs temp>> 1array ;
M: ##compare-imm temp-vregs temp>> 1array ;
M: ##compare-float temp-vregs temp>> 1array ;
M: ##gc temp-vregs [ temp1>> ] [ temp2>> ] bi 2array ;
M: _dispatch temp-vregs temp>> 1array ;
M: insn temp-vregs drop f ;

M: ##unary uses-vregs src>> 1array ;
M: ##binary uses-vregs [ src1>> ] [ src2>> ] bi 2array ;
M: ##binary-imm uses-vregs src1>> 1array ;
M: ##effect uses-vregs src>> 1array ;
M: ##slot uses-vregs [ obj>> ] [ slot>> ] bi 2array ;
M: ##slot-imm uses-vregs obj>> 1array ;
M: ##set-slot uses-vregs [ src>> ] [ obj>> ] [ slot>> ] tri 3array ;
M: ##set-slot-imm uses-vregs [ src>> ] [ obj>> ] bi 2array ;
M: ##string-nth uses-vregs [ obj>> ] [ index>> ] bi 2array ;
M: ##set-string-nth-fast uses-vregs [ src>> ] [ obj>> ] [ index>> ] tri 3array ;
M: ##conditional-branch uses-vregs [ src1>> ] [ src2>> ] bi 2array ;
M: ##compare-imm-branch uses-vregs src1>> 1array ;
M: ##dispatch uses-vregs src>> 1array ;
M: ##alien-getter uses-vregs src>> 1array ;
M: ##alien-setter uses-vregs [ src>> ] [ value>> ] bi 2array ;
M: ##fixnum-overflow uses-vregs [ src1>> ] [ src2>> ] bi 2array ;
M: ##phi uses-vregs inputs>> values ;
M: _conditional-branch uses-vregs [ src1>> ] [ src2>> ] bi 2array ;
M: _compare-imm-branch uses-vregs src1>> 1array ;
M: _dispatch uses-vregs src>> 1array ;
M: insn uses-vregs drop f ;

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
