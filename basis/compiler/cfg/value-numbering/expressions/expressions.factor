! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes.algebra combinators
compiler.cfg.instructions compiler.cfg.instructions.syntax
compiler.cfg.value-numbering.graph generic.parser kernel make
math namespaces quotations sequences sequences.private sets
slots words ;
IN: compiler.cfg.value-numbering.expressions

<<

GENERIC: >expr ( insn -- expr )

: input-values ( slot-specs -- slot-specs' )
    [ type>> { use literal } member-eq? ] filter ;

: slot->expr-quot ( slot-spec -- quot )
    [ name>> reader-word 1quotation ]
    [
        type>> {
            { use [ [ vreg>vn ] ] }
            { literal [ [ ] ] }
        } case
    ] bi append ;

: narray-quot ( length -- quot )
    [
        [ , [ f <array> ] % ]
        [
            dup <iota> [
                - 1 - , [ swap [ set-array-nth ] keep ] %
            ] with each
        ] bi
    ] [ ] make ;

: >expr-quot ( insn slot-specs -- quot )
    [
        [ literalize , \ swap , ]
        [
            [ [ slot->expr-quot ] map cleave>quot % ]
            [ length 1 + narray-quot % ]
            bi
        ] bi*
    ] [ ] make ;

: define->expr-method ( insn slot-specs -- )
    [ drop \ >expr create-method-in ] [ >expr-quot ] 2bi define ;

insn-classes get
[ foldable-insn class<= ] filter
{ ##copy ##load-integer ##load-reference } diff
[
    dup "insn-slots" word-prop input-values
    define->expr-method
] each

>>

TUPLE: integer-expr value ;

C: <integer-expr> integer-expr

TUPLE: reference-expr value ;

C: <reference-expr> reference-expr

M: reference-expr equal?
    over reference-expr? [
        [ value>> ] bi@
        2dup [ float? ] both?
        [ fp-bitwise= ] [ eq? ] if
    ] [ 2drop f ] if ;

M: reference-expr hashcode*
    nip value>> dup float? [ double>bits ] [ identity-hashcode ] if ;

M: insn >expr drop input-expr-counter counter neg ;

M: ##copy >expr "Fail" throw ;

M: ##load-integer >expr val>> <integer-expr> ;

M: ##load-reference >expr obj>> <reference-expr> ;
