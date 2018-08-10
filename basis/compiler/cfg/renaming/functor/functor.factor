! Copyright (C) 2009, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors2 kernel sequences slots strings ;
IN: compiler.cfg.renaming.functor

! Like compiler.cfg.def-use, but for changing operands

: slot-change-quot ( slots quot -- quot' )
    '[ [ _ ] dip changer-word [ ] 2sequence ] map [ ] join
    [ drop ] append ;

INLINE-FUNCTOR: renaming ( name: name def-quot: string use-quot: string temp-quot: string -- ) [[
    GENERIC: ${name}-insn-defs ( insn -- )
    GENERIC: ${name}-insn-uses ( insn -- )
    GENERIC: ${name}-insn-temps ( insn -- )

    M: insn ${name}-insn-defs drop ;
    M: insn ${name}-insn-uses drop ;
    M: insn ${name}-insn-temps drop ;

    ! Instructions with unusual operands

    ! Special ${name}-insn-defs methods
    M: parallel-copy## ${name}-insn-defs
        [ [ first2 ${def-quot} dip 2array ] map ] change-values drop ;

    M: phi## ${name}-insn-defs ${def-quot} change-dst drop ;

    M: alien-call-insn ${name}-insn-defs
        [ [ first3 ${def-quot} 2dip 3array ] map ] change-reg-outputs
        drop ;

    M: callback-inputs## ${name}-insn-defs
        [ [ first3 ${def-quot} 2dip 3array ] map ] change-reg-outputs
        [ [ first3 ${def-quot} 2dip 3array ] map ] change-stack-outputs
        drop ;

    ! Special ${name}-insn-uses methods
    M: parallel-copy## ${name}-insn-uses
        [ [ first2 ${use-quot} call 2array ] map ] change-values drop ;

    M: phi## ${name}-insn-uses
        [ ${use-quot} assoc-map ] change-inputs drop ;

    M: alien-call-insn ${name}-insn-uses
        [ [ first3 ${use-quot} 2dip 3array ] map ] change-reg-inputs
        [ [ first3 ${use-quot} 2dip 3array ] map ] change-stack-inputs
        drop ;

    M: alien-indirect## ${name}-insn-uses
        ${use-quot} change-src call-next-method ;

    M: callback-outputs## ${name}-insn-uses
        [ [ first3 ${use-quot} 2dip 3array ] map ] change-reg-inputs
        drop ;

    <<
    ! Generate methods for everything else
    insn-classes get special-vreg-insns diff [ insn-def-slots empty? ] reject [
        [ \ ${name}-insn-defs create-method-in ]
        [ insn-def-slots [ name>> ] map ${def-quot} slot-change-quot ] bi
        define
    ] each

    insn-classes get special-vreg-insns diff [ insn-use-slots empty? ] reject [
        [ \ ${name}-insn-uses create-method-in ]
        [ insn-use-slots [ name>> ] map ${use-quot} slot-change-quot ] bi
        define
    ] each

    insn-classes get [ insn-temp-slots empty? ] reject [
        [ \ ${name}-insn-temps create-method-in ]
        [ insn-temp-slots [ name>> ] map ${temp-quot} slot-change-quot ] bi
        define
    ] each
    >>

]]
