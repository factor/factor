! Copyright (C) 2009, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.instructions.syntax fry
functors generic.parser kernel lexer namespaces parser sequences
sets slots words ;
IN: compiler.cfg.renaming.functor

! Like compiler.cfg.def-use, but for changing operands

: slot-change-quot ( slots quot -- quot' )
    '[ [ _ ] dip changer-word [ ] 2sequence ] map [ ] join
    [ drop ] append ;

<FUNCTOR: define-renaming ( NAME DEF-QUOT USE-QUOT TEMP-QUOT -- )

rename-insn-defs DEFINES ${NAME}-insn-defs
rename-insn-uses DEFINES ${NAME}-insn-uses
rename-insn-temps DEFINES ${NAME}-insn-temps

WHERE

GENERIC: rename-insn-defs ( insn -- )
GENERIC: rename-insn-uses ( insn -- )
GENERIC: rename-insn-temps ( insn -- )

M: insn rename-insn-defs drop ;
M: insn rename-insn-uses drop ;
M: insn rename-insn-temps drop ;

! Instructions with unusual operands

! Special rename-insn-defs methods
M: ##parallel-copy rename-insn-defs
    [ [ first2 DEF-QUOT dip 2array ] map ] change-values drop ;

M: ##phi rename-insn-defs DEF-QUOT change-dst drop ;

M: alien-call-insn rename-insn-defs
    [ [ first3 DEF-QUOT 2dip 3array ] map ] change-reg-outputs
    drop ;

M: ##callback-inputs rename-insn-defs
    [ [ first3 DEF-QUOT 2dip 3array ] map ] change-reg-outputs
    [ [ first3 DEF-QUOT 2dip 3array ] map ] change-stack-outputs
    drop ;

! Special rename-insn-uses methods
M: ##parallel-copy rename-insn-uses
    [ [ first2 USE-QUOT call 2array ] map ] change-values drop ;

M: ##phi rename-insn-uses
    [ USE-QUOT assoc-map ] change-inputs drop ;

M: alien-call-insn rename-insn-uses
    [ [ first3 USE-QUOT 2dip 3array ] map ] change-reg-inputs
    [ [ first3 USE-QUOT 2dip 3array ] map ] change-stack-inputs
    drop ;

M: ##alien-indirect rename-insn-uses
    USE-QUOT change-src call-next-method ;

M: ##callback-outputs rename-insn-uses
    [ [ first3 USE-QUOT 2dip 3array ] map ] change-reg-inputs
    drop ;

! Generate methods for everything else
insn-classes get special-vreg-insns diff [ insn-def-slots empty? ] reject [
    [ \ rename-insn-defs create-method-in ]
    [ insn-def-slots [ name>> ] map DEF-QUOT slot-change-quot ] bi
    define
] each

insn-classes get special-vreg-insns diff [ insn-use-slots empty? ] reject [
    [ \ rename-insn-uses create-method-in ]
    [ insn-use-slots [ name>> ] map USE-QUOT slot-change-quot ] bi
    define
] each

insn-classes get [ insn-temp-slots empty? ] reject [
    [ \ rename-insn-temps create-method-in ]
    [ insn-temp-slots [ name>> ] map TEMP-QUOT slot-change-quot ] bi
    define
] each

;FUNCTOR>

SYNTAX: RENAMING: scan-token scan-object scan-object scan-object define-renaming ;
