! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes classes.algebra classes.parser
classes.tuple combinators combinators.short-circuit fry
generic.parser kernel layouts math namespaces quotations
sequences slots splitting words
cpu.architecture
compiler.cfg.instructions
compiler.cfg.instructions.syntax
compiler.cfg.value-numbering.graph ;
IN: compiler.cfg.value-numbering.expressions

TUPLE: integer-expr < expr value ;

C: <integer-expr> integer-expr

: zero-expr? ( expr -- ? ) T{ integer-expr f 0 } = ; inline

TUPLE: reference-expr < expr value ;

C: <reference-expr> reference-expr

M: reference-expr equal?
    over reference-expr? [
        [ value>> ] bi@
        2dup [ float? ] both?
        [ fp-bitwise= ] [ eq? ] if
    ] [ 2drop f ] if ;

M: reference-expr hashcode*
    nip value>> dup float? [ double>bits ] [ identity-hashcode ] if ;

UNION: literal-expr integer-expr reference-expr ;

GENERIC: >expr ( insn -- expr )

M: insn >expr drop next-input-expr ;

M: ##copy >expr "Fail" throw ;

M: ##load-integer >expr val>> <integer-expr> ;

M: ##load-reference >expr obj>> <reference-expr> ;

GENERIC: expr>integer ( expr -- n )

M: integer-expr expr>integer value>> ;

: vn>integer ( vn -- n ) vn>expr expr>integer ;

: vreg>integer ( vreg -- n ) vreg>vn vn>integer ; inline

: vreg-immediate-arithmetic? ( vreg -- ? )
    vreg>expr {
        [ integer-expr? ]
        [ expr>integer immediate-arithmetic? ]
    } 1&& ;

: vreg-immediate-bitwise? ( vreg -- ? )
    vreg>expr {
        [ integer-expr? ]
        [ expr>integer immediate-bitwise? ]
    } 1&& ;

GENERIC: expr>comparand ( expr -- n )

M: integer-expr expr>comparand value>> tag-fixnum ;

M: reference-expr expr>comparand value>> ;

: vn>comparand ( vn -- n ) vn>expr expr>comparand ;

: vreg>comparand ( vreg -- n ) vreg>vn vn>comparand ; inline

: vreg-immediate-comparand? ( vreg -- ? )
    vreg>expr {
        { [ dup integer-expr? ] [ expr>integer tag-fixnum immediate-comparand? ] }
        { [ dup reference-expr? ] [ value>> immediate-comparand? ] }
        [ drop f ]
    } cond ;

<<

: input-values ( slot-specs -- slot-specs' )
    [ type>> { use literal } member-eq? ] filter ;

: expr-class ( insn -- expr )
    name>> "##" ?head drop "-expr" append create-class-in ;

: define-expr-class ( expr slot-specs -- )
    [ expr ] dip [ name>> ] map define-tuple-class ;

: >expr-quot ( expr slot-specs -- quot )
     [
        [ name>> reader-word 1quotation ]
        [
            type>> {
                { use [ [ vreg>vn ] ] }
                { literal [ [ ] ] }
            } case
        ] bi append
    ] map cleave>quot swap suffix \ boa suffix ;

: define->expr-method ( insn expr slot-specs -- )
    [ \ >expr create-method-in ] 2dip >expr-quot define ;

: handle-pure-insn ( insn -- )
    [ ] [ expr-class ] [ "insn-slots" word-prop input-values ] tri
    [ define-expr-class drop ] [ define->expr-method ] 3bi ;

insn-classes get [ pure-insn class<= ] filter [ handle-pure-insn ] each

>>
