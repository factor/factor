! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes classes.algebra classes.parser
classes.tuple combinators combinators.short-circuit fry
generic.parser kernel layouts math namespaces quotations
sequences slots splitting words make
cpu.architecture
compiler.cfg.instructions
compiler.cfg.instructions.syntax
compiler.cfg.value-numbering.graph ;
FROM: sequences.private => set-array-nth ;
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
            dup iota [
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
[ pure-insn class<= ] filter
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

! Expressions whose values are inputs to the basic block.
TUPLE: input-expr n ;

: next-input-expr ( -- expr )
    input-expr-counter counter input-expr boa ;

M: insn >expr drop next-input-expr ;

M: ##copy >expr "Fail" throw ;

M: ##load-integer >expr val>> <integer-expr> ;

M: ##load-reference >expr obj>> <reference-expr> ;

GENERIC: insn>integer ( insn -- n )

M: ##load-integer insn>integer val>> ;

: vreg>integer ( vreg -- n ) vreg>insn insn>integer ; inline

: vreg-immediate-arithmetic? ( vreg -- ? )
    vreg>insn {
        [ ##load-integer? ]
        [ val>> immediate-arithmetic? ]
    } 1&& ;

: vreg-immediate-bitwise? ( vreg -- ? )
    vreg>insn {
        [ ##load-integer? ]
        [ val>> immediate-bitwise? ]
    } 1&& ;

GENERIC: insn>comparand ( expr -- n )

M: ##load-integer insn>comparand val>> tag-fixnum ;

M: ##load-reference insn>comparand obj>> ;

: vreg>comparand ( vreg -- n ) vreg>insn insn>comparand ; inline

: vreg-immediate-comparand? ( vreg -- ? )
    vreg>insn {
        { [ dup ##load-integer? ] [ val>> tag-fixnum immediate-comparand? ] }
        { [ dup ##load-reference? ] [ obj>> immediate-comparand? ] }
        [ drop f ]
    } cond ;
