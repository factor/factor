! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes kernel math namespaces combinators
combinators.short-circuit compiler.cfg.instructions
compiler.cfg.value-numbering.graph ;
IN: compiler.cfg.value-numbering.expressions

! Referentially-transparent expressions
TUPLE: unary-expr < expr in ;
TUPLE: binary-expr < expr in1 in2 ;
TUPLE: commutative-expr < binary-expr ;
TUPLE: compare-expr < binary-expr cc ;
TUPLE: constant-expr < expr value ;
TUPLE: reference-expr < expr value ;

: <constant> ( constant -- expr )
    f swap constant-expr boa ; inline

M: constant-expr equal?
    over constant-expr? [
        {
            [ [ value>> class ] bi@ = ]
            [ [ value>> ] bi@ = ]
        } 2&&
    ] [ 2drop f ] if ;

: <reference> ( constant -- expr )
    f swap reference-expr boa ; inline

M: reference-expr equal?
    over reference-expr? [
        [ value>> ] bi@ {
            { [ 2dup eq? ] [ 2drop t ] }
            { [ 2dup [ float? ] both? ] [ fp-bitwise= ] }
            [ 2drop f ]
        } cond
    ] [ 2drop f ] if ;

: constant>vn ( constant -- vn ) <constant> expr>vn ; inline

GENERIC: >expr ( insn -- expr )

M: ##load-immediate >expr val>> <constant> ;

M: ##load-reference >expr obj>> <reference> ;

M: ##unary >expr
    [ class ] [ src>> vreg>vn ] bi unary-expr boa ;

M: ##binary >expr
    [ class ] [ src1>> vreg>vn ] [ src2>> vreg>vn ] tri
    binary-expr boa ;

M: ##binary-imm >expr
    [ class ] [ src1>> vreg>vn ] [ src2>> constant>vn ] tri
    binary-expr boa ;

M: ##commutative >expr
    [ class ] [ src1>> vreg>vn ] [ src2>> vreg>vn ] tri
    commutative-expr boa ;

M: ##commutative-imm >expr
    [ class ] [ src1>> vreg>vn ] [ src2>> constant>vn ] tri
    commutative-expr boa ;

: compare>expr ( insn -- expr )
    {
        [ class ]
        [ src1>> vreg>vn ]
        [ src2>> vreg>vn ]
        [ cc>> ]
    } cleave compare-expr boa ; inline

M: ##compare >expr compare>expr ;

: compare-imm>expr ( insn -- expr )
    {
        [ class ]
        [ src1>> vreg>vn ]
        [ src2>> constant>vn ]
        [ cc>> ]
    } cleave compare-expr boa ; inline

M: ##compare-imm >expr compare-imm>expr ;

M: ##compare-float >expr compare>expr ;

M: ##flushable >expr drop next-input-expr ;

: init-expressions ( -- )
    0 input-expr-counter set ;
