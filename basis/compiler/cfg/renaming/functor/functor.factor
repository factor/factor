! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs fry functors generic.parser
kernel lexer namespaces parser sequences slots words sets
compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.instructions.syntax ;
IN: compiler.cfg.renaming.functor

: slot-change-quot ( slots quot -- quot' )
    '[ [ _ ] dip changer-word [ ] 2sequence ] map [ ] join
    [ drop ] append ;

FUNCTOR: define-renaming ( NAME DEF-QUOT USE-QUOT TEMP-QUOT -- )

rename-insn-defs DEFINES ${NAME}-insn-defs
rename-insn-uses DEFINES ${NAME}-insn-uses
rename-insn-temps DEFINES ${NAME}-insn-temps

WHERE

GENERIC: rename-insn-defs ( insn -- )

M: insn rename-insn-defs drop ;

insn-classes get [ insn-def-slot ] filter [
    [ \ rename-insn-defs create-method-in ]
    [ insn-def-slot name>> 1array DEF-QUOT slot-change-quot ] bi
    define
] each

GENERIC: rename-insn-uses ( insn -- )

M: insn rename-insn-uses drop ;

insn-classes get { ##phi } diff [ insn-use-slots empty? not ] filter [
    [ \ rename-insn-uses create-method-in ]
    [ insn-use-slots [ name>> ] map USE-QUOT slot-change-quot ] bi
    define
] each

M: ##phi rename-insn-uses
    [ USE-QUOT assoc-map ] change-inputs drop ;

GENERIC: rename-insn-temps ( insn -- )

M: insn rename-insn-temps drop ;

insn-classes get [ insn-temp-slots empty? not ] filter [
    [ \ rename-insn-temps create-method-in ]
    [ insn-temp-slots [ name>> ] map TEMP-QUOT slot-change-quot ] bi
    define
] each

;FUNCTOR

SYNTAX: RENAMING: scan scan-object scan-object scan-object define-renaming ;