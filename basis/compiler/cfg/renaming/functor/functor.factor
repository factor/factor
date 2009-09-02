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

insn-classes get [
    [ \ rename-insn-defs create-method-in ]
    [ insn-def-slot dup [ name>> 1array ] when DEF-QUOT slot-change-quot ] bi
    define
] each

GENERIC: rename-insn-uses ( insn -- )

insn-classes get { ##phi } diff [
    [ \ rename-insn-uses create-method-in ]
    [ insn-use-slots [ name>> ] map USE-QUOT slot-change-quot ] bi
    define
] each

M: ##phi rename-insn-uses
    [ USE-QUOT assoc-map ] change-inputs drop ;

GENERIC: rename-insn-temps ( insn -- )

insn-classes get [
    [ \ rename-insn-temps create-method-in ]
    [ insn-temp-slots [ name>> ] map TEMP-QUOT slot-change-quot ] bi
    define
] each

;FUNCTOR

SYNTAX: RENAMING: scan scan-object scan-object scan-object define-renaming ;