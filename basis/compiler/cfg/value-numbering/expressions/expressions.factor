! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes classes.algebra classes.parser
classes.tuple combinators combinators.short-circuit fry
generic.parser kernel math namespaces quotations sequences slots
splitting words compiler.cfg.instructions
compiler.cfg.instructions.syntax
compiler.cfg.value-numbering.graph ;
IN: compiler.cfg.value-numbering.expressions

TUPLE: constant-expr < expr value ;

C: <constant> constant-expr

M: constant-expr equal?
    over constant-expr? [
        [ value>> ] bi@
        2dup [ float? ] both? [ fp-bitwise= ] [
            { [ [ class ] bi@ = ] [ = ] } 2&&
        ] if
    ] [ 2drop f ] if ;

TUPLE: reference-expr < expr value ;

C: <reference> reference-expr

M: reference-expr equal?
    over reference-expr? [ [ value>> ] bi@ eq? ] [ 2drop f ] if ;

M: reference-expr hashcode*
    nip value>> identity-hashcode ;

: constant>vn ( constant -- vn ) <constant> expr>vn ; inline

GENERIC: >expr ( insn -- expr )

M: insn >expr drop next-input-expr ;

M: ##load-immediate >expr val>> <constant> ;

M: ##load-reference >expr obj>> <reference> ;

M: ##load-constant >expr obj>> <constant> ;

<<

: input-values ( slot-specs -- slot-specs' )
    [ type>> { use literal constant } member-eq? ] filter ;

: expr-class ( insn -- expr )
    name>> "##" ?head drop "-expr" append create-class-in ;

: define-expr-class ( insn expr slot-specs -- )
    [ nip expr ] dip [ name>> ] map define-tuple-class ;

: >expr-quot ( expr slot-specs -- quot )
     [
        [ name>> reader-word 1quotation ]
        [
            type>> {
                { use [ [ vreg>vn ] ] }
                { literal [ [ ] ] }
                { constant [ [ constant>vn ] ] }
            } case
        ] bi append
    ] map cleave>quot swap suffix \ boa suffix ;

: define->expr-method ( insn expr slot-specs -- )
    [ 2drop \ >expr create-method-in ] [ >expr-quot nip ] 3bi define ;

: handle-pure-insn ( insn -- )
    [ ] [ expr-class ] [ "insn-slots" word-prop input-values ] tri
    [ define-expr-class ] [ define->expr-method ] 3bi ;

insn-classes get [ pure-insn class<= ] filter [ handle-pure-insn ] each

>>
