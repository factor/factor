! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes kernel math namespaces sorting
compiler.vops compiler.cfg.vn.graph ;
IN: compiler.cfg.vn.expressions

! Referentially-transparent expressions
TUPLE: expr op ;
TUPLE: nullary-expr < expr ;
TUPLE: unary-expr < expr in ;
TUPLE: binary-expr < expr in1 in2 ;
TUPLE: commutative-expr < binary-expr ;
TUPLE: boolean-expr < unary-expr code ;
TUPLE: constant-expr < expr value ;
TUPLE: literal-expr < unary-expr object ;

! op is always %peek
TUPLE: peek-expr < expr loc ;

SYMBOL: input-expr-counter

: next-input-expr ( -- n )
    input-expr-counter [ dup 1 + ] change ;

! Expressions whose values are inputs to the basic block. We
! can eliminate a second computation having the same 'n' as
! the first one; we can also eliminate input-exprs whose
! result is not used.
TUPLE: input-expr < expr n ;

GENERIC: >expr ( insn -- expr )

M: %literal-table >expr
    class nullary-expr boa ;

M: constant-op >expr
    [ class ] [ value>> ] bi constant-expr boa ;

M: %literal >expr
    [ class ] [ in>> vreg>vn ] [ object>> ] tri literal-expr boa ;

M: unary-op >expr
    [ class ] [ in>> vreg>vn ] bi unary-expr boa ;

M: binary-op >expr
    [ class ] [ in1>> vreg>vn ] [ in2>> vreg>vn ] tri
    binary-expr boa ;

M: commutative-op >expr
    [ class ] [ in1>> vreg>vn ] [ in2>> vreg>vn ] tri
    sort-pair commutative-expr boa ;

M: boolean-op >expr
    [ class ] [ in>> vreg>vn ] [ code>> ] tri
    boolean-expr boa ;

M: %peek >expr
    [ class ] [ stack-loc ] bi peek-expr boa ;

M: flushable-op >expr
    class next-input-expr input-expr boa ;

: init-expressions ( -- )
    0 input-expr-counter set ;
