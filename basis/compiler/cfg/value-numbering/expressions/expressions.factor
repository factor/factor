! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler.cfg.value-numbering.expressions

! Referentially-transparent expressions.

TUPLE: expr op ;

! op is always %peek
TUPLE: peek-expr < expr loc ;
TUPLE: unary-expr < expr in ;
TUPLE: load-literal-expr < expr obj ;

GENERIC: >expr ( insn -- expr )

M: ##peek >expr
    [ class ] [ loc>> ] bi peek-expr boa ;

M: ##load-literal >expr
    [ class ] [ obj>> ] bi load-literal-expr boa ;

M: ##unary >expr
    [ class ] [ src>> vreg>vn ] bi unary-expr boa ;
