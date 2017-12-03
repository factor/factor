! Copyright (C) 2009, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors2 kernel sequences slots strings ;
IN: compiler.cfg.renaming.functor

! Like compiler.cfg.def-use, but for changing operands

: slot-change-quot ( slots quot -- quot' )
    '[ [ _ ] dip changer-word [ ] 2sequence ] map [ ] join
    [ drop ] append ;

SAME-FUNCTOR: renaming ( NAME: name DEF-QUOT: string USE-QUOT: string TEMP-QUOT: string -- ) [[

! rename-insn-defs DEFINES ${NAME}-insn-defs
! rename-insn-uses DEFINES ${NAME}-insn-uses
! rename-insn-temps DEFINES ${NAME}-insn-temps

! WHERE

GENERIC: ${NAME}-insn-defs ( insn -- )
GENERIC: ${NAME}-insn-uses ( insn -- )
GENERIC: ${NAME}-insn-temps ( insn -- )

M: insn ${NAME}-insn-defs drop ;
M: insn ${NAME}-insn-uses drop ;
M: insn ${NAME}-insn-temps drop ;

! Instructions with unusual operands

! Special ${NAME}-insn-defs methods
M: ##parallel-copy ${NAME}-insn-defs
    [ [ first2 ${DEF-QUOT} dip 2array ] map ] change-values drop ;

M: ##phi ${NAME}-insn-defs ${DEF-QUOT} change-dst drop ;

M: alien-call-insn ${NAME}-insn-defs
    [ [ first3 ${DEF-QUOT} 2dip 3array ] map ] change-reg-outputs
    drop ;

M: ##callback-inputs ${NAME}-insn-defs
    [ [ first3 ${DEF-QUOT} 2dip 3array ] map ] change-reg-outputs
    [ [ first3 ${DEF-QUOT} 2dip 3array ] map ] change-stack-outputs
    drop ;

! Special ${NAME}-insn-uses methods
M: ##parallel-copy ${NAME}-insn-uses
    [ [ first2 ${USE-QUOT} call 2array ] map ] change-values drop ;

M: ##phi ${NAME}-insn-uses
    [ ${USE-QUOT} assoc-map ] change-inputs drop ;

M: alien-call-insn ${NAME}-insn-uses
    [ [ first3 ${USE-QUOT} 2dip 3array ] map ] change-reg-inputs
    [ [ first3 ${USE-QUOT} 2dip 3array ] map ] change-stack-inputs
    drop ;

M: ##alien-indirect ${NAME}-insn-uses
    ${USE-QUOT} change-src call-next-method ;

M: ##callback-outputs ${NAME}-insn-uses
    [ [ first3 ${USE-QUOT} 2dip 3array ] map ] change-reg-inputs
    drop ;

<<
! Generate methods for everything else
insn-classes get special-vreg-insns diff [ insn-def-slots empty? ] reject [
    [ \ ${NAME}-insn-defs create-method-in ]
    [ insn-def-slots [ name>> ] map ${DEF-QUOT} slot-change-quot ] bi
    define
] each

insn-classes get special-vreg-insns diff [ insn-use-slots empty? ] reject [
    [ \ ${NAME}-insn-uses create-method-in ]
    [ insn-use-slots [ name>> ] map ${USE-QUOT} slot-change-quot ] bi
    define
] each

insn-classes get [ insn-temp-slots empty? ] reject [
    [ \ ${NAME}-insn-temps create-method-in ]
    [ insn-temp-slots [ name>> ] map ${TEMP-QUOT} slot-change-quot ] bi
    define
] each
>>

]]

! SYNTAX: \RENAMING: scan-token scan-object scan-object scan-object define-renaming ;
